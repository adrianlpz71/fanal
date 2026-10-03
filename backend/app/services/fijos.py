"""Panel de reducción de gastos fijos (spec §7).

· Fijos = recurrentes activos de gasto + cuotas de compras fraccionadas vivas ("fijos
  temporales"), con su coste mensual y anual y el % sobre la nómina.
· Tendencia: fijos + cuotas por ciclo (de las estadísticas de gastos).
· Ahorro conseguido: recurrentes que marcaste para cancelar y que ya terminaron (fecha de fin en
  los últimos 12 meses): su coste anual (o el ahorro estimado que pusiste).
· Posibles suscripciones nuevas: conceptos que se repiten en ciclos seguidos con un importe
  parecido (±10 %) y que no son ya un recurrente.
· Recordatorio de revisión: cada 90 días.
"""

import uuid
from collections import defaultdict
from dataclasses import dataclass
from datetime import date, timedelta
from decimal import Decimal
from itertools import pairwise
from statistics import median
from typing import Any

from sqlalchemy import select
from sqlalchemy.orm import Session

from app.models import (
    Goal,
    InstallmentPlan,
    Movement,
    PayCycle,
    RecurringPriceChange,
    RecurringTemplate,
)
from app.services import gastos as gsvc
from app.services import gastos_extra as ex
from app.services.categories_seed import normalize

ZERO = Decimal(0)
REVIEW_EVERY_DAYS = 90


@dataclass
class FixedItem:
    kind: str  # recurrente | cuota
    id: uuid.UUID
    name: str
    monthly: Decimal
    yearly: Decimal
    review: str | None  # ok | revisar | cancelar (solo recurrentes)
    est_saving_year: Decimal | None
    price_changes: int
    ends: date | None  # cuotas: última cuota
    category_id: uuid.UUID | None


@dataclass
class Suggestion:
    concept: str
    amount: Decimal  # mediana, con signo
    cycles: int
    day_of_month: int
    category_id: uuid.UUID | None


@dataclass
class Panel:
    items: list[FixedItem]
    monthly_total: Decimal
    yearly_total: Decimal
    payroll: Decimal | None
    share_of_payroll: Decimal | None
    trend: list[tuple[str, Decimal]]  # (ciclo, fijos + cuotas)
    goal: Goal | None
    saved_year: Decimal  # ahorro anual conseguido por recortes (últimos 12 meses)
    to_review_saving: Decimal  # ahorro anual estimado de lo marcado "revisar" o "cancelar"
    suggestions: list[Suggestion]
    review_due: bool
    last_review: date | None


def _installment_monthly(db: Session, plan: InstallmentPlan) -> tuple[Decimal, date | None]:
    pending = [i for i in plan.installments if i.status == "pendiente"]
    if not pending:
        return ZERO, None
    nxt = min(pending, key=lambda i: i.due_date)
    return nxt.amount / plan.every_months, max(i.due_date for i in pending)


def suggestions(db: Session, user_id: uuid.UUID, cycles: int = 4) -> list[Suggestion]:
    account = gsvc.main_account(db, user_id)
    recent = list(
        db.scalars(
            select(PayCycle)
            .where(PayCycle.user_id == user_id, PayCycle.account_id == account.id)
            .order_by(PayCycle.start_date.desc())
            .limit(cycles)
        )
    )[::-1]
    if len(recent) < 2:
        return []
    order = {c.id: n for n, c in enumerate(recent)}
    known = {
        normalize(t.concept)
        for t in db.scalars(select(RecurringTemplate).where(RecurringTemplate.user_id == user_id))
    }
    seen: dict[str, list[Movement]] = defaultdict(list)
    for m in db.scalars(
        select(Movement).where(
            Movement.user_id == user_id,
            Movement.cycle_id.in_(order.keys()),
            Movement.kind == "gasto",
            Movement.status != "cancelled",
            Movement.source.in_(("manual", "bank_import", "excel")),
        )
    ):
        seen[normalize(m.concept)].append(m)
    out = []
    for key, movs in seen.items():
        if not key or key in known:
            continue
        idx = sorted({order[m.cycle_id] for m in movs if m.cycle_id in order})
        consecutive = any(b - a == 1 for a, b in pairwise(idx))
        if len(idx) < 2 or not consecutive:
            continue
        amounts = [m.amount for m in movs]
        med = Decimal(median(amounts))
        if med >= 0 or any(abs(a - med) > abs(med) * Decimal("0.10") for a in amounts):
            continue  # importes muy distintos: no parece una cuota fija
        days = [m.date.day for m in movs if m.date]
        out.append(
            Suggestion(
                movs[0].concept,
                med,
                len(idx),
                int(median(days)) if days else 1,
                movs[0].category_id,
            )
        )
    return sorted(out, key=lambda s: s.amount)


def panel(db: Session, user_id: uuid.UUID) -> Panel:
    items: list[FixedItem] = []
    # Solo gasto: los traspasos recurrentes (al ahorro, a la cartera) no son un coste fijo. Igual
    # que en Este ciclo y Estadísticas, donde cuentan como ahorro.
    for t in db.scalars(
        select(RecurringTemplate).where(
            RecurringTemplate.user_id == user_id,
            RecurringTemplate.active.is_(True),
            RecurringTemplate.amount < 0,
            RecurringTemplate.kind == "gasto",
        )
    ):
        if t.end_date and t.end_date < date.today():
            continue
        monthly = -t.amount / t.every_months
        n_changes = len(
            db.scalars(
                select(RecurringPriceChange.id).where(
                    RecurringPriceChange.template_id == t.id,
                    RecurringPriceChange.acknowledged.is_(False),
                )
            ).all()
        )
        items.append(
            FixedItem(
                "recurrente",
                t.id,
                t.concept,
                monthly,
                monthly * 12,
                t.review,
                t.est_saving_year,
                n_changes,
                t.end_date,
                t.category_id,
            )
        )
    for p in db.scalars(
        select(InstallmentPlan).where(
            InstallmentPlan.user_id == user_id, InstallmentPlan.status == "activa"
        )
    ):
        monthly, ends = _installment_monthly(db, p)
        if monthly > 0:
            items.append(
                FixedItem(
                    "cuota",
                    p.id,
                    p.description,
                    monthly,
                    monthly * 12,
                    None,
                    None,
                    0,
                    ends,
                    p.category_id,
                )
            )
    items.sort(key=lambda i: -i.monthly)
    monthly_total = sum((i.monthly for i in items), ZERO)
    s = gsvc.get_settings(db, user_id)
    payroll = Decimal(s["usual_payroll"]) if s.get("usual_payroll") else None
    stats = ex.cycles_stats(db, user_id, 12)
    trend = [(c.label, c.fixed + c.installments) for c in stats]
    goal = db.scalar(
        select(Goal).where(
            Goal.user_id == user_id, Goal.kind == "fijos_max", Goal.archived.is_(False)
        )
    )
    year_ago = date.today() - timedelta(days=365)
    saved = ZERO
    for t in db.scalars(
        select(RecurringTemplate).where(
            RecurringTemplate.user_id == user_id,
            RecurringTemplate.review == "cancelar",
            RecurringTemplate.amount < 0,
            RecurringTemplate.kind == "gasto",
        )
    ):
        ended = (t.end_date is not None and year_ago <= t.end_date <= date.today()) or not t.active
        if ended:
            saved += t.est_saving_year or (-t.amount / t.every_months * 12)
    to_review = sum(
        (i.est_saving_year or i.yearly for i in items if i.review in ("revisar", "cancelar")), ZERO
    )
    last = s.get("fixed_last_review")
    last_d = date.fromisoformat(last) if last else None
    return Panel(
        items,
        monthly_total,
        monthly_total * 12,
        payroll,
        (monthly_total / payroll) if payroll else None,
        trend,
        goal,
        saved,
        to_review,
        suggestions(db, user_id),
        last_d is None or (date.today() - last_d).days >= REVIEW_EVERY_DAYS,
        last_d,
    )


def mark_reviewed(db: Session, user_id: uuid.UUID) -> dict[str, Any]:
    return gsvc.save_settings(db, user_id, {"fixed_last_review": date.today().isoformat()})
