"""Evolución del patrimonio (D9): cuentas reconstruidas desde el saldo de hoy, un punto por ciclo
mientras no hay fechas, traspasos de una pata a cuentas propias neutros e hitos."""

from datetime import date
from decimal import Decimal as D

import pytest
from sqlalchemy import select

from app.db import SessionLocal
from app.domain import milestones as ms
from app.models import Account, Movement, PayCycle, User
from app.services import analytics as an
from app.services import networth as nw
from tests.conftest import auth_header, enroll
from tests.test_api_gastos import setup_gastos

TODAY = date(2026, 4, 5)  # domingo


def _excel_like(email: str) -> dict:
    """Como el Excel: ciclos cerrados con movimientos sin fecha, traspasos de una pata a
    "Ahorro" y a fondos, y la cuenta de ahorro dada de alta después con lo acumulado."""
    with SessionLocal() as db:
        u = db.scalar(select(User).where(User.email == email))
        assert u is not None
        gastos = Account(
            user_id=u.id,
            kind="gastos",
            name="Cuenta de gastos",
            bank="Banco",
            opening_balance=D("300.00"),
            opening_date=date(2026, 1, 27),
        )
        ahorro = Account(
            user_id=u.id,
            kind="ahorro",
            name="Cuenta remunerada",
            bank="TR",
            opening_balance=D("400.00"),
            opening_date=date(2026, 4, 1),
        )
        db.add_all([gastos, ahorro])
        db.flush()

        def mov(cycle, concept, amount, kind="gasto", on=None):
            db.add(
                Movement(
                    user_id=u.id,
                    account_id=gastos.id,
                    cycle_id=cycle.id,
                    date=on,
                    kind=kind,
                    status="posted",
                    concept=concept,
                    amount=D(amount),
                    source="excel",
                )
            )

        ends = [(date(2026, 1, 27), date(2026, 2, 27)), (date(2026, 2, 27), date(2026, 3, 27))]
        for i, (start, end) in enumerate(ends):
            c = PayCycle(
                user_id=u.id,
                account_id=gastos.id,
                label=f"C{i}",
                start_date=start,
                end_date=end,
                status="closed",
            )
            db.add(c)
            db.flush()
            mov(c, "Nómina", "2000.00", "nomina", start)
            mov(c, "Gastos del mes", "-1500.00")
            mov(c, "Ahorro", "-200.00", "transferencia")
            if i == 1:
                mov(c, "Fondos indexados", "-100.00", "transferencia")
        cur = PayCycle(
            user_id=u.id,
            account_id=gastos.id,
            label="C2",
            start_date=date(2026, 3, 27),
            status="open",
        )
        db.add(cur)
        db.flush()
        mov(cur, "Nómina", "2000.00", "nomina", date(2026, 3, 27))
        mov(cur, "Súper", "-100.00", on=date(2026, 3, 30))
        db.commit()
        return {"user": u.id, "gastos": gastos.id, "ahorro": ahorro.id}


@pytest.fixture
def h(client, make_user):
    make_user("ana@example.com")
    return auth_header(enroll(client, "ana@example.com"))


def test_accounts_rebuilt_back_from_today(client, h):
    ids = _excel_like("ana@example.com")
    with SessionLocal() as db:
        hist = nw.history(db, ids["user"], TODAY)
    g, a = f"c:{ids['gastos']}", f"c:{ids['ahorro']}"
    by_day = {p.on: p for p in hist.points}
    # Un punto por ciclo mientras hay movimientos sin fecha (al cierre: lo que sobró), y semanal
    # después
    assert hist.per_cycle_until == date(2026, 3, 26)
    assert list(by_day) == [date(2026, 2, 26), date(2026, 3, 26), date(2026, 3, 29), TODAY]
    # Hoy, lo mismo que la tarjeta: 300 + (2000 − 1700) + (2000 − 1800) + 2000 − 100
    assert by_day[TODAY].components[g] == D("2700.00")
    assert by_day[TODAY].components[a] == D("400.00")
    # Al cierre del primer ciclo: 300 + 2000 − 1700 en gastos y los 200 € ya en el ahorro
    # (antes salía 0 hasta el día del alta y luego un salto de 400 €)
    assert by_day[date(2026, 2, 26)].components[g] == D("600.00")
    assert by_day[date(2026, 2, 26)].components[a] == D("200.00")
    assert by_day[date(2026, 3, 26)].components[a] == D("400.00")
    # El traspaso a fondos sí sale de las cuentas (va a inversión); el de ahorro, no
    assert [t.movement.concept for t in hist.own_transfers] == ["Ahorro", "Ahorro"]
    assert [m.concept for m, _ in hist.other_one_leg] == ["Fondos indexados"]
    totals = [p.accounts for p in hist.points]
    assert totals == [D("800.00"), D("1200.00"), D("3200.00"), D("3100.00")]
    # La serie que ya usaban la Revisión y /networth/history es esta misma
    with SessionLocal() as db:
        assert an.networth_history(db, ids["user"])[-1][1] == D("3100.00")
    with SessionLocal() as db:
        card = an.networth(db, ids["user"])
    assert sum((b for _, b in card.accounts), D(0)) == by_day[TODAY].accounts


def test_weekly_points_before_the_first_cycle():
    """Inversiones desde enero y ciclos (sin fechas) desde julio: antes de julio, semanal; luego,
    el cierre de cada ciclo; y después, semanal otra vez."""
    days = nw._sample_days(
        start=date(2026, 1, 1),
        today=date(2026, 10, 3),
        cycle_ends=[date(2026, 7, 26), date(2026, 8, 26), date(2026, 9, 27)],
        per_cycle_until=date(2026, 9, 27),
        first_cycle=date(2026, 6, 29),
    )
    assert days[0] == date(2026, 1, 4)  # primer domingo
    assert date(2026, 6, 28) in days and date(2026, 7, 5) not in days  # semanal hasta el ciclo
    assert [d for d in days if date(2026, 6, 29) <= d] == [
        date(2026, 7, 26),
        date(2026, 8, 26),
        date(2026, 9, 27),
        date(2026, 10, 3),
    ]


def test_evolution_endpoint_net_with_debts_and_installments(client, h):
    setup_gastos(client, h, balance="1000.00")
    client.post(
        "/api/debts",
        headers=h,
        json={
            "name": "Préstamo",
            "direction": "debo",
            "opening_balance": "300.00",
            "opening_date": date.today().isoformat(),
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
            "first_due": date.today().isoformat(),
            "paid_count": 1,
        },
    )
    ev = client.get("/api/analytics/networth/evolution", headers=h).json()
    last = ev["points"][-1]
    card = client.get("/api/analytics/networth", headers=h).json()
    assert last["net"] == card["total"]
    assert D(last["debts"]) == D("300.00") and D(last["installments"]) == D(card["installments"])
    assert {c["kind"] for c in ev["components"]} == {"cuenta"}
    assert all(c["key"] in last["components"] for c in ev["components"])


def test_milestones_domain():
    pts = [
        (date(2026, 1, 1), D("800")),
        (date(2026, 2, 1), D("1200")),
        (date(2026, 3, 1), D("900")),
        (date(2026, 4, 1), D("2600")),
    ]
    got = ms.reached(pts, [D("2500"), D("1000"), D("500"), D("5000")])
    assert [(m.amount, m.reached_on, m.before_start) for m in got] == [
        (D("500"), date(2026, 1, 1), True),  # ya lo tenías al empezar la serie
        (D("1000"), date(2026, 2, 1), False),  # la primera vez que se cruzó (luego bajó)
        (D("2500"), date(2026, 4, 1), False),
        (D("5000"), None, False),
    ]
    nxt = ms.next_one(D("2600"), [D("1000"), D("5000")], D("865"), date(2026, 10, 3))
    assert nxt == ms.Next(D("5000"), 3, date(2027, 1, 1))  # 2.400 / 865 → 3 meses
    assert ms.next_one(D("2600"), [D("5000")], D("0"), date(2026, 10, 3)) == ms.Next(
        D("5000"), None, None
    )
    assert ms.next_one(D("6000"), [D("5000")], D("100"), date(2026, 10, 3)) is None
    assert ms.clean([D("5000"), D("-1"), D("1000"), D("1000")]) == [D("1000.00"), D("5000.00")]
    with pytest.raises(ValueError):
        ms.clean([D(i) for i in range(1, 30)])


def test_milestones_api_configurable(client, h):
    setup_gastos(client, h, balance="1200.00")
    r = client.get("/api/analytics/milestones", headers=h).json()
    assert [D(x) for x in r["thresholds"]] == ms.DEFAULT_THRESHOLDS
    first = r["items"][0]
    assert D(first["amount"]) == D("1000") and first["before_start"] is True
    assert D(r["next"]["amount"]) == D("2500")
    r = client.put("/api/analytics/milestones", headers=h, json={"thresholds": ["3000", "1500"]})
    assert r.status_code == 200, r.text
    assert r.json()["thresholds"] == ["1500.00", "3000.00"]
    bad = client.put(
        "/api/analytics/milestones", headers=h, json={"thresholds": [str(i) for i in range(1, 22)]}
    )
    assert bad.status_code == 422
