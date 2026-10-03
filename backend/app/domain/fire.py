"""Calculadora de independencia financiera (FIRE). Todo en EUROS DE HOY (términos reales).

· Rentabilidad real = (1 + nominal − costes) / (1 + inflación) − 1
· Capital necesario al retirarte = gasto anual bruto (lo que hay que retirar para que te quede
  el neto deseado, tras impuestos) / tasa de retiro segura (SWR). Con pensión pública: solo la
  parte que la pensión no cubre va a perpetuidad, y el "puente" (lo que cubrirá la pensión) se
  financia como una renta hasta la edad de la pensión.
· Simulación mensual: el capital rinde la real mensual equivalente y al final de cada mes entra
  la aportación (que crece un % real cada año).
"""

from collections.abc import Callable
from dataclasses import dataclass, field, replace
from decimal import Decimal, localcontext

ZERO = Decimal(0)
ONE = Decimal(1)
TWELVE = Decimal(12)
MAX_AGE = Decimal(100)

GrossUp = Callable[[Decimal], Decimal]  # neto anual → bruto anual


@dataclass(frozen=True)
class FireInput:
    age: Decimal  # edad actual (con decimales)
    target_age: Decimal
    monthly_spend: Decimal  # neto deseado, euros de hoy
    swr: Decimal
    nominal_return: Decimal
    inflation: Decimal
    costs: Decimal = ZERO  # TER y comisiones anuales
    capital: Decimal = ZERO
    monthly_contribution: Decimal = ZERO
    contribution_growth: Decimal = ZERO  # real, anual
    pension_monthly: Decimal = ZERO  # neta, euros de hoy
    pension_age: Decimal = Decimal(67)
    gross_up: GrossUp | None = field(default=None, compare=False)


def real_return(i: FireInput) -> Decimal:
    return (ONE + i.nominal_return - i.costs) / (ONE + i.inflation) - ONE


def _monthly(r: Decimal) -> Decimal:
    with localcontext() as ctx:
        ctx.prec = 34
        return (ONE + r) ** (ONE / TWELVE) - ONE


def _gross(i: FireInput, annual_net: Decimal) -> Decimal:
    return i.gross_up(annual_net) if i.gross_up and annual_net > 0 else annual_net


def needed_capital(i: FireInput, retire_age: Decimal | None = None) -> Decimal:
    """Capital (euros de hoy) que hace falta al retirarte a `retire_age`."""
    retire_age = i.target_age if retire_age is None else retire_age
    full = _gross(i, i.monthly_spend * TWELVE)
    if i.pension_monthly <= 0:
        return full / i.swr
    after = _gross(i, max(i.monthly_spend - i.pension_monthly, ZERO) * TWELVE)
    perpetual = after / i.swr
    years = max(i.pension_age - retire_age, ZERO)
    if years == 0:
        return perpetual
    gap = full - after  # lo que cubrirá la pensión, a financiar hasta que llegue
    r = real_return(i)
    if abs(r) < Decimal("1E-9"):
        return perpetual + gap * years
    with localcontext() as ctx:
        ctx.prec = 34
        bridge = gap * (ONE - (ONE + r) ** (-years)) / r
    return perpetual + bridge


def project(i: FireInput, months: int) -> Decimal:
    rm = _monthly(real_return(i))
    cap = i.capital
    for m in range(months):
        cap = cap * (ONE + rm) + i.monthly_contribution * (ONE + i.contribution_growth) ** (m // 12)
    return cap


def fi_age(i: FireInput) -> Decimal | None:
    """Edad a la que llegarías al ritmo actual (None si no llegas antes de los 100)."""
    rm = _monthly(real_return(i))
    cap, age, m = i.capital, i.age, 0
    while age <= MAX_AGE:
        if cap >= needed_capital(i, age):
            return age
        cap = cap * (ONE + rm) + i.monthly_contribution * (ONE + i.contribution_growth) ** (m // 12)
        m += 1
        age = i.age + Decimal(m) / TWELVE
    return None


def months_to(i: FireInput) -> int:
    return max(int(((i.target_age - i.age) * TWELVE).to_integral_value()), 0)


def required_contribution(i: FireInput) -> Decimal:
    """Aportación mensual (euros de hoy) para llegar justo a la edad objetivo."""
    target, n = needed_capital(i), months_to(i)
    if project(replace(i, monthly_contribution=ZERO), n) >= target:
        return ZERO
    lo, hi = ZERO, max(target, ONE)
    for _ in range(80):
        mid = (lo + hi) / 2
        if project(replace(i, monthly_contribution=mid), n) >= target:
            hi = mid
        else:
            lo = mid
    return hi


def coast_number(i: FireInput) -> Decimal:
    """Capital que, sin aportar nada más, llega al necesario a la edad objetivo."""
    rm = _monthly(real_return(i))
    with localcontext() as ctx:
        ctx.prec = 34
        return needed_capital(i) / (ONE + rm) ** months_to(i)


@dataclass(frozen=True)
class FireResult:
    real_return: Decimal
    needed: Decimal  # euros de hoy
    needed_nominal: Decimal  # en euros de la fecha objetivo
    progress: Decimal
    required_monthly: Decimal
    fi_age: Decimal | None
    coast: Decimal
    coast_reached: bool
    bridge: Decimal  # parte del necesario que es "puente" hasta la pensión


def calculate(i: FireInput) -> FireResult:
    needed = needed_capital(i)
    perpetual_only = needed_capital(replace(i, pension_age=i.target_age))
    years = i.target_age - i.age
    with localcontext() as ctx:
        ctx.prec = 34
        nominal = needed * (ONE + i.inflation) ** max(years, ZERO)
    coast = coast_number(i)
    return FireResult(
        real_return(i), needed, nominal, (i.capital / needed) if needed else ONE,
        required_contribution(i), fi_age(i), coast, i.capital >= coast,
        needed - perpetual_only if i.pension_monthly > 0 else ZERO,
    )  # fmt: skip


def yearly_projection(i: FireInput, until_age: Decimal) -> list[tuple[Decimal, Decimal]]:
    """(edad, capital en euros de hoy) al final de cada año."""
    out = []
    years = int((until_age - i.age).to_integral_value())
    for y in range(0, max(years, 0) + 1):
        out.append((i.age + y, project(i, y * 12)))
    return out
