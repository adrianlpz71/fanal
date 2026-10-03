"""¿Y si vendo X € hoy? Ganancia de la venta con el FIFO real de los lotes (D8).

Se vende de un activo o de toda la cartera en proporción a lo que pesa cada uno. Las
participaciones salen de los lotes más antiguos primero, como exige Hacienda para valores
homogéneos; la ganancia es lo que recibes menos el coste de esas participaciones.
"""

from dataclasses import dataclass
from decimal import Decimal

from app.domain.allocation import largest_remainder
from app.domain.portfolio import Lot

ZERO = Decimal(0)
Q10 = Decimal("1E-10")


@dataclass(frozen=True)
class Holding:
    key: str
    name: str
    units: Decimal
    price: Decimal
    lots: tuple[Lot, ...]

    @property
    def value(self) -> Decimal:
        return self.units * self.price


@dataclass(frozen=True)
class SalePart:
    key: str
    name: str
    amount: Decimal
    units: Decimal
    cost: Decimal

    @property
    def gain(self) -> Decimal:
        return self.amount - self.cost


def fifo_cost(lots: tuple[Lot, ...], units: Decimal) -> Decimal:
    """Coste de vender `units` consumiendo primero los lotes más antiguos."""
    cost, left = ZERO, units
    for lot in sorted(lots, key=lambda x: x.acquired):
        if left <= 0:
            break
        if lot.units <= 0:
            continue
        take = min(left, lot.units)
        cost += lot.cost * take / lot.units
        left -= take
    return cost


def preview(holdings: list[Holding], amount: Decimal) -> list[SalePart]:
    """Reparte `amount` entre los activos (por su valor) y calcula el coste FIFO de cada parte."""
    live = [h for h in holdings if h.units > 0 and h.price > 0]
    total = sum((h.value for h in live), ZERO)
    if amount <= 0:
        raise ValueError("El importe tiene que ser mayor que 0")
    if amount > total.quantize(Decimal("0.01")):
        raise ValueError(f"Solo tienes {total.quantize(Decimal('0.01'))} € para vender")
    split = largest_remainder({h.key: amount * h.value / total for h in live}, amount)
    out = []
    for h in live:
        part = split[h.key]
        if part <= 0:
            continue
        units = min((part / h.price).quantize(Q10), h.units)
        cost = fifo_cost(h.lots, units).quantize(Decimal("0.01"))
        out.append(SalePart(h.key, h.name, part, units, cost))
    return out
