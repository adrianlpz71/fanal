"""Esquemas de la revisión trimestral."""

import datetime as dt

from pydantic import BaseModel, Field

from app.schemas.types import Money, Quantity


class QuarterItemOut(BaseModel):
    quarter: str  # "2026-Q3"
    label: str  # "T3 2026"
    in_progress: bool
    saved: bool


class ReviewGoalOut(BaseModel):
    name: str
    progress: Quantity | None
    on_track: bool | None


class QuarterMetricsOut(BaseModel):
    cycles: int
    income: Money
    spend: Money
    surplus: Money
    savings_rate: Quantity | None
    fixed_avg: Money | None
    portfolio_start: Money
    portfolio_end: Money
    contributed: Money
    gain: Money
    twr: Quantity | None
    networth_start: Money
    networth_end: Money
    fire_needed: Money | None
    fire_progress: Quantity | None
    fire_age: Quantity | None
    out_of_range: list[str]
    goals: list[ReviewGoalOut]


class CategoryRiseOut(BaseModel):
    name: str
    amount: Money
    previous: Money


class QuarterReviewOut(BaseModel):
    quarter: str
    label: str
    start: dt.date
    end: dt.date
    in_progress: bool
    metrics: QuarterMetricsOut
    previous: QuarterMetricsOut | None
    previous_label: str
    rising: list[CategoryRiseOut]
    changed: str
    next_steps: str
    saved_at: dt.datetime | None


class QuarterReviewIn(BaseModel):
    changed: str = Field(default="", max_length=4000)
    next_steps: str = Field(default="", max_length=4000)
