"""Deshacer "He cobrado": todo vuelve a como estaba y lo apuntado después no se pierde."""

from datetime import date, timedelta
from decimal import Decimal as D

import pytest

from tests.conftest import auth_header, enroll
from tests.test_api_gastos import add, current, setup_gastos


@pytest.fixture
def h(client, make_user):
    make_user("ana@example.com")
    return auth_header(enroll(client, "ana@example.com"))


def _state(client, h):
    """Lo que tiene que quedar igual tras cobrar y deshacer."""
    c = current(client, h)
    movs = sorted((m["concept"], m["amount"], m["status"]) for m in c["movements"])
    cycles = sorted((x["label"], x["status"]) for x in client.get("/api/cycles", headers=h).json())
    acc = {a["name"]: a["balance"] for a in client.get("/api/accounts", headers=h).json()}
    settings = client.get("/api/gastos/settings", headers=h).json()
    return c["id"], c["summary"], movs, cycles, acc, settings["usual_payroll"]


def test_undo_payday_restores_everything_and_keeps_later_movements(client, h):
    setup_gastos(client, h, usual_payroll="1800.00")
    today = date.today()
    add(client, h, "Cena", "-100.00")
    add(client, h, "Fibra", "-9.00", status="planned")
    drop = add(client, h, "Cuota rara", "-50.00", status="planned")
    client.post(
        "/api/recurring",
        headers=h,
        json={
            "concept": "Claude",
            "amount": "-108.00",
            "day_of_month": 1,
            "start_date": (today - timedelta(days=400)).isoformat(),
        },
    )
    client.post(
        "/api/installments",
        headers=h,
        json={
            "description": "OP Box",
            "provider": "paypal",
            "total": "300.00",
            "n": 3,
            "first_due": today.isoformat(),
            "paid_count": 1,
        },
    )
    before = _state(client, h)
    assert client.get("/api/cycles/payday/undo", headers=h).json()["available"] is False

    r = client.post(
        "/api/cycles/payday",
        headers=h,
        json={
            "payroll_amount": "1845.00",
            "payroll_date": today.isoformat(),
            "real_balance_before": "380.00",
            "pending_actions": {drop["id"]: "cancel"},
        },
    )
    assert r.status_code == 200, r.text
    assert r.json()["discrepancy"] != "0.00"
    new = current(client, h)
    assert new["id"] != before[0]
    # Un gasto apuntado ya en el ciclo nuevo
    add(client, h, "Súper", "-40.00")

    st = client.get("/api/cycles/payday/undo", headers=h).json()
    assert st == {"available": True, "reason": None}
    r = client.post("/api/cycles/payday/undo", headers=h)
    assert r.status_code == 200, r.text
    assert r.json()["id"] == before[0] and r.json()["status"] == "open"

    cid, summary, movs, cycles, acc, payroll = _state(client, h)
    assert cid == before[0] and cycles == before[3] and payroll == before[5]
    # Lo de antes, igual (la cuota rara vuelve a prevista), más el súper apuntado después
    assert movs == sorted([*before[2], ("Súper", "-40.00", "posted")])
    # Saldos: los de antes; la cuenta de gastos, con el súper descontado
    gastos = next(a for a in client.get("/api/accounts", headers=h).json() if a["kind"] == "gastos")
    assert {k: v for k, v in acc.items() if k != gastos["name"]} == {
        k: v for k, v in before[4].items() if k != gastos["name"]
    }
    assert D(acc[gastos["name"]]) == D(before[4][gastos["name"]]) - D("40.00")
    assert summary["opening"] == before[1]["opening"]

    # No se deshace dos veces; y se puede volver a cobrar con normalidad
    assert client.post("/api/cycles/payday/undo", headers=h).status_code == 409
    assert client.get("/api/cycles/payday/undo", headers=h).json()["available"] is False
    r = client.post(
        "/api/cycles/payday",
        headers=h,
        json={
            "payroll_amount": "1845.00",
            "payroll_date": today.isoformat(),
            "real_balance_before": "331.00",
        },
    )
    assert r.status_code == 200, r.text
    gen = [m for m in current(client, h)["movements"] if m["source"] == "recurring"]
    # El del ciclo nuevo se vuelve a generar (más el del reabierto, que pasa como previsto), sin
    # duplicar ningún mes
    assert len(gen) == 2 and len({m["due_date"] for m in gen}) == 2


def test_undo_only_last_payday_while_open(client, h):
    setup_gastos(client, h)
    today = date.today()
    body = {
        "payroll_amount": "1000.00",
        "payroll_date": today.isoformat(),
        "real_balance_before": "500.00",
    }
    assert client.post("/api/cycles/payday", headers=h, json=body).status_code == 200
    body["real_balance_before"] = "1500.00"
    assert client.post("/api/cycles/payday", headers=h, json=body).status_code == 200
    # Se deshace el último; el anterior ya no (su ciclo está cerrado)
    assert client.post("/api/cycles/payday/undo", headers=h).status_code == 200
    r = client.post("/api/cycles/payday/undo", headers=h)
    assert r.status_code == 409 and "último" in r.json()["detail"]
