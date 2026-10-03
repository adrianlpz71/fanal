"""Historial de aportaciones: los totales cuadran con la suma de las operaciones y traspasos."""

from datetime import date, timedelta
from decimal import Decimal as D

from app.domain.contributions import APORTACION, PARTIDA, RETIRADA, TRASPASO, Flow, streak, totals
from tests.test_api_gastos import setup_gastos
from tests.test_api_inversiones import TODAY, build, h, post  # noqa: F401


def test_domain_totals_pace_and_streak():
    today = date(2026, 10, 3)
    flows = [
        Flow(date(2026, 10, 1), D("300"), APORTACION, "a"),
        Flow(date(2026, 9, 1), D("300"), APORTACION, "a"),
        Flow(date(2026, 8, 1), D("200"), APORTACION, "b"),
        Flow(date(2026, 6, 1), D("100"), APORTACION, "a"),  # julio sin aportar: corta la racha
        Flow(date(2025, 9, 1), D("999"), APORTACION, "a"),  # fuera de los 12 meses del ritmo
        Flow(date(2026, 9, 15), D("50"), RETIRADA, "a"),
        Flow(date(2026, 9, 15), D("70"), TRASPASO, "a"),
        Flow(date(2026, 1, 1), D("1000"), PARTIDA, "a"),
    ]
    t = totals(flows, today)
    assert t.this_month == D("300") and t.this_year == D("900") and t.total == D("1899")
    assert t.withdrawn == D("50") and t.starting == D("1000")
    assert t.pace == D("75.00")  # 900 / 12
    assert t.streak == 3  # ago, sep y oct
    # Si este mes aún no has aportado, la racha cuenta hasta el mes anterior
    assert streak({(2026, 9), (2026, 8)}, today) == 2


def test_api_contributions_match_transactions(client, h):  # noqa: F811
    setup_gastos(client, h)
    _, ids = build(client, h)  # posiciones iniciales = saldo de partida
    ago = (TODAY - timedelta(days=40)).isoformat()
    post(
        client,
        h,
        "/api/inv/transactions",
        {
            "asset_id": ids["msci"],
            "kind": "compra",
            "trade_date": ago,
            "units": "10",
            "amount_eur": "150",
            "fee": "1.50",
        },
    )
    post(
        client,
        h,
        "/api/inv/transactions",
        {
            "asset_id": ids["btc"],
            "kind": "compra",
            "trade_date": TODAY.isoformat(),
            "units": "0.001",
            "amount_eur": "71.50",
        },
    )
    post(
        client,
        h,
        "/api/inv/transactions",
        {
            "asset_id": ids["em"],
            "kind": "venta",
            "trade_date": TODAY.isoformat(),
            "units": "0.1",
            "amount_eur": "26.89",
        },
    )
    # Ahorro: traspaso de la cuenta de gastos a una cuenta de ahorro
    acc = post(
        client, h, "/api/accounts", {"name": "Ahorro", "kind": "ahorro", "opening_balance": "0"}
    )
    body = {
        "concept": "A ahorro",
        "amount": "-200.00",
        "kind": "transferencia",
        "status": "posted",
        "to_account_id": acc["id"],
        "date": TODAY.isoformat(),
    }
    post(client, h, "/api/movements", body)

    r = client.get("/api/analytics/contributions", headers=h).json()
    items = r["items"]
    sum_type = lambda t: sum(D(i["amount"]) for i in items if i["type"] == t)  # noqa: E731
    assert D(r["total"]) == sum_type("aportacion") == D("151.50") + D("71.50") + D("200.00")
    assert D(r["withdrawn"]) == sum_type("retirada") == D("26.89")
    assert D(r["starting"]) == sum_type("partida") > 0  # posiciones iniciales, aparte
    assert D(r["this_month"]) == D("271.50")
    assert sum(D(m["total"]) for m in r["months"]) == D(r["total"])
    saving = next(i for i in items if i["kind"] == "ahorro")
    assert saving["destination_label"] == "Ahorro" and saving["origin"] == "cuenta de gastos"
    assert {d["kind"] for d in r["destinations"]} == {"inversion", "ahorro"}
    assert r["streak"] >= 1
    # Ritmo de la Cartera: solo inversiones (151,50 + 71,50 este mes), sin la cuenta de ahorro
    assert D(r["pace_investing"]) == ((D("151.50") + D("71.50")) / 12).quantize(D("0.01"))
    assert D(r["pace"]) == ((D("151.50") + D("71.50") + D("200.00")) / 12).quantize(D("0.01"))
    assert 1 <= r["streak_investing"] <= r["streak"]
