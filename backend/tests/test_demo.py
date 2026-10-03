"""Datos de demostración: se crean con los servicios reales y la app los puede calcular todos."""

from datetime import date
from decimal import Decimal as D

from sqlalchemy import select

from app.db import SessionLocal
from app.demo import seed
from app.models import Goal, PayCycle
from app.services import analytics as an
from app.services import gastos as gsvc
from app.services import inversiones as isvc
from app.services import planes as psvc


def test_demo_seed_is_coherent():
    with SessionLocal() as db:
        u = seed(db, "demo@faro.example", "demo-faro-2026", today=date(2026, 10, 2))
        db.commit()
        cycles = db.scalars(
            select(PayCycle).where(PayCycle.user_id == u.id).order_by(PayCycle.start_date)
        ).all()
        assert len(cycles) == 13 and [c.status for c in cycles].count("open") == 1
        # Sin descuadres: cada arrastre es el anterior más lo cargado en ese ciclo
        main = gsvc.main_account(db, u.id)
        cur = cycles[-1]
        summ = gsvc.cycle_summary(db, cur, today=date(2026, 10, 2))
        assert summ.carried == cur.carried_real and summ.opening == cur.carried_real + summ.payroll
        assert gsvc.account_balance(db, main) > 0
        assert all(c.carried_real > 0 for c in cycles[1:])

        p = isvc.portfolio(db, u.id)
        assert len(p.classes) >= 2 and p.value > D(5000)
        assert an.networth(db, u.id).total > p.value

        plan = psvc.fire_plan(db, u)
        assert plan.auto.monthly_contribution > 0 and plan.base.needed > 0
        for g in db.scalars(select(Goal).where(Goal.user_id == u.id)):
            psvc.goal_progress(db, u, g)
