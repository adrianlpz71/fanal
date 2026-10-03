"""Panel de gastos fijos: totales, ahorro conseguido, sugerencias y recordatorio."""

from datetime import date, timedelta
from decimal import Decimal as D

import pytest

from tests.conftest import auth_header, enroll
from tests.test_api_gastos import add, setup_gastos

TODAY = date.today()


@pytest.fixture
def h(client, make_user):
    make_user("ana@example.com")
    hh = auth_header(enroll(client, "ana@example.com"))
    setup_gastos(client, hh, balance="1000.00", usual_payroll="2000.00")
    return hh


def test_panel_totals_cuts_and_reminder(client, h):
    start = (TODAY - timedelta(days=200)).isoformat()
    n = client.post(
        "/api/recurring",
        headers=h,
        json={"concept": "Netflix", "amount": "-15.00", "day_of_month": 3, "start_date": start},
    ).json()
    client.post(
        "/api/recurring",
        headers=h,
        json={
            "concept": "Seguro",
            "amount": "-120.00",
            "day_of_month": 5,
            "every_months": 12,
            "start_date": start,
        },
    )
    client.post(
        "/api/installments",
        headers=h,
        json={"description": "Portátil", "total": "300.00", "n": 3, "first_due": TODAY.isoformat()},
    )
    # Un traspaso recurrente al ahorro no es un gasto fijo
    client.post(
        "/api/recurring",
        headers=h,
        json={
            "concept": "A la cuenta de ahorro",
            "amount": "-400.00",
            "kind": "transferencia",
            "day_of_month": 2,
            "start_date": start,
        },
    )
    p = client.get("/api/gastos/fijos", headers=h).json()
    assert "A la cuenta de ahorro" not in {i["name"] for i in p["items"]}
    by = {i["name"]: i for i in p["items"]}
    assert by["Netflix"]["monthly"] == "15.00" and by["Netflix"]["yearly"] == "180.00"
    assert by["Seguro"]["monthly"] == "10.00"
    assert by["Portátil"]["kind"] == "cuota" and by["Portátil"]["monthly"] == "100.00"
    assert p["monthly_total"] == "125.00" and D(p["share_of_payroll"]) == D("0.0625")
    assert p["review_due"] is True and p["saved_year"] == "0.00"
    # Marcar Netflix para cancelar y darlo de baja: cuenta como ahorro conseguido
    client.patch(f"/api/recurring/{n['id']}", headers=h, json={"review": "cancelar"})
    assert client.get("/api/gastos/fijos", headers=h).json()["to_review_saving"] == "180.00"
    client.patch(
        f"/api/recurring/{n['id']}",
        headers=h,
        json={"end_date": (TODAY - timedelta(days=1)).isoformat()},
    )
    p = client.get("/api/gastos/fijos", headers=h).json()
    assert p["saved_year"] == "180.00" and "Netflix" not in {i["name"] for i in p["items"]}
    assert client.post("/api/gastos/fijos/reviewed", headers=h).status_code == 204
    assert client.get("/api/gastos/fijos", headers=h).json()["review_due"] is False


def test_detects_new_subscription_in_consecutive_cycles(client, h):
    add(client, h, "Gimnasio Fit", "-30.00")
    r = client.post(
        "/api/cycles/payday",
        headers=h,
        json={
            "payroll_amount": "2000",
            "payroll_date": TODAY.isoformat(),
            "real_balance_before": "970",
        },
    )
    assert r.status_code == 200, r.text
    add(client, h, "GIMNASIO FIT", "-31.00")
    add(client, h, "Cena", "-45.00")
    s = client.get("/api/gastos/fijos", headers=h).json()["suggestions"]
    assert [(x["concept"].lower(), x["cycles"]) for x in s] == [("gimnasio fit", 2)]
