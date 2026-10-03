"""Servicios de la fase 2b: compartidos, deudas, seguimientos, reglas, presupuestos y
estadísticas. Toda consulta filtra por user_id."""

import uuid
from collections import defaultdict
from dataclasses import dataclass, field
from datetime import UTC, date, datetime
from decimal import Decimal

from fastapi import HTTPException, status
from sqlalchemy import func, or_, select
from sqlalchemy.orm import Session

from app.domain.money import ZERO
from app.models import (
    Budget,
    Category,
    CategoryRule,
    Debt,
    Movement,
    MovementShare,
    PayCycle,
    Person,
    Tracker,
)
from app.services import gastos as svc
from app.services.categories_seed import normalize

SPEND_KINDS = ("gasto", "reembolso")


# --- Personas y gastos compartidos --------------------------------------------------------
def get_or_create_person(db: Session, user_id: uuid.UUID, name: str) -> Person:
    name = name.strip()
    p = db.scalar(
        select(Person).where(Person.user_id == user_id, func.lower(Person.name) == name.lower())
    )
    if p is None:
        p = Person(user_id=user_id, name=name)
        db.add(p)
        db.flush()
    return p


def person_balances(db: Session, user_id: uuid.UUID) -> dict[uuid.UUID, tuple[Decimal, Decimal]]:
    """{person_id: (me_deben pendiente, debo pendiente)}"""
    out: dict[uuid.UUID, list[Decimal]] = defaultdict(lambda: [ZERO, ZERO])
    rows = db.execute(
        select(MovementShare.person_id, MovementShare.direction, func.sum(MovementShare.amount))
        .where(MovementShare.user_id == user_id, MovementShare.status == "pendiente")
        .group_by(MovementShare.person_id, MovementShare.direction)
    ).all()
    for pid, direction, total in rows:
        out[pid][0 if direction == "me_deben" else 1] += Decimal(total)
    return {k: (v[0], v[1]) for k, v in out.items()}


def set_shares(
    db: Session, user_id: uuid.UUID, movement: Movement, items: list[dict]
) -> list[MovementShare]:
    """Sustituye las partes PENDIENTES de un movimiento (las saldadas se conservan)."""
    for sh in db.scalars(
        select(MovementShare).where(
            MovementShare.movement_id == movement.id, MovementShare.status == "pendiente"
        )
    ):
        db.delete(sh)
    db.flush()
    created = []
    for it in items:
        if it.get("person_id"):
            person = svc.get_owned(db, Person, it["person_id"], user_id)
        else:
            person = get_or_create_person(db, user_id, it["person_name"])
        sh = MovementShare(
            user_id=user_id, movement_id=movement.id, person_id=person.id,
            amount=it["amount"], direction=it.get("direction", "me_deben"),
        )  # fmt: skip
        db.add(sh)
        created.append(sh)
    total = sum((s.amount for s in created), ZERO)
    if total > abs(movement.amount) and movement.amount != 0:
        raise HTTPException(
            status.HTTP_422_UNPROCESSABLE_ENTITY,
            f"Las partes ({total} €) superan el importe del movimiento ({abs(movement.amount)} €)",
        )
    db.flush()
    return created


def settle_share(
    db: Session,
    user_id: uuid.UUID,
    share: MovementShare,
    create_movement: bool,
    on_date: date | None = None,
    existing_movement_id: uuid.UUID | None = None,
) -> Movement | None:
    """Saldar una parte: crea el reembolso (Bizum que me devuelven / pago que hago) vinculado al
    gasto original, o vincula uno ya existente."""
    if share.status == "saldada":
        raise HTTPException(status.HTTP_409_CONFLICT, "Ya está saldada")
    original = db.get(Movement, share.movement_id)
    person = db.get(Person, share.person_id)
    mv: Movement | None = None
    if existing_movement_id:
        mv = svc.get_owned(db, Movement, existing_movement_id, user_id)
        mv.refund_of_id = share.movement_id
        if mv.kind in ("ingreso", "gasto"):
            mv.kind = "reembolso"
    elif create_movement and original is not None:
        cyc = svc.open_cycle(db, user_id, original.account_id)
        sign = 1 if share.direction == "me_deben" else -1
        mv = Movement(
            user_id=user_id, account_id=original.account_id, cycle_id=cyc.id if cyc else None,
            date=on_date or date.today(), kind="reembolso", status="posted",
            concept=f"{'Devolución de' if sign > 0 else 'Pago a'} {person.name if person else '—'}"
                    f" · {original.concept}",
            amount=share.amount * sign, category_id=original.category_id, source="manual",
            refund_of_id=original.id,
        )  # fmt: skip
        db.add(mv)
        db.flush()
    share.status = "saldada"
    share.settled_at = datetime.now(UTC)
    share.settled_by_movement_id = mv.id if mv else None
    db.flush()
    return mv


# --- Deudas -------------------------------------------------------------------------------
def debt_remaining(db: Session, debt: Debt) -> tuple[Decimal, Decimal]:
    """(pendiente, movido) — movido = Σ importes vinculados."""
    moved = Decimal(
        db.scalar(
            select(func.coalesce(func.sum(Movement.amount), 0)).where(
                Movement.user_id == debt.user_id,
                Movement.debt_id == debt.id,
                Movement.status == "posted",
            )
        )
    )
    rem = debt.opening_balance + moved if debt.direction == "debo" else debt.opening_balance - moved
    return rem, moved


def refresh_debt_status(db: Session, debt: Debt) -> None:
    rem, _ = debt_remaining(db, debt)
    debt.status = "saldada" if rem <= 0 else "viva"


# --- Seguimientos -------------------------------------------------------------------------
def _effective_date():
    return func.coalesce(Movement.date, PayCycle.start_date, func.date(Movement.created_at))


def tracker_movements_query(db: Session, t: Tracker):
    cats = set(t.category_ids or [])
    if cats:  # incluir subcategorías
        subs = select(Category.id).where(
            Category.user_id == t.user_id, Category.parent_id.in_(cats)
        )
        cats |= set(db.scalars(subs))
    conds = []
    if cats:
        conds.append(Movement.category_id.in_(cats))
    for kw in t.keywords or []:
        conds.append(Movement.concept.ilike(f"%{kw}%"))
    if not conds:
        return None
    return (
        select(Movement, PayCycle.label)
        .outerjoin(PayCycle, PayCycle.id == Movement.cycle_id)
        .where(
            Movement.user_id == t.user_id,
            Movement.status == "posted",
            or_(*conds),
            _effective_date() >= t.opening_date,
        )
    )


@dataclass
class TrackerState:
    balance: Decimal
    by_cycle: list[tuple[str, Decimal]] = field(default_factory=list)
    count: int = 0


def tracker_state(db: Session, t: Tracker) -> TrackerState:
    q = tracker_movements_query(db, t)
    if q is None:
        return TrackerState(t.opening_balance)
    per: dict[str, Decimal] = defaultdict(lambda: ZERO)
    order: list[str] = []
    total = ZERO
    n = 0
    for m, label in db.execute(q.order_by(_effective_date())).all():
        key = label or "Sin ciclo"
        if key not in per:
            order.append(key)
        per[key] += m.amount
        total += m.amount
        n += 1
    return TrackerState(t.opening_balance + total, [(k, per[k]) for k in order], n)


# --- Reglas de categorización ------------------------------------------------------------
def learn_rule(
    db: Session, user_id: uuid.UUID, concept: str, category_id: uuid.UUID | None
) -> None:
    """Aprende "concepto → categoría" de lo que el usuario elige o corrige."""
    if not category_id or not concept.strip():
        return
    pattern = normalize(concept)[:160]
    r = db.scalar(
        select(CategoryRule).where(CategoryRule.user_id == user_id, CategoryRule.pattern == pattern)
    )
    if r is None:
        db.add(CategoryRule(user_id=user_id, pattern=pattern, category_id=category_id))
    elif r.category_id != category_id:
        r.category_id, r.hits = category_id, 1
    else:
        r.hits += 1
    db.flush()


def rule_category(db: Session, user_id: uuid.UUID, concept: str) -> uuid.UUID | None:
    n = normalize(concept)
    exact = db.scalar(
        select(CategoryRule.category_id).where(
            CategoryRule.user_id == user_id, CategoryRule.pattern == n
        )
    )
    if exact:
        return exact
    # Regla cuyo patrón está contenido en el concepto (la más larga gana)
    rows = db.execute(
        select(CategoryRule.pattern, CategoryRule.category_id).where(
            CategoryRule.user_id == user_id
        )
    ).all()
    best = max((r for r in rows if len(r[0]) >= 4 and r[0] in n), key=lambda r: len(r[0]),
               default=None)  # fmt: skip
    return best[1] if best else None


# --- Estadísticas ------------------------------------------------------------------------
@dataclass
class CycleStats:
    cycle_id: uuid.UUID
    label: str
    status: str
    payroll: Decimal
    income: Decimal  # ingresos sin nómina
    spend: Decimal  # gasto neto (gastos − reembolsos), positivo
    fixed: Decimal
    variable: Decimal
    installments: Decimal
    savings: Decimal
    savings_rate: Decimal | None
    by_category: dict[uuid.UUID | None, Decimal]  # categoría raíz → gasto neto positivo


def _root_map(db: Session, user_id: uuid.UUID) -> tuple[dict[uuid.UUID, uuid.UUID], dict]:
    cats = {c.id: c for c in db.scalars(select(Category).where(Category.user_id == user_id))}
    root = {cid: (c.parent_id if c.parent_id in cats else cid) for cid, c in cats.items()}
    return root, cats


def cycles_stats(db: Session, user_id: uuid.UUID, n: int) -> list[CycleStats]:
    account = svc.main_account(db, user_id)
    cycles = list(
        db.scalars(
            select(PayCycle)
            .where(PayCycle.user_id == user_id, PayCycle.account_id == account.id)
            .order_by(PayCycle.start_date.desc())
            .limit(n)
        )
    )[::-1]
    root, _ = _root_map(db, user_id)
    out: list[CycleStats] = []
    for c in cycles:
        s = svc.cycle_summary(db, c)
        by_cat: dict[uuid.UUID | None, Decimal] = defaultdict(lambda: ZERO)
        income = ZERO
        for m in svc.cycle_movements(db, c):
            if m.status == "cancelled" or m.id == c.payroll_movement_id:
                continue
            if m.kind in SPEND_KINDS:
                by_cat[root.get(m.category_id) if m.category_id else None] -= m.amount
            elif m.kind == "ingreso":
                income += m.amount
        spend = sum(by_cat.values(), ZERO)
        out.append(
            CycleStats(c.id, c.label, c.status, c.payroll_amount, income, spend, s.fixed_spend,
                       s.variable_spend, s.installments, s.savings, s.savings_rate,
                       dict(by_cat))
        )  # fmt: skip
    return out


@dataclass
class CategoryStat:
    category_id: uuid.UUID | None
    name: str
    current: Decimal
    average: Decimal  # media de los ciclos cerrados del rango
    budget: Decimal | None
    trend: list[Decimal]


def category_stats(db: Session, user_id: uuid.UUID, n: int) -> list[CategoryStat]:
    stats = cycles_stats(db, user_id, n)
    _, cats = _root_map(db, user_id)
    budgets = {b.category_id: b.amount for b in db.scalars(
        select(Budget).where(Budget.user_id == user_id, Budget.active.is_(True)))}  # fmt: skip
    keys: set[uuid.UUID | None] = set(budgets)
    for s in stats:
        keys |= set(s.by_category)
    closed = [s for s in stats if s.status == "closed"]
    current = next((s for s in stats if s.status == "open"), stats[-1] if stats else None)
    out = []
    for k in keys:
        trend = [s.by_category.get(k, ZERO) for s in stats]
        avg = (
            (sum((s.by_category.get(k, ZERO) for s in closed), ZERO) / len(closed))
            if closed
            else ZERO
        )
        name = cats[k].name if k in cats else "Sin categoría"
        cur = current.by_category.get(k, ZERO) if current else ZERO
        if cur == 0 and avg == 0 and k not in budgets:
            continue
        out.append(CategoryStat(k, name, cur, avg.quantize(Decimal("0.01")), budgets.get(k), trend))
    out.sort(key=lambda c: (-c.current, -c.average))
    return out


def top_concepts(
    db: Session, user_id: uuid.UUID, n_cycles: int, limit: int
) -> list[tuple[str, Decimal, int]]:
    ids = [s.cycle_id for s in cycles_stats(db, user_id, n_cycles)]
    totals: dict[str, list] = {}
    for m in db.scalars(
        select(Movement).where(
            Movement.user_id == user_id,
            Movement.cycle_id.in_(ids),
            Movement.status != "cancelled",
            Movement.kind.in_(SPEND_KINDS),
        )
    ):
        k = normalize(m.concept)
        e = totals.setdefault(k, [m.concept.strip(), ZERO, 0])
        e[1] -= m.amount
        e[2] += 1
    rows = sorted(((c, t, n) for c, t, n in totals.values() if t > 0), key=lambda x: -x[1])
    return rows[:limit]
