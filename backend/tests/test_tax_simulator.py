"""Impuestos (fase 5): cálculo paso a paso con tramos, prellenado y "¿y si vendo X € hoy?" (D8)."""

from datetime import date, timedelta
from decimal import Decimal as D

import pytest

from app.domain import sale as S
from app.domain import tax as T
from app.domain.portfolio import Lot
from tests.conftest import auth_header, enroll
from tests.test_analytics import _buy, _fund, _price
from tests.test_api_gastos import setup_gastos

SCALE_A = {"tramos": [{"hasta": "10000", "tipo": "0.10"}, {"hasta": None, "tipo": "0.20"}]}
SCALE_B = {
    "tramos": [
        {"hasta": "5000", "tipo": "0.01"},
        {"hasta": "20000", "tipo": "0.02"},
        {"hasta": None, "tipo": "0.03"},
    ]
}


@pytest.fixture
def h(client, make_user):
    make_user("ana@example.com")
    return auth_header(enroll(client, "ana@example.com"))


def test_brackets_merge_scales_and_add_up():
    rows = T.brackets(D("15000"), SCALE_A, SCALE_B)
    # Cortes de las dos escalas: 5.000, 10.000 y 20.000
    assert [(b.lo, b.hi, b.rate, b.amount) for b in rows] == [
        (D(0), D(5000), D("0.11"), D(5000)),
        (D(5000), D(10000), D("0.12"), D(5000)),
        (D(10000), D(20000), D("0.22"), D(5000)),
        (D(20000), None, D("0.23"), D(0)),
    ]
    total = sum((b.tax for b in rows), D(0))
    assert total == T.progressive(D(15000), SCALE_A) + T.progressive(D(15000), SCALE_B)
    assert T.marginal(D("15000"), SCALE_A, SCALE_B) == D("0.22")
    assert T.marginal(D(0), SCALE_A) == D("0.10")  # sin base: el primer tramo


def test_fifo_cost_and_proportional_sale():
    lots = (Lot(date(2024, 1, 1), D(10), D(100)), Lot(date(2025, 1, 1), D(10), D(200)))
    assert S.fifo_cost(lots, D(5)) == D(50)  # solo del lote más antiguo
    assert S.fifo_cost(lots, D(15)) == D(100) + D(100)  # el antiguo entero y medio del nuevo
    a = S.Holding("a", "A", D(20), D(30), lots)  # vale 600
    b = S.Holding("b", "B", D(10), D(20), (Lot(date(2025, 6, 1), D(10), D(150)),))  # vale 200
    parts = S.preview([a, b], D("400"))
    assert [(p.key, p.amount) for p in parts] == [("a", D("300.00")), ("b", D("100.00"))]
    assert sum((p.amount for p in parts), D(0)) == D("400")
    # A: 300 € a 30 € = 10 participaciones del lote de 2024 (coste 100) → ganancia 200
    assert parts[0].units == D(10) and parts[0].cost == D("100.00") and parts[0].gain == D(200)
    with pytest.raises(ValueError, match="Solo tienes"):
        S.preview([a, b], D("900"))


def test_tax_step_by_step_matches_the_quota(client, h):
    r = client.post(
        "/api/planes/tax", headers=h, json={"base_general": "30000", "base_savings": "8000"}
    )
    assert r.status_code == 200, r.text
    t = r.json()
    general = sum(D(b["tax"]) for b in t["general_brackets"])
    # Cuota general = escala(base) − escala(mínimo), estatal + autonómica
    assert general - D(t["minimum_quota"]) == pytest.approx(
        D(t["irpf_general_state"]) + D(t["irpf_general_regional"]), abs=D("0.01")
    )
    assert sum(D(b["amount"]) for b in t["general_brackets"]) == D(30000)
    assert sum(D(b["amount"]) for b in t["savings_brackets"]) == D(8000)
    assert sum(D(b["tax"]) for b in t["savings_brackets"]) == pytest.approx(
        D(t["irpf_savings"]), abs=D("0.01")
    )
    assert D(t["average_rate"]) == pytest.approx(D(t["irpf_total"]) / D(38000), abs=D("0.0001"))
    assert D(t["marginal_general"]) > D(t["general_brackets"][0]["rate"])


def test_prefill_remembers_base_and_uses_this_year(client, h):
    setup_gastos(client, h)
    client.post(
        "/api/cycles/payday",
        headers=h,
        json={
            "payroll_amount": "1845.00",
            "payroll_date": date.today().isoformat(),
            "real_balance_before": "500.00",
        },
    )
    p = client.get("/api/planes/tax/prefill", headers=h).json()
    assert p["year"] == date.today().year and D(p["payroll_net"]) >= D("1845.00")
    assert p["base_general"] is None  # la base la escribe el usuario
    client.post(
        "/api/planes/tax", headers=h, json={"base_general": "24000", "remember_base_general": True}
    )
    assert client.get("/api/planes/tax/prefill", headers=h).json()["base_general"] == "24000.00"


def test_sell_preview_fifo_and_incremental_tax(client, h):
    today = date.today()
    a = _fund(client, h, "Mundo")
    _buy(client, h, a["id"], today - timedelta(days=400), "10", "100")  # lote antiguo a 10 €
    _buy(client, h, a["id"], today - timedelta(days=30), "10", "250")  # lote nuevo a 25 €
    _price(a["id"], today, "30")
    r = client.post(
        "/api/planes/tax/sell-preview",
        headers=h,
        json={"amount": "150", "asset_id": a["id"], "base_general": "30000"},
    )
    assert r.status_code == 200, r.text
    s = r.json()
    # 150 € a 30 € = 5 participaciones del lote antiguo (coste 50) → ganancia 100
    assert D(s["gain"]) == D("100.00") and D(s["available"]) == D("600.00")
    assert D(s["tax"]) > 0 and D(s["net"]) == D("150.00") - D(s["tax"])
    # Toda la cartera (un solo activo aquí) y un importe imposible
    assert (
        client.post("/api/planes/tax/sell-preview", headers=h, json={"amount": "150"}).json()[
            "gain"
        ]
        == "100.00"
    )
    bad = client.post("/api/planes/tax/sell-preview", headers=h, json={"amount": "5000"})
    assert bad.status_code == 422 and "Solo tienes" in bad.json()["detail"]
