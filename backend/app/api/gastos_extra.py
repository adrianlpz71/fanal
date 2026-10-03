"""API de la fase 2b: personas y compartidos, deudas, seguimientos, reglas, presupuestos y
estadísticas."""

import uuid
from datetime import date
from decimal import Decimal

from fastapi import APIRouter, HTTPException, Query, Response, status
from sqlalchemy import select

from app.api.deps import DB, CurrentUser
from app.domain.money import ZERO
from app.models import (
    Budget,
    Category,
    CategoryRule,
    Debt,
    InstallmentPlan,
    Movement,
    MovementShare,
    Person,
    Tracker,
)
from app.schemas.gastos import InstallmentPlanOut
from app.schemas.gastos_extra import (
    BudgetIn,
    BudgetOut,
    CategoryAmountOut,
    CategoryStatOut,
    CycleStatsOut,
    DebtIn,
    DebtMovementOut,
    DebtOut,
    DebtPatch,
    DebtPaymentIn,
    FixedItemOut,
    FixedPanelOut,
    FixedSuggestionOut,
    FixedTrendOut,
    InstallmentPlanPatch,
    PersonIn,
    PersonOut,
    PersonPatch,
    RuleOut,
    SettleIn,
    SettleOut,
    ShareIn,
    ShareOut,
    StatsOut,
    TopConceptOut,
    TrackerCycleOut,
    TrackerIn,
    TrackerOut,
    TrackerPatch,
)
from app.services import gastos as svc
from app.services import gastos_extra as ex

router = APIRouter(tags=["gastos"])


def _dec(v: str | None) -> Decimal | None:
    return Decimal(v) if v not in (None, "") else None


# --- Personas y gastos compartidos ---------------------------------------------------------
def _person_out(p: Person, bal: dict) -> PersonOut:
    owed, owe = bal.get(p.id, (ZERO, ZERO))
    return PersonOut(id=p.id, name=p.name, notes=p.notes, archived=p.archived,
                     owed_to_me=owed, i_owe=owe, net=owed - owe)  # fmt: skip


def share_out(db: DB, sh: MovementShare, with_movement: bool = False) -> ShareOut:
    person = db.get(Person, sh.person_id)
    m = db.get(Movement, sh.movement_id) if with_movement else None
    return ShareOut(
        id=sh.id, movement_id=sh.movement_id, person_id=sh.person_id,
        person_name=person.name if person else "—", amount=sh.amount,
        direction=sh.direction, status=sh.status,  # type: ignore[arg-type]
        settled_by_movement_id=sh.settled_by_movement_id,
        movement_concept=m.concept if m else None, movement_date=m.date if m else None,
    )  # fmt: skip


@router.get("/people", response_model=list[PersonOut])
def list_people(db: DB, user: CurrentUser, include_archived: bool = False):
    q = select(Person).where(Person.user_id == user.id)
    if not include_archived:
        q = q.where(Person.archived.is_(False))
    bal = ex.person_balances(db, user.id)
    people = [_person_out(p, bal) for p in db.scalars(q.order_by(Person.name))]
    return sorted(people, key=lambda p: (-abs(p.net), p.name))


@router.post("/people", response_model=PersonOut, status_code=status.HTTP_201_CREATED)
def create_person(body: PersonIn, db: DB, user: CurrentUser) -> PersonOut:
    p = ex.get_or_create_person(db, user.id, body.name)
    p.notes = body.notes
    return _person_out(p, ex.person_balances(db, user.id))


@router.patch("/people/{person_id}", response_model=PersonOut)
def patch_person(person_id: uuid.UUID, body: PersonPatch, db: DB, user: CurrentUser):
    p = svc.get_owned(db, Person, person_id, user.id)
    for k, v in body.model_dump(exclude_none=True).items():
        setattr(p, k, v)
    return _person_out(p, ex.person_balances(db, user.id))


@router.get("/people/{person_id}/shares", response_model=list[ShareOut])
def person_shares(person_id: uuid.UUID, db: DB, user: CurrentUser):
    svc.get_owned(db, Person, person_id, user.id)
    rows = db.scalars(
        select(MovementShare).where(MovementShare.user_id == user.id,
                                    MovementShare.person_id == person_id)
        .order_by(MovementShare.status.desc(), MovementShare.created_at.desc())
    )  # fmt: skip
    return [share_out(db, s, with_movement=True) for s in rows]


@router.get("/movements/{movement_id}/shares", response_model=list[ShareOut])
def get_shares(movement_id: uuid.UUID, db: DB, user: CurrentUser):
    svc.get_owned(db, Movement, movement_id, user.id)
    rows = db.scalars(select(MovementShare).where(MovementShare.movement_id == movement_id))
    return [share_out(db, s) for s in rows]


@router.put("/movements/{movement_id}/shares", response_model=list[ShareOut])
def put_shares(movement_id: uuid.UUID, body: list[ShareIn], db: DB, user: CurrentUser):
    """Reparte un gasto: qué parte corresponde a cada persona (me deben / debo)."""
    m = svc.get_owned(db, Movement, movement_id, user.id)
    ex.set_shares(db, user.id, m, [s.model_dump() for s in body])
    rows = db.scalars(select(MovementShare).where(MovementShare.movement_id == movement_id))
    return [share_out(db, s) for s in rows]


@router.post("/shares/{share_id}/settle", response_model=SettleOut)
def settle(share_id: uuid.UUID, body: SettleIn, db: DB, user: CurrentUser) -> SettleOut:
    sh = svc.get_owned(db, MovementShare, share_id, user.id)
    mv = ex.settle_share(db, user.id, sh, body.create_movement, body.date, body.movement_id)
    return SettleOut(share=share_out(db, sh), movement_id=mv.id if mv else None)


# --- Deudas --------------------------------------------------------------------------------
def _debt_out(db: DB, d: Debt) -> DebtOut:
    rem, moved = ex.debt_remaining(db, d)
    person = db.get(Person, d.person_id) if d.person_id else None
    movs = db.scalars(select(Movement).where(Movement.user_id == d.user_id,
                                             Movement.debt_id == d.id)
                      .order_by(Movement.date.desc().nulls_last()))  # fmt: skip
    return DebtOut(
        id=d.id, name=d.name, person_name=person.name if person else None,
        direction=d.direction, opening_balance=d.opening_balance,  # type: ignore[arg-type]
        opening_date=d.opening_date, remaining=rem, paid=abs(moved),
        status=d.status, interest_rate=str(d.interest_rate) if d.interest_rate else None,  # type: ignore[arg-type]
        notes=d.notes,
        movements=[DebtMovementOut(id=m.id, date=m.date, concept=m.concept, amount=m.amount)
                   for m in movs],
    )  # fmt: skip


@router.get("/debts", response_model=list[DebtOut])
def list_debts(db: DB, user: CurrentUser):
    rows = db.scalars(select(Debt).where(Debt.user_id == user.id)
                      .order_by(Debt.status.desc(), Debt.opening_date))  # fmt: skip
    return [_debt_out(db, d) for d in rows]


@router.post("/debts", response_model=DebtOut, status_code=status.HTTP_201_CREATED)
def create_debt(body: DebtIn, db: DB, user: CurrentUser) -> DebtOut:
    person = ex.get_or_create_person(db, user.id, body.person_name) if body.person_name else None
    d = Debt(user_id=user.id, name=body.name, person_id=person.id if person else None,
             direction=body.direction, opening_balance=abs(body.opening_balance),
             opening_date=body.opening_date, interest_rate=_dec(body.interest_rate),
             notes=body.notes)  # fmt: skip
    db.add(d)
    db.flush()
    return _debt_out(db, d)


@router.patch("/debts/{debt_id}", response_model=DebtOut)
def patch_debt(debt_id: uuid.UUID, body: DebtPatch, db: DB, user: CurrentUser) -> DebtOut:
    d = svc.get_owned(db, Debt, debt_id, user.id)
    data = body.model_dump(exclude_none=True)
    if "interest_rate" in data:
        data["interest_rate"] = _dec(data["interest_rate"])
    for k, v in data.items():
        setattr(d, k, v)
    return _debt_out(db, d)


@router.post("/debts/{debt_id}/payments", response_model=DebtOut)
def debt_payment(debt_id: uuid.UUID, body: DebtPaymentIn, db: DB, user: CurrentUser):
    """Registra un pago (sale dinero si debo; entra si me deben) en la cuenta de gastos.
    Es una transferencia de patrimonio, no un gasto: no cuenta en las estadísticas."""
    d = svc.get_owned(db, Debt, debt_id, user.id)
    account = svc.main_account(db, user.id)
    cyc = svc.open_cycle(db, user.id, account.id)
    sign = -1 if d.direction == "debo" else 1
    db.add(Movement(
        user_id=user.id, account_id=account.id, cycle_id=cyc.id if cyc else None,
        date=body.date or date.today(), kind="transferencia", status="posted",
        concept=body.concept or f"{'Pago' if sign < 0 else 'Cobro'} · {d.name}",
        amount=abs(body.amount) * sign, source="manual", debt_id=d.id,
    ))  # fmt: skip
    db.flush()
    ex.refresh_debt_status(db, d)
    return _debt_out(db, d)


# --- Seguimientos ------------------------------------------------------------------------
def _tracker_out(db: DB, t: Tracker) -> TrackerOut:
    st = ex.tracker_state(db, t)
    return TrackerOut(
        id=t.id, name=t.name, opening_balance=t.opening_balance, opening_date=t.opening_date,
        category_ids=list(t.category_ids or []), keywords=list(t.keywords or []),
        archived=t.archived, notes=t.notes, balance=st.balance, movements_count=st.count,
        by_cycle=[TrackerCycleOut(label=k, amount=v) for k, v in st.by_cycle],
    )  # fmt: skip


def _check_categories(db: DB, user_id: uuid.UUID, ids: list[uuid.UUID]) -> None:
    for cid in ids:
        svc.get_owned(db, Category, cid, user_id)


@router.get("/trackers", response_model=list[TrackerOut])
def list_trackers(db: DB, user: CurrentUser):
    rows = db.scalars(select(Tracker).where(Tracker.user_id == user.id).order_by(Tracker.name))
    return [_tracker_out(db, t) for t in rows]


@router.post("/trackers", response_model=TrackerOut, status_code=status.HTTP_201_CREATED)
def create_tracker(body: TrackerIn, db: DB, user: CurrentUser) -> TrackerOut:
    _check_categories(db, user.id, body.category_ids)
    if not body.category_ids and not body.keywords:
        raise HTTPException(status.HTTP_422_UNPROCESSABLE_ENTITY,
                            "Elige al menos una categoría o una palabra clave")  # fmt: skip
    t = Tracker(user_id=user.id, **body.model_dump())
    db.add(t)
    db.flush()
    return _tracker_out(db, t)


@router.patch("/trackers/{tracker_id}", response_model=TrackerOut)
def patch_tracker(tracker_id: uuid.UUID, body: TrackerPatch, db: DB, user: CurrentUser):
    t = svc.get_owned(db, Tracker, tracker_id, user.id)
    data = body.model_dump(exclude_unset=True)
    if data.get("category_ids"):
        _check_categories(db, user.id, data["category_ids"])
    for k, v in data.items():
        setattr(t, k, v)
    db.flush()
    return _tracker_out(db, t)


@router.delete("/trackers/{tracker_id}", status_code=status.HTTP_204_NO_CONTENT)
def delete_tracker(tracker_id: uuid.UUID, db: DB, user: CurrentUser) -> Response:
    db.delete(svc.get_owned(db, Tracker, tracker_id, user.id))
    return Response(status_code=status.HTTP_204_NO_CONTENT)


# --- Reglas ---------------------------------------------------------------------------------
@router.get("/category-rules", response_model=list[RuleOut])
def list_rules(db: DB, user: CurrentUser):
    rows = db.scalars(select(CategoryRule).where(CategoryRule.user_id == user.id)
                      .order_by(CategoryRule.hits.desc(), CategoryRule.pattern))  # fmt: skip
    return [RuleOut.model_validate(r, from_attributes=True) for r in rows]


@router.delete("/category-rules/{rule_id}", status_code=status.HTTP_204_NO_CONTENT)
def delete_rule(rule_id: uuid.UUID, db: DB, user: CurrentUser) -> Response:
    db.delete(svc.get_owned(db, CategoryRule, rule_id, user.id))
    return Response(status_code=status.HTTP_204_NO_CONTENT)


# --- Presupuestos -------------------------------------------------------------------------
@router.get("/budgets", response_model=list[BudgetOut])
def list_budgets(db: DB, user: CurrentUser):
    return [BudgetOut.model_validate(b, from_attributes=True)
            for b in db.scalars(select(Budget).where(Budget.user_id == user.id))]  # fmt: skip


@router.put("/budgets/{category_id}", response_model=BudgetOut)
def put_budget(category_id: uuid.UUID, body: BudgetIn, db: DB, user: CurrentUser) -> BudgetOut:
    svc.get_owned(db, Category, category_id, user.id)
    b = db.scalar(
        select(Budget).where(Budget.user_id == user.id, Budget.category_id == category_id)
    )
    if b is None:
        b = Budget(user_id=user.id, category_id=category_id, amount=abs(body.amount))
        db.add(b)
    else:
        b.amount, b.active = abs(body.amount), True
    db.flush()
    return BudgetOut.model_validate(b, from_attributes=True)


@router.delete("/budgets/{category_id}", status_code=status.HTTP_204_NO_CONTENT)
def delete_budget(category_id: uuid.UUID, db: DB, user: CurrentUser) -> Response:
    b = db.scalar(
        select(Budget).where(Budget.user_id == user.id, Budget.category_id == category_id)
    )
    if b is None:
        raise svc.not_found("Budget")
    db.delete(b)
    return Response(status_code=status.HTTP_204_NO_CONTENT)


# --- Estadísticas -----------------------------------------------------------------------
@router.get("/stats", response_model=StatsOut)
def stats(db: DB, user: CurrentUser, cycles: int = Query(default=6, ge=1, le=36),
          top: int = Query(default=15, ge=1, le=50)) -> StatsOut:  # fmt: skip
    cs = ex.cycles_stats(db, user.id, cycles)
    cats = ex.category_stats(db, user.id, cycles)
    closed = [c for c in cs if c.status == "closed"] or cs
    rates = [c.savings_rate for c in closed if c.savings_rate is not None]
    return StatsOut(
        cycles=[
            CycleStatsOut(
                cycle_id=c.cycle_id, label=c.label, status=c.status, payroll=c.payroll,
                income=c.income, spend=c.spend, fixed=c.fixed, variable=c.variable,
                installments=c.installments, savings=c.savings,
                savings_rate=f"{c.savings_rate:.4f}" if c.savings_rate is not None else None,
                by_category=[CategoryAmountOut(category_id=k, amount=v)
                             for k, v in sorted(c.by_category.items(), key=lambda x: -x[1])],
            )
            for c in cs
        ],
        categories=[
            CategoryStatOut(
                category_id=c.category_id, name=c.name, current=c.current, average=c.average,
                budget=c.budget,
                budget_used=f"{(c.current / c.budget):.4f}" if c.budget else None,
                trend=c.trend,
            )
            for c in cats
        ],
        top_concepts=[TopConceptOut(concept=k, total=t, count=n)
                      for k, t, n in ex.top_concepts(db, user.id, cycles, top)],
        avg_spend=(sum((c.spend for c in closed), ZERO) / len(closed)).quantize(Decimal("0.01"))
        if closed else ZERO,
        avg_savings_rate=f"{sum(rates) / len(rates):.4f}" if rates else None,
    )  # fmt: skip


# --- Fraccionadas: renombrar / recategorizar -------------------------------------------------
@router.patch("/installments/{plan_id}", response_model=InstallmentPlanOut)
def patch_plan(plan_id: uuid.UUID, body: InstallmentPlanPatch, db: DB, user: CurrentUser):
    from app.api.gastos import _plan_out  # evitar import circular a nivel de módulo

    p = svc.get_owned(db, InstallmentPlan, plan_id, user.id)
    data = body.model_dump(exclude_unset=True)
    if data.get("category_id"):
        svc.get_owned(db, Category, data["category_id"], user.id)
    for k, v in data.items():
        setattr(p, k, v)
    # Las cuotas pendientes heredan el nombre y la categoría del plan
    for i in p.installments:
        if i.movement_id and i.status == "pendiente":
            m = db.get(Movement, i.movement_id)
            if m is not None:
                if "description" in data:
                    m.concept = f"{p.description} ({i.seq}/{p.n})"
                if "category_id" in data:
                    m.category_id = p.category_id
    db.flush()
    return _plan_out(p)


# --- Panel de gastos fijos ----------------------------------------------------------------------
@router.get("/gastos/fijos", response_model=FixedPanelOut)
def fixed_panel(db: DB, user: CurrentUser) -> FixedPanelOut:
    from app.services import fijos

    p = fijos.panel(db, user.id)
    return FixedPanelOut(
        items=[FixedItemOut(**i.__dict__) for i in p.items],
        monthly_total=p.monthly_total,
        yearly_total=p.yearly_total,
        payroll=p.payroll,
        share_of_payroll=p.share_of_payroll,
        trend=[FixedTrendOut(label=label, fixed=v) for label, v in p.trend],
        goal_max=p.goal.target_value if p.goal else None,
        goal_name=p.goal.name if p.goal else None,
        saved_year=p.saved_year,
        to_review_saving=p.to_review_saving,
        suggestions=[FixedSuggestionOut(**s.__dict__) for s in p.suggestions],
        review_due=p.review_due,
        last_review=p.last_review,
    )


@router.post("/gastos/fijos/reviewed", status_code=status.HTTP_204_NO_CONTENT)
def fixed_reviewed(db: DB, user: CurrentUser) -> Response:
    """Marca la revisión periódica de suscripciones como hecha (vuelve a avisar en 90 días)."""
    from app.services import fijos

    fijos.mark_reviewed(db, user.id)
    return Response(status_code=status.HTTP_204_NO_CONTENT)
