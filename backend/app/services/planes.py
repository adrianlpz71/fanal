"""Fase 5: fiscalidad, FIRE, interés compuesto y objetivos, conectados con los datos de la app.

Los parámetros fiscales salen SIEMPRE de `tax_parameters` (año más reciente ≤ el pedido, región
del usuario); si faltan, se dice cuál falta en vez de inventarlo.
"""

import uuid
from dataclasses import dataclass, replace
from datetime import date
from decimal import Decimal
from typing import Any

from fastapi import HTTPException, status
from sqlalchemy import select
from sqlalchemy.orm import Session

from app.domain import fire as F
from app.domain import sale as S
from app.domain import tax as T
from app.models import Account, Goal, Movement, PayCycle, User, UserSetting
from app.services import analytics as an
from app.services import gastos as gsvc
from app.services import gastos_extra as ex
from app.services import inversiones as inv

ZERO = Decimal(0)
ONE = Decimal(1)
SETTINGS_KEY = "fire"
# Valores de partida genéricos (editables). Los del usuario se piden en el primer uso de Planes.
DEFAULTS: dict[str, Any] = {
    "configured": False,
    "target_age": 65,
    "monthly_spend": "2000",
    "swr": "0.04",
    "nominal_return": "0.07",
    "inflation": "0.025",
    "costs": "0.002",
    "contribution_growth": "0",
    "pension_monthly": "0",
    "pension_age": 67,
    "include_taxes": True,
    "home_value": "0",  # vivienda habitual (para Patrimonio)
    "volatility": "0.15",  # Monte Carlo: desviación típica anual de la rentabilidad
    "horizon_age": 95,  # Monte Carlo: hasta qué edad tiene que durar el dinero
    "capital_override": None,  # None = automático desde la app
    "contribution_override": None,
}


def missing(what: str) -> HTTPException:
    return HTTPException(status.HTTP_409_CONFLICT, what)


# --- Parámetros fiscales --------------------------------------------------------------------------
def _param(db: Session, user: User, key: str, region: str, on: date | None = None) -> Any:
    p = an.tax_parameter(db, user.id, key, on, region)
    if p is None:
        raise missing(f"Faltan los parámetros fiscales '{key}' ({region}) en Fanal")
    return p.value


def irpf_params(db: Session, user: User, on: date | None = None) -> T.IrpfParams:
    region = user.tax_region or "ES-CN"
    return T.IrpfParams(
        general_state=_param(db, user, "general_escala", "ES", on),
        general_regional=_param(db, user, "general_escala", region, on),
        savings=_param(db, user, "ahorro_escala", "ES", on),
        minimum_state=Decimal(_param(db, user, "minimo_contribuyente", "ES", on)["general"]),
        minimum_regional=Decimal(_param(db, user, "minimo_contribuyente", region, on)["general"]),
    )


def wealth_params(db: Session, user: User, on: date | None = None) -> T.WealthParams:
    region = user.tax_region or "ES-CN"
    try:
        scale = _param(db, user, "patrimonio_escala", region, on)
    except HTTPException:
        scale = _param(db, user, "patrimonio_escala", "ES", on)  # sin escala propia: la estatal
    try:
        minimum = _param(db, user, "patrimonio_minimo_exento", region, on)
    except HTTPException:
        minimum = _param(db, user, "patrimonio_minimo_exento", "ES", on)
    limit = _param(db, user, "patrimonio_limite_conjunto", "ES", on)
    return T.WealthParams(
        scale,
        Decimal(minimum["importe"]),
        Decimal(_param(db, user, "patrimonio_vivienda_exenta", "ES", on)["importe"]),
        Decimal(limit["limite"]),
        Decimal(limit["reduccion_max"]),
    )


# --- Ajustes FIRE ---------------------------------------------------------------------------------
def get_settings(db: Session, user_id: uuid.UUID) -> dict[str, Any]:
    row = db.scalar(
        select(UserSetting).where(UserSetting.user_id == user_id, UserSetting.key == SETTINGS_KEY)
    )
    return {**DEFAULTS, **(row.value if row else {})}


def save_settings(db: Session, user_id: uuid.UUID, values: dict[str, Any]) -> dict[str, Any]:
    row = db.scalar(
        select(UserSetting).where(UserSetting.user_id == user_id, UserSetting.key == SETTINGS_KEY)
    )
    merged = {**DEFAULTS, **(row.value if row else {}), **values}
    clean = {k: (str(v) if isinstance(v, Decimal) else v) for k, v in merged.items()}
    if row:
        row.value = clean
    else:
        db.add(UserSetting(user_id=user_id, key=SETTINGS_KEY, value=clean))
    db.flush()
    return clean


def age_on(birth: date, today: date | None = None) -> Decimal:
    today = today or date.today()
    return (Decimal((today - birth).days) / Decimal("365.25")).quantize(Decimal("0.01"))


@dataclass
class AutoValues:
    capital: Decimal  # inversiones + cuentas de ahorro (sin gastos ni fondo de emergencia)
    capital_cost: Decimal  # lo que te costó (para estimar qué parte de lo retirado es ganancia)
    monthly_contribution: Decimal  # media de lo ahorrado en los últimos ciclos
    cycles_used: int
    avg_spend: Decimal | None  # gasto medio por ciclo (referencia)


def auto_values(db: Session, user_id: uuid.UUID) -> AutoValues:
    p = inv.portfolio(db, user_id)
    savings_accounts = [
        a
        for a in db.scalars(
            select(Account).where(
                Account.user_id == user_id,
                Account.archived.is_(False),
                Account.kind.in_(("ahorro", "inversion")),
            )
        )
    ]
    accounts = sum((gsvc.account_balance(db, a) for a in savings_accounts), ZERO)
    stats = _closed_stats(db, user_id, 13)[-12:]
    # Lo que te sobra de cada ciclo (nómina + otros ingresos − gasto neto): lo que puedes invertir
    surplus = [s.payroll + s.income - s.spend for s in stats]
    contrib = (sum(surplus, ZERO) / len(surplus)) if surplus else ZERO
    spend = (sum((s.spend for s in stats), ZERO) / len(stats)) if stats else None
    return AutoValues(
        p.value + p.pending + accounts,
        p.cost + p.pending + accounts,
        max(contrib, ZERO),
        len(stats),
        spend,
    )


# --- FIRE -----------------------------------------------------------------------------------------
@dataclass
class FirePlan:
    settings: dict[str, Any]
    auto: AutoValues
    age: Decimal
    gain_ratio: Decimal | None
    base: F.FireResult
    pessimistic: F.FireResult
    optimistic: F.FireResult
    projection: list[tuple[Decimal, Decimal, Decimal, Decimal]]  # edad, pesimista, base, optimista
    gross_annual: Decimal  # lo que hay que retirar al año (bruto) para el gasto neto deseado
    tax_annual: Decimal
    cut_effect: list[tuple[Decimal, Decimal | None]]  # (recorte €/mes, edad FI)


def fire_plan(db: Session, user: User, overrides: dict[str, Any] | None = None) -> FirePlan:
    s = {**get_settings(db, user.id), **(overrides or {})}
    if user.birth_date is None:
        raise missing("Falta tu fecha de nacimiento (Más → Perfil)")
    auto = auto_values(db, user.id)
    capital = Decimal(s["capital_override"]) if s.get("capital_override") else auto.capital
    contribution = (
        Decimal(s["contribution_override"])
        if s.get("contribution_override")
        else auto.monthly_contribution
    )
    age = age_on(user.birth_date)
    gain_ratio: Decimal | None = None
    gross_fn = None
    if s.get("include_taxes"):
        params = irpf_params(db, user)
        # Qué parte de lo que retires será ganancia: la ganancia esperada al llegar al objetivo
        # (estimación conservadora: todo lo que no hayas aportado tú)
        target = F.FireInput(
            age,
            Decimal(s["target_age"]),
            Decimal(s["monthly_spend"]),
            Decimal(s["swr"]),
            Decimal(s["nominal_return"]),
            Decimal(s["inflation"]),
        )
        # Suponiendo que aportas lo necesario para llegar (sin impuestos) o lo que ya aportas
        needed = F.needed_capital(target)
        months = F.months_to(target)
        plan_in = replace(
            target, capital=capital, monthly_contribution=contribution, costs=Decimal(s["costs"])
        )
        monthly = max(contribution, F.required_contribution(plan_in))
        put_in = auto.capital_cost + monthly * months
        gain_ratio = min(max(ONE - put_in / needed, Decimal("0.1")), ONE) if needed else ONE

        def gross_fn(net: Decimal, g: Decimal = gain_ratio, p: T.IrpfParams = params) -> Decimal:
            return T.gross_up(net, g, p)[0]

    base_in = F.FireInput(
        age=age,
        target_age=Decimal(s["target_age"]),
        monthly_spend=Decimal(s["monthly_spend"]),
        swr=Decimal(s["swr"]),
        nominal_return=Decimal(s["nominal_return"]),
        inflation=Decimal(s["inflation"]),
        costs=Decimal(s["costs"]),
        capital=capital,
        monthly_contribution=contribution,
        contribution_growth=Decimal(s["contribution_growth"]),
        pension_monthly=Decimal(s["pension_monthly"]),
        pension_age=Decimal(s["pension_age"]),
        gross_up=gross_fn,
    )
    pess = replace(base_in, nominal_return=base_in.nominal_return - Decimal("0.02"))
    opt = replace(base_in, nominal_return=base_in.nominal_return + Decimal("0.02"))
    base_res = F.calculate(base_in)
    # La gráfica llega hasta la mayor de (edad objetivo, edad estimada) + 5
    reach = base_res.fi_age + 5 if base_res.fi_age is not None else Decimal(0)
    until = min(max(base_in.target_age + 10, age + 20, reach), Decimal(100))
    proj_b = F.yearly_projection(base_in, until)
    proj_p = dict(F.yearly_projection(pess, until))
    proj_o = dict(F.yearly_projection(opt, until))
    projection = [(a, proj_p[a], c, proj_o[a]) for a, c in proj_b]
    annual_net = base_in.monthly_spend * 12
    gross_annual = gross_fn(annual_net) if gross_fn else annual_net
    cuts = []
    for cut in (Decimal(50), Decimal(100), Decimal(200)):
        if cut < base_in.monthly_spend:
            cuts.append(
                (
                    cut,
                    F.fi_age(
                        replace(
                            base_in,
                            monthly_spend=base_in.monthly_spend - cut,
                            monthly_contribution=contribution + cut,
                        )
                    ),
                )
            )
    return FirePlan(
        s,
        auto,
        age,
        gain_ratio,
        base_res,
        F.calculate(pess),
        F.calculate(opt),
        projection,
        gross_annual,
        gross_annual - annual_net,
        cuts,
    )


# --- Simulador fiscal -----------------------------------------------------------------------------
@dataclass
class TaxSimulation:
    year: int
    region: str
    irpf: T.IrpfResult
    wealth: T.WealthResult
    wealth_obliged: bool  # obligación de declarar IP (cuota > 0 o bienes > 2 M)
    solidarity_warning: bool  # patrimonio neto > 3 M: revisar el impuesto de grandes fortunas
    params: T.IrpfParams | None = None  # para enseñar el cálculo paso a paso
    base_general: Decimal = ZERO
    base_savings: Decimal = ZERO


def simulate_taxes(
    db: Session,
    user: User,
    base_general: Decimal,
    base_savings: Decimal,
    net_wealth: Decimal | None = None,
    home: Decimal | None = None,
) -> TaxSimulation:
    p = irpf_params(db, user)
    r = T.irpf(base_general, base_savings, p)
    nw = an.networth(db, user.id).total if net_wealth is None else net_wealth
    home_v = Decimal(get_settings(db, user.id)["home_value"]) if home is None else home
    w = T.wealth_tax(
        nw + home_v, home_v, wealth_params(db, user), r.total, base_general + base_savings
    )
    year_param = an.tax_parameter(db, user.id, "general_escala", None, "ES")
    return TaxSimulation(
        year_param.year if year_param else date.today().year,
        user.tax_region or "ES-CN",
        r,
        w,
        w.quota > 0 or nw + home_v > Decimal(2_000_000),
        nw > Decimal(3_000_000),
        p,
        base_general,
        base_savings,
    )


# --- Simulador de impuestos: prellenado y "¿y si vendo?" ---------------------------------------
TAX_KEY = "tax_simulator"


def tax_settings(db: Session, user_id: uuid.UUID) -> dict[str, Any]:
    row = db.scalar(
        select(UserSetting).where(UserSetting.user_id == user_id, UserSetting.key == TAX_KEY)
    )
    return dict(row.value) if row else {}


def save_base_general(db: Session, user_id: uuid.UUID, base: Decimal) -> None:
    """La base liquidable general la escribe el usuario (no se deduce de la nómina neta)."""
    row = db.scalar(
        select(UserSetting).where(UserSetting.user_id == user_id, UserSetting.key == TAX_KEY)
    )
    value = {**(row.value if row else {}), "base_general": str(base)}
    if row is None:
        db.add(UserSetting(user_id=user_id, key=TAX_KEY, value=value))
    else:
        row.value = value
    db.flush()


@dataclass
class TaxPrefill:
    year: int
    payroll_net: Decimal  # nóminas cobradas en el año (de los ciclos): solo como referencia
    base_general: Decimal | None  # la que guardó el usuario
    realized_gains: Decimal  # ganancias y pérdidas FIFO de las ventas del año (Informe fiscal)
    income: Decimal  # dividendos, intereses y recompensas del año
    sales: int

    @property
    def base_savings(self) -> Decimal:
        return self.realized_gains + self.income


def tax_prefill(db: Session, user: User, year: int) -> TaxPrefill:
    from app.services import export

    starts = {
        c.id: c.start_date for c in db.scalars(select(PayCycle).where(PayCycle.user_id == user.id))
    }
    payroll = ZERO
    for m in db.scalars(
        select(Movement).where(
            Movement.user_id == user.id, Movement.status == "posted", Movement.kind == "nomina"
        )
    ):
        on = m.date or starts.get(m.cycle_id)  # type: ignore[arg-type]
        if on is not None and on.year == year:
            payroll += m.amount
    rep = export.tax_report(db, user.id, year)
    saved = tax_settings(db, user.id).get("base_general")
    return TaxPrefill(
        year,
        payroll,
        Decimal(saved) if saved is not None else None,
        rep.gains_total,
        rep.income_total,
        len(rep.sales),
    )


@dataclass
class SellPreview:
    parts: list[S.SalePart]
    available: Decimal
    tax_before: Decimal
    tax_after: Decimal

    @property
    def amount(self) -> Decimal:
        return sum((p.amount for p in self.parts), ZERO)

    @property
    def gain(self) -> Decimal:
        return sum((p.gain for p in self.parts), ZERO)

    @property
    def tax(self) -> Decimal:
        """Lo que esa venta añade a tu IRPF del año (no el impuesto de toda la base)."""
        return self.tax_after - self.tax_before


def sell_preview(
    db: Session,
    user: User,
    amount: Decimal,
    asset_id: uuid.UUID | None,
    base_general: Decimal,
    base_savings: Decimal,
) -> SellPreview:
    holdings = []
    for r in inv.portfolio(db, user.id).rows:
        if asset_id is not None and r.asset.id != asset_id:
            continue
        if r.price is None or r.position.units <= 0:
            continue
        lots = tuple(r.position.lots)
        holdings.append(S.Holding(str(r.asset.id), r.asset.name, r.position.units, r.price, lots))
    if not holdings:
        raise HTTPException(status.HTTP_422_UNPROCESSABLE_ENTITY, "No hay nada que vender ahí")
    try:
        parts = S.preview(holdings, amount)
    except ValueError as e:
        raise HTTPException(status.HTTP_422_UNPROCESSABLE_ENTITY, str(e)) from e
    p = irpf_params(db, user)
    gain = sum((x.gain for x in parts), ZERO)
    before = T.irpf(base_general, base_savings, p).total
    after = T.irpf(base_general, base_savings + gain, p).total
    available = sum((h.value for h in holdings), ZERO)
    return SellPreview(parts, available.quantize(Decimal("0.01")), before, after)


# --- Objetivos ------------------------------------------------------------------------------------
@dataclass
class GoalProgress:
    goal: Goal
    current: Decimal | None
    target: Decimal | None
    progress: Decimal | None  # 0..1 (o más)
    on_track: bool | None
    detail: str


def goal_progress(db: Session, user: User, g: Goal) -> GoalProgress:
    t = g.target_value
    if g.kind == "patrimonio":
        cur = an.networth(db, user.id).total
        return GoalProgress(g, cur, t, (cur / t) if t else None, None, "Patrimonio neto actual")
    if g.kind == "fondo_emergencia":
        e = inv.emergency(db, user.id)
        if e is None:
            return GoalProgress(
                g, None, t, None, None, "Configura el fondo de emergencia en Gastos"
            )
        target = t or e.target
        return GoalProgress(
            g,
            e.current,
            target,
            e.current / target if target else None,
            None,
            "Saldo de la cuenta refugio",
        )
    if g.kind == "cartera_en_fecha":
        p = inv.portfolio(db, user.id)
        return GoalProgress(
            g, p.value, t, (p.value / t) if t else None, None, "Valor de la cartera"
        )
    if g.kind == "fijos_max":
        stats = _closed_stats(db, user.id, 4)
        cur = (sum((s.fixed + s.installments for s in stats), ZERO) / len(stats)) if stats else None
        ok = (cur <= t) if cur is not None and t is not None else None
        prog = (t / cur) if cur and t else None
        return GoalProgress(g, cur, t, prog, ok, "Fijos + cuotas, media de los últimos ciclos")
    if g.kind == "tasa_ahorro_min":
        stats = _closed_stats(db, user.id, 7)
        rates = [s.savings_rate for s in stats if s.savings_rate is not None]
        cur = (sum(rates, ZERO) / len(rates)) if rates else None
        ok = (cur >= t) if cur is not None and t is not None else None
        return GoalProgress(
            g,
            cur,
            t,
            (cur / t) if cur is not None and t else None,
            ok,
            "Tasa de ahorro media de los últimos ciclos",
        )
    # edad_fi: la edad a la que llegarías al ritmo actual frente a la objetivo
    try:
        plan = fire_plan(db, user, {"target_age": int(t)} if t else None)
    except HTTPException as e:
        return GoalProgress(g, None, t, None, None, str(e.detail))
    fi = plan.base.fi_age
    ok = (fi <= t) if fi is not None and t is not None else False
    return GoalProgress(g, fi, t, plan.base.progress, ok, "Edad a la que llegarías al ritmo actual")


def _closed_stats(db: Session, user_id: uuid.UUID, n: int) -> list[ex.CycleStats]:
    """Ciclos cerrados (sin el módulo de gastos configurado no hay ninguno)."""
    try:
        return [s for s in ex.cycles_stats(db, user_id, n) if s.status == "closed"]
    except HTTPException:
        return []


# --- Monte Carlo ----------------------------------------------------------------------------------
def montecarlo(db: Session, user: User, overrides: dict[str, Any] | None = None,
               simulations: int = 2000) -> tuple[Any, dict[str, Any]]:  # fmt: skip
    from app.domain import montecarlo as mc

    plan = fire_plan(db, user, overrides)
    s = plan.settings
    capital = Decimal(s["capital_override"]) if s.get("capital_override") else plan.auto.capital
    contribution = (Decimal(s["contribution_override"]) if s.get("contribution_override")
                    else plan.auto.monthly_contribution)  # fmt: skip
    spend, pension = Decimal(s["monthly_spend"]) * 12, Decimal(s["pension_monthly"]) * 12
    gross_full = plan.gross_annual
    if pension > 0 and s.get("include_taxes"):
        params = irpf_params(db, user)
        rest = T.gross_up(max(spend - pension, ZERO), plan.gain_ratio or ONE, params)[0]
        pension_gross = gross_full - rest
    else:
        pension_gross = min(pension, gross_full)
    inp = mc.MonteCarloInput(
        age=int(plan.age), target_age=int(s["target_age"]), horizon_age=int(s["horizon_age"]),
        capital=capital, annual_contribution=contribution * 12,
        contribution_growth=Decimal(s["contribution_growth"]), annual_spend_gross=gross_full,
        annual_pension_gross=pension_gross, pension_age=int(s["pension_age"]),
        needed=plan.base.needed, mean_real_return=plan.base.real_return,
        volatility=Decimal(s["volatility"]), simulations=simulations,
        seed=uuid.UUID(str(user.id)).int % 1_000_003,
    )  # fmt: skip
    return mc.simulate(inp), s
