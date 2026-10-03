"""API del módulo de gastos (fase 2a)."""

import uuid
from datetime import date
from decimal import Decimal

from fastapi import APIRouter, HTTPException, Query, Response, status
from sqlalchemy import select

from app.api.deps import DB, CurrentUser
from app.domain import calendar as cal
from app.domain.money import ZERO
from app.models import (
    Account,
    AuditLog,
    Category,
    Debt,
    InstallmentPlan,
    Movement,
    MovementShare,
    PayCycle,
    Person,
    RecurringPriceChange,
    RecurringTemplate,
)
from app.schemas.gastos import (
    AccountIn,
    AccountOut,
    AccountPatch,
    AdvanceIn,
    AdvanceOut,
    CategoryIn,
    CategoryOut,
    CategoryPatch,
    CycleDetailOut,
    CycleOut,
    CycleStartIn,
    CycleSummaryOut,
    ForecastMonthOut,
    ForecastOut,
    GastosSettingsIn,
    GastosSettingsOut,
    GastosSetupIn,
    InstallmentOut,
    InstallmentPlanIn,
    InstallmentPlanOut,
    MonthItemOut,
    MonthOut,
    MovementIn,
    MovementLineOut,
    MovementOut,
    MovementPatch,
    OccurrenceIn,
    PaydayIn,
    PaydayOut,
    PaydayUndoOut,
    PriceChangeOut,
    ReconcileIn,
    ReconcileOut,
    RecurringIn,
    RecurringOut,
    RecurringPatch,
    ShareBriefOut,
    SuggestionOut,
)
from app.services import gastos as svc
from app.services import gastos_extra as ex
from app.services.categories_seed import seed_categories

router = APIRouter(tags=["gastos"])


# --- Conversión a esquemas -----------------------------------------------------------------
def _dec(v: object) -> Decimal | None:
    return Decimal(str(v)) if v not in (None, "") else None


def _settings_out(s: dict) -> GastosSettingsOut:
    return GastosSettingsOut(
        configured=bool(s["main_account_id"]),
        payday_day=int(s["payday_day"]),
        usual_payroll=_dec(s["usual_payroll"]),
        main_account_id=s["main_account_id"],
        refugio_account_id=s["refugio_account_id"],
        emergency_target=_dec(s["emergency_target"]),
        monthly_refugio=_dec(s["monthly_refugio"]),
        forecast_months=int(s["forecast_months"]),
    )


def _account_out(db: DB, a: Account) -> AccountOut:
    return AccountOut(
        id=a.id, kind=a.kind, name=a.name, bank=a.bank,  # type: ignore[arg-type]
        balance=svc.account_balance(db, a),
        balance_with_planned=svc.account_balance(db, a, include_planned=True),
        archived=a.archived,
    )  # fmt: skip


def _shares_by_movement(db: DB, ids: list[uuid.UUID]) -> dict[uuid.UUID, list[ShareBriefOut]]:
    out: dict[uuid.UUID, list[ShareBriefOut]] = {}
    if not ids:
        return out
    rows = db.execute(
        select(MovementShare, Person.name)
        .join(Person, Person.id == MovementShare.person_id)
        .where(MovementShare.movement_id.in_(ids))
    ).all()
    for sh, name in rows:
        out.setdefault(sh.movement_id, []).append(
            ShareBriefOut(
                id=sh.id,
                person_name=name,
                amount=sh.amount,
                direction=sh.direction,
                status=sh.status,
            )  # type: ignore[arg-type]
        )
    return out


def _movements_out(db: DB, movs: list[Movement]) -> list[MovementOut]:
    shares = _shares_by_movement(db, [m.id for m in movs])
    return [_movement_out(m, shares.get(m.id, [])) for m in movs]


def _one(db: DB, m: Movement) -> MovementOut:
    return _movements_out(db, [m])[0]


def _movement_out(m: Movement, shares: list[ShareBriefOut] | None = None) -> MovementOut:
    return MovementOut(
        id=m.id, account_id=m.account_id, cycle_id=m.cycle_id, date=m.date, due_date=m.due_date,
        kind=m.kind, status=m.status, concept=m.concept, amount=m.amount,  # type: ignore[arg-type]
        expression=m.expression,
        lines=[MovementLineOut(seq=ln.seq, amount=ln.amount, note=ln.note) for ln in m.lines],
        category_id=m.category_id, source=m.source, source_ref=m.source_ref, notes=m.notes,
        debt_id=m.debt_id, refund_of_id=m.refund_of_id, shares=shares or [],
    )  # fmt: skip


def _cycle_out(db: DB, c: PayCycle) -> CycleOut:
    s = svc.cycle_summary(db, c)
    return CycleOut(
        id=c.id, label=c.label, status=c.status,  # type: ignore[arg-type]
        start_date=c.start_date, end_date=c.end_date,
        carried_expected=c.carried_expected, discrepancy=c.discrepancy,
        summary=CycleSummaryOut(
            carried=s.carried, payroll=s.payroll, opening=s.opening,
            available_now=s.available_now, expected_end=s.expected_end,
            net_movements=s.net_movements, pending_total=s.pending_total,
            fixed_spend=s.fixed_spend, variable_spend=s.variable_spend,
            installments=s.installments, savings=s.savings,
            savings_rate=f"{s.savings_rate:.4f}" if s.savings_rate is not None else None,
            days_to_payday=s.days_to_payday, per_day=s.per_day,
        ),
    )  # fmt: skip


def _cycle_detail(db: DB, c: PayCycle) -> CycleDetailOut:
    movements = _movements_out(db, svc.cycle_movements(db, c))
    return CycleDetailOut(**_cycle_out(db, c).model_dump(), movements=movements)


def _plan_out(p: InstallmentPlan) -> InstallmentPlanOut:
    pend = [i for i in p.installments if i.status == "pendiente"]
    return InstallmentPlanOut(
        id=p.id, description=p.description, merchant=p.merchant,
        provider=p.provider, total=p.total, n=p.n,  # type: ignore[arg-type]
        every_months=p.every_months, first_due=p.first_due, fee=p.fee, status=p.status,
        category_id=p.category_id,
        paid=sum(1 for i in p.installments if i.status in ("pagada", "adelantada")),
        remaining_amount=sum((i.amount for i in pend), ZERO),
        next_due=min((i.due_date for i in pend), default=None),
        installments=[
            InstallmentOut(seq=i.seq, due_date=i.due_date, amount=i.amount, status=i.status,
                           movement_id=i.movement_id)
            for i in p.installments
        ],
    )  # fmt: skip


def _recurring_out(db: DB, t: RecurringTemplate) -> RecurringOut:
    changes = db.scalars(
        select(RecurringPriceChange)
        .where(
            RecurringPriceChange.template_id == t.id, RecurringPriceChange.acknowledged.is_(False)
        )
        .order_by(RecurringPriceChange.detected_at.desc())
    ).all()
    monthly = -t.amount / t.every_months
    return RecurringOut(
        id=t.id, concept=t.concept, amount=t.amount, amount_is_estimate=t.amount_is_estimate,
        kind=t.kind, category_id=t.category_id, every_months=t.every_months,  # type: ignore[arg-type]
        day_of_month=t.day_of_month, start_date=t.start_date, end_date=t.end_date,
        active=t.active, review=t.review, est_saving_year=t.est_saving_year,
        monthly_cost=monthly, yearly_cost=monthly * 12,
        price_changes=[
            PriceChangeOut(id=c.id, old_amount=c.old_amount, new_amount=c.new_amount,
                           detected_at=c.detected_at.isoformat())
            for c in changes
        ],
        notes=t.notes,
    )  # fmt: skip


# --- Configuración / onboarding del módulo -------------------------------------------------
@router.get("/gastos/settings", response_model=GastosSettingsOut)
def get_settings(db: DB, user: CurrentUser) -> GastosSettingsOut:
    return _settings_out(svc.get_settings(db, user.id))


@router.patch("/gastos/settings", response_model=GastosSettingsOut)
def patch_settings(body: GastosSettingsIn, db: DB, user: CurrentUser) -> GastosSettingsOut:
    return _settings_out(svc.save_settings(db, user.id, body.model_dump(exclude_none=True)))


@router.post("/gastos/setup", response_model=CycleOut, status_code=status.HTTP_201_CREATED)
def setup(body: GastosSetupIn, db: DB, user: CurrentUser) -> CycleOut:
    """Onboarding del módulo: cuenta de gastos (+ refugio opcional), ajustes, categorías y el
    primer ciclo (abierto con el saldo actual como arrastre)."""
    if svc.get_settings(db, user.id)["main_account_id"]:
        raise HTTPException(status.HTTP_409_CONFLICT, "El módulo de gastos ya está configurado")
    seed_categories(db, user.id)
    today = date.today()
    main = Account(user_id=user.id, kind="gastos", name="Cuenta de gastos", bank=body.bank,
                   opening_balance=body.current_balance, opening_date=today)  # fmt: skip
    db.add(main)
    refugio = None
    if body.refugio_bank is not None:
        refugio = Account(user_id=user.id, kind="refugio", name="Fondo de emergencia",
                          bank=body.refugio_bank, opening_balance=body.refugio_balance or ZERO,
                          opening_date=today, sort=1)  # fmt: skip
        db.add(refugio)
    db.flush()
    svc.save_settings(
        db, user.id,
        {"payday_day": body.payday_day, "usual_payroll": body.usual_payroll,
         "main_account_id": main.id, "refugio_account_id": refugio.id if refugio else None,
         "emergency_target": body.emergency_target, "monthly_refugio": body.monthly_refugio},
    )  # fmt: skip
    key = cal.cycle_for_date(today, body.payday_day)
    # Cuenta: saldo de apertura = saldo actual. Ciclo: arrastra ese mismo saldo (sin nómina).
    # Ningún movimiento extra: si no, el saldo se contaría dos veces.
    cycle = svc.create_cycle(db, user.id, main, key.label, today, body.current_balance, ZERO)
    return _cycle_out(db, cycle)


# --- Cuentas ---------------------------------------------------------------------------
@router.get("/accounts", response_model=list[AccountOut])
def list_accounts(db: DB, user: CurrentUser) -> list[AccountOut]:
    rows = db.scalars(select(Account).where(Account.user_id == user.id).order_by(Account.sort))
    return [_account_out(db, a) for a in rows]


@router.post("/accounts", response_model=AccountOut, status_code=status.HTTP_201_CREATED)
def create_account(body: AccountIn, db: DB, user: CurrentUser) -> AccountOut:
    if body.id and (existing := db.get(Account, body.id)):
        if existing.user_id != user.id:
            raise svc.not_found("Account")
        return _account_out(db, existing)
    a = Account(
        user_id=user.id, kind=body.kind, name=body.name, bank=body.bank,
        opening_balance=body.opening_balance, opening_date=body.opening_date or date.today(),
        apy=_dec(body.apy),
    )  # fmt: skip
    if body.id:
        a.id = body.id
    db.add(a)
    db.flush()
    return _account_out(db, a)


@router.patch("/accounts/{account_id}", response_model=AccountOut)
def patch_account(account_id: uuid.UUID, body: AccountPatch, db: DB, user: CurrentUser):
    a = svc.get_owned(db, Account, account_id, user.id)
    for k, v in body.model_dump(exclude_none=True).items():
        setattr(a, k, _dec(v) if k == "apy" else v)
    return _account_out(db, a)


@router.post("/accounts/{account_id}/reconcile", response_model=ReconcileOut)
def reconcile(account_id: uuid.UUID, body: ReconcileIn, db: DB, user: CurrentUser):
    """Cuadre con el banco: diferencia entre el saldo calculado y el real; opcionalmente crea un
    movimiento de ajuste en el ciclo abierto."""
    a = svc.get_owned(db, Account, account_id, user.id)
    computed = svc.account_balance(db, a)
    diff = body.real_balance - computed
    adj_id = None
    if diff != 0 and body.create_adjustment:
        cyc = svc.open_cycle(db, user.id, a.id)
        m = Movement(user_id=user.id, account_id=a.id, cycle_id=cyc.id if cyc else None,
                     date=date.today(), kind="ajuste", status="posted",
                     concept="Ajuste de cuadre", amount=diff, source="manual",
                     notes=f"Calculado {computed} · banco {body.real_balance}")  # fmt: skip
        db.add(m)
        db.flush()
        adj_id = m.id
        db.add(AuditLog(user_id=user.id, entity="account", entity_id=str(a.id),
                        action="reconcile", after={"difference": str(diff)}))  # fmt: skip
    return ReconcileOut(computed=computed, real=body.real_balance, difference=diff,
                        adjustment_id=adj_id)  # fmt: skip


# --- Categorías ----------------------------------------------------------------------------
@router.get("/categories", response_model=list[CategoryOut])
def list_categories(db: DB, user: CurrentUser) -> list[CategoryOut]:
    seed_categories(db, user.id)
    rows = db.scalars(
        select(Category).where(Category.user_id == user.id).order_by(Category.sort, Category.name)
    )
    return [CategoryOut.model_validate(c, from_attributes=True) for c in rows]


@router.post("/categories", response_model=CategoryOut, status_code=status.HTTP_201_CREATED)
def create_category(body: CategoryIn, db: DB, user: CurrentUser) -> CategoryOut:
    if body.parent_id:
        svc.get_owned(db, Category, body.parent_id, user.id)
    c = Category(user_id=user.id, **body.model_dump())
    db.add(c)
    db.flush()
    return CategoryOut.model_validate(c, from_attributes=True)


@router.patch("/categories/{category_id}", response_model=CategoryOut)
def patch_category(category_id: uuid.UUID, body: CategoryPatch, db: DB, user: CurrentUser):
    c = svc.get_owned(db, Category, category_id, user.id)
    for k, v in body.model_dump(exclude_none=True).items():
        setattr(c, k, v)
    return CategoryOut.model_validate(c, from_attributes=True)


# --- Ciclos ----------------------------------------------------------------------------
@router.get("/cycles", response_model=list[CycleOut])
def list_cycles(db: DB, user: CurrentUser, limit: int = Query(default=24, le=120)):
    rows = db.scalars(
        select(PayCycle).where(PayCycle.user_id == user.id)
        .order_by(PayCycle.start_date.desc()).limit(limit)
    )  # fmt: skip
    return [_cycle_out(db, c) for c in rows]


@router.get("/cycles/current", response_model=CycleDetailOut)
def current_cycle(db: DB, user: CurrentUser) -> CycleDetailOut:
    account = svc.main_account(db, user.id)
    c = svc.open_cycle(db, user.id, account.id)
    if c is None:
        raise HTTPException(status.HTTP_404_NOT_FOUND, "No hay ningún ciclo abierto")
    return _cycle_detail(db, c)


@router.get("/cycles/{cycle_id}", response_model=CycleDetailOut)
def get_cycle(cycle_id: uuid.UUID, db: DB, user: CurrentUser) -> CycleDetailOut:
    c = svc.get_owned(db, PayCycle, cycle_id, user.id)
    return _cycle_detail(db, c)


@router.post("/cycles/start", response_model=CycleOut, status_code=status.HTTP_201_CREATED)
def start_cycle(body: CycleStartIn, db: DB, user: CurrentUser) -> CycleOut:
    account = svc.main_account(db, user.id)
    if svc.open_cycle(db, user.id, account.id):
        raise HTTPException(status.HTTP_409_CONFLICT, "Ya hay un ciclo abierto")
    d = body.payroll_date or date.today()
    key = cal.cycle_for_date(d, int(svc.get_settings(db, user.id)["payday_day"]))
    c = svc.create_cycle(db, user.id, account, key.label, d, body.current_balance,
                         body.payroll_amount, payroll_date=d)  # fmt: skip
    return _cycle_out(db, c)


@router.post("/cycles/payday", response_model=PaydayOut)
def payday(body: PaydayIn, db: DB, user: CurrentUser) -> PaydayOut:
    """Botón "He cobrado"."""
    r = svc.payday(db, user.id, body.payroll_amount, body.payroll_date,
                   body.real_balance_before, dict(body.pending_actions))  # fmt: skip
    return PaydayOut(closed_id=r.closed.id, opened=_cycle_out(db, r.opened),
                     discrepancy=r.discrepancy, carried_over=r.carried_over,
                     cancelled=r.cancelled)  # fmt: skip


@router.get("/cycles/payday/undo", response_model=PaydayUndoOut)
def payday_undo_status(db: DB, user: CurrentUser) -> PaydayUndoOut:
    """¿Se puede deshacer el último "He cobrado"? Solo mientras su ciclo siga abierto."""
    reason = svc.payday_undo_blocker(db, user.id)
    return PaydayUndoOut(available=reason is None, reason=reason)


@router.post("/cycles/payday/undo", response_model=CycleOut)
def undo_payday(db: DB, user: CurrentUser) -> CycleOut:
    """Deshace el último "He cobrado": reabre el ciclo anterior y borra el nuevo (lo apuntado en
    el nuevo vuelve al reabierto)."""
    return _cycle_out(db, svc.undo_payday(db, user.id))


# --- Movimientos -----------------------------------------------------------------------
@router.get("/movements/suggest", response_model=list[SuggestionOut])
def suggest(db: DB, user: CurrentUser, q: str = Query(min_length=1, max_length=80)):
    out = svc.suggest(db, user.id, q)
    if out and out[0]["amount"] is None:  # sin historial: la regla aprendida manda
        out[0]["category_id"] = ex.rule_category(db, user.id, q) or out[0]["category_id"]
    elif not out and (cid := ex.rule_category(db, user.id, q)):
        out = [{"concept": q.strip(), "category_id": cid, "amount": None}]
    return [SuggestionOut(**s) for s in out]


@router.post("/movements", response_model=MovementOut, status_code=status.HTTP_201_CREATED)
def create_movement(body: MovementIn, response: Response, db: DB, user: CurrentUser):
    if body.id and (existing := db.get(Movement, body.id)):  # reintento idempotente
        if existing.user_id != user.id:
            raise svc.not_found("Movement")
        response.status_code = status.HTTP_200_OK
        return _one(db, existing)
    account = (svc.get_owned(db, Account, body.account_id, user.id) if body.account_id
               else svc.main_account(db, user.id))  # fmt: skip
    if body.cycle_id:
        cycle = svc.get_owned(db, PayCycle, body.cycle_id, user.id)
    else:
        cycle = svc.open_cycle(db, user.id, account.id)
    if body.category_id:
        svc.get_owned(db, Category, body.category_id, user.id)
    m = Movement(
        user_id=user.id, account_id=account.id, cycle_id=cycle.id if cycle else None,
        date=body.date or (date.today() if body.status == "posted" else None),
        due_date=body.due_date, kind=body.kind, status=body.status, concept=body.concept.strip(),
        amount=ZERO, category_id=body.category_id, notes=body.notes, source="manual",
    )  # fmt: skip
    if body.id:
        m.id = body.id
    if m.category_id is None:  # sin categoría elegida: reglas aprendidas
        m.category_id = ex.rule_category(db, user.id, m.concept)
    else:
        ex.learn_rule(db, user.id, m.concept, m.category_id)
    svc.apply_amount(m, body.amount, body.expression)
    _planned_date_is_due(m, explicit_due=body.due_date is not None)
    if body.month:
        svc.put_in_month(db, m, body.month, body.due_date or body.date)
    elif not body.cycle_id:
        svc.place_planned(db, m)
    db.add(m)
    db.flush()
    if body.kind == "transferencia" and body.to_account_id:
        dest = svc.get_owned(db, Account, body.to_account_id, user.id)
        if dest.id == account.id:
            raise HTTPException(status.HTTP_422_UNPROCESSABLE_ENTITY, "Origen y destino iguales")
        other = Movement(
            user_id=user.id, account_id=dest.id,
            cycle_id=(c2.id if (c2 := svc.open_cycle(db, user.id, dest.id)) else None),
            date=m.date, due_date=m.due_date, kind="transferencia", status=m.status,
            concept=f"{m.concept} (desde {account.name})", amount=-m.amount,
            category_id=m.category_id, source="manual", transfer_pair_id=m.id,
        )  # fmt: skip
        svc.place_planned(db, other)
        db.add(other)
        db.flush()
        m.transfer_pair_id = other.id
    return _one(db, m)


def _planned_date_is_due(m: Movement, explicit_due: bool = False) -> None:
    """Un previsto no tiene fecha de cargo: la fecha que llegue es la prevista (`due_date`). Las
    versiones anteriores de la app mandaban la fecha prevista como `date` y el previsto conservaba
    la antigua (pasó con un recurrente: se cambiaba la fecha y la lista seguía igual)."""
    if m.status == "planned" and m.date is not None:
        if not explicit_due or m.due_date is None:
            m.due_date = m.date
        m.date = None


@router.patch("/movements/{movement_id}", response_model=MovementOut)
def patch_movement(movement_id: uuid.UUID, body: MovementPatch, db: DB, user: CurrentUser):
    m = svc.get_owned(db, Movement, movement_id, user.id)
    old_amount, old_status = m.amount, m.status
    data = body.model_dump(exclude_unset=True)
    if data.get("cycle_id"):
        svc.get_owned(db, PayCycle, data["cycle_id"], user.id)
    if data.get("category_id"):
        svc.get_owned(db, Category, data["category_id"], user.id)
        ex.learn_rule(db, user.id, data.get("concept") or m.concept, data["category_id"])
    old_debt = m.debt_id
    if data.get("debt_id"):
        svc.get_owned(db, Debt, data["debt_id"], user.id)
    if "amount" in data or "expression" in data:
        svc.apply_amount(m, data.pop("amount", None), data.pop("expression", None))
    month = data.pop("month", None)
    for k, v in data.items():
        setattr(m, k, v)
    _planned_date_is_due(m, explicit_due="due_date" in data)
    if month:
        if m.source == "installment" or m.bank_ref:
            raise HTTPException(
                status.HTTP_409_CONFLICT,
                "Una cuota o un cargo del extracto no se cambia de mes",
            )
        svc.put_in_month(db, m, month, data.get("due_date") or data.get("date"))
    elif "due_date" in data or "date" in data or "status" in data:
        svc.place_planned(db, m)
    if m.status == "posted" and m.date is None:
        m.date = date.today()
    # De cargado a previsto: la fecha de cargo deja de serlo y pasa a fecha prevista (si no tenía)
    if old_status == "posted" and m.status == "planned" and "date" not in data:
        m.due_date = m.due_date or m.date
        m.date = None
    if m.status == "posted" and m.cycle_id is None:  # un previsto futuro que ya se ha cargado
        cur = svc.open_cycle(db, user.id, m.account_id)
        m.cycle_id = cur.id if cur else None
    svc.check_recurring_price(db, m, old_amount)
    svc.sync_installment_from_movement(db, m)
    # La otra pata de una transferencia se mantiene coherente
    other = db.get(Movement, m.transfer_pair_id) if m.transfer_pair_id else None
    if other is not None and other.user_id == user.id:
        other.amount, other.status, other.date = -m.amount, m.status, m.date
        other.due_date = m.due_date
        svc.place_planned(db, other)
    db.flush()
    for did in {old_debt, m.debt_id} - {None}:
        d = db.get(Debt, did)
        if d is not None:
            ex.refresh_debt_status(db, d)
    return _one(db, m)


@router.delete("/movements/{movement_id}", status_code=status.HTTP_204_NO_CONTENT)
def delete_movement(movement_id: uuid.UUID, db: DB, user: CurrentUser) -> Response:
    m = svc.get_owned(db, Movement, movement_id, user.id)
    if m.source == "installment":
        raise HTTPException(
            status.HTTP_409_CONFLICT, "Es una cuota: cancela o adelanta el plan en Fraccionadas"
        )
    other = db.get(Movement, m.transfer_pair_id) if m.transfer_pair_id else None
    if other is not None and other.user_id == user.id:
        db.delete(other)
    db.delete(m)
    return Response(status_code=status.HTTP_204_NO_CONTENT)


@router.post("/movements/{movement_id}/duplicate", response_model=MovementOut,
             status_code=status.HTTP_201_CREATED)  # fmt: skip
def duplicate_movement(movement_id: uuid.UUID, db: DB, user: CurrentUser) -> MovementOut:
    m = svc.get_owned(db, Movement, movement_id, user.id)
    cyc = svc.open_cycle(db, user.id, m.account_id)
    copy = Movement(
        user_id=user.id, account_id=m.account_id, cycle_id=cyc.id if cyc else m.cycle_id,
        date=date.today(), kind=m.kind, status="posted", concept=m.concept, amount=ZERO,
        category_id=m.category_id, notes=m.notes, source="manual",
    )  # fmt: skip
    svc.apply_amount(copy, m.amount if not m.expression else None, m.expression)
    db.add(copy)
    db.flush()
    return _one(db, copy)


# --- Recurrentes -----------------------------------------------------------------------
@router.get("/recurring", response_model=list[RecurringOut])
def list_recurring(db: DB, user: CurrentUser) -> list[RecurringOut]:
    rows = db.scalars(
        select(RecurringTemplate).where(RecurringTemplate.user_id == user.id)
        .order_by(RecurringTemplate.active.desc(), RecurringTemplate.concept)
    )  # fmt: skip
    return [_recurring_out(db, t) for t in rows]


@router.post("/recurring", response_model=RecurringOut, status_code=status.HTTP_201_CREATED)
def create_recurring(body: RecurringIn, db: DB, user: CurrentUser) -> RecurringOut:
    account = (svc.get_owned(db, Account, body.account_id, user.id) if body.account_id
               else svc.main_account(db, user.id))  # fmt: skip
    data = body.model_dump(exclude={"account_id"})
    t = RecurringTemplate(user_id=user.id, account_id=account.id, **data)
    db.add(t)
    db.flush()
    cur = svc.open_cycle(db, user.id, account.id)
    if cur:
        svc.generate_recurring(db, cur, int(svc.get_settings(db, user.id)["payday_day"]))
    return _recurring_out(db, t)


@router.patch("/recurring/{template_id}", response_model=RecurringOut)
def patch_recurring(template_id: uuid.UUID, body: RecurringPatch, db: DB, user: CurrentUser):
    t = svc.get_owned(db, RecurringTemplate, template_id, user.id)
    data = body.model_dump(exclude_unset=True)
    for k, v in data.items():
        setattr(t, k, v)
    if data.get("end_date"):
        svc.end_recurring_after(db, t)
    return _recurring_out(db, t)


@router.post("/recurring/{template_id}/occurrences", response_model=MovementOut)
def recurring_occurrence(
    template_id: uuid.UUID, body: OccurrenceIn, db: DB, user: CurrentUser
) -> MovementOut:
    """Edita o salta una ocurrencia futura de un recurrente sin tocar la plantilla."""
    t = svc.get_owned(db, RecurringTemplate, template_id, user.id)
    m = svc.materialize_occurrence(db, t, body.date, skip=body.action == "saltar")
    return _one(db, m)


@router.post("/recurring/{template_id}/ack-price", response_model=RecurringOut)
def ack_price(template_id: uuid.UUID, db: DB, user: CurrentUser) -> RecurringOut:
    t = svc.get_owned(db, RecurringTemplate, template_id, user.id)
    for c in db.scalars(
        select(RecurringPriceChange).where(RecurringPriceChange.template_id == t.id)
    ):
        c.acknowledged = True
    db.flush()
    return _recurring_out(db, t)


@router.delete("/recurring/{template_id}", status_code=status.HTTP_204_NO_CONTENT)
def delete_recurring(template_id: uuid.UUID, db: DB, user: CurrentUser) -> Response:
    t = svc.get_owned(db, RecurringTemplate, template_id, user.id)
    # Los previstos aún no cargados de esta plantilla se cancelan; el histórico se conserva.
    for m in db.scalars(select(Movement).where(Movement.user_id == user.id,
                                               Movement.source_ref == t.id,
                                               Movement.status == "planned")):  # fmt: skip
        m.status = "cancelled"
    db.delete(t)
    return Response(status_code=status.HTTP_204_NO_CONTENT)


# --- Fraccionadas ------------------------------------------------------------------------
@router.get("/installments", response_model=list[InstallmentPlanOut])
def list_plans(db: DB, user: CurrentUser, include_closed: bool = False):
    q = select(InstallmentPlan).where(InstallmentPlan.user_id == user.id)
    if not include_closed:
        q = q.where(InstallmentPlan.status == "activa")
    return [_plan_out(p) for p in db.scalars(q.order_by(InstallmentPlan.first_due))]


@router.post("/installments", response_model=InstallmentPlanOut,
             status_code=status.HTTP_201_CREATED)  # fmt: skip
def create_plan(body: InstallmentPlanIn, db: DB, user: CurrentUser) -> InstallmentPlanOut:
    account = svc.main_account(db, user.id)
    if body.category_id:
        svc.get_owned(db, Category, body.category_id, user.id)
    p = svc.create_installment_plan(
        db, user.id, account, body.description, body.total, body.n, body.first_due,
        body.every_months, body.provider, body.merchant, body.fee, body.category_id,
        body.custom_amounts, set(range(1, body.paid_count + 1)),
    )  # fmt: skip
    return _plan_out(p)


@router.get("/installments/{plan_id}", response_model=InstallmentPlanOut)
def get_plan(plan_id: uuid.UUID, db: DB, user: CurrentUser) -> InstallmentPlanOut:
    return _plan_out(svc.get_owned(db, InstallmentPlan, plan_id, user.id))


@router.post("/installments/{plan_id}/advance", response_model=AdvanceOut)
def advance_plan(plan_id: uuid.UUID, body: AdvanceIn, db: DB, user: CurrentUser) -> AdvanceOut:
    p = svc.get_owned(db, InstallmentPlan, plan_id, user.id)
    moved, amount = svc.advance_plan(db, user.id, p, body.merge)
    return AdvanceOut(moved=moved, amount=amount)


@router.post("/installments/{plan_id}/cancel", response_model=InstallmentPlanOut)
def cancel_plan(plan_id: uuid.UUID, db: DB, user: CurrentUser) -> InstallmentPlanOut:
    p = svc.get_owned(db, InstallmentPlan, plan_id, user.id)
    svc.cancel_plan(db, p)
    return _plan_out(p)


# --- Meses vista -------------------------------------------------------------------------
@router.get("/forecast", response_model=ForecastOut)
def get_forecast(
    db: DB,
    user: CurrentUser,
    months: int = Query(default=0, ge=0, le=24, description="0 = el valor de tus ajustes"),
):
    n = months or int(svc.get_settings(db, user.id)["forecast_months"])
    rows = svc.forecast(db, user.id, n)
    return ForecastOut(
        months=[_month_out(r) for r in rows],
        live_installment_debt=svc.live_installment_debt(db, user.id),
    )


def _month_out(r: svc.ForecastMonth) -> ForecastMonthOut:
    return ForecastMonthOut(
        label=r.label, ym=r.ym, start=r.start, end=r.end, payroll=r.payroll,
        recurring=r.recurring, installments=r.installments, other=r.other, free=r.free,
        cumulative=r.cumulative,
    )  # fmt: skip


@router.get("/months/{ym}", response_model=MonthOut)
def get_month(ym: str, db: DB, user: CurrentUser) -> MonthOut:
    """Un ciclo futuro con todo lo que tiene previsto (movimientos y recurrentes proyectados).
    Los ciclos actual y pasados se ven en /cycles."""
    key, cur = svc.ym_key(ym), svc.current_key(db, user.id)
    ahead = svc.months_between(cur, key)
    if ahead < 1 or ahead > 36:
        raise svc.not_found("Mes futuro")
    r = svc.forecast(db, user.id, ahead)[-1]
    movs = [i.movement for i in r.items if i.movement is not None]
    by_id = {mo.id: mo for mo in _movements_out(db, movs)}
    items = [
        MonthItemOut(
            kind=i.kind,
            date=i.on,
            concept=i.concept,
            amount=i.amount,  # type: ignore[arg-type]
            category_id=i.category_id,
            source=i.source,
            template_id=i.template_id,
            movement=by_id[i.movement.id] if i.movement is not None else None,
        )
        for i in r.items
    ]
    return MonthOut(**_month_out(r).model_dump(), items=items)
