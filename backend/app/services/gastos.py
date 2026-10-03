"""Servicios del módulo de gastos. Toda consulta filtra por user_id (aislamiento multiusuario)."""

import uuid
from dataclasses import dataclass
from datetime import UTC, date, datetime, timedelta
from decimal import Decimal
from typing import Any

from fastapi import HTTPException, status
from sqlalchemy import func, select
from sqlalchemy.orm import Session

from app.domain import calendar as cal
from app.domain.cycles import CycleSummary, Mov, summarize
from app.domain.expression import parse_expression
from app.domain.installments import schedule
from app.domain.money import ZERO, q2
from app.domain.recurring import occurrences
from app.models import (
    Account,
    AuditLog,
    Category,
    Installment,
    InstallmentPlan,
    InvTransaction,
    Movement,
    MovementLine,
    PayCycle,
    RecurringPriceChange,
    RecurringTemplate,
    UserSetting,
)
from app.services.categories_seed import category_index, guess_category_path, normalize

SETTINGS_KEY = "gastos"
DEFAULT_SETTINGS: dict[str, Any] = {
    "payday_day": 27,
    "usual_payroll": None,  # str decimal
    "main_account_id": None,
    "refugio_account_id": None,
    "emergency_target": None,  # str decimal
    "monthly_refugio": None,  # str decimal: aportación mensual sugerida a la refugio
    "forecast_months": 6,
}


def not_found(what: str = "Recurso") -> HTTPException:
    return HTTPException(status.HTTP_404_NOT_FOUND, f"{what} no encontrado")


def get_owned[T](db: Session, model: type[T], obj_id: uuid.UUID, user_id: uuid.UUID) -> T:
    obj = db.get(model, obj_id)
    if obj is None or getattr(obj, "user_id", None) != user_id:
        raise not_found(model.__name__)
    return obj


# --- Ajustes del módulo -------------------------------------------------------------------
def get_settings(db: Session, user_id: uuid.UUID) -> dict[str, Any]:
    row = db.scalar(
        select(UserSetting).where(UserSetting.user_id == user_id, UserSetting.key == SETTINGS_KEY)
    )
    return {**DEFAULT_SETTINGS, **(row.value if row else {})}


def save_settings(db: Session, user_id: uuid.UUID, values: dict[str, Any]) -> dict[str, Any]:
    row = db.scalar(
        select(UserSetting).where(UserSetting.user_id == user_id, UserSetting.key == SETTINGS_KEY)
    )
    merged = {**DEFAULT_SETTINGS, **(row.value if row else {}), **values}
    clean = {k: (str(v) if isinstance(v, Decimal | uuid.UUID) else v) for k, v in merged.items()}
    if row:
        row.value = clean
    else:
        db.add(UserSetting(user_id=user_id, key=SETTINGS_KEY, value=clean))
    db.flush()
    return clean


def main_account(db: Session, user_id: uuid.UUID) -> Account:
    s = get_settings(db, user_id)
    if s["main_account_id"]:
        acc = db.get(Account, uuid.UUID(s["main_account_id"]))
        if acc and acc.user_id == user_id:
            return acc
    acc = db.scalar(
        select(Account)
        .where(Account.user_id == user_id, Account.kind == "gastos", Account.archived.is_(False))
        .order_by(Account.sort)
        .limit(1)
    )
    if acc is None:
        raise HTTPException(status.HTTP_409_CONFLICT, "Configura primero tu cuenta de gastos")
    return acc


# --- Cuentas ------------------------------------------------------------------------------
def account_balance(db: Session, account: Account, include_planned: bool = False) -> Decimal:
    statuses = ("posted", "planned") if include_planned else ("posted",)
    total = db.scalar(
        select(func.coalesce(func.sum(Movement.amount), 0)).where(
            Movement.user_id == account.user_id,
            Movement.account_id == account.id,
            Movement.status.in_(statuses),
        )
    )
    return account.opening_balance + Decimal(total)


# --- Ciclos -------------------------------------------------------------------------------
def open_cycle(db: Session, user_id: uuid.UUID, account_id: uuid.UUID) -> PayCycle | None:
    return db.scalar(
        select(PayCycle).where(
            PayCycle.user_id == user_id,
            PayCycle.account_id == account_id,
            PayCycle.status == "open",
        )
    )


def cycle_movements(db: Session, cycle: PayCycle) -> list[Movement]:
    return list(
        db.scalars(
            select(Movement)
            .where(Movement.user_id == cycle.user_id, Movement.cycle_id == cycle.id)
            .order_by(Movement.status.desc(), Movement.sort, Movement.created_at)
        )
    )


def _category_flags(db: Session, user_id: uuid.UUID) -> dict[uuid.UUID, Category]:
    return {c.id: c for c in db.scalars(select(Category).where(Category.user_id == user_id))}


def cycle_summary(db: Session, cycle: PayCycle, today: date | None = None) -> CycleSummary:
    s = get_settings(db, cycle.user_id)
    cats = _category_flags(db, cycle.user_id)
    movs: list[Mov] = []
    for m in cycle_movements(db, cycle):
        if m.status == "cancelled" or m.id == cycle.payroll_movement_id:
            continue
        cat = cats.get(m.category_id) if m.category_id else None
        parent = cats.get(cat.parent_id) if cat and cat.parent_id else None
        movs.append(
            Mov(
                amount=m.amount,
                posted=m.status == "posted",
                kind=m.kind,
                fixed=bool((cat and cat.fixed) or (parent and parent.fixed)),
                installment=m.source == "installment",
                # Salida a una cuenta propia (refugio, inversión…) = ahorro del ciclo
                to_savings=m.kind == "transferencia" and m.amount < 0,
            )
        )
    key = cal.key_from_label(cycle.label)
    next_pay = cal.cycle_start(key.next(), int(s["payday_day"])) if key else None
    if cycle.status == "closed":
        today = None
    return summarize(
        cycle.carried_real, cycle.payroll_amount, movs, today or date.today(), next_pay
    )


def _attach_pending_to_cycle(db: Session, cycle: PayCycle, payday_day: int) -> int:
    """Previstos sin ciclo (cuotas futuras, etc.) cuya fecha cae antes del siguiente cobro."""
    key = cal.key_from_label(cycle.label)
    if key is None:
        return 0
    until = cal.cycle_start(key.next(), payday_day)
    rows = db.scalars(
        select(Movement).where(
            Movement.user_id == cycle.user_id,
            Movement.account_id == cycle.account_id,
            Movement.cycle_id.is_(None),
            Movement.status == "planned",
            Movement.due_date.is_not(None),
            Movement.due_date < until,
        )
    ).all()
    for m in rows:
        m.cycle_id = cycle.id
    return len(rows)


def generate_recurring(db: Session, cycle: PayCycle, payday_day: int) -> int:
    """Crea como 'previsto' cada recurrente que toca en el ciclo (idempotente por external_ref)."""
    key = cal.key_from_label(cycle.label)
    if key is None:
        return 0
    start = cal.cycle_start(key, payday_day)
    until = cal.cycle_start(key.next(), payday_day)
    n = 0
    for t in db.scalars(
        select(RecurringTemplate).where(
            RecurringTemplate.user_id == cycle.user_id,
            RecurringTemplate.account_id == cycle.account_id,
            RecurringTemplate.active.is_(True),
        )
    ):
        for d in occurrences(
            t.start_date, t.every_months, t.day_of_month, start, until, t.end_date
        ):
            ref = f"rec:{t.id}:{d.isoformat()}"
            dup = db.scalar(
                select(Movement.id).where(
                    Movement.user_id == cycle.user_id,
                    (Movement.external_ref == ref)
                    | ((Movement.source_ref == t.id) & (Movement.due_date == d)),
                )
            )
            if dup:
                continue
            db.add(
                Movement(
                    user_id=cycle.user_id, account_id=cycle.account_id, cycle_id=cycle.id,
                    due_date=d, kind=t.kind, status="planned", concept=t.concept,
                    amount=t.amount, category_id=t.category_id, source="recurring",
                    source_ref=t.id, external_ref=ref,
                )
            )  # fmt: skip
            n += 1
    db.flush()
    return n


def create_cycle(
    db: Session,
    user_id: uuid.UUID,
    account: Account,
    label: str,
    start_date: date,
    carried_real: Decimal,
    payroll_amount: Decimal,
    payroll_date: date | None = None,
    carried_expected: Decimal | None = None,
    external_ref: str | None = None,
    generate: bool = True,
) -> PayCycle:
    cycle = PayCycle(
        user_id=user_id, account_id=account.id, label=label, start_date=start_date,
        payroll_amount=payroll_amount, carried_real=carried_real,
        carried_expected=carried_expected,
        discrepancy=(carried_real - carried_expected) if carried_expected is not None else None,
        status="open", external_ref=external_ref,
    )  # fmt: skip
    db.add(cycle)
    db.flush()
    if payroll_amount != 0:
        cats = category_index(db, user_id)
        pm = Movement(
            user_id=user_id, account_id=account.id, cycle_id=cycle.id,
            date=payroll_date or start_date, kind="nomina", status="posted", concept="Nómina",
            amount=payroll_amount, category_id=cats.get("Ingresos/Nómina"), source="manual",
            external_ref=f"{external_ref}:nomina" if external_ref else None,
        )  # fmt: skip
        db.add(pm)
        db.flush()
        cycle.payroll_movement_id = pm.id
    if generate:
        payday_day = int(get_settings(db, user_id)["payday_day"])
        _attach_pending_to_cycle(db, cycle, payday_day)
        generate_recurring(db, cycle, payday_day)
    return cycle


@dataclass
class PaydayResult:
    closed: PayCycle
    opened: PayCycle
    discrepancy: Decimal
    carried_over: int
    cancelled: int


def payday(
    db: Session,
    user_id: uuid.UUID,
    payroll_amount: Decimal,
    payroll_date: date,
    real_balance_before: Decimal,
    pending_actions: dict[uuid.UUID, str],
) -> PaydayResult:
    """Botón "He cobrado": cierra el ciclo abierto arrastrando el saldo REAL (el descuadre se
    registra y se apunta como ajuste) y abre el nuevo con saldo inicial = real + nómina."""
    account = main_account(db, user_id)
    cur = open_cycle(db, user_id, account.id)
    if cur is None:
        raise HTTPException(status.HTTP_409_CONFLICT, "No hay ningún ciclo abierto")
    settings = get_settings(db, user_id)
    payday_day = int(settings["payday_day"])
    prev_end = cur.end_date

    # 1) Previstos no cargados: pasan al nuevo ciclo o se cancelan (por defecto, pasan).
    pending = [m for m in cycle_movements(db, cur) if m.status == "planned"]
    to_move: list[Movement] = []
    cancelled = 0
    for m in pending:
        action = pending_actions.get(m.id, "carry")
        if action == "cancel":
            m.status = "cancelled"
            cancelled += 1
        else:
            to_move.append(m)

    # 2) Descuadre: saldo calculado (solo cargados) vs. el real que dice el banco.
    expected = account_balance(db, account)
    diff = real_balance_before - expected
    adjustment = None
    if diff != 0:
        adjustment = Movement(
            user_id=user_id,
            account_id=account.id,
            cycle_id=cur.id,
            date=payroll_date,
            kind="ajuste",
            status="posted",
            concept="Ajuste de cuadre",
            amount=diff,
            source="manual",
            notes=f"Calculado {expected} · real {real_balance_before}",
        )
        db.add(adjustment)
    cur.status = "closed"
    cur.end_date = payroll_date
    db.flush()

    # 3) Nuevo ciclo
    key = cal.key_from_label(cur.label)
    new_key = key.next() if key else cal.cycle_for_date(payroll_date, payday_day)
    opened = create_cycle(
        db, user_id, account, new_key.label, payroll_date, real_balance_before, payroll_amount,
        payroll_date=payroll_date, carried_expected=expected, generate=False,
    )  # fmt: skip
    for m in to_move:
        m.cycle_id = opened.id
    db.flush()
    # Lo que entra en el ciclo nuevo se apunta por separado para poder deshacer el cobro
    base = {m.id for m in cycle_movements(db, opened)}
    _attach_pending_to_cycle(db, opened, payday_day)
    attached = {m.id for m in cycle_movements(db, opened)} - base
    generate_recurring(db, opened, payday_day)
    generated = {m.id for m in cycle_movements(db, opened)} - base - attached
    save_settings(db, user_id, {"usual_payroll": str(payroll_amount)})
    undo = {
        "end_date": prev_end.isoformat() if prev_end else None,
        "usual_payroll": settings.get("usual_payroll"),
        "adjustment": str(adjustment.id) if adjustment else None,
        "moved": [str(m.id) for m in to_move],
        "cancelled": [str(m.id) for m in pending if m.status == "cancelled"],
        "attached": [str(i) for i in attached],
        "generated": [str(i) for i in generated],
    }
    db.add(
        AuditLog(
            user_id=user_id, entity="pay_cycle", entity_id=str(cur.id), action="payday",
            after={"opened": str(opened.id), "discrepancy": str(diff), "undo": undo},
        )
    )  # fmt: skip
    db.flush()
    return PaydayResult(cur, opened, diff, len(to_move), cancelled)


def last_payday(db: Session, user_id: uuid.UUID) -> AuditLog | None:
    return db.scalar(
        select(AuditLog)
        .where(
            AuditLog.user_id == user_id,
            AuditLog.entity == "pay_cycle",
            AuditLog.action == "payday",
        )
        .order_by(AuditLog.at.desc())
        .limit(1)
    )


def payday_undo_blocker(db: Session, user_id: uuid.UUID) -> str | None:
    """Por qué no se puede deshacer el último "He cobrado" (None si se puede)."""
    account = main_account(db, user_id)
    opened = open_cycle(db, user_id, account.id)
    log = last_payday(db, user_id)
    if log is None or opened is None or (log.after or {}).get("opened") != str(opened.id):
        return "Solo se puede deshacer el último «He cobrado» mientras su ciclo siga abierto"
    if not (log.after or {}).get("undo"):
        return "Este cobro se hizo antes de que existiera «Deshacer» y no se puede deshacer solo"
    closed = db.get(PayCycle, uuid.UUID(log.entity_id)) if log.entity_id else None
    if closed is None or closed.user_id != user_id or closed.status != "closed":
        return "El ciclo anterior ya no está cerrado"
    return None


def undo_payday(db: Session, user_id: uuid.UUID) -> PayCycle:
    """Deshace el último "He cobrado" mientras su ciclo siga abierto: reabre el ciclo anterior y
    borra el nuevo. Lo que apuntaste en el ciclo nuevo no se pierde: vuelve al ciclo reabierto."""
    if reason := payday_undo_blocker(db, user_id):
        raise HTTPException(status.HTTP_409_CONFLICT, reason)
    account = main_account(db, user_id)
    opened = open_cycle(db, user_id, account.id)
    log = last_payday(db, user_id)
    assert opened is not None and log is not None and log.entity_id
    snap = log.after["undo"]
    closed = db.get(PayCycle, uuid.UUID(log.entity_id))
    assert closed is not None
    generated = set(snap["generated"])
    attached = set(snap["attached"])
    linked = set(
        db.scalars(select(InvTransaction.movement_id).where(InvTransaction.user_id == user_id))
    )
    for m in cycle_movements(db, opened):
        mid = str(m.id)
        if m.id == opened.payroll_movement_id:
            db.delete(m)
        elif m.status == "planned" and mid in generated and m.id not in linked:
            db.delete(m)  # el siguiente cobro lo vuelve a generar
        elif m.status == "planned" and mid in attached:
            m.cycle_id = None  # cuotas futuras: vuelven a esperar su ciclo
        else:
            m.cycle_id = closed.id  # previstos que pasaron y lo que apuntaste después
    for mid in snap["cancelled"]:
        m = db.get(Movement, uuid.UUID(mid))
        if m is not None and m.user_id == user_id and m.status == "cancelled":
            m.status = "planned"
    if snap["adjustment"]:
        adj = db.get(Movement, uuid.UUID(snap["adjustment"]))
        if adj is not None and adj.user_id == user_id:
            db.delete(adj)
    db.delete(opened)
    db.flush()
    closed.status = "open"
    closed.end_date = date.fromisoformat(snap["end_date"]) if snap["end_date"] else None
    row = db.scalar(
        select(UserSetting).where(UserSetting.user_id == user_id, UserSetting.key == SETTINGS_KEY)
    )
    if row is not None:
        value = {k: v for k, v in row.value.items() if k != "usual_payroll"}
        if snap["usual_payroll"] is not None:
            value["usual_payroll"] = snap["usual_payroll"]
        row.value = value
    log.after = {**log.after, "undone": True}
    db.add(
        AuditLog(
            user_id=user_id,
            entity="pay_cycle",
            entity_id=str(closed.id),
            action="undo_payday",
            before={"opened": str(opened.id)},
        )
    )
    db.flush()
    return closed


# --- Movimientos --------------------------------------------------------------------------
def apply_amount(m: Movement, amount: Decimal | None, expression: str | None) -> None:
    """Fija el importe: o un número, o una expresión "=-60+20+12" que genera submovimientos."""
    if expression:
        terms = parse_expression(expression)
        if terms is None:
            raise HTTPException(
                status.HTTP_422_UNPROCESSABLE_ENTITY,
                "La expresión solo admite sumas y restas de números (p. ej. =-60+20+12)",
            )
        m.expression = expression if expression.startswith("=") else f"={expression}"
        m.lines = [MovementLine(seq=i + 1, amount=q2(t)) for i, t in enumerate(terms)]
        m.amount = q2(sum(terms, ZERO))
    elif amount is not None:
        m.amount = q2(amount)
        m.expression = None
        m.lines = []


def check_recurring_price(db: Session, m: Movement, old_amount: Decimal) -> None:
    """Si un cargo REAL (cargado) de un recurrente cambia de importe, se avisa y se actualiza la
    plantilla (para que los ciclos siguientes usen el precio nuevo). Editar un previsto es un
    ajuste solo de ese mes."""
    if m.source != "recurring" or not m.source_ref or m.amount == old_amount:
        return
    if m.status != "posted":
        return
        return
    t = db.get(RecurringTemplate, m.source_ref)
    if t is None or t.user_id != m.user_id or t.amount == m.amount:
        return
    rel = abs((m.amount - t.amount) / t.amount) if t.amount else Decimal(1)
    if not t.amount_is_estimate or rel > Decimal("0.10"):
        db.add(
            RecurringPriceChange(
                template_id=t.id, detected_at=datetime.now(UTC),
                old_amount=t.amount, new_amount=m.amount,
            )
        )  # fmt: skip
    t.amount = m.amount


def suggest(db: Session, user_id: uuid.UUID, q: str, limit: int = 8) -> list[dict[str, Any]]:
    """Autocompletado de concepto: conceptos usados antes (más recientes primero) con su última
    categoría e importe; si no hay historial, la categoría que sugieren las palabras clave."""
    out: list[dict[str, Any]] = []
    if q.strip():
        rows = db.execute(
            select(Movement.concept, Movement.category_id, Movement.amount, Movement.updated_at)
            .where(
                Movement.user_id == user_id,
                Movement.concept.ilike(f"%{q.strip()}%"),
                Movement.kind.in_(("gasto", "ingreso", "reembolso")),
                Movement.status != "cancelled",
            )
            .order_by(Movement.updated_at.desc())
            .limit(200)
        ).all()
        seen: set[str] = set()
        for concept, cat_id, amount, _ in rows:
            k = normalize(concept)
            if k in seen:
                continue
            seen.add(k)
            out.append({"concept": concept.strip(), "category_id": cat_id, "amount": amount})
            if len(out) >= limit:
                break
    if not out and q.strip():
        path = guess_category_path(q)
        if path:
            cid = category_index(db, user_id).get(path)
            out.append({"concept": q.strip(), "category_id": cid, "amount": None})
    return out


# --- Recurrentes --------------------------------------------------------------------------
PriceChangeRow = tuple[RecurringPriceChange, RecurringTemplate]


def pending_price_changes(db: Session, user_id: uuid.UUID) -> list[PriceChangeRow]:
    return list(
        db.execute(
            select(RecurringPriceChange, RecurringTemplate)
            .join(RecurringTemplate, RecurringTemplate.id == RecurringPriceChange.template_id)
            .where(
                RecurringTemplate.user_id == user_id, RecurringPriceChange.acknowledged.is_(False)
            )
        ).tuples()
    )


# --- Fraccionadas -------------------------------------------------------------------------
def create_installment_plan(
    db: Session,
    user_id: uuid.UUID,
    account: Account,
    description: str,
    total: Decimal,
    n: int,
    first_due: date,
    every_months: int = 1,
    provider: str = "otro",
    merchant: str = "",
    fee: Decimal = ZERO,
    category_id: uuid.UUID | None = None,
    custom: list[Decimal] | None = None,
    paid_seqs: set[int] | None = None,
    external_ref: str | None = None,
) -> InstallmentPlan:
    """Crea el plan y sus cuotas como movimientos 'previstos' (las ya pagadas, si se indican,
    quedan marcadas como pagadas sin movimiento: su cargo ya está en el histórico)."""
    try:
        cuotas = schedule(q2(total), n, first_due, every_months, custom)
    except ValueError as e:
        raise HTTPException(status.HTTP_422_UNPROCESSABLE_ENTITY, str(e)) from None
    plan = InstallmentPlan(
        user_id=user_id, account_id=account.id, description=description, merchant=merchant,
        provider=provider, total=q2(total), n=n, every_months=every_months, first_due=first_due,
        fee=fee, category_id=category_id, external_ref=external_ref,
    )  # fmt: skip
    db.add(plan)
    db.flush()
    paid_seqs = paid_seqs or set()
    payday_day = int(get_settings(db, user_id)["payday_day"])
    for c in cuotas:
        inst = Installment(plan_id=plan.id, seq=c.seq, due_date=c.due, amount=c.amount)
        if c.seq in paid_seqs:
            inst.status = "pagada"
        else:
            mv = Movement(
                user_id=user_id, account_id=account.id,
                cycle_id=_cycle_id_for_date(db, user_id, account.id, c.due, payday_day),
                due_date=c.due, kind="gasto", status="planned",
                concept=f"{description} ({c.seq}/{n})", amount=-c.amount,
                category_id=category_id, source="installment", source_ref=plan.id,
            )  # fmt: skip
            db.add(mv)
            db.flush()
            inst.movement_id = mv.id
        db.add(inst)
    db.flush()
    refresh_plan_status(plan)
    return plan


def _cycle_id_for_date(
    db: Session, user_id: uuid.UUID, account_id: uuid.UUID, d: date, payday_day: int
) -> uuid.UUID | None:
    label = cal.cycle_for_date(d, payday_day).label
    cyc = db.scalar(
        select(PayCycle).where(
            PayCycle.user_id == user_id, PayCycle.account_id == account_id, PayCycle.label == label
        )
    )
    if cyc and cyc.status == "open":
        return cyc.id
    # Una cuota de una fecha ya pasada se asigna al ciclo abierto (no a uno cerrado).
    cur = open_cycle(db, user_id, account_id)
    if cur and cyc and cyc.status == "closed":
        return cur.id
    return None


def refresh_plan_status(plan: InstallmentPlan) -> None:
    if plan.status == "cancelada":
        return
    pending = [i for i in plan.installments if i.status == "pendiente"]
    plan.status = "activa" if pending else "liquidada"


def sync_installment_from_movement(db: Session, m: Movement) -> None:
    """Al marcar como cargada (o desmarcar) la cuota, se actualiza su estado."""
    if m.source != "installment" or not m.source_ref:
        return
    inst = db.scalar(select(Installment).where(Installment.movement_id == m.id))
    if inst is None:
        return
    if m.status == "posted" and inst.status == "pendiente":
        inst.status = "pagada"
    elif m.status == "planned" and inst.status == "pagada":
        inst.status = "pendiente"
    elif m.status == "cancelled":
        inst.status = "cancelada"
    plan = db.get(InstallmentPlan, m.source_ref)
    if plan:
        refresh_plan_status(plan)


def advance_plan(
    db: Session, user_id: uuid.UUID, plan: InstallmentPlan, merge: bool
) -> tuple[int, Decimal]:
    """Adelantar pago: las cuotas pendientes pasan al ciclo actual. Con `merge`, se agrupan en un
    único cargo previsto con la suma (las cuotas quedan 'adelantadas')."""
    cur = open_cycle(db, user_id, plan.account_id)
    if cur is None:
        raise HTTPException(status.HTTP_409_CONFLICT, "No hay ningún ciclo abierto")
    pend = [i for i in plan.installments if i.status == "pendiente"]
    if not pend:
        raise HTTPException(status.HTTP_409_CONFLICT, "No quedan cuotas pendientes")
    total = sum((i.amount for i in pend), ZERO)
    if merge:
        mv = Movement(
            user_id=user_id, account_id=plan.account_id, cycle_id=cur.id, due_date=date.today(),
            kind="gasto", status="planned",
            concept=f"{plan.description} (adelanto {len(pend)} cuotas)", amount=-total,
            category_id=plan.category_id, source="installment", source_ref=plan.id,
        )  # fmt: skip
        db.add(mv)
        db.flush()
        for i in pend:
            if i.movement_id:
                old = db.get(Movement, i.movement_id)
                if old:
                    old.status = "cancelled"
            i.status = "adelantada"
            i.movement_id = mv.id
    else:
        for i in pend:
            if i.movement_id:
                mv2 = db.get(Movement, i.movement_id)
                if mv2:
                    mv2.cycle_id = cur.id
    refresh_plan_status(plan)
    db.flush()
    return len(pend), total


def cancel_plan(db: Session, plan: InstallmentPlan) -> int:
    n = 0
    for i in plan.installments:
        if i.status == "pendiente":
            i.status = "cancelada"
            if i.movement_id:
                mv = db.get(Movement, i.movement_id)
                if mv and mv.status == "planned":
                    mv.status = "cancelled"
            n += 1
    plan.status = "cancelada"
    db.flush()
    return n


def live_installment_debt(db: Session, user_id: uuid.UUID) -> Decimal:
    total = db.scalar(
        select(func.coalesce(func.sum(Installment.amount), 0))
        .join(InstallmentPlan, InstallmentPlan.id == Installment.plan_id)
        .where(InstallmentPlan.user_id == user_id, Installment.status == "pendiente")
    )
    return Decimal(total)


# --- Meses vista --------------------------------------------------------------------------
@dataclass
class MonthItem:
    """Algo previsto en un ciclo futuro: un movimiento real o la proyección de un recurrente."""

    kind: str  # movimiento | recurrente
    on: date
    concept: str
    amount: Decimal
    category_id: uuid.UUID | None
    source: str
    movement: Movement | None = None
    template_id: uuid.UUID | None = None


@dataclass
class ForecastMonth:
    label: str
    ym: str
    start: date
    end: date
    payroll: Decimal
    recurring: Decimal
    installments: Decimal
    other: Decimal
    free: Decimal  # nómina + compromisos de ese ciclo
    cumulative: Decimal  # arrastrando el previsto del ciclo actual
    items: list[MonthItem]


def ym_key(ym: str) -> cal.CycleKey:
    try:
        y, m = (int(x) for x in ym.split("-"))
        if not 1 <= m <= 12 or y < 2000:
            raise ValueError
    except ValueError:
        raise HTTPException(
            status.HTTP_422_UNPROCESSABLE_ENTITY, "Mes no válido (AAAA-MM)"
        ) from None
    return cal.CycleKey(y, m)


def key_ym(key: cal.CycleKey) -> str:
    return f"{key.year:04d}-{key.month:02d}"


def current_key(db: Session, user_id: uuid.UUID) -> cal.CycleKey:
    """Ciclo actual: el abierto o, si no hay, el que toca por fecha."""
    account = main_account(db, user_id)
    cur = open_cycle(db, user_id, account.id)
    key = cal.key_from_label(cur.label) if cur else None
    return key or cal.cycle_for_date(date.today(), int(get_settings(db, user_id)["payday_day"]))


def months_between(a: cal.CycleKey, b: cal.CycleKey) -> int:
    return (b.year - a.year) * 12 + b.month - a.month


def place_planned(db: Session, m: Movement) -> None:
    """Un previsto cuya fecha cae después del ciclo abierto se queda sin ciclo (se asignará al
    abrirse el suyo); si cae dentro, va al ciclo abierto. Nunca saca nada de un ciclo cerrado."""
    if m.status != "planned" or m.due_date is None:
        return
    cur = open_cycle(db, m.user_id, m.account_id)
    key = cal.key_from_label(cur.label) if cur else None
    if cur is None or key is None:
        return
    if m.cycle_id is not None and m.cycle_id != cur.id:
        return  # ciclo cerrado: no se toca
    until = cal.cycle_start(key.next(), int(get_settings(db, m.user_id)["payday_day"]))
    m.cycle_id = None if m.due_date >= until else cur.id


def put_in_month(db: Session, m: Movement, ym: str, wanted: date | None) -> None:
    """Coloca un movimiento en el ciclo `ym`: el actual o uno futuro (como previsto). Los ciclos
    cerrados no admiten movimientos nuevos: su saldo final ya es el real del banco."""
    payday_day = int(get_settings(db, m.user_id)["payday_day"])
    key, cur_key = ym_key(ym), current_key(db, m.user_id)
    if key < cur_key:
        raise HTTPException(
            status.HTTP_422_UNPROCESSABLE_ENTITY,
            "Ese ciclo ya está cerrado: su saldo final es el real del banco",
        )
    if months_between(cur_key, key) > 36:
        raise HTTPException(status.HTTP_422_UNPROCESSABLE_ENTITY, "Como mucho, 36 meses vista")
    start, until = cal.cycle_start(key, payday_day), cal.cycle_start(key.next(), payday_day)
    if key == cur_key:
        cur = open_cycle(db, m.user_id, m.account_id)
        m.cycle_id = cur.id if cur else None
        if m.due_date is not None and m.due_date >= until:
            m.due_date = wanted if wanted and wanted < until else None
        return
    m.status = "planned"
    m.date = None
    m.due_date = wanted if wanted and start <= wanted < until else start
    m.cycle_id = None


def forecast(db: Session, user_id: uuid.UUID, months: int) -> list[ForecastMonth]:
    s = get_settings(db, user_id)
    payday_day = int(s["payday_day"])
    account = main_account(db, user_id)
    cur = open_cycle(db, user_id, account.id)
    today = date.today()
    key = current_key(db, user_id)
    payroll = Decimal(s["usual_payroll"]) if s["usual_payroll"] else (
        cur.payroll_amount if cur else ZERO
    )  # fmt: skip
    running = cycle_summary(db, cur, today).expected_end if cur else account_balance(db, account)

    templates = db.scalars(
        select(RecurringTemplate).where(
            RecurringTemplate.user_id == user_id,
            RecurringTemplate.account_id == account.id,
            RecurringTemplate.active.is_(True),
        )
    ).all()
    unassigned = db.scalars(
        select(Movement)
        .where(
            Movement.user_id == user_id,
            Movement.account_id == account.id,
            Movement.cycle_id.is_(None),
            Movement.status.in_(("planned", "cancelled")),
            Movement.due_date.is_not(None),
        )
        .order_by(Movement.due_date, Movement.created_at)
    ).all()
    planned = [m for m in unassigned if m.status == "planned"]
    # Ocurrencias de recurrentes ya concretadas (editadas, saltadas o movidas de mes)
    recs = [m for m in unassigned if m.source == "recurring"]
    taken_refs = {m.external_ref for m in recs if m.external_ref}
    taken_dates = {(m.source_ref, m.due_date) for m in recs}

    out: list[ForecastMonth] = []
    k = key
    for _ in range(months):
        k = k.next()
        start = cal.cycle_start(k, payday_day)
        until = cal.cycle_start(k.next(), payday_day)
        items: list[MonthItem] = []
        for t in templates:
            for d in occurrences(t.start_date, t.every_months, t.day_of_month, start, until,
                                 t.end_date):  # fmt: skip
                if f"rec:{t.id}:{d.isoformat()}" in taken_refs or (t.id, d) in taken_dates:
                    continue
                items.append(MonthItem("recurrente", d, t.concept, t.amount, t.category_id,
                                       "recurring", template_id=t.id))  # fmt: skip
        for m in planned:
            if m.due_date and start <= m.due_date < until:
                tid = m.source_ref if m.source == "recurring" else None
                item = MonthItem("movimiento", m.due_date, m.concept, m.amount, m.category_id,
                                 m.source, movement=m, template_id=tid)  # fmt: skip
                items.append(item)
        items.sort(key=lambda i: (i.on, i.concept))
        rec = sum((i.amount for i in items if i.source == "recurring"), ZERO)
        inst = sum((i.amount for i in items if i.source == "installment"), ZERO)
        other = sum((i.amount for i in items if i.source not in ("installment", "recurring")), ZERO)
        free = payroll + rec + inst + other
        running = running + free
        out.append(ForecastMonth(k.label, key_ym(k), start, until - timedelta(days=1), payroll,
                                 rec, inst, other, free, running, items))  # fmt: skip
    return out


def materialize_occurrence(db: Session, t: RecurringTemplate, on: date, skip: bool) -> Movement:
    """Concreta una ocurrencia futura de un recurrente para editarla o saltarla solo ese mes."""
    ref = f"rec:{t.id}:{on.isoformat()}"
    m = db.scalar(
        select(Movement).where(Movement.user_id == t.user_id, Movement.external_ref == ref)
    )
    if m is None:
        m = Movement(
            user_id=t.user_id, account_id=t.account_id, due_date=on, kind=t.kind,
            status="planned", concept=t.concept, amount=t.amount, category_id=t.category_id,
            source="recurring", source_ref=t.id, external_ref=ref,
        )  # fmt: skip
        db.add(m)
        place_planned(db, m)
    if skip:
        m.status = "cancelled"
    db.flush()
    return m


def end_recurring_after(db: Session, t: RecurringTemplate) -> int:
    """Al poner fecha de fin, quita los previstos de esa plantilla posteriores a ella."""
    if t.end_date is None:
        return 0
    rows = db.scalars(
        select(Movement).where(
            Movement.user_id == t.user_id,
            Movement.source_ref == t.id,
            Movement.source == "recurring",
            Movement.status.in_(("planned", "cancelled")),
            Movement.due_date > t.end_date,
        )
    ).all()
    for m in rows:
        db.delete(m)
    return len(rows)
