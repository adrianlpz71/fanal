"""API de gastos (fase 2a): flujo completo del ciclo, cuotas, recurrentes y aislamiento."""

from datetime import date, timedelta
from decimal import Decimal as D

import pytest

from app.domain import calendar as cal
from tests.conftest import auth_header, enroll


@pytest.fixture
def h(client, make_user):
    make_user("ana@example.com")
    return auth_header(enroll(client, "ana@example.com"))


def setup_gastos(client, h, balance="500.00", **extra):
    body = {"bank": "Banco", "current_balance": balance, "payday_day": 27, **extra}
    r = client.post("/api/gastos/setup", json=body, headers=h)
    assert r.status_code == 201, r.text
    return r.json()


def add(client, h, concept, amount=None, **kw):
    body = {"concept": concept, **kw}
    if amount is not None:
        body["amount"] = amount
    r = client.post("/api/movements", json=body, headers=h)
    assert r.status_code in (200, 201), r.text
    return r.json()


def current(client, h):
    r = client.get("/api/cycles/current", headers=h)
    assert r.status_code == 200, r.text
    return r.json()


def test_setup_creates_cycle_accounts_and_categories(client, h):
    c = setup_gastos(client, h, refugio_bank="TR", refugio_balance="200.00",
                     emergency_target="4000.00")  # fmt: skip
    assert c["status"] == "open"
    assert c["summary"]["opening"] == "500.00"
    assert c["summary"]["expected_end"] == "500.00"
    accs = client.get("/api/accounts", headers=h).json()
    assert {a["kind"]: a["balance"] for a in accs} == {"gastos": "500.00", "refugio": "200.00"}
    cats = client.get("/api/categories", headers=h).json()
    assert any(c["name"] == "Comida fuera" for c in cats)
    assert client.post("/api/gastos/setup", json={"bank": "x", "current_balance": "1"},
                       headers=h).status_code == 409  # fmt: skip


def test_movements_posted_planned_and_expression(client, h):
    setup_gastos(client, h)
    add(client, h, "Hamburguesa", "-15.00")
    add(client, h, "Fibra", "-9.00", status="planned")
    m = add(client, h, "Cena", expression="=-60+20+12")
    assert m["amount"] == "-28.00"
    assert [ln["amount"] for ln in m["lines"]] == ["-60.00", "20.00", "12.00"]
    s = current(client, h)["summary"]
    assert s["available_now"] == "457.00"  # 500 - 15 - 28
    assert s["expected_end"] == "448.00"  # - 9 previsto
    assert s["pending_total"] == "-9.00"
    bad = client.post("/api/movements", json={"concept": "x", "expression": "=A1+2"}, headers=h)
    assert bad.status_code == 422


def test_client_generated_id_is_idempotent(client, h):
    setup_gastos(client, h)
    mid = "0192f0a0-0000-7000-8000-000000000001"
    a = client.post(
        "/api/movements", json={"id": mid, "concept": "Café", "amount": "-2"}, headers=h
    )
    b = client.post(
        "/api/movements", json={"id": mid, "concept": "Café", "amount": "-2"}, headers=h
    )
    assert (a.status_code, b.status_code) == (201, 200)
    assert len(current(client, h)["movements"]) == 1


def test_mark_posted_edit_duplicate_delete(client, h):
    setup_gastos(client, h)
    m = add(client, h, "Fibra", "-9.00", status="planned")
    r = client.patch(f"/api/movements/{m['id']}", json={"status": "posted"}, headers=h)
    assert r.json()["status"] == "posted" and r.json()["date"] == date.today().isoformat()
    # Vuelve a previsto: la fecha de cargo pasa a ser la prevista (no parece "cargado el …")
    r = client.patch(f"/api/movements/{m['id']}", json={"status": "planned"}, headers=h)
    assert r.json()["status"] == "planned" and r.json()["date"] is None
    assert r.json()["due_date"] == date.today().isoformat()
    r = client.patch(f"/api/movements/{m['id']}", json={"status": "posted"}, headers=h)
    assert r.json()["date"] == date.today().isoformat()
    d = client.post(f"/api/movements/{m['id']}/duplicate", headers=h).json()
    assert d["amount"] == "-9.00" and d["id"] != m["id"]
    assert client.delete(f"/api/movements/{d['id']}", headers=h).status_code == 204
    assert current(client, h)["summary"]["available_now"] == "491.00"


def test_suggestions_from_history_and_keywords(client, h):
    setup_gastos(client, h)
    cats = {c["name"]: c["id"] for c in client.get("/api/categories", headers=h).json()}
    add(client, h, "Burger Bar", "-15.00", category_id=cats["Fast food"])
    s = client.get("/api/movements/suggest", params={"q": "burg"}, headers=h).json()
    assert s[0]["concept"] == "Burger Bar" and s[0]["amount"] == "-15.00"
    s2 = client.get("/api/movements/suggest", params={"q": "Netflix"}, headers=h).json()
    assert s2[0]["category_id"] == cats["Streaming"]


def test_transfer_creates_linked_pair_not_counted_as_spend(client, h):
    setup_gastos(client, h, refugio_bank="TR", refugio_balance="200.00")
    accs = {a["kind"]: a["id"] for a in client.get("/api/accounts", headers=h).json()}
    add(client, h, "Ahorro", "-200.00", kind="transferencia", to_account_id=accs["refugio"])
    bal = {a["kind"]: a["balance"] for a in client.get("/api/accounts", headers=h).json()}
    assert bal == {"gastos": "300.00", "refugio": "400.00"}
    s = current(client, h)["summary"]
    assert s["savings"] == "200.00" and s["variable_spend"] == "0.00"


def test_payday_closes_with_discrepancy_and_carries_pending(client, h):
    setup_gastos(client, h)
    add(client, h, "Cena", "-100.00")
    keep = add(client, h, "Fibra", "-9.00", status="planned")
    drop = add(client, h, "Cuota rara", "-50.00", status="planned")
    cur = current(client, h)
    r = client.post("/api/cycles/payday", headers=h, json={
        "payroll_amount": "1845.00", "payroll_date": date.today().isoformat(),
        "real_balance_before": "395.00",  # calculado 400 → descuadre -5
        "pending_actions": {drop["id"]: "cancel"},
    })  # fmt: skip
    assert r.status_code == 200, r.text
    out = r.json()
    assert out["discrepancy"] == "-5.00" and out["carried_over"] == 1 and out["cancelled"] == 1
    new = out["opened"]
    assert new["summary"]["opening"] == "2240.00"  # 395 + 1845
    assert new["summary"]["expected_end"] == "2231.00"  # - la fibra pasa al nuevo ciclo
    assert new["label"] == cal.key_from_label(cur["label"]).next().label
    old = client.get(f"/api/cycles/{cur['id']}", headers=h).json()
    assert old["status"] == "closed"
    assert any(m["concept"] == "Ajuste de cuadre" and m["amount"] == "-5.00"
               for m in old["movements"])  # fmt: skip
    moved = [m for m in current(client, h)["movements"] if m["id"] == keep["id"]]
    assert moved and moved[0]["status"] == "planned"
    acc = client.get("/api/accounts", headers=h).json()[0]
    assert acc["balance"] == "2240.00"  # cuenta = real + nómina


def test_recurring_generated_on_payday_and_price_change_detected(client, h):
    setup_gastos(client, h)
    today = date.today()
    t = client.post("/api/recurring", headers=h, json={
        "concept": "Claude", "amount": "-108.00", "day_of_month": 1,
        "start_date": (today - timedelta(days=400)).isoformat(), "amount_is_estimate": True,
    }).json()  # fmt: skip
    assert t["monthly_cost"] == "108.00" and t["yearly_cost"] == "1296.00"
    # Al crearlo ya se genera el cargo de este ciclo; en "He cobrado" se cancela ese previsto
    # para quedarnos solo con el que genera el ciclo nuevo.
    old = [m["id"] for m in current(client, h)["movements"] if m["source"] == "recurring"]
    assert len(old) == 1
    client.post("/api/cycles/payday", headers=h, json={
        "payroll_amount": "1800", "payroll_date": today.isoformat(), "real_balance_before": "500",
        "pending_actions": {old[0]: "cancel"},
    })  # fmt: skip
    gen = [m for m in current(client, h)["movements"] if m["source"] == "recurring"]
    assert len(gen) == 1 and gen[0]["amount"] == "-108.00" and gen[0]["status"] == "planned"
    # Cargo real de 91 € (−15,7 % > 10 %): aviso + la plantilla pasa a 91
    client.patch(f"/api/movements/{gen[0]['id']}", json={"amount": "-91.00", "status": "posted"},
                 headers=h)  # fmt: skip
    t2 = client.get("/api/recurring", headers=h).json()[0]
    assert t2["amount"] == "-91.00"
    assert [(c["old_amount"], c["new_amount"]) for c in t2["price_changes"]] == [
        ("-108.00", "-91.00")
    ]
    assert (
        client.post(f"/api/recurring/{t2['id']}/ack-price", headers=h).json()["price_changes"] == []
    )


def test_installment_plan_lifecycle_and_forecast(client, h):
    setup_gastos(client, h, usual_payroll="1845.00")
    today = date.today()
    p = client.post("/api/installments", headers=h, json={
        "description": "OP Box", "provider": "paypal", "total": "476.00", "n": 3,
        "first_due": today.isoformat(), "paid_count": 1,
    }).json()  # fmt: skip
    assert [i["amount"] for i in p["installments"]] == ["158.66", "158.66", "158.68"]
    assert p["paid"] == 1 and p["remaining_amount"] == "317.34"
    fc = client.get("/api/forecast", params={"months": 3}, headers=h).json()
    assert fc["live_installment_debt"] == "317.34"
    assert D(fc["months"][0]["installments"]) + D(fc["months"][1]["installments"]) <= D(0)
    assert fc["months"][0]["payroll"] == "1845.00"
    # Adelantar: las 2 restantes en un solo cargo previsto en el ciclo actual
    adv = client.post(f"/api/installments/{p['id']}/advance", json={"merge": True}, headers=h)
    assert adv.json() == {"moved": 2, "amount": "317.34"}
    merged = [m for m in current(client, h)["movements"] if "adelanto" in m["concept"]]
    assert merged and merged[0]["amount"] == "-317.34"
    assert client.get("/api/forecast", headers=h).json()["live_installment_debt"] == "0.00"
    assert client.get(f"/api/installments/{p['id']}", headers=h).json()["status"] == "liquidada"


def test_posting_installment_marks_it_paid_and_cancel_plan(client, h):
    setup_gastos(client, h)
    p = client.post("/api/installments", headers=h, json={
        "description": "Zapatillas", "total": "141.00", "n": 3,
        "first_due": date.today().isoformat(),
    }).json()  # fmt: skip
    first = next(m for m in current(client, h)["movements"] if m["source"] == "installment")
    client.patch(f"/api/movements/{first['id']}", json={"status": "posted"}, headers=h)
    p2 = client.get(f"/api/installments/{p['id']}", headers=h).json()
    assert p2["paid"] == 1 and p2["installments"][0]["status"] == "pagada"
    assert client.delete(f"/api/movements/{first['id']}", headers=h).status_code == 409
    c = client.post(f"/api/installments/{p['id']}/cancel", headers=h).json()
    assert c["status"] == "cancelada"
    assert [i["status"] for i in c["installments"]] == ["pagada", "cancelada", "cancelada"]


def test_reconcile_creates_adjustment(client, h):
    setup_gastos(client, h, balance="801.00")
    acc = client.get("/api/accounts", headers=h).json()[0]
    r = client.post(f"/api/accounts/{acc['id']}/reconcile", json={"real_balance": "845.30"},
                    headers=h).json()  # fmt: skip
    assert r["difference"] == "44.30" and r["adjustment_id"]
    assert client.get("/api/accounts", headers=h).json()[0]["balance"] == "845.30"


def test_isolation_between_users(client, make_user):
    make_user("ana@example.com")
    make_user("bea@example.com")
    ha = auth_header(enroll(client, "ana@example.com"))
    hb = auth_header(enroll(client, "bea@example.com"))
    setup_gastos(client, ha)
    setup_gastos(client, hb)
    m = add(client, ha, "Secreto", "-1.00")
    cyc = current(client, ha)
    p = client.post(
        "/api/installments",
        headers=ha,
        json={"description": "x", "total": "10", "n": 2, "first_due": date.today().isoformat()},
    ).json()
    t = client.post(
        "/api/recurring",
        headers=ha,
        json={"concept": "x", "amount": "-1", "start_date": date.today().isoformat()},
    ).json()
    acc_a = client.get("/api/accounts", headers=ha).json()[0]["id"]
    for method, url, body in [
        ("PATCH", f"/api/movements/{m['id']}", {"concept": "hack"}),
        ("DELETE", f"/api/movements/{m['id']}", None),
        ("POST", f"/api/movements/{m['id']}/duplicate", None),
        ("GET", f"/api/cycles/{cyc['id']}", None),
        ("GET", f"/api/installments/{p['id']}", None),
        ("POST", f"/api/installments/{p['id']}/cancel", None),
        ("PATCH", f"/api/recurring/{t['id']}", {"active": False}),
        ("POST", f"/api/accounts/{acc_a}/reconcile", {"real_balance": "0"}),
        ("POST", "/api/movements", {"concept": "x", "amount": "-1", "account_id": acc_a}),
        ("POST", "/api/movements", {"concept": "x", "amount": "-1", "id": m["id"]}),
    ]:
        r = client.request(method, url, json=body, headers=hb)
        assert r.status_code == 404, f"{method} {url} → {r.status_code}"
    assert all(x["concept"] != "Secreto" for x in current(client, hb)["movements"])
    assert client.get("/api/movements/suggest", params={"q": "Secr"}, headers=hb).json() == []


def test_planned_date_is_the_due_date(client, h):
    """En un previsto, la fecha que llega es la prevista (antes la app la mandaba como `date` y el
    previsto se quedaba con la antigua)."""
    setup_gastos(client, h)
    d1, d2 = date.today(), date.today() + timedelta(days=1)
    m = add(client, h, "Fibra", "-9.00", status="planned", date=d1.isoformat())
    assert m["due_date"] == d1.isoformat() and m["date"] is None
    # Con la fecha como `date` (app anterior) o como `due_date` (la de ahora): cambia la prevista
    r = client.patch(
        f"/api/movements/{m['id']}", json={"status": "planned", "date": d2.isoformat()}, headers=h
    ).json()
    assert r["due_date"] == d2.isoformat() and r["date"] is None
    r = client.patch(
        f"/api/movements/{m['id']}",
        json={"status": "planned", "due_date": d1.isoformat()},
        headers=h,
    ).json()
    assert r["due_date"] == d1.isoformat() and r["date"] is None
    # Al cargarlo, la fecha es la de cargo
    r = client.patch(
        f"/api/movements/{m['id']}", json={"status": "posted", "date": d2.isoformat()}, headers=h
    ).json()
    assert r["status"] == "posted" and r["date"] == d2.isoformat()
