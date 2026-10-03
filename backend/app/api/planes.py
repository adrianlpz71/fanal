"""API de la fase 5: FIRE, interés compuesto, simulador fiscal y objetivos."""

import uuid
from decimal import Decimal

from fastapi import APIRouter, Query, Response, status
from sqlalchemy import select

from app.api.deps import DB, CurrentUser
from app.domain import compound as C
from app.domain import fire as F
from app.domain import tax as T
from app.models import Goal
from app.schemas.planes import (
    BandOut,
    CompoundIn,
    CompoundOut,
    CompoundYearOut,
    CutEffectOut,
    FirePlanOut,
    FireResultOut,
    FireSettingsIn,
    FireSettingsOut,
    GoalIn,
    GoalOut,
    MonteCarloOut,
    ProjectionPointOut,
    SalePartOut,
    SellPreviewIn,
    SellPreviewOut,
    TaxBracketOut,
    TaxIn,
    TaxOut,
    TaxPrefillOut,
)
from app.services import gastos as gsvc
from app.services import planes as svc

router = APIRouter(prefix="/planes", tags=["planes"])


def _settings_out(s: dict) -> FireSettingsOut:
    return FireSettingsOut(**{k: s[k] for k in FireSettingsOut.model_fields})


@router.get("/fire/settings", response_model=FireSettingsOut)
def get_fire_settings(db: DB, user: CurrentUser) -> FireSettingsOut:
    return _settings_out(svc.get_settings(db, user.id))


@router.put("/fire/settings", response_model=FireSettingsOut)
def put_fire_settings(body: FireSettingsIn, db: DB, user: CurrentUser) -> FireSettingsOut:
    data = body.model_dump(
        exclude_unset=True, exclude={"clear_capital_override", "clear_contribution_override"}
    )
    if body.clear_capital_override:
        data["capital_override"] = None
    if body.clear_contribution_override:
        data["contribution_override"] = None
    return _settings_out(svc.save_settings(db, user.id, {**data, "configured": True}))


def _result(r: F.FireResult) -> FireResultOut:
    return FireResultOut(
        real_return=r.real_return,
        needed=r.needed,
        needed_nominal=r.needed_nominal,
        progress=r.progress,
        required_monthly=r.required_monthly,
        fi_age=r.fi_age,
        coast=r.coast,
        coast_reached=r.coast_reached,
        bridge=r.bridge,
    )


def _plan_out(p: svc.FirePlan) -> FirePlanOut:
    s = p.settings
    capital = Decimal(s["capital_override"]) if s.get("capital_override") else p.auto.capital
    contrib = (
        Decimal(s["contribution_override"])
        if s.get("contribution_override")
        else p.auto.monthly_contribution
    )
    return FirePlanOut(
        settings=_settings_out(s),
        age=p.age,
        capital=capital,
        capital_auto=p.auto.capital,
        monthly_contribution=contrib,
        contribution_auto=p.auto.monthly_contribution,
        cycles_used=p.auto.cycles_used,
        avg_spend=p.auto.avg_spend,
        gain_ratio=p.gain_ratio,
        gross_annual=p.gross_annual,
        tax_annual=p.tax_annual,
        base=_result(p.base),
        pessimistic=_result(p.pessimistic),
        optimistic=_result(p.optimistic),
        projection=[
            ProjectionPointOut(age=a, pessimistic=lo, base=b, optimistic=hi)
            for a, lo, b, hi in p.projection
        ],
        cut_effect=[CutEffectOut(cut=c, fi_age=a) for c, a in p.cut_effect],
    )


@router.get("/fire", response_model=FirePlanOut)
def get_fire(db: DB, user: CurrentUser) -> FirePlanOut:
    return _plan_out(svc.fire_plan(db, user))


@router.post("/fire/simulate", response_model=FirePlanOut)
def simulate_fire(body: FireSettingsIn, db: DB, user: CurrentUser) -> FirePlanOut:
    """¿Y si…? Calcula con otros valores sin guardarlos."""
    overrides = body.model_dump(
        exclude_unset=True, exclude={"clear_capital_override", "clear_contribution_override"}
    )
    return _plan_out(svc.fire_plan(db, user, overrides))


@router.post("/compound", response_model=CompoundOut)
def compound(body: CompoundIn, db: DB, user: CurrentUser) -> CompoundOut:
    rows = C.compound(
        body.initial,
        body.contribution,
        body.annual_rate,
        body.years,
        body.periods,
        body.timing,
        body.convention,
        body.annual_increase,
        body.inflation,
    )
    last = rows[-1]
    tax = net = None
    if body.tax_on_withdrawal:
        p = svc.irpf_params(db, user)
        tax = T.irpf(Decimal(0), last.interest, p).savings
        net = last.total - tax
    rate = C.period_rate(body.annual_rate, body.periods, body.convention)
    n = body.periods
    formula = f"anual / {n}" if body.convention == "nominal" else f"(1 + anual)^(1/{n}) − 1"
    note = f"Tipo por periodo: {formula} = {(rate * 100).quantize(Decimal('0.0001'))} %"
    return CompoundOut(
        rows=[
            CompoundYearOut(
                year=r.year,
                contributed=r.contributed,
                interest=r.interest,
                total=r.total,
                real_total=r.real_total,
            )
            for r in rows
        ],
        total=last.total,
        contributed=last.contributed,
        interest=last.interest,
        real_total=last.real_total,
        tax_if_withdrawn=tax,
        net_if_withdrawn=net,
        convention_note=note,
    )


def _brackets(rows: list[T.Bracket]) -> list[TaxBracketOut]:
    return [TaxBracketOut(lo=b.lo, hi=b.hi, rate=b.rate, amount=b.amount, tax=b.tax) for b in rows]


@router.post("/tax", response_model=TaxOut)
def simulate_tax(body: TaxIn, db: DB, user: CurrentUser) -> TaxOut:
    r = svc.simulate_taxes(
        db, user, body.base_general, body.base_savings, body.net_wealth, body.home_value
    )
    if body.remember_base_general:
        svc.save_base_general(db, user.id, body.base_general)
    p = r.params
    assert p is not None
    bg, bs = max(r.base_general, Decimal(0)), max(r.base_savings, Decimal(0))
    min_quota = T.progressive(min(p.minimum_state, bg), p.general_state) + T.progressive(
        min(p.minimum_regional, bg), p.general_regional
    )
    return TaxOut(
        base_general=r.base_general,
        base_savings=r.base_savings,
        minimum_state=p.minimum_state,
        minimum_regional=p.minimum_regional,
        minimum_quota=min_quota,
        general_brackets=_brackets(T.brackets(bg, p.general_state, p.general_regional)),
        savings_brackets=_brackets(T.brackets(bs, p.savings)),
        average_rate=(r.irpf.total / (bg + bs)) if bg + bs > 0 else None,
        marginal_general=T.marginal(bg, p.general_state, p.general_regional),
        marginal_savings=T.marginal(bs, p.savings),
        year=r.year,
        region=r.region,
        irpf_general_state=r.irpf.general_state,
        irpf_general_regional=r.irpf.general_regional,
        irpf_savings=r.irpf.savings,
        irpf_total=r.irpf.total,
        wealth_taxable=r.wealth.taxable,
        wealth_quota_before_limit=r.wealth.quota_before_limit,
        wealth_quota=r.wealth.quota,
        wealth_joint_limit_applied=r.wealth.joint_limit_applied,
        wealth_obliged=r.wealth_obliged,
        solidarity_warning=r.solidarity_warning,
    )


@router.get("/tax/prefill", response_model=TaxPrefillOut)
def tax_prefill(
    db: DB, user: CurrentUser, year: int = Query(0, ge=0, description="0 = el año en curso")
) -> TaxPrefillOut:
    """Datos para prellenar el simulador: nóminas del año (referencia), la base general que
    guardaste, y ganancias FIFO e ingresos del año (como en el Informe fiscal)."""
    from datetime import date

    p = svc.tax_prefill(db, user, year or date.today().year)
    return TaxPrefillOut(
        year=p.year,
        payroll_net=p.payroll_net,
        base_general=p.base_general,
        realized_gains=p.realized_gains,
        income=p.income,
        base_savings=p.base_savings,
        sales=p.sales,
    )


@router.post("/tax/sell-preview", response_model=SellPreviewOut)
def sell_preview(body: SellPreviewIn, db: DB, user: CurrentUser) -> SellPreviewOut:
    """¿Y si vendo X € hoy? Ganancia FIFO de esa venta (de un activo o de toda la cartera en
    proporción a su peso, D8) y lo que añade a tu IRPF del año."""
    r = svc.sell_preview(db, user, body.amount, body.asset_id, body.base_general, body.base_savings)
    return SellPreviewOut(
        amount=r.amount,
        gain=r.gain,
        tax=r.tax,
        net=r.amount - r.tax,
        available=r.available,
        parts=[
            SalePartOut(
                asset_id=uuid.UUID(x.key),
                name=x.name,
                amount=x.amount,
                units=x.units,
                cost=x.cost,
                gain=x.gain,
            )
            for x in r.parts
        ],
    )


# --- Objetivos ------------------------------------------------------------------------------------
def _goal_out(db: DB, user, g: Goal) -> GoalOut:  # type: ignore[no-untyped-def]
    p = svc.goal_progress(db, user, g)
    return GoalOut(
        id=g.id,
        kind=g.kind,
        name=g.name,
        target_value=g.target_value,  # type: ignore[arg-type]
        target_date=g.target_date,
        current=p.current,
        progress=p.progress,
        on_track=p.on_track,
        detail=p.detail,
    )


@router.get("/goals", response_model=list[GoalOut])
def list_goals(db: DB, user: CurrentUser) -> list[GoalOut]:
    rows = db.scalars(
        select(Goal)
        .where(Goal.user_id == user.id, Goal.archived.is_(False))
        .order_by(Goal.created_at)
    )
    return [_goal_out(db, user, g) for g in rows]


@router.post("/goals", response_model=GoalOut, status_code=status.HTTP_201_CREATED)
def create_goal(body: GoalIn, db: DB, user: CurrentUser) -> GoalOut:
    g = Goal(user_id=user.id, **body.model_dump(exclude={"id"}))
    if body.id:
        g.id = body.id
    db.add(g)
    db.flush()
    return _goal_out(db, user, g)


@router.put("/goals/{goal_id}", response_model=GoalOut)
def update_goal(goal_id: uuid.UUID, body: GoalIn, db: DB, user: CurrentUser) -> GoalOut:
    g = gsvc.get_owned(db, Goal, goal_id, user.id)
    for k, v in body.model_dump(exclude={"id"}).items():
        setattr(g, k, v)
    db.flush()
    return _goal_out(db, user, g)


@router.delete("/goals/{goal_id}", status_code=status.HTTP_204_NO_CONTENT)
def delete_goal(goal_id: uuid.UUID, db: DB, user: CurrentUser) -> Response:
    db.delete(gsvc.get_owned(db, Goal, goal_id, user.id))
    return Response(status_code=status.HTTP_204_NO_CONTENT)


@router.post("/fire/montecarlo", response_model=MonteCarloOut)
def montecarlo(body: FireSettingsIn, db: DB, user: CurrentUser) -> MonteCarloOut:
    """Probabilidad de éxito con rentabilidades aleatorias (2.000 simulaciones)."""
    overrides = body.model_dump(
        exclude_unset=True, exclude={"clear_capital_override", "clear_contribution_override"}
    )
    r, s = svc.montecarlo(db, user, overrides)
    return MonteCarloOut(
        simulations=2000,
        volatility=Decimal(s["volatility"]),
        horizon_age=int(s["horizon_age"]),
        target_age=int(s["target_age"]),
        success=r.success,
        reach=r.reach,
        fi_age_p10=r.fi_age_p10,
        fi_age_p50=r.fi_age_p50,
        fi_age_p90=r.fi_age_p90,
        depletion_median_age=r.depletion_median_age,
        bands=[BandOut(age=a, p10=lo, p50=mid, p90=hi) for a, lo, mid, hi in r.bands],
    )
