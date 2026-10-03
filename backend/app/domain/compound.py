"""Interés compuesto con aportaciones periódicas.

Convención del tipo por periodo (siempre se indica cuál se usa):
  · "nominal": anual / periodos (la que usan muchas calculadoras; capitaliza algo más del anual)
  · "efectivo": (1 + anual)^(1/periodos) − 1 (en un año da exactamente el tipo anual)
"""

from dataclasses import dataclass
from decimal import Decimal, localcontext
from typing import Literal

ZERO = Decimal(0)
ONE = Decimal(1)


def period_rate(
    annual: Decimal, periods: int, convention: Literal["nominal", "efectivo"]
) -> Decimal:
    if convention == "nominal":
        return annual / periods
    with localcontext() as ctx:
        ctx.prec = 34
        return (ONE + annual) ** (ONE / Decimal(periods)) - ONE


@dataclass(frozen=True)
class YearRow:
    year: int
    contributed: Decimal  # acumulado (incluye el capital inicial)
    interest: Decimal  # acumulado
    total: Decimal
    real_total: Decimal  # en euros de hoy


def compound(
    initial: Decimal,
    contribution: Decimal,
    annual_rate: Decimal,
    years: int,
    periods: int = 12,
    timing: Literal["inicio", "final"] = "final",
    convention: Literal["nominal", "efectivo"] = "nominal",
    annual_increase: Decimal = ZERO,
    inflation: Decimal = ZERO,
) -> list[YearRow]:
    """Tabla año a año. `contribution` es la aportación de cada periodo del primer año; crece
    un `annual_increase` cada año."""
    r = period_rate(annual_rate, periods, convention)
    balance, contributed = initial, initial
    rows = []
    for y in range(1, years + 1):
        c = contribution * (ONE + annual_increase) ** (y - 1)
        for _ in range(periods):
            if timing == "inicio":
                balance += c
            balance *= ONE + r
            if timing == "final":
                balance += c
            contributed += c
        real = balance / (ONE + inflation) ** y
        rows.append(YearRow(y, contributed, balance - contributed, balance, real))
    return rows
