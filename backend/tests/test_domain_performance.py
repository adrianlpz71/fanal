"""Rentabilidad: casos calculados a mano."""

from datetime import date
from decimal import Decimal as D

from app.domain.performance import (
    Flow,
    Point,
    annualize,
    chain,
    max_drawdown,
    modified_dietz,
    monthly,
    volatility,
    xirr,
)


def close(a, b, tol="0.0001"):
    return abs(a - D(b)) <= D(tol)


def test_modified_dietz_weights_flow_by_days_left():
    # 1.000 € a 31/01; aporto 100 € el 14/02 (mitad del periodo, pesa 0,5); acaba en 1.150 €
    r = modified_dietz(date(2026, 1, 31), date(2026, 2, 28), D(1000), D(1150),
                       [Flow(date(2026, 2, 14), D(100))])  # fmt: skip
    assert close(r, "0.047619")  # 50 / 1.050
    # Sin capital no hay rentabilidad que calcular
    assert modified_dietz(date(2026, 1, 1), date(2026, 1, 31), D(0), D(0), []) is None


def test_chain_and_annualize():
    assert chain([D("0.1"), D("-0.1")]) == D("-0.01")
    assert close(annualize(D("0.21"), 730), "0.1")  # 21 % en dos años = 10 % anual
    assert annualize(D("0.05"), 200) is None  # menos de un año: no se anualiza


def test_xirr():
    one_year = [Flow(date(2025, 1, 1), D(-1000)), Flow(date(2026, 1, 1), D(1100))]
    assert close(xirr(one_year), "0.1")
    # Dos aportaciones de 1.000 € (la segunda a mitad de año) y 2.200 € al final ≈ 13,46 %
    two = [Flow(date(2025, 1, 1), D(-1000)), Flow(date(2025, 7, 2), D(-1000)),
           Flow(date(2026, 1, 1), D(2200))]  # fmt: skip
    assert close(xirr(two), "0.1346", "0.0005")
    assert xirr([Flow(date(2025, 1, 1), D(-1000))]) is None


def test_drawdown_and_volatility():
    assert max_drawdown([D(1), D("1.2"), D("0.9"), D("1.3"), D("1.04")]) == D("-0.25")
    assert max_drawdown([D(1), D(2), D(3)]) == 0
    assert close(volatility([D("0.01"), D("-0.01"), D("0.02"), D(0)]), "0.04472")
    assert volatility([D("0.01")]) is None


def test_monthly_table():
    pts = [
        Point(date(2026, 1, 10), D(1000), D(1000)),  # primera compra
        Point(date(2026, 1, 31), D(1050)),
        Point(date(2026, 2, 14), D(1160), D(100)),
        Point(date(2026, 2, 28), D(1150)),
    ]
    jan, feb = monthly(pts)
    assert (jan.start_value, jan.end_value, jan.net_flow, jan.gain) == (
        D(0),
        D(1050),
        D(1000),
        D(50),
    )
    assert close(jan.ret, "0.05")  # 1.000 € invertidos → 1.050 €
    assert (feb.start_value, feb.net_flow, feb.gain) == (D(1050), D(100), D(0))
    # Día 14: +10 € sobre 1.050 (+0,952 %); día 28: −10 € sobre 1.160 (−0,862 %)
    assert close(feb.ret, "0.000821")
    assert close(feb.cumulative, "0.050862")
