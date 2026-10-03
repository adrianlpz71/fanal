"""Monte Carlo para FIRE: miles de "vidas posibles" con rentabilidades anuales aleatorias.

Modelo (en euros de hoy, como el resto de la calculadora):
  · Cada año la rentabilidad real se sortea con una lognormal: ln(1 + r) ~ N(μ, σ), calibrada
    para que la media sea la rentabilidad real esperada y la volatilidad σ_r la indicada.
  · Acumulación hasta la edad objetivo (aportación anual, que crece un % real) y después
    retirada anual del gasto bruto (menos la pensión desde su edad) hasta el horizonte.
  · Éxito = el dinero no se acaba antes del horizonte retirándote a la edad objetivo.

Los números aleatorios son float (es un sorteo, no dinero); el capital se lleva en Decimal.
Semilla fija por usuario: el mismo plan da siempre el mismo resultado.
"""

import math
import random
from collections.abc import Callable
from dataclasses import dataclass
from decimal import Decimal

ZERO = Decimal(0)
ONE = Decimal(1)
Q = Decimal("0.000001")


@dataclass(frozen=True)
class MonteCarloInput:
    age: int  # edad actual (años enteros)
    target_age: int
    horizon_age: int  # hasta cuándo tiene que durar el dinero
    capital: Decimal
    annual_contribution: Decimal
    contribution_growth: Decimal
    annual_spend_gross: Decimal  # lo que hay que retirar al año (bruto)
    annual_pension_gross: Decimal  # lo que la pensión cubre (en bruto) desde su edad
    pension_age: int
    needed: Decimal  # capital necesario a la edad objetivo (cálculo determinista)
    mean_real_return: Decimal
    volatility: Decimal  # desviación típica anual de la rentabilidad
    simulations: int = 2000
    seed: int = 42


@dataclass(frozen=True)
class MonteCarloResult:
    success: Decimal  # probabilidad de no quedarse sin dinero hasta el horizonte
    reach: Decimal  # probabilidad de tener el capital necesario a la edad objetivo
    fi_age_p10: int | None  # edad a la que llegarías al necesario (percentiles)
    fi_age_p50: int | None
    fi_age_p90: int | None
    bands: list[tuple[int, Decimal, Decimal, Decimal]]  # (edad, p10, p50, p90) del capital
    depletion_median_age: int | None  # en los casos de fracaso, edad típica a la que se acaba


def _lognormal_params(mean: float, vol: float) -> tuple[float, float]:
    m = 1 + mean
    s2 = math.log(1 + (vol * vol) / (m * m))
    return math.log(m) - s2 / 2, math.sqrt(s2)


def _percentile(sorted_vals: list, p: float):
    if not sorted_vals:
        return None
    k = min(len(sorted_vals) - 1, max(0, round(p * (len(sorted_vals) - 1))))
    return sorted_vals[k]


def simulate(
    i: MonteCarloInput, rng_factory: Callable[[int], random.Random] = random.Random
) -> MonteCarloResult:
    rng = rng_factory(i.seed)
    mu, sigma = _lognormal_params(float(i.mean_real_return), float(i.volatility))
    years = max(i.horizon_age - i.age, 1)
    paths: list[list[Decimal]] = []
    successes = reaches = 0
    fi_ages: list[int] = []
    depletions: list[int] = []
    for _ in range(i.simulations):
        returns = [Decimal(math.exp(rng.gauss(mu, sigma)) - 1).quantize(Q) for _ in range(years)]
        # A) Solo acumulando: ¿a qué edad tendrías el capital necesario?
        cap = i.capital
        for y, r in enumerate(returns):
            cap = cap * (ONE + r) + i.annual_contribution * (ONE + i.contribution_growth) ** y
            if cap >= i.needed:
                fi_ages.append(i.age + y + 1)
                break
        # B) Retirándote a la edad objetivo: ¿te dura el dinero hasta el horizonte?
        cap = i.capital
        path = [cap]
        depleted_at = None
        for y, r in enumerate(returns):
            age = i.age + y
            cap *= ONE + r
            if age < i.target_age:
                cap += i.annual_contribution * (ONE + i.contribution_growth) ** y
            else:
                pension = i.annual_pension_gross if age >= i.pension_age else ZERO
                cap -= max(i.annual_spend_gross - pension, ZERO)
            if age + 1 == i.target_age and cap >= i.needed:
                reaches += 1
            if cap <= 0 and depleted_at is None:
                depleted_at = age + 1
            cap = max(cap, ZERO)
            path.append(cap)
        if depleted_at is None:
            successes += 1
        else:
            depletions.append(depleted_at)
        paths.append(path)
    n = Decimal(i.simulations)
    bands = []
    for y in range(years + 1):
        col = sorted(p[y] for p in paths)
        bands.append(
            (i.age + y, _percentile(col, 0.1), _percentile(col, 0.5), _percentile(col, 0.9))
        )
    fi_sorted = sorted(fi_ages)

    def age_pct(p: float) -> int | None:
        # Sobre TODAS las simulaciones: las que nunca llegan cuentan como "más tarde que todo"
        k = round(p * (i.simulations - 1))
        return fi_sorted[k] if k < len(fi_sorted) else None

    return MonteCarloResult(
        Decimal(successes) / n,
        Decimal(reaches) / n,
        age_pct(0.1),
        age_pct(0.5),
        age_pct(0.9),
        bands,
        _percentile(sorted(depletions), 0.5),
    )
