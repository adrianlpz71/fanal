"""Hitos del patrimonio: primera fecha en que se cruzó cada umbral y, para el siguiente, una
estimación con la aportación media (sin rentabilidad: no es una previsión)."""

from dataclasses import dataclass
from datetime import date
from decimal import ROUND_CEILING, Decimal

DEFAULT_THRESHOLDS = [Decimal(x) for x in (1000, 2500, 5000, 10000, 25000, 50000, 100000)]
MAX_THRESHOLDS = 20


@dataclass(frozen=True)
class Milestone:
    amount: Decimal
    reached_on: date | None
    before_start: bool  # ya se superaba al empezar la serie: la fecha real es anterior


@dataclass(frozen=True)
class Next:
    amount: Decimal
    months: int | None  # al ritmo de aportación actual; None si no hay ritmo
    eta: date | None  # primer día del mes estimado


def reached(points: list[tuple[date, Decimal]], thresholds: list[Decimal]) -> list[Milestone]:
    out = []
    for t in sorted(set(thresholds)):
        hit = next((p for p in points if p[1] >= t), None)
        if hit is None:
            out.append(Milestone(t, None, False))
        else:
            out.append(Milestone(t, hit[0], hit is points[0]))
    return out


def add_months(d: date, n: int) -> date:
    m = d.month - 1 + n
    return date(d.year + m // 12, m % 12 + 1, 1)


def next_one(net: Decimal, thresholds: list[Decimal], pace: Decimal, today: date) -> Next | None:
    """El primer umbral que aún no se tiene HOY, con cuántos meses faltan al ritmo dado."""
    target = next((t for t in sorted(set(thresholds)) if t > net), None)
    if target is None:
        return None
    if pace <= 0:
        return Next(target, None, None)
    months = int(((target - net) / pace).to_integral_value(rounding=ROUND_CEILING))
    return Next(target, months, add_months(today, months))


def clean(values: list[Decimal]) -> list[Decimal]:
    """Umbrales válidos: positivos, sin repetir, ordenados y como mucho MAX_THRESHOLDS."""
    out = sorted({v.quantize(Decimal("0.01")) for v in values if v > 0})
    if len(out) > MAX_THRESHOLDS:
        raise ValueError(f"Como mucho {MAX_THRESHOLDS} hitos")
    return out
