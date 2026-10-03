"""Objetivos de asignación (dos niveles) y motor de aportaciones.

Motor (replica el Excel, spec §5.3): dado un importe A, para cada elemento i con valor v_i y
objetivo t_i (tanto por uno), con S = Σ v:
    déficit_i   = max(0, t_i · (S + A) − v_i)
    aportación_i = A · déficit_i / Σ déficit_j
En cascada: primero entre categorías macro y, con lo asignado a cada categoría, entre sus activos.
Solo compras (nunca sugiere vender). Céntimos por el método del mayor resto, así que la suma es
exactamente A. Un importe mínimo por operación anula las aportaciones pequeñas y reparte su parte.
Opcionalmente, las órdenes se redondean a múltiplos de una unidad (1 €, 5 €…) con el mismo método,
para que sean fáciles de meter en el banco; si A no es múltiplo, lo que sobra va a la mayor.
"""

from dataclasses import dataclass
from decimal import ROUND_DOWN, Decimal

ZERO = Decimal(0)
CENT = Decimal("0.01")


@dataclass(frozen=True)
class Item:
    key: str
    value: Decimal
    target: Decimal  # tanto por uno


def largest_remainder(
    raw: dict[str, Decimal], total: Decimal, unit: Decimal = CENT
) -> dict[str, Decimal]:
    """Redondea a múltiplos de `unit` (céntimos por defecto) manteniendo la suma exacta (mayor
    resto). Si `total` no es múltiplo de `unit`, lo que sobra (< 1 unidad) va a la mayor."""
    floors = {k: (v / unit).to_integral_value(rounding=ROUND_DOWN) * unit for k, v in raw.items()}
    leftover = int(
        ((total - sum(floors.values(), ZERO)) / unit).to_integral_value(rounding=ROUND_DOWN)
    )
    order = sorted(raw, key=lambda k: (raw[k] - floors[k], raw[k]), reverse=True)
    for k in order[: max(leftover, 0)]:
        floors[k] += unit
    rest = total - sum(floors.values(), ZERO)
    if rest and floors:
        floors[max(floors, key=lambda k: (floors[k], raw[k]))] += rest
    return {k: v.quantize(CENT) for k, v in floors.items()}


def split(
    amount: Decimal, items: list[Item], min_op: Decimal = ZERO, unit: Decimal = CENT
) -> dict[str, Decimal]:
    """Reparte `amount` entre `items` según déficit frente al objetivo."""
    out = {i.key: ZERO for i in items}
    if amount <= 0 or not items:
        return out
    active = list(items)
    while True:
        total = sum((i.value for i in items), ZERO)  # S incluye a todos (también los excluidos)
        deficits = {i.key: max(ZERO, i.target * (total + amount) - i.value) for i in active}
        dsum = sum(deficits.values(), ZERO)
        if dsum == 0:
            # Todo en objetivo o por encima: se reparte por peso objetivo
            tsum = sum((i.target for i in active), ZERO)
            if tsum == 0:
                return out
            raw = {i.key: amount * i.target / tsum for i in active}
        else:
            raw = {k: amount * d / dsum for k, d in deficits.items()}
        rounded = largest_remainder(raw, amount, unit)
        small = [k for k, v in rounded.items() if 0 < v < min_op]
        if not small or len(small) == len([v for v in rounded.values() if v > 0]):
            out.update(rounded)
            return out
        active = [i for i in active if i.key not in small]


def cascade(
    amount: Decimal,
    macro: list[Item],
    inner: dict[str, list[Item]],
    min_op: Decimal = ZERO,
    unit: Decimal = CENT,
) -> tuple[dict[str, Decimal], dict[str, dict[str, Decimal]]]:
    """Primero entre categorías macro y luego, con lo asignado a cada una, entre sus activos.
    Una categoría sin activos con objetivo se queda sin reparto (su importe vuelve al resto)."""
    usable = [m for m in macro if inner.get(m.key)]
    top = split(amount, usable, min_op, unit)
    for m in macro:
        top.setdefault(m.key, ZERO)
    per = {k: split(top[k], inner.get(k, []), min_op, unit) for k in top if inner.get(k)}
    return top, per


def weights(items: list[Item]) -> dict[str, Decimal]:
    total = sum((i.value for i in items), ZERO)
    return {i.key: (i.value / total if total else ZERO) for i in items}


def macro_status(weight: Decimal, min_w: Decimal, max_w: Decimal) -> str:
    if weight < min_w:
        return "bajo"
    if weight > max_w:
        return "alto"
    return "ok"


def internal_status(weight: Decimal, target: Decimal, tolerance_pp: Decimal) -> str:
    tol = tolerance_pp / 100
    if weight < target - tol:
        return "comprar"
    if weight > target + tol:
        return "no_comprar"
    return "ok"


@dataclass(frozen=True)
class EmergencyFund:
    target: Decimal
    current: Decimal
    coverage: Decimal  # tanto por uno
    missing: Decimal
    months_covered: Decimal | None  # meses de gasto medio cubiertos
    suggested_monthly: Decimal


def emergency_fund(
    target: Decimal,
    current: Decimal,
    avg_monthly_spend: Decimal | None = None,
    monthly_contribution: Decimal | None = None,
) -> EmergencyFund:
    missing = max(ZERO, target - current)
    coverage = (current / target) if target else ZERO
    months = (current / avg_monthly_spend) if avg_monthly_spend else None
    suggested = min(missing, monthly_contribution) if monthly_contribution else missing
    return EmergencyFund(target, current, coverage, missing, months, suggested)
