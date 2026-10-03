"""Revisión trimestral (Planes → Revisión)."""

from datetime import date

from fastapi import APIRouter

from app.api.deps import DB, CurrentUser
from app.schemas.revision import (
    CategoryRiseOut,
    QuarterItemOut,
    QuarterMetricsOut,
    QuarterReviewIn,
    QuarterReviewOut,
    ReviewGoalOut,
)
from app.services import revision as svc

router = APIRouter(prefix="/planes/reviews", tags=["planes"])


def _metrics(m: svc.Metrics) -> QuarterMetricsOut:
    return QuarterMetricsOut(
        cycles=m.cycles,
        income=m.income,
        spend=m.spend,
        surplus=m.surplus,
        savings_rate=m.savings_rate,
        fixed_avg=m.fixed_avg,
        portfolio_start=m.portfolio_start,
        portfolio_end=m.portfolio_end,
        contributed=m.contributed,
        gain=m.gain,
        twr=m.twr,
        networth_start=m.networth_start,
        networth_end=m.networth_end,
        fire_needed=m.fire_needed,
        fire_progress=m.fire_progress,
        fire_age=m.fire_age,
        out_of_range=m.out_of_range,
        goals=[
            ReviewGoalOut(name=g.name, progress=g.progress, on_track=g.on_track) for g in m.goals
        ],
    )


def _out(r: svc.Review) -> QuarterReviewOut:
    q = r.quarter
    return QuarterReviewOut(
        quarter=q.key,
        label=q.label,
        start=q.start,
        end=q.end,
        in_progress=r.in_progress,
        metrics=_metrics(r.metrics),
        previous=_metrics(r.previous) if r.previous else None,
        previous_label=q.prev().label,
        rising=[
            CategoryRiseOut(name=n, amount=a, previous=b)
            for n, a, b in svc.rising(r.metrics, r.previous)
        ],
        changed=r.changed,
        next_steps=r.next_steps,
        saved_at=r.saved_at,
    )


@router.get("", response_model=list[QuarterItemOut])
def list_quarters(db: DB, user: CurrentUser) -> list[QuarterItemOut]:
    """Trimestres con datos, del más reciente al más antiguo."""
    today = date.today()
    return [
        QuarterItemOut(quarter=q.key, label=q.label, in_progress=q.end >= today, saved=done)
        for q, done in svc.quarters(db, user.id, today)
    ]


@router.get("/{quarter}", response_model=QuarterReviewOut)
def get_review(quarter: str, db: DB, user: CurrentUser) -> QuarterReviewOut:
    return _out(svc.review(db, user, svc.Quarter.parse(quarter)))


@router.put("/{quarter}", response_model=QuarterReviewOut)
def save_review(quarter: str, body: QuarterReviewIn, db: DB, user: CurrentUser) -> QuarterReviewOut:
    """Guarda las respuestas y una foto de las métricas de este momento."""
    q = svc.Quarter.parse(quarter)
    svc.save(db, user, q, body.changed, body.next_steps)
    return _out(svc.review(db, user, q))
