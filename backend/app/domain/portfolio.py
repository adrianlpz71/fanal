"""Posición de un activo a partir de sus transacciones (fuente única de verdad).

Dos vistas a la vez:
  · PMP (precio medio ponderado), la que enseñan los brokers (MyInvestor).
  · Lotes FIFO, la que exige Hacienda para valores homogéneos: al vender se consumen primero las
    participaciones más antiguas. La ganancia fiscal sale de aquí, no del PMP.

Las correcciones manuales (participaciones y/o PMP) reinician el PMP en su fecha; los lotes FIFO
se reescalan proporcionalmente conservando sus fechas.
"""

from dataclasses import dataclass, field
from datetime import date
from decimal import ROUND_DOWN, Decimal

ZERO = Decimal(0)
Q10 = Decimal("1E-10")


def qunits(x: Decimal, decimals: int) -> Decimal:
    """Participaciones truncadas a los decimales de la plataforma (las gestoras redondean hacia
    abajo)."""
    return x.quantize(Decimal(1).scaleb(-decimals), rounding=ROUND_DOWN)


@dataclass
class Lot:
    acquired: date
    units: Decimal
    cost: Decimal  # coste total de esas participaciones (incluye comisiones de compra)


@dataclass(frozen=True)
class Tx:
    # posicion_inicial | compra | aportacion_periodica | venta | traspaso_salida |
    # traspaso_entrada | recompensa | correccion | dividendo | interes | comision
    kind: str
    on: date
    units: Decimal = ZERO  # positivas
    amount: Decimal = ZERO  # € positivos: pagado (compras) o recibido (ventas, dividendos)
    fee: Decimal = ZERO
    avg_cost: Decimal | None = None  # posicion_inicial / correccion: PMP indicado
    lots: tuple[Lot, ...] = ()  # traspaso_entrada: lotes heredados del fondo de origen


@dataclass
class Realized:
    on: date
    units: Decimal
    proceeds: Decimal
    cost_fifo: Decimal
    cost_pmp: Decimal

    @property
    def gain_fifo(self) -> Decimal:
        return self.proceeds - self.cost_fifo

    @property
    def gain_pmp(self) -> Decimal:
        return self.proceeds - self.cost_pmp


@dataclass
class Position:
    units: Decimal = ZERO
    avg_cost: Decimal = ZERO  # PMP
    lots: list[Lot] = field(default_factory=list)
    realized: list[Realized] = field(default_factory=list)
    income: Decimal = ZERO  # dividendos e intereses cobrados
    fees: Decimal = ZERO  # comisiones sueltas (no capitalizadas)
    first_date: date | None = None

    @property
    def cost(self) -> Decimal:
        """Coste según PMP (lo que enseña el broker)."""
        return self.units * self.avg_cost

    @property
    def cost_fifo(self) -> Decimal:
        return sum((lot.cost for lot in self.lots), ZERO)


def _take_fifo(lots: list[Lot], units: Decimal) -> tuple[list[Lot], Decimal]:
    """Saca `units` de los lotes más antiguos. Devuelve (lotes extraídos, coste extraído)."""
    out: list[Lot] = []
    remaining = units
    cost = ZERO
    while remaining > 0 and lots:
        lot = lots[0]
        if lot.units <= remaining:
            out.append(lot)
            cost += lot.cost
            remaining -= lot.units
            lots.pop(0)
        else:
            part_cost = (lot.cost * remaining / lot.units).quantize(Q10)
            out.append(Lot(lot.acquired, remaining, part_cost))
            lot.units -= remaining
            lot.cost -= part_cost
            cost += part_cost
            remaining = ZERO
    if remaining > Decimal("1E-8"):
        raise ValueError(f"Se venden más participaciones de las que hay (faltan {remaining})")
    return out, cost


def replay(txs: list[Tx]) -> Position:
    p = Position()
    for t in sorted(txs, key=lambda x: x.on):
        if p.first_date is None and t.kind in ("posicion_inicial", "compra", "aportacion_periodica",
                                               "traspaso_entrada", "recompensa"):  # fmt: skip
            p.first_date = t.on
        if t.kind == "posicion_inicial":
            assert t.avg_cost is not None
            cost = t.units * t.avg_cost
            p.lots.append(Lot(t.on, t.units, cost))
            total_cost = p.cost + cost
            p.units += t.units
            p.avg_cost = (total_cost / p.units).quantize(Q10) if p.units else ZERO
        elif t.kind in ("compra", "aportacion_periodica", "recompensa"):
            cost = t.amount + t.fee
            p.lots.append(Lot(t.on, t.units, cost))
            total_cost = p.cost + cost
            p.units += t.units
            p.avg_cost = (total_cost / p.units).quantize(Q10) if p.units else ZERO
        elif t.kind == "traspaso_entrada":
            # Hereda coste y fechas de adquisición (en España el traspaso no tributa)
            inherited = list(t.lots) or [Lot(t.on, t.units, t.amount)]
            # Las participaciones son las del fondo destino (otro VL): se reparten entre los
            # lotes heredados en proporción, conservando el coste y la fecha de cada uno.
            got = sum((lot.units for lot in inherited), ZERO)
            if t.units and got and t.units != got:
                ratio = t.units / got
                inherited = [Lot(lot.acquired, (lot.units * ratio).quantize(Q10), lot.cost)
                             for lot in inherited]  # fmt: skip
            p.lots.extend(Lot(lot.acquired, lot.units, lot.cost) for lot in inherited)
            total_cost = p.cost + sum((lot.cost for lot in inherited), ZERO)
            p.units += sum((lot.units for lot in inherited), ZERO)
            p.avg_cost = (total_cost / p.units).quantize(Q10) if p.units else ZERO
        elif t.kind in ("venta", "traspaso_salida"):
            _, cost_fifo = _take_fifo(p.lots, t.units)
            cost_pmp = t.units * p.avg_cost
            if t.kind == "venta":
                p.realized.append(Realized(t.on, t.units, t.amount - t.fee, cost_fifo, cost_pmp))
            p.units -= t.units
            if p.units <= Decimal("1E-8"):
                p.units, p.avg_cost, p.lots = ZERO, ZERO, []
        elif t.kind == "correccion":
            new_units = t.units if t.units else p.units
            new_avg = t.avg_cost if t.avg_cost is not None else p.avg_cost
            new_cost = new_units * new_avg
            old_units = sum((lot.units for lot in p.lots), ZERO)
            if p.lots and old_units > 0:
                # Reescalar los lotes conservando sus fechas
                for lot in p.lots:
                    share = lot.units / old_units
                    lot.units = (new_units * share).quantize(Q10)
                    lot.cost = (new_cost * share).quantize(Q10)
            elif new_units > 0:
                p.lots = [Lot(t.on, new_units, new_cost)]
            p.units, p.avg_cost = new_units, new_avg
        elif t.kind in ("dividendo", "interes"):
            p.income += t.amount
        elif t.kind == "comision":
            p.fees += t.amount
        else:
            raise ValueError(f"Tipo de transacción desconocido: {t.kind}")
    return p


def lots_for_transfer(position_before: Position, units: Decimal) -> list[Lot]:
    """Lotes FIFO que salen en un traspaso (para pasarlos al fondo de destino)."""
    lots = [Lot(lot.acquired, lot.units, lot.cost) for lot in position_before.lots]
    out, _ = _take_fifo(lots, units)
    return out


@dataclass(frozen=True)
class Valuation:
    value: Decimal
    cost: Decimal
    pnl: Decimal
    pnl_pct: Decimal | None


def valuation(p: Position, price: Decimal | None) -> Valuation:
    value = p.units * price if price is not None else p.cost
    pnl = value - p.cost
    return Valuation(value, p.cost, pnl, (pnl / p.cost) if p.cost else None)
