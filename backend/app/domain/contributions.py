"""Historial de aportaciones: cuánto dinero nuevo metes cada mes en inversiones y en ahorro.

Solo cuenta como aportación el dinero **nuevo**: compras y aportaciones periódicas a inversiones, y
traspasos que entran en una cuenta de ahorro o refugio. Las ventas y retiradas restan aparte, los
traspasos entre fondos no son dinero nuevo y la posición inicial es un saldo de partida (no se
sabe cuándo se aportó).

- Ritmo mensual = lo aportado en los 12 meses que acaban en el mes actual, entre 12.
- Racha = meses seguidos con alguna aportación, hasta el mes actual (o el anterior, si este mes
  aún no has aportado: la racha no se rompe hasta que acaba el mes).
"""

from dataclasses import dataclass
from datetime import date
from decimal import Decimal

ZERO = Decimal(0)
TWELVE = Decimal(12)

# Tipo de cada línea del historial
APORTACION = "aportacion"
RETIRADA = "retirada"
TRASPASO = "traspaso"
PARTIDA = "partida"


@dataclass(frozen=True)
class Flow:
    on: date
    amount: Decimal  # siempre positivo; el tipo dice si entra o sale
    type: str  # aportacion | retirada | traspaso | partida
    destination: str  # clave del destino (activo o cuenta)


@dataclass(frozen=True)
class Totals:
    this_month: Decimal
    this_year: Decimal
    total: Decimal
    withdrawn: Decimal
    starting: Decimal
    pace: Decimal  # media mensual de los últimos 12 meses
    streak: int  # meses seguidos aportando


def ym(d: date) -> tuple[int, int]:
    return (d.year, d.month)


def _prev(y: int, m: int) -> tuple[int, int]:
    return (y - 1, 12) if m == 1 else (y, m - 1)


def months_back(today: date, n: int) -> list[tuple[int, int]]:
    """Los `n` meses que acaban en el mes de `today` (del más antiguo al actual)."""
    out = [ym(today)]
    while len(out) < n:
        out.append(_prev(*out[-1]))
    return list(reversed(out))


def by_month(flows: list[Flow]) -> dict[tuple[int, int], dict[str, Decimal]]:
    """Aportaciones por mes y destino (solo dinero nuevo)."""
    out: dict[tuple[int, int], dict[str, Decimal]] = {}
    for f in flows:
        if f.type != APORTACION:
            continue
        m = out.setdefault(ym(f.on), {})
        m[f.destination] = m.get(f.destination, ZERO) + f.amount
    return out


def streak(months_with: set[tuple[int, int]], today: date) -> int:
    cur = ym(today)
    if cur not in months_with:
        cur = _prev(*cur)  # este mes aún puede llegar la aportación
    n = 0
    while cur in months_with:
        n += 1
        cur = _prev(*cur)
    return n


def totals(flows: list[Flow], today: date) -> Totals:
    contrib = [f for f in flows if f.type == APORTACION]
    last12 = set(months_back(today, 12))
    return Totals(
        this_month=sum((f.amount for f in contrib if ym(f.on) == ym(today)), ZERO),
        this_year=sum((f.amount for f in contrib if f.on.year == today.year), ZERO),
        total=sum((f.amount for f in contrib), ZERO),
        withdrawn=sum((f.amount for f in flows if f.type == RETIRADA), ZERO),
        starting=sum((f.amount for f in flows if f.type == PARTIDA), ZERO),
        pace=(sum((f.amount for f in contrib if ym(f.on) in last12), ZERO) / TWELVE).quantize(
            Decimal("0.01")
        ),
        streak=streak({ym(f.on) for f in contrib if f.amount > 0}, today),
    )
