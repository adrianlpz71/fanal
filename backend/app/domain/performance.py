"""Rentabilidad de una cartera con aportaciones: funciones puras sobre Decimal.

Convenciones:
  · Flujo (`flow`) = dinero que ENTRA en la cartera desde fuera (aportación > 0, retirada < 0).
    Los dividendos o intereses que se quedan dentro no son flujo: son rentabilidad.
  · Modified Dietz del periodo [inicio, fin]:
        r = (V_fin − V_ini − ΣF) / (V_ini + Σ w_i·F_i)
    con w_i = (días desde el flujo hasta el fin) / días del periodo
    (un flujo del primer día pesa casi 1; uno del último día, 0).
  · TWR = encadenar (1 + r_mes) − 1: mide la gestión, no cuándo aportaste.
  · XIRR = tasa anual que hace cero el valor actual de los flujos (desde el punto de vista del
    inversor: aportar es negativo y el valor final, positivo). Mide TU rentabilidad real.
"""

from dataclasses import dataclass
from datetime import date
from decimal import Decimal, localcontext

ZERO = Decimal(0)
ONE = Decimal(1)


@dataclass(frozen=True)
class Flow:
    on: date
    amount: Decimal  # > 0 aportación, < 0 retirada


def modified_dietz(
    start: date, end: date, v_start: Decimal, v_end: Decimal, flows: list[Flow]
) -> Decimal | None:
    days = (end - start).days
    inside = [f for f in flows if start < f.on <= end]
    net = sum((f.amount for f in inside), ZERO)
    if days <= 0:
        return None
    weighted = sum((f.amount * Decimal((end - f.on).days) / Decimal(days) for f in inside), ZERO)
    base = v_start + weighted
    if base <= 0:
        return None  # sin capital invertido en el periodo: la rentabilidad no tiene sentido
    return (v_end - v_start - net) / base


def chain(returns: list[Decimal]) -> Decimal:
    acc = ONE
    for r in returns:
        acc *= ONE + r
    return acc - ONE


def annualize(total: Decimal, days: int) -> Decimal | None:
    if days < 1 or total <= -1:
        return None
    if days < 365:
        return None  # anualizar menos de un año exagera; la UI enseña la acumulada
    with localcontext() as ctx:
        ctx.prec = 28
        return (ONE + total) ** (Decimal(365) / Decimal(days)) - ONE


def xirr(flows: list[Flow], guess: Decimal = Decimal("0.1")) -> Decimal | None:
    """Flujos desde el punto de vista del inversor (aportar < 0, valor final > 0). Bisección
    robusta entre −99 % y +1000 %; None si no hay cambio de signo."""
    if not flows or all(f.amount >= 0 for f in flows) or all(f.amount <= 0 for f in flows):
        return None
    t0 = min(f.on for f in flows)

    def npv(rate: Decimal) -> Decimal:
        with localcontext() as ctx:
            ctx.prec = 40
            total = ZERO
            for f in flows:
                years = Decimal((f.on - t0).days) / Decimal(365)
                total += f.amount / (ONE + rate) ** years
            return total

    lo, hi = Decimal("-0.99"), Decimal("10")
    f_lo, f_hi = npv(lo), npv(hi)
    if f_lo * f_hi > 0:
        return None
    for _ in range(200):
        mid = (lo + hi) / 2
        f_mid = npv(mid)
        if abs(f_mid) < Decimal("1E-9") or (hi - lo) < Decimal("1E-12"):
            return mid
        if f_lo * f_mid < 0:
            hi, f_hi = mid, f_mid
        else:
            lo, f_lo = mid, f_mid
    return (lo + hi) / 2


def max_drawdown(index: list[Decimal]) -> Decimal:
    """Mayor caída desde un máximo previo, sobre un índice de rentabilidad (no sobre el valor,
    que sube con cada aportación). Devuelve un número ≤ 0 (−0,12 = −12 %)."""
    peak, worst = None, ZERO
    for v in index:
        if peak is None or v > peak:
            peak = v
        if peak and peak > 0:
            worst = min(worst, v / peak - ONE)
    return worst


def volatility(returns: list[Decimal], periods_per_year: int = 12) -> Decimal | None:
    """Desviación típica (muestral) anualizada de las rentabilidades del periodo."""
    if len(returns) < 2:
        return None
    mean = sum(returns, ZERO) / len(returns)
    var = sum(((r - mean) ** 2 for r in returns), ZERO) / (len(returns) - 1)
    return var.sqrt() * Decimal(periods_per_year).sqrt()


@dataclass(frozen=True)
class Point:
    """Foto de un día: valor de la cartera al cierre y flujo neto de ese día."""

    on: date
    value: Decimal
    flow: Decimal = ZERO


@dataclass(frozen=True)
class MonthRow:
    year: int
    month: int
    start_value: Decimal
    end_value: Decimal
    net_flow: Decimal
    gain: Decimal  # Δvalor − aportaciones netas
    ret: Decimal | None  # Modified Dietz del mes
    cumulative: Decimal | None  # TWR encadenada hasta este mes


def daily_index(points: list[Point]) -> list[tuple[date, Decimal, bool]]:
    """Índice de rentabilidad encadenando día a día (flujo al cierre: lo aportado un día no
    rinde ese día). Devuelve (día, índice, ¿había capital?). Exacto con valoración diaria;
    Modified Dietz es la aproximación para cuando solo hay valores de fin de mes."""
    out: list[tuple[date, Decimal, bool]] = []
    idx, prev = ONE, None
    for p in sorted(points, key=lambda x: x.on):
        invested = prev is not None and prev.value > 0
        if invested:
            idx *= ONE + (p.value - p.flow - prev.value) / prev.value  # type: ignore[union-attr]
        out.append((p.on, idx, invested))
        prev = p
    return out


def monthly(points: list[Point]) -> list[MonthRow]:
    """Tabla mensual a partir de fotos diarias. El valor inicial de un mes es el último del mes
    anterior (el primer mes empieza en 0: todo es aportación). La rentabilidad del mes es la del
    índice diario encadenado (TWR exacta); un mes sin capital invertido no tiene rentabilidad."""
    pts = sorted(points, key=lambda p: p.on)
    if not pts:
        return []
    index = daily_index(pts)
    months: dict[tuple[int, int], list[int]] = {}
    for i, p in enumerate(pts):
        months.setdefault((p.on.year, p.on.month), []).append(i)
    rows: list[MonthRow] = []
    prev_value, prev_idx = ZERO, ONE
    for (y, m), ids in sorted(months.items()):
        end = pts[ids[-1]]
        net = sum((pts[i].flow for i in ids), ZERO)
        any_capital = any(index[i][2] for i in ids)
        end_idx = index[ids[-1]][1]
        r = (end_idx / prev_idx - ONE) if any_capital else None
        cumulative = (end_idx - ONE) if any(x[2] for x in index[: ids[-1] + 1]) else None
        rows.append(MonthRow(y, m, prev_value, end.value, net, end.value - prev_value - net, r,
                             cumulative))  # fmt: skip
        prev_value, prev_idx = end.value, end_idx
    return rows
