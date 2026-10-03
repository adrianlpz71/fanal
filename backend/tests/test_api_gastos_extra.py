"""Fase 2b: compartidos, deudas, seguimientos, reglas aprendidas, presupuestos y estadísticas."""

from datetime import date

import pytest

from tests.conftest import auth_header, enroll
from tests.test_api_gastos import add, current, setup_gastos


@pytest.fixture
def h(client, make_user):
    make_user("ana@example.com")
    hh = auth_header(enroll(client, "ana@example.com"))
    setup_gastos(client, hh, balance="1000.00")
    return hh


def cats(client, h):
    return {c["name"]: c["id"] for c in client.get("/api/categories", headers=h).json()}


def test_shared_expense_and_settle(client, h):
    m = add(client, h, "Cena", "-60.00")
    r = client.put(f"/api/movements/{m['id']}/shares", headers=h, json=[
        {"person_name": "Luis", "amount": "20.00"},
        {"person_name": "Marta", "amount": "12.00"},
    ])  # fmt: skip
    assert r.status_code == 200 and len(r.json()) == 2
    people = {p["name"]: p for p in client.get("/api/people", headers=h).json()}
    assert people["Luis"]["owed_to_me"] == "20.00" and people["Luis"]["net"] == "20.00"
    # El movimiento muestra sus partes
    mv = next(x for x in current(client, h)["movements"] if x["id"] == m["id"])
    assert {s["person_name"] for s in mv["shares"]} == {"Luis", "Marta"}
    # Luis devuelve su parte → reembolso vinculado, el gasto neto baja a 40
    sid = next(s["id"] for s in r.json() if s["person_name"] == "Luis")
    st = client.post(f"/api/shares/{sid}/settle", json={}, headers=h).json()
    assert st["share"]["status"] == "saldada" and st["movement_id"]
    s = current(client, h)["summary"]
    assert s["variable_spend"] == "40.00" and s["available_now"] == "960.00"
    people = {p["name"]: p for p in client.get("/api/people", headers=h).json()}
    assert people["Luis"]["net"] == "0.00" and people["Marta"]["net"] == "12.00"
    assert client.post(f"/api/shares/{sid}/settle", json={}, headers=h).status_code == 409
    # No se puede repartir más de lo que costó
    bad = client.put(f"/api/movements/{m['id']}/shares", headers=h,
                     json=[{"person_name": "X", "amount": "100"}])  # fmt: skip
    assert bad.status_code == 422


def test_i_owe_someone(client, h):
    m = add(client, h, "Entradas que pagó Bea", "-30.00", status="planned")
    client.put(f"/api/movements/{m['id']}/shares", headers=h,
               json=[{"person_name": "Bea", "amount": "30.00", "direction": "debo"}])  # fmt: skip
    bea = next(p for p in client.get("/api/people", headers=h).json() if p["name"] == "Bea")
    assert bea["i_owe"] == "30.00" and bea["net"] == "-30.00"


def test_debt_lifecycle(client, h):
    d = client.post("/api/debts", headers=h, json={
        "name": "Préstamo de Juan", "person_name": "Juan", "direction": "debo",
        "opening_balance": "500.00", "opening_date": date.today().isoformat(),
    }).json()  # fmt: skip
    assert d["remaining"] == "500.00" and d["status"] == "viva"
    d = client.post(f"/api/debts/{d['id']}/payments", json={"amount": "200"}, headers=h).json()
    assert d["remaining"] == "300.00" and d["paid"] == "200.00" and len(d["movements"]) == 1
    # El pago no cuenta como gasto (es transferencia de patrimonio)
    assert current(client, h)["summary"]["variable_spend"] == "0.00"
    d = client.post(f"/api/debts/{d['id']}/payments", json={"amount": "300"}, headers=h).json()
    assert d["remaining"] == "0.00" and d["status"] == "saldada"
    # Vincular un movimiento existente a una deuda (me deben)
    lent = client.post("/api/debts", headers=h, json={
        "name": "Dejé a Pablo", "direction": "me_deben", "opening_balance": "100",
        "opening_date": date.today().isoformat()}).json()  # fmt: skip
    mv = add(client, h, "Bizum Pablo", "40.00", kind="ingreso")
    client.patch(f"/api/movements/{mv['id']}", json={"debt_id": lent["id"]}, headers=h)
    lent = next(x for x in client.get("/api/debts", headers=h).json() if x["id"] == lent["id"])
    assert lent["remaining"] == "60.00"


def test_tracker_follows_category_and_keywords(client, h):
    c = cats(client, h)
    t = client.post("/api/trackers", headers=h, json={
        "name": "Bote del grupo", "opening_balance": "-300.00",
        "opening_date": date.today().isoformat(), "category_ids": [c["Compras"]],
    }).json()  # fmt: skip
    assert t["balance"] == "-300.00"
    add(client, h, "Entradas concierto", "-100.00", category_id=c["Compras"])
    add(client, h, "Me devuelve Laura", "50.00", kind="ingreso", category_id=c["Compras"])
    add(client, h, "Hamburguesa", "-10.00", category_id=c["Fast food"])
    t = client.get("/api/trackers", headers=h).json()[0]
    assert t["balance"] == "-350.00" and t["movements_count"] == 2
    assert t["by_cycle"][0]["amount"] == "-50.00"
    # El seguimiento no toca el patrimonio ni el ciclo
    assert current(client, h)["summary"]["available_now"] == "940.00"
    kw = client.post("/api/trackers", headers=h, json={
        "name": "Vinilos", "opening_date": date.today().isoformat(), "keywords": ["vinilo"]
    }).json()  # fmt: skip
    add(client, h, "Vinilo Pink Floyd", "-80.00")
    kw = next(x for x in client.get("/api/trackers", headers=h).json() if x["id"] == kw["id"])
    assert kw["balance"] == "-80.00"
    assert (
        client.post(
            "/api/trackers",
            headers=h,
            json={"name": "Vacío", "opening_date": date.today().isoformat()},
        ).status_code
        == 422
    )


def test_rules_are_learned_from_corrections(client, h):
    c = cats(client, h)
    m = add(client, h, "Tienda Nymeria", "-20.00")
    # Sin regla: sin categoría útil. El usuario la corrige → se aprende.
    client.patch(f"/api/movements/{m['id']}", json={"category_id": c["Compras"]}, headers=h)
    rules = client.get("/api/category-rules", headers=h).json()
    assert rules[0]["pattern"] == "tienda nymeria" and rules[0]["category_id"] == c["Compras"]
    # Un movimiento nuevo con el mismo concepto y sin categoría la recibe sola
    m2 = add(client, h, "Tienda Nymeria", "-5.00")
    assert m2["category_id"] == c["Compras"]
    assert client.delete(f"/api/category-rules/{rules[0]['id']}", headers=h).status_code == 204


def test_budgets_and_stats(client, h):
    c = cats(client, h)
    add(client, h, "Hamburguesa", "-15.00", category_id=c["Fast food"])
    add(client, h, "Cena", "-45.00", category_id=c["Restaurantes"])
    add(client, h, "Fibra", "-9.00", category_id=c["Telefonía e internet"])
    add(client, h, "Venta bici", "30.00", kind="ingreso")
    assert client.put(f"/api/budgets/{c['Comida fuera']}", json={"amount": "50"},
                      headers=h).status_code == 200  # fmt: skip
    st = client.get("/api/stats", headers=h).json()
    cyc = st["cycles"][-1]
    assert cyc["spend"] == "69.00" and cyc["income"] == "30.00"
    by = {x["category_id"]: x["amount"] for x in cyc["by_category"]}
    assert by[c["Comida fuera"]] == "60.00"  # subcategorías agregadas en la raíz
    food = next(x for x in st["categories"] if x["category_id"] == c["Comida fuera"])
    assert food["budget"] == "50.00" and food["budget_used"] == "1.2000"  # 120 %: aviso
    assert st["top_concepts"][0]["concept"] == "Cena"
    assert client.delete(f"/api/budgets/{c['Comida fuera']}", headers=h).status_code == 204


def test_rename_installment_plan_propagates(client, h):
    p = client.post("/api/installments", headers=h, json={
        "description": "Gasto 107", "total": "321", "n": 3,
        "first_due": date.today().isoformat()}).json()  # fmt: skip
    r = client.patch(f"/api/installments/{p['id']}", json={"description": "Móvil"}, headers=h)
    assert r.json()["description"] == "Móvil"
    concepts = [
        m["concept"] for m in current(client, h)["movements"] if m["source"] == "installment"
    ]
    assert concepts and all(x.startswith("Móvil (") for x in concepts)


def test_isolation_2b(client, make_user, h):
    make_user("bea@example.com")
    hb = auth_header(enroll(client, "bea@example.com"))
    setup_gastos(client, hb)
    m = add(client, h, "Cena", "-60.00")
    sh = client.put(f"/api/movements/{m['id']}/shares", headers=h,
                    json=[{"person_name": "Luis", "amount": "20"}]).json()[0]  # fmt: skip
    pid = client.get("/api/people", headers=h).json()[0]["id"]
    d = client.post("/api/debts", headers=h, json={"name": "x", "opening_balance": "1",
                    "opening_date": date.today().isoformat()}).json()  # fmt: skip
    t = client.post("/api/trackers", headers=h, json={"name": "x", "keywords": ["a"],
                    "opening_date": date.today().isoformat()}).json()  # fmt: skip
    for method, url, body in [
        ("PUT", f"/api/movements/{m['id']}/shares", [{"person_name": "Z", "amount": "1"}]),
        ("POST", f"/api/shares/{sh['id']}/settle", {}),
        ("GET", f"/api/people/{pid}/shares", None),
        ("PATCH", f"/api/people/{pid}", {"name": "hack"}),
        ("POST", f"/api/debts/{d['id']}/payments", {"amount": "1"}),
        ("PATCH", f"/api/trackers/{t['id']}", {"name": "hack"}),
        ("DELETE", f"/api/trackers/{t['id']}", None),
    ]:
        r = client.request(method, url, json=body, headers=hb)
        assert r.status_code == 404, f"{method} {url} → {r.status_code}"
    assert client.get("/api/people", headers=hb).json() == []
    assert client.get("/api/debts", headers=hb).json() == []
