"""Aportaciones periódicas: generación de pendientes de VL y recurrente enlazado en gastos."""

from datetime import date, timedelta
from decimal import Decimal as D

import pytest
from sqlalchemy import select

from app.db import SessionLocal
from app.models import ContributionPlan, InvTransaction, User
from app.services import inversiones as svc
from tests.conftest import auth_header, enroll
from tests.test_api_gastos import setup_gastos


@pytest.fixture
def h(client, make_user):
    make_user("ana@example.com")
    return auth_header(enroll(client, "ana@example.com"))


def fund(client, h):
    cls = {c["name"]: c["id"] for c in client.get("/api/inv/classes", headers=h).json()}
    r = client.post(
        "/api/inv/assets",
        headers=h,
        json={"name": "MSCI", "type": "fondo", "asset_class_id": cls["Fondos"]},
    )
    return r.json()["id"]


def test_plan_with_gastos_account_creates_linked_recurring(client, h):
    setup_gastos(client, h)
    aid = fund(client, h)
    acc = client.get("/api/accounts", headers=h).json()[0]
    r = client.post("/api/inv/plans", headers=h, json={
        "asset_id": aid, "amount": "150", "day_of_month": 5,
        "start_date": date.today().isoformat(), "from_account_id": acc["id"],
    })  # fmt: skip
    assert r.status_code == 201, r.text
    p = r.json()
    assert p["from_account_id"] == acc["id"] and p["next_date"] is not None
    rec = client.get("/api/recurring", headers=h).json()
    assert [(t["concept"], t["amount"], t["kind"]) for t in rec] == [
        ("Aportación periódica (MSCI)", "-150.00", "transferencia")
    ]
    # Cambiar el importe actualiza el recurrente; borrar el plan lo desactiva
    body = {**{k: p[k] for k in ("asset_id", "day_of_month", "start_date")},
            "amount": "200", "from_account_id": acc["id"]}  # fmt: skip
    assert client.put(f"/api/inv/plans/{p['id']}", headers=h, json=body).status_code == 200
    assert client.get("/api/recurring", headers=h).json()[0]["amount"] == "-200.00"
    assert client.delete(f"/api/inv/plans/{p['id']}", headers=h).status_code == 204
    assert client.get("/api/recurring", headers=h).json()[0]["active"] is False


# Un día distinto de hoy: el cargo de hoy (si tocara) se generaría y el test no sería estable
DAY = 15 if date.today().day != 15 else 16


def test_generation_is_forward_only_and_idempotent(client, h):
    aid = fund(client, h)
    start = date(2026, 1, 1)
    r = client.post("/api/inv/plans", headers=h, json={
        "asset_id": aid, "amount": "100", "day_of_month": DAY, "start_date": start.isoformat(),
    })  # fmt: skip
    assert r.status_code == 201, r.text
    with SessionLocal() as db:
        uid = db.scalar(select(User.id).where(User.email == "ana@example.com"))
        p = db.scalar(select(ContributionPlan).where(ContributionPlan.user_id == uid))
        today = date.today()
        # El pasado no se rellena (ya está en la posición)
        assert svc.generate_plans(db, today) == 0
        # Dentro de 3 meses: tres cargos (días 1) y ni uno más al repetir
        later = today + timedelta(days=92)
        n = svc.generate_plans(db, later)
        assert n in (3, 4)
        assert svc.generate_plans(db, later) == 0
        txs = db.scalars(select(InvTransaction).where(InvTransaction.user_id == uid)).all()
        assert all(t.status == "pendiente_vl" and t.amount_eur == D("100") for t in txs)
        assert all(t.trade_date.day == DAY and t.trade_date > today for t in txs)
        assert p.last_generated == later
        db.rollback()
