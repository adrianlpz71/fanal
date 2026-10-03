"""Motor fiscal (IRPF y Patrimonio) sobre parámetros que vienen de `tax_parameters`.

Aquí no hay ni un tipo ni un tramo: todo llega como argumento (escalas como
`{"tramos": [{"hasta": "12450", "tipo": "0.095"}, …, {"hasta": None, "tipo": …}]}`).

IRPF (Ley 35/2006):
  · Base general: cuota estatal = escala estatal(base) − escala estatal(mínimo estatal) y cuota
    autonómica = escala autonómica(base) − escala autonómica(mínimo autonómico).
  · Base del ahorro: la escala del ahorro completa es estatal + autonómica a partes iguales. Si
    el mínimo no cabe en la base general, el resto se aplica en la del ahorro, por separado en
    cada mitad con su mínimo (art. 56).
Patrimonio (Ley 19/1991): base − exenciones (vivienda habitual con su tope) − mínimo exento;
límite conjunto con el IRPF (art. 31): la suma de cuotas no pasa del 60 % de la base imponible
del IRPF, pero la reducción de la cuota de Patrimonio no puede pasar del 80 %.
"""

from dataclasses import dataclass
from decimal import Decimal
from typing import Any

ZERO = Decimal(0)
HALF = Decimal("0.5")
CENT = Decimal("0.01")


def progressive(base: Decimal, scale: dict[str, Any], factor: Decimal = Decimal(1)) -> Decimal:
    """Cuota de una escala por tramos. `factor` permite usar media escala (p. ej. la estatal del
    ahorro es la mitad de la escala completa)."""
    if base <= 0:
        return ZERO
    tax, prev = ZERO, ZERO
    for t in scale["tramos"]:
        top = Decimal(t["hasta"]) if t["hasta"] is not None else None
        chunk = (min(base, top) if top is not None else base) - prev
        if chunk <= 0:
            break
        tax += chunk * Decimal(t["tipo"]) * factor
        if top is None or base <= top:
            break
        prev = top
    return tax


@dataclass(frozen=True)
class Bracket:
    """Un tramo de una escala: de `lo` a `hi` (None = sin tope), al `rate`, con lo que cae en
    él (`amount`) y su cuota."""

    lo: Decimal
    hi: Decimal | None
    rate: Decimal
    amount: Decimal
    tax: Decimal


def _tops(scale: dict[str, Any]) -> list[tuple[Decimal | None, Decimal]]:
    return [
        (Decimal(t["hasta"]) if t["hasta"] is not None else None, Decimal(t["tipo"]))
        for t in scale["tramos"]
    ]


def brackets(base: Decimal, *scales: dict[str, Any], factor: Decimal = Decimal(1)) -> list[Bracket]:
    """Tramos de una o varias escalas sumadas (p. ej. estatal + autonómica): los cortes de todas,
    el tipo de cada trozo sumando el de cada escala y lo que cae en cada uno de `base`."""
    tops = sorted({t for sc in scales for t, _ in _tops(sc) if t is not None})
    out, lo = [], ZERO
    for hi in [*tops, None]:
        rate = ZERO
        for sc in scales:
            rate += next(r for t, r in _tops(sc) if t is None or t > lo) * factor
        amount = max(ZERO, (min(base, hi) if hi is not None else base) - lo)
        out.append(Bracket(lo, hi, rate, amount, amount * rate))
        if hi is None:
            break
        lo = hi
    return out


def marginal(base: Decimal, *scales: dict[str, Any], factor: Decimal = Decimal(1)) -> Decimal:
    """Tipo del tramo en el que cae el último euro de `base`."""
    rows = brackets(base, *scales, factor=factor)
    hit = [b for b in rows if b.amount > 0]
    return (hit[-1] if hit else rows[0]).rate


@dataclass(frozen=True)
class IrpfParams:
    general_state: dict[str, Any]
    general_regional: dict[str, Any]
    savings: dict[str, Any]
    minimum_state: Decimal
    minimum_regional: Decimal


@dataclass(frozen=True)
class IrpfResult:
    general_state: Decimal
    general_regional: Decimal
    savings: Decimal

    @property
    def total(self) -> Decimal:
        return self.general_state + self.general_regional + self.savings


def irpf(base_general: Decimal, base_savings: Decimal, p: IrpfParams) -> IrpfResult:
    def part(scale: dict[str, Any], minimum: Decimal) -> tuple[Decimal, Decimal]:
        used = min(minimum, max(base_general, ZERO))
        quota = progressive(base_general, scale) - progressive(used, scale)
        return max(quota, ZERO), minimum - used  # cuota y mínimo sobrante para el ahorro

    gs, rest_s = part(p.general_state, p.minimum_state)
    gr, rest_r = part(p.general_regional, p.minimum_regional)
    savings = ZERO
    for rest in (rest_s, rest_r):  # mitad estatal y mitad autonómica del ahorro
        q = progressive(base_savings, p.savings, HALF)
        q -= progressive(min(rest, max(base_savings, ZERO)), p.savings, HALF)
        savings += max(q, ZERO)
    return IrpfResult(gs, gr, savings)


def gross_up(net: Decimal, gain_ratio: Decimal, p: IrpfParams, base_general: Decimal = ZERO
             ) -> tuple[Decimal, Decimal]:  # fmt: skip
    """Cuánto hay que retirar (vendiendo participaciones) para quedarse `net` limpio, si una
    fracción `gain_ratio` de lo retirado es ganancia (base del ahorro). Devuelve (bruto, impuesto).
    Solo grava la ganancia; el resto es devolución del coste."""
    if net <= 0:
        return ZERO, ZERO
    lo, hi = net, net * 2 + 1
    for _ in range(200):
        mid = (lo + hi) / 2
        tax = irpf(base_general, mid * gain_ratio, p).savings
        if mid - tax < net:
            lo = mid
        else:
            hi = mid
        if hi - lo < Decimal("0.001"):
            break
    gross = hi.quantize(CENT)
    return gross, irpf(base_general, gross * gain_ratio, p).savings.quantize(CENT)


@dataclass(frozen=True)
class WealthParams:
    scale: dict[str, Any]
    exempt_minimum: Decimal
    home_exempt_cap: Decimal
    joint_limit: Decimal  # 0.60
    max_reduction: Decimal  # 0.80


@dataclass(frozen=True)
class WealthResult:
    taxable: Decimal
    quota_before_limit: Decimal
    quota: Decimal
    joint_limit_applied: bool


def wealth_tax(net_wealth: Decimal, main_home: Decimal, p: WealthParams,
               irpf_quota: Decimal = ZERO, irpf_taxable_base: Decimal | None = None
               ) -> WealthResult:  # fmt: skip
    home_exempt = min(max(main_home, ZERO), p.home_exempt_cap)
    taxable = max(net_wealth - home_exempt - p.exempt_minimum, ZERO)
    q = progressive(taxable, p.scale)
    final, applied = q, False
    if irpf_taxable_base is not None and q > 0:
        cap = irpf_taxable_base * p.joint_limit
        if irpf_quota + q > cap:
            final = max(cap - irpf_quota, q * (1 - p.max_reduction))
            applied = True
    return WealthResult(taxable, q, final, applied)
