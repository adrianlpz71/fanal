"""Aceptación del dominio de inversiones (spec §12) con una cartera de ejemplo inventada."""

from datetime import date
from decimal import Decimal as D

import pytest

from app.domain.allocation import (
    Item,
    cascade,
    emergency_fund,
    internal_status,
    largest_remainder,
    macro_status,
    split,
    weights,
)
from app.domain.money import q2
from app.domain.portfolio import Tx, lots_for_transfer, qunits, replay, valuation

T0 = date(2026, 10, 1)

# (participaciones, PMP, precio)
POS = {
    "msci": (D("95.00"), D("11.20"), D("15.10")),
    "em": (D("1.15"), D("205.40"), D("268.90")),
    "sc": (D("0.55"), D("300.15"), D("371.80")),
    "btc": (D("0.00250"), D("58200"), D("71500")),
}
FONDOS = ("msci", "em", "sc")


def positions():
    return {
        k: replay([Tx("posicion_inicial", T0, units=u, avg_cost=c)]) for k, (u, c, _) in POS.items()
    }


def values():
    return {k: valuation(p, POS[k][2]) for k, p in positions().items()}


def test_portfolio_totals():
    v = values()
    value = sum(x.value for x in v.values())
    cost = sum(x.cost for x in v.values())
    assert q2(value) == D("2126.98")
    assert q2(cost) == D("1610.79")
    assert q2(value - cost) == D("516.18")
    assert round((value - cost) / cost * 100, 2) == D("32.05")


def test_weights_and_statuses():
    v = values()
    fondos = sum(v[k].value for k in FONDOS)
    macro = weights([Item("fondos", fondos, D("0.9")), Item("cripto", v["btc"].value, D("0.1"))])
    assert round(macro["fondos"] * 100, 2) == D("91.60")
    assert round(macro["cripto"] * 100, 2) == D("8.40")
    assert macro_status(macro["fondos"], D("0.70"), D("0.95")) == "ok"

    targets = {"msci": D("0.70"), "em": D("0.18"), "sc": D("0.12")}
    inner = weights([Item(k, v[k].value, targets[k]) for k in FONDOS])
    assert [round(inner[k] * 100, 2) for k in FONDOS] == [D("73.63"), D("15.87"), D("10.50")]
    assert [internal_status(inner[k], targets[k], D(1)) for k in FONDOS] == [
        "no_comprar",
        "comprar",
        "comprar",
    ]


def test_contribution_engine_300():
    v = values()
    fondos = sum(v[k].value for k in FONDOS)
    macro = [
        Item("fondos", fondos, D("0.90")),
        Item("cripto", v["btc"].value, D("0.10")),
        Item("acciones", D(0), D(0)),
    ]
    inner = {
        "fondos": [
            Item("msci", v["msci"].value, D("0.70")),
            Item("em", v["em"].value, D("0.18")),
            Item("sc", v["sc"].value, D("0.12")),
        ],
        "cripto": [Item("btc", v["btc"].value, D("1"))],
        "acciones": [Item("accion_a", D(0), D("0.45")), Item("accion_b", D(0), D("0.55"))],
    }
    top, per = cascade(D("300"), macro, inner)
    assert (top["fondos"], top["cripto"], top["acciones"]) == (D("236.05"), D("63.95"), D("0.00"))
    assert (per["fondos"]["msci"], per["fondos"]["em"], per["fondos"]["sc"]) == (
        D("94.49"),
        D("83.94"),
        D("57.62"),
    )
    assert per["cripto"]["btc"] == D("63.95")
    assert sum(top.values()) == D("300")


def test_engine_never_sells_and_min_operation():
    # Uno muy por encima del objetivo no recibe nada (nunca se sugiere vender)
    out = split(D("100"), [Item("a", D("900"), D("0.5")), Item("b", D("100"), D("0.5"))])
    assert out == {"a": D("0.00"), "b": D("100.00")}
    # Con mínimo por operación de 10 €, una aportación de 3 € se reparte entre las demás
    items = [
        Item("a", D("0"), D("0.5")),
        Item("b", D("0"), D("0.47")),
        Item("c", D("0"), D("0.03")),
    ]
    out = split(D("100"), items, min_op=D("10"))
    assert out["c"] == D("0") and out["a"] + out["b"] == D("100")


def test_contribution_rounded_to_whole_euros():
    # Mismo reparto que el de 300 €, pero cada orden en euros enteros y la suma igual de exacta
    v = values()
    macro = [
        Item("fondos", sum(v[k].value for k in FONDOS), D("0.90")),
        Item("cripto", v["btc"].value, D("0.10")),
    ]
    inner = {
        "fondos": [
            Item("msci", v["msci"].value, D("0.70")),
            Item("em", v["em"].value, D("0.18")),
            Item("sc", v["sc"].value, D("0.12")),
        ],
        "cripto": [Item("btc", v["btc"].value, D("1"))],
    }
    top, per = cascade(D("300"), macro, inner, unit=D("1"))
    assert (top["fondos"], top["cripto"]) == (D("236.00"), D("64.00"))
    assert (per["fondos"]["msci"], per["fondos"]["em"], per["fondos"]["sc"]) == (
        D("94.00"),
        D("84.00"),
        D("58.00"),
    )
    orders = [*per["fondos"].values(), per["cripto"]["btc"]]
    assert sum(orders) == D("300") and all(o == o.to_integral_value() for o in orders)
    # A múltiplos de 5 €: 236 → 95 / 85 / 55 (+1 € que no llega a 5 va a la mayor)
    top5, per5 = cascade(D("300"), macro, inner, unit=D("5"))
    assert sum(top5.values()) == D("300")
    assert sum(per5["fondos"].values()) == top5["fondos"]


def test_rounding_with_amount_not_multiple_goes_to_largest():
    r = largest_remainder({"a": D("60.2"), "b": D("40.3")}, D("100.50"), D("1"))
    assert r == {"a": D("60.50"), "b": D("40.00")}  # los 0,50 € sobrantes, a la mayor
    assert sum(r.values()) == D("100.50")


def test_largest_remainder_sums_exactly():
    r = largest_remainder({"a": D(1) / 3 * 100, "b": D(1) / 3 * 100, "c": D(1) / 3 * 100}, D(100))
    assert sum(r.values()) == D(100) and sorted(r.values()) == [D("33.33"), D("33.33"), D("33.34")]


def test_buy_updates_pmp():
    units = qunits(D("50") / D("15.10"), 4)
    assert units == D("3.3112")
    p = replay([
        Tx("posicion_inicial", T0, units=D("95.00"), avg_cost=D("11.20")),
        Tx("compra", date(2026, 10, 20), units=units, amount=D("50")),
    ])  # fmt: skip
    assert p.units == D("98.3112")
    assert round(p.avg_cost, 4) == D("11.3314")


def test_partial_sale_fifo_vs_pmp():
    p = replay([
        Tx("compra", date(2025, 1, 10), units=D("10"), amount=D("100")),  # 10 €/u
        Tx("compra", date(2025, 6, 10), units=D("10"), amount=D("200")),  # 20 €/u
        Tx("venta", date(2026, 3, 1), units=D("15"), amount=D("375")),  # 25 €/u
    ])  # fmt: skip
    (r,) = p.realized
    assert r.cost_fifo == D("200")  # 10×10 + 5×20
    assert r.cost_pmp == D("225")  # 15 × 15
    assert (r.gain_fifo, r.gain_pmp) == (D("175"), D("150"))
    assert p.units == D("5") and p.avg_cost == D("15")
    assert [(lot.acquired, lot.units, lot.cost) for lot in p.lots] == [
        (date(2025, 6, 10), D("5"), D("100"))
    ]


def test_transfer_keeps_cost_and_dates():
    src = replay([
        Tx("compra", date(2024, 1, 1), units=D("10"), amount=D("100")),
        Tx("compra", date(2025, 1, 1), units=D("10"), amount=D("150")),
    ])  # fmt: skip
    lots = lots_for_transfer(src, D("15"))
    dst = replay([Tx("traspaso_entrada", date(2026, 1, 1), lots=tuple(lots))])
    assert dst.cost_fifo == D("175") and dst.first_date == date(
        2026, 1, 1
    )  # rentabilidad desde el traspaso
    assert [lot.acquired for lot in dst.lots] == [date(2024, 1, 1), date(2025, 1, 1)]
    # El fondo destino tiene sus propias participaciones (otro VL): 15 de origen → 5 de destino
    dst2 = replay([Tx("traspaso_entrada", date(2026, 1, 1), units=D("5"), lots=tuple(lots))])
    assert dst2.units == D("5") and dst2.cost_fifo == D("175")
    assert round(dst2.avg_cost, 2) == D("35.00")


def test_correction_rescales_lots():
    p = replay([
        Tx("compra", date(2025, 1, 1), units=D("10"), amount=D("100")),
        Tx("compra", date(2025, 2, 1), units=D("10"), amount=D("100")),
        Tx("correccion", date(2026, 1, 1), units=D("20.5"), avg_cost=D("10")),
    ])  # fmt: skip
    assert p.units == D("20.5") and p.cost == D("205.0")
    assert [lot.acquired for lot in p.lots] == [date(2025, 1, 1), date(2025, 2, 1)]


def test_overselling_fails():
    with pytest.raises(ValueError):
        replay([Tx("compra", T0, units=D("1"), amount=D("10")), Tx("venta", T0, units=D("2"))])


def test_emergency_fund():
    e = emergency_fund(
        D("4000"), D("200"), avg_monthly_spend=D("1000"), monthly_contribution=D("150")
    )
    assert e.coverage == D("0.05") and e.missing == D("3800")
    assert e.months_covered == D("0.2") and e.suggested_monthly == D("150")
