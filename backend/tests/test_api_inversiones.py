"""API de inversiones (fase 3a): cartera de ejemplo (inventada) de punta a punta."""

from datetime import date, timedelta
from decimal import Decimal as D

import pytest

from tests.conftest import auth_header, enroll
from tests.test_api_gastos import setup_gastos

TODAY = date.today()


@pytest.fixture
def h(client, make_user):
    make_user("ana@example.com")
    return auth_header(enroll(client, "ana@example.com"))


def post(client, h, url, body, code=201):
    r = client.post(url, json=body, headers=h)
    assert r.status_code == code, r.text
    return r.json()


def build(client, h):
    """Cartera de ejemplo: 3 fondos en MyInvestor, BTC en Neverless y 2 acciones sin comprar."""
    cls = {c["name"]: c["id"] for c in client.get("/api/inv/classes", headers=h).json()}
    myi = post(client, h, "/api/inv/platforms", {"name": "MyInvestor", "units_decimals": 4})
    nev = post(client, h, "/api/inv/platforms", {"name": "Neverless", "kind": "exchange",
                                                  "units_decimals": 8})  # fmt: skip
    ids = {}
    for key, name, typ, c, plat, units, pmp, price in [
        ("msci", "MSCI World", "fondo", "Fondos", myi, "95.00", "11.20", "15.10"),
        ("em", "Emerging Markets", "fondo", "Fondos", myi, "1.15", "205.40", "268.90"),
        ("sc", "Small Caps", "fondo", "Fondos", myi, "0.55", "300.15", "371.80"),
        ("btc", "Bitcoin", "cripto", "Cripto", nev, "0.00250", "58200", "71500"),
    ]:
        a = post(client, h, "/api/inv/assets", {"name": name, "type": typ,
                 "asset_class_id": cls[c], "platform_id": plat["id"]})  # fmt: skip
        ids[key] = a["id"]
        post(client, h, "/api/inv/transactions", {
            "asset_id": a["id"], "kind": "posicion_inicial", "trade_date": TODAY.isoformat(),
            "units": units, "avg_cost": pmp, "amount_eur": "0",
        })  # fmt: skip
        r = client.put(f"/api/inv/assets/{a['id']}/prices", headers=h,
                       json={"date": TODAY.isoformat(), "price": price})  # fmt: skip
        assert r.status_code == 200, r.text
    for key, name in [("accion_a", "Acción A"), ("accion_b", "Acción B")]:
        ids[key] = post(client, h, "/api/inv/assets", {"name": name, "type": "accion",
                        "asset_class_id": cls["Acciones"]})["id"]  # fmt: skip
    r = client.put("/api/inv/targets", headers=h, json={
        "macro": [
            {"asset_class_id": cls["Fondos"], "target": "0.90", "min": "0.70", "max": "0.95"},
            {"asset_class_id": cls["Cripto"], "target": "0.10", "min": "0.10", "max": "0.25"},
            {"asset_class_id": cls["Acciones"], "target": "0", "min": "0", "max": "0.05"},
        ],
        "assets": [
            {"asset_id": ids["msci"], "target": "0.70"}, {"asset_id": ids["em"], "target": "0.18"},
            {"asset_id": ids["sc"], "target": "0.12"}, {"asset_id": ids["btc"], "target": "1"},
            {"asset_id": ids["accion_a"], "target": "0.45"},
            {"asset_id": ids["accion_b"], "target": "0.55"},
        ],
    })  # fmt: skip
    assert r.status_code == 200, r.text
    return cls, ids


def test_portfolio_matches_excel(client, h):
    build(client, h)
    p = client.get("/api/inv/portfolio", headers=h).json()
    assert (p["value"], p["cost"], p["pnl"]) == ("2126.98", "1610.79", "516.18")
    assert round(D(p["pnl_pct"]) * 100, 2) == D("32.05")
    by = {c["asset_class"]["name"]: c for c in p["classes"]}
    assert round(D(by["Fondos"]["weight"]) * 100, 2) == D("91.60")
    assert by["Fondos"]["status"] == "ok" and by["Cripto"]["status"] == "bajo"
    st = {x["asset"]["name"]: x["inner_status"] for x in by["Fondos"]["positions"]}
    assert st == {
        "MSCI World": "no_comprar",
        "Emerging Markets": "comprar",
        "Small Caps": "comprar",
    }


def test_contribution_engine_and_orders(client, h):
    setup_gastos(client, h)
    _, ids = build(client, h)
    s = post(client, h, "/api/inv/contribution/suggest", {"amount": "300"}, 200)
    amounts = {o["asset_name"]: o["amount"] for o in s["orders"]}
    assert amounts == {"MSCI World": "94.49", "Emerging Markets": "83.94", "Small Caps": "57.62",
                       "Bitcoin": "63.95"}  # fmt: skip
    # Redondeado a euros enteros (opción de la pantalla Aportar): misma suma, sin céntimos
    r = post(client, h, "/api/inv/contribution/suggest", {"amount": "300", "round_to": "1"}, 200)
    rounded = {o["asset_name"]: o["amount"] for o in r["orders"]}
    assert rounded == {
        "MSCI World": "94.00",
        "Emerging Markets": "84.00",
        "Small Caps": "58.00",
        "Bitcoin": "64.00",
    }
    em = next(o for o in s["orders"] if o["asset_name"] == "Emerging Markets")
    assert em["approx_units"] == "0.3121"  # 83,94 / 268,90 truncado a 4 decimales

    acc = client.get("/api/accounts", headers=h).json()[0]
    txs = post(client, h, "/api/inv/contribution/orders", {
        "orders": [{"asset_id": o["asset_id"], "amount": o["amount"]} for o in s["orders"]],
        "trade_date": TODAY.isoformat(), "from_account_id": acc["id"],
    })  # fmt: skip
    assert len(txs) == 4 and all(t["status"] == "pendiente_vl" for t in txs)
    # La transferencia queda prevista en el ciclo de gastos (no cuenta como gasto)
    cur = client.get("/api/cycles/current", headers=h).json()
    tr = [m for m in cur["movements"] if m["concept"].startswith("Aportación inversión")]
    assert tr and tr[0]["amount"] == "-300.00" and tr[0]["kind"] == "transferencia"
    # Con lo pendiente ya repartido, una segunda sugerencia no vuelve a cargar EM igual
    p = client.get("/api/inv/portfolio", headers=h).json()
    assert p["pending"] == "300.00" and p["value"] == "2126.98"

    # Liquidar con el VL del día
    msci_tx = next(t for t in txs if t["asset_id"] == ids["msci"])
    st = post(client, h, f"/api/inv/transactions/{msci_tx['id']}/settle", {"price": "15.10"}, 200)
    assert st["status"] == "liquidada" and st["units"] == "6.2576"  # 94,49 / 15,10
    d = client.get(f"/api/inv/assets/{ids['msci']}", headers=h).json()
    assert d["position"]["units"] == "101.2576"
    assert len(d["lots"]) == 2


def test_buy_sell_fifo_and_validation(client, h):
    cls = {c["name"]: c["id"] for c in client.get("/api/inv/classes", headers=h).json()}
    a = post(client, h, "/api/inv/assets", {"name": "Fondo X", "type": "fondo",
             "asset_class_id": cls["Fondos"]})  # fmt: skip
    d0 = TODAY - timedelta(days=400)
    for d, units, amount in [(d0, "10", "100"), (d0 + timedelta(days=100), "10", "200")]:
        post(client, h, "/api/inv/transactions", {"asset_id": a["id"], "kind": "compra",
             "trade_date": d.isoformat(), "units": units, "amount_eur": amount})  # fmt: skip
    r = client.post(
        "/api/inv/transactions",
        headers=h,
        json={
            "asset_id": a["id"],
            "kind": "venta",
            "trade_date": TODAY.isoformat(),
            "units": "25",
            "amount_eur": "500",
        },
    )
    assert r.status_code == 422
    post(client, h, "/api/inv/transactions", {"asset_id": a["id"], "kind": "venta",
         "trade_date": TODAY.isoformat(), "units": "15", "amount_eur": "375"})  # fmt: skip
    d = client.get(f"/api/inv/assets/{a['id']}", headers=h).json()
    (r,) = d["realized"]
    assert (r["gain_fifo"], r["gain_pmp"]) == ("175.00", "150.00")
    assert d["position"]["units"] == "5"


def test_transfer_keeps_lots_and_correction_is_audited(client, h):
    cls = {c["name"]: c["id"] for c in client.get("/api/inv/classes", headers=h).json()}
    a = post(
        client,
        h,
        "/api/inv/assets",
        {"name": "A", "type": "fondo", "asset_class_id": cls["Fondos"]},
    )
    b = post(
        client,
        h,
        "/api/inv/assets",
        {"name": "B", "type": "fondo", "asset_class_id": cls["Fondos"]},
    )
    d0 = date(2024, 1, 2)
    post(client, h, "/api/inv/transactions", {"asset_id": a["id"], "kind": "compra",
         "trade_date": d0.isoformat(), "units": "10", "amount_eur": "100"})  # fmt: skip
    post(
        client,
        h,
        "/api/inv/transfers",
        {
            "from_asset_id": a["id"],
            "to_asset_id": b["id"],
            "trade_date": "2025-01-02",
            "units_out": "10",
            "units_in": "4",
            "amount_eur": "130",
        },
    )
    db_ = client.get(f"/api/inv/assets/{b['id']}", headers=h).json()
    assert db_["lots"] == [{"acquired": "2024-01-02", "units": "10", "cost": "100.00"}] or (
        db_["lots"][0]["acquired"] == "2024-01-02" and db_["lots"][0]["cost"] == "100.00"
    )
    assert client.get(f"/api/inv/assets/{a['id']}", headers=h).json()["position"]["units"] == "0"

    r = client.post(
        f"/api/inv/assets/{b['id']}/correction",
        headers=h,
        json={"units": "4.5", "avg_cost": "22", "reason": "Ajuste con el extracto"},
    )
    assert r.status_code == 200, r.text
    assert r.json()["units"] == "4.5" and r.json()["cost"] == "99.00"


def test_targets_must_sum_100(client, h):
    cls = {c["name"]: c["id"] for c in client.get("/api/inv/classes", headers=h).json()}
    r = client.put("/api/inv/targets", headers=h, json={"macro": [
        {"asset_class_id": cls["Fondos"], "target": "0.8"},
        {"asset_class_id": cls["Cripto"], "target": "0.1"},
    ]})  # fmt: skip
    assert r.status_code == 422


def test_manual_history_and_isolation(client, h, make_user):
    _, ids = build(client, h)
    r = client.put("/api/inv/history", headers=h, json={"date": "2026-04-30", "value": "1755",
                                                        "cost": "1400"})  # fmt: skip
    assert r.status_code == 200 and r.json()["manual"] is True
    make_user("eva@example.com")
    h2 = auth_header(enroll(client, "eva@example.com"))
    assert client.get(f"/api/inv/assets/{ids['msci']}", headers=h2).status_code == 404
    assert client.get("/api/inv/history", headers=h2).json() == []
    assert client.get("/api/inv/portfolio", headers=h2).json()["value"] == "0.00"
    r = client.post("/api/inv/transactions", headers=h2, json={"asset_id": ids["msci"],
                    "kind": "compra", "trade_date": TODAY.isoformat(), "units": "1",
                    "amount_eur": "1"})  # fmt: skip
    assert r.status_code == 404
