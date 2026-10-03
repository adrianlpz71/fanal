"""Patrimonio, rentabilidad y exposición (fase 4) con datos inventados."""

from datetime import date, timedelta
from decimal import Decimal as D

import pytest
from sqlalchemy import select

from app.db import SessionLocal
from app.models import Asset, PriceHistory, User
from app.services import analytics as an
from tests.conftest import auth_header, enroll
from tests.test_api_gastos import setup_gastos

TODAY = date.today()
T0 = TODAY - timedelta(days=70)


@pytest.fixture
def h(client, make_user):
    make_user("ana@example.com")
    return auth_header(enroll(client, "ana@example.com"))


def _fund(client, h, name="Fondo", isin=None):
    cls = {c["name"]: c["id"] for c in client.get("/api/inv/classes", headers=h).json()}
    return client.post(
        "/api/inv/assets",
        headers=h,
        json={"name": name, "type": "fondo", "asset_class_id": cls["Fondos"], "isin": isin},
    ).json()


def _buy(client, h, aid, on, units, amount):
    r = client.post(
        "/api/inv/transactions",
        headers=h,
        json={
            "asset_id": aid,
            "kind": "compra",
            "trade_date": on.isoformat(),
            "units": units,
            "amount_eur": amount,
        },
    )
    assert r.status_code == 201, r.text


def _price(aid, on, price):
    with SessionLocal() as db:
        a = db.get(Asset, aid)
        db.add(
            PriceHistory(
                user_id=a.user_id,
                asset_id=a.id,
                date=on,
                price=D(price),
                source="manual",
                fetched_at=a.created_at,
            )
        )
        db.commit()


def test_performance_series_and_kpis(client, h):
    a = _fund(client, h)
    _buy(client, h, a["id"], T0, "100", "1000")  # 10 €/part.
    _price(a["id"], T0 + timedelta(days=30), "11")  # +10 %
    _buy(client, h, a["id"], T0 + timedelta(days=40), "50", "550")  # a 11 €
    _price(a["id"], T0 + timedelta(days=60), "9.9")  # −10 %
    p = client.get("/api/analytics/performance", headers=h).json()
    assert p["first"] == T0.isoformat()
    assert p["contributed"] == "1550.00" and p["value"] == "1485.00"  # 150 × 9,90
    assert p["gain"] == "-65.00"
    # TWR: +10 % y luego −10 % = −1 % (independiente de cuándo aporté)
    assert abs(D(p["twr"]) - D("-0.01")) < D("0.0001")
    assert D(p["max_drawdown"]) == D("-0.1")
    assert p["xirr"] is not None and D(p["xirr"]) < 0
    assert p["series"][-1]["contributed"] == "1550.00"
    # Por activo da lo mismo (solo hay uno)
    one = client.get(f"/api/analytics/performance?asset_id={a['id']}", headers=h).json()
    assert one["twr"] == p["twr"]


def test_transfer_is_not_a_flow_for_the_whole_portfolio(client, h):
    a, b = _fund(client, h, "A"), _fund(client, h, "B")
    _buy(client, h, a["id"], T0, "10", "100")
    r = client.post(
        "/api/inv/transfers",
        headers=h,
        json={
            "from_asset_id": a["id"],
            "to_asset_id": b["id"],
            "trade_date": (T0 + timedelta(days=5)).isoformat(),
            "units_out": "10",
            "units_in": "5",
            "amount_eur": "100",
        },
    )
    assert r.status_code == 201, r.text
    _price(b["id"], T0 + timedelta(days=5), "20")
    total = client.get("/api/analytics/performance", headers=h).json()
    assert total["contributed"] == "100.00"  # el traspaso no suma aportación
    only_b = client.get(f"/api/analytics/performance?asset_id={b['id']}", headers=h).json()
    assert only_b["contributed"] == "100.00"  # para B, el traspaso sí es su entrada


def test_networth_with_tax_estimate(client, h):
    setup_gastos(client, h, balance="1000.00")
    a = _fund(client, h)
    _buy(client, h, a["id"], T0, "100", "1000")
    _price(a["id"], TODAY, "80")  # ganancia latente 7.000 €
    client.post(
        "/api/debts",
        headers=h,
        json={
            "name": "Préstamo",
            "direction": "debo",
            "opening_balance": "300.00",
            "opening_date": T0.isoformat(),
        },
    )
    n = client.get("/api/analytics/networth", headers=h).json()
    assert n["investments"] == "8000.00" and n["unrealized_gain"] == "7000.00"
    # Base del ahorro 2026: 6.000 × 19 % + 1.000 × 21 % = 1.350 €
    assert n["tax_if_sold"] == "1350.00" and n["tax_year"] == 2026
    assert n["tax_source"].startswith("https://www.boe.es/")
    acc = sum(D(x["balance"]) for x in n["accounts"])
    assert D(n["total"]) == acc + D("8000.00") - D(n["debts"])
    assert D(n["after_tax"]) == D(n["total"]) - D("1350.00")
    hist = client.get("/api/analytics/networth/history", headers=h).json()
    assert hist[-1]["investments"] == "8000.00"


def test_savings_tax_brackets():
    scale = {
        "tramos": [
            {"hasta": "6000", "tipo": "0.19"},
            {"hasta": "50000", "tipo": "0.21"},
            {"hasta": None, "tipo": "0.23"},
        ]
    }
    assert an.savings_tax(D("5000"), scale) == D("950.00")
    assert an.savings_tax(D("60000"), scale) == D("1140") + D("9240") + D("2300")
    assert an.savings_tax(D("-10"), scale) == 0


def test_exposure_with_manual_weights_and_unknowns(client, h):
    a = _fund(client, h, "Mundo")
    _buy(client, h, a["id"], T0, "100", "1000")
    cls = {c["name"]: c["id"] for c in client.get("/api/inv/classes", headers=h).json()}
    btc = client.post(
        "/api/inv/assets",
        headers=h,
        json={"name": "BTC", "type": "cripto", "asset_class_id": cls["Cripto"]},
    ).json()
    _buy(client, h, btc["id"], T0, "0.01", "1000")
    r = client.put(
        f"/api/analytics/exposure/{a['id']}",
        headers=h,
        json=[
            {"dimension": "pais", "key": "Estados Unidos", "weight": "0.6"},
            {"dimension": "pais", "key": "Japón", "weight": "0.1"},
        ],
    )
    assert r.status_code == 200, r.text
    e = client.get("/api/analytics/exposure", headers=h).json()
    pais = {x["key"]: x["weight"] for x in e["pais"]}
    assert pais == {
        "Estados Unidos": "0.3",
        "Global (cripto)": "0.5",
        "Sin datos": "0.15",
        "Japón": "0.05",
    }
    assert {x["key"] for x in e["tipo"]} == {"Fondos", "Cripto"}
    bad = client.put(
        f"/api/analytics/exposure/{a['id']}",
        headers=h,
        json=[{"dimension": "pais", "key": "X", "weight": "1.2"}],
    )
    assert bad.status_code == 422


def test_isolation(client, h, make_user):
    a = _fund(client, h)
    make_user("eva@example.com")
    h2 = auth_header(enroll(client, "eva@example.com"))
    assert (
        client.get(f"/api/analytics/performance?asset_id={a['id']}", headers=h2).status_code == 404
    )
    assert client.get(f"/api/analytics/exposure/{a['id']}", headers=h2).status_code == 404
    with SessionLocal() as db:
        assert db.scalar(select(User).where(User.email == "eva@example.com")) is not None


def test_track_start_summarizes_earlier_history(client, h):
    """Inicio del seguimiento: lo anterior se resume y la rentabilidad empieza ese día."""
    a = _fund(client, h)
    old, start = TODAY - timedelta(days=700), TODAY - timedelta(days=40)
    _buy(client, h, a["id"], old, "10", "100")  # compra suelta de hace dos años, a 10 €
    _price(a["id"], start - timedelta(days=5), "15")  # cuando empieza el seguimiento vale 150 €
    _buy(client, h, a["id"], start + timedelta(days=5), "10", "150")  # y aquí se toma en serio
    full = client.get("/api/analytics/performance", headers=h).json()
    assert full["before_until"] is None and full["first"] == old.isoformat()

    r = client.put("/api/inv/settings", headers=h, json={"track_start": start.isoformat()})
    assert r.status_code == 200 and r.json()["track_start"] == start.isoformat()
    p = client.get("/api/analytics/performance", headers=h).json()
    assert p["first"] == start.isoformat()
    assert p["before_until"] == (start - timedelta(days=1)).isoformat()
    assert D(p["before_contributed"]) == D(100) and D(p["before_value"]) == D(150)
    # El capital de partida cuenta como aportado: 150 de partida + 150 nuevos
    assert D(p["contributed"]) == D(300) and D(p["value"]) == D(300)
    assert D(p["twr"]) == 0  # sin cambios de precio desde el inicio: 0 %, no +50 %
    assert all((m["year"], m["month"]) >= (start.year, start.month) for m in p["months"])
    assert p["series"][0]["date"] == (start - timedelta(days=1)).isoformat()
    # El patrimonio, en cambio, no se recorta: enseña todo el histórico (desde la primera compra)
    hist = client.get("/api/analytics/networth/history", headers=h).json()
    assert (
        hist
        and hist[0]["date"] < start.isoformat()
        and hist[0]["date"] <= (old + timedelta(days=7)).isoformat()
    )

    # Quitarlo vuelve a mirar desde la primera operación
    client.put("/api/inv/settings", headers=h, json={"clear_track_start": True})
    assert client.get("/api/analytics/performance", headers=h).json()["first"] == old.isoformat()
