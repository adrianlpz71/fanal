"""Meses: apuntar gastos a un ciclo futuro y gestionar lo previsto mes a mes."""

from datetime import date, timedelta

import pytest

from app.domain import calendar as cal
from tests.conftest import auth_header, enroll
from tests.test_api_gastos import add, current, setup_gastos


@pytest.fixture
def h(client, make_user):
    make_user("ana@example.com")
    return auth_header(enroll(client, "ana@example.com"))


def ym(key: cal.CycleKey) -> str:
    return f"{key.year:04d}-{key.month:02d}"


def keys(client, h) -> list[cal.CycleKey]:
    """[actual, +1, +2, +3]"""
    k = cal.key_from_label(current(client, h)["label"])
    out = [k]
    for _ in range(3):
        out.append(out[-1].next())
    return out


def month(client, h, key):
    r = client.get(f"/api/months/{ym(key)}", headers=h)
    assert r.status_code == 200, r.text
    return r.json()


def test_gasto_in_future_month_and_back(client, h):
    setup_gastos(client, h, usual_payroll="1800.00")
    cur, nxt, *_ = keys(client, h)
    m = add(client, h, "Regalo cumple", "-80.00", month=ym(nxt))
    assert m["status"] == "planned" and m["cycle_id"] is None
    assert m["due_date"] == cal.cycle_start(nxt, 27).isoformat()
    assert all(x["id"] != m["id"] for x in current(client, h)["movements"])

    mo = month(client, h, nxt)
    assert mo["label"] == nxt.label and mo["other"] == "-80.00" and mo["free"] == "1720.00"
    assert [(i["kind"], i["concept"]) for i in mo["items"]] == [("movimiento", "Regalo cumple")]
    fc = client.get("/api/forecast", params={"months": 2}, headers=h).json()["months"]
    assert fc[0]["ym"] == ym(nxt) and fc[0]["other"] == "-80.00"

    # Fecha concreta dentro del ciclo elegido
    d = cal.cycle_start(nxt, 27) + timedelta(days=10)
    m2 = add(client, h, "Concierto", "-40.00", month=ym(nxt), due_date=d.isoformat())
    assert m2["due_date"] == d.isoformat()

    # Volver a este ciclo
    r = client.patch(f"/api/movements/{m['id']}", json={"month": ym(cur)}, headers=h)
    assert r.status_code == 200, r.text
    assert r.json()["cycle_id"] == current(client, h)["id"] and r.json()["due_date"] is None
    assert month(client, h, nxt)["other"] == "-40.00"

    # Cargar un previsto futuro lo trae al ciclo abierto
    r = client.patch(f"/api/movements/{m2['id']}", json={"status": "posted"}, headers=h)
    assert r.json()["cycle_id"] == current(client, h)["id"]

    # Los ciclos cerrados no admiten movimientos nuevos; el actual no es "mes futuro"
    r = client.post("/api/movements", headers=h,
                    json={"concept": "x", "amount": "-1.00", "month": ym(cur.prev())})  # fmt: skip
    assert r.status_code == 422
    assert client.get(f"/api/months/{ym(cur)}", headers=h).status_code == 404
    assert client.get("/api/months/2026-13", headers=h).status_code == 422


def test_future_planned_lands_in_its_cycle_on_payday(client, h):
    setup_gastos(client, h)
    _, nxt, *_ = keys(client, h)
    m = add(client, h, "Seguro coche", "-300.00", month=ym(nxt))
    r = client.post("/api/cycles/payday", headers=h, json={
        "payroll_amount": "1800", "payroll_date": date.today().isoformat(),
        "real_balance_before": "500",
    })  # fmt: skip
    assert r.status_code == 200, r.text
    assert any(x["id"] == m["id"] for x in current(client, h)["movements"])


def test_manage_recurring_per_month(client, h):
    setup_gastos(client, h)
    _, m1, m2, m3 = keys(client, h)
    t = client.post("/api/recurring", headers=h, json={
        "concept": "Netflix", "amount": "-13.99", "day_of_month": 28,
        "start_date": (date.today() - timedelta(days=400)).isoformat(),
    }).json()  # fmt: skip

    def rec_items(key):
        return [i for i in month(client, h, key)["items"] if i["template_id"] == t["id"]]

    (proj,) = rec_items(m1)
    assert proj["kind"] == "recurrente" and proj["movement"] is None and proj["amount"] == "-13.99"

    # Saltar solo el mes +1
    r = client.post(f"/api/recurring/{t['id']}/occurrences", headers=h,
                    json={"date": proj["date"], "action": "saltar"})  # fmt: skip
    assert r.status_code == 200 and r.json()["status"] == "cancelled"
    assert rec_items(m1) == [] and month(client, h, m1)["recurring"] == "0.00"

    # Editar solo el mes +2
    (p2,) = rec_items(m2)
    mv = client.post(f"/api/recurring/{t['id']}/occurrences", headers=h,
                     json={"date": p2["date"], "action": "editar"}).json()  # fmt: skip
    client.patch(f"/api/movements/{mv['id']}", json={"amount": "-6.99"}, headers=h)
    (e2,) = rec_items(m2)
    assert e2["kind"] == "movimiento" and e2["amount"] == "-6.99"
    assert month(client, h, m2)["recurring"] == "-6.99"
    assert (
        client.get("/api/recurring", headers=h).json()[0]["amount"] == "-13.99"
    )  # plantilla igual

    # Darlo de baja a partir del mes +3: desaparece de ahí en adelante, lo anterior se queda
    end = cal.cycle_start(m3, 27) - timedelta(days=1)
    client.patch(f"/api/recurring/{t['id']}", json={"end_date": end.isoformat()}, headers=h)
    assert rec_items(m3) == [] and len(rec_items(m2)) == 1


def test_months_isolation(client, h, make_user):
    setup_gastos(client, h)
    t = client.post("/api/recurring", headers=h, json={
        "concept": "Spotify", "amount": "-10.99", "day_of_month": 2,
        "start_date": date.today().isoformat(),
    }).json()  # fmt: skip
    make_user("eva@example.com")
    h2 = auth_header(enroll(client, "eva@example.com"))
    r = client.post(f"/api/recurring/{t['id']}/occurrences", headers=h2,
                    json={"date": date.today().isoformat(), "action": "saltar"})  # fmt: skip
    assert r.status_code == 404
