import datetime as dt
import uuid
from decimal import Decimal
from typing import Literal

from pydantic import BaseModel, Field, model_validator

from app.schemas.types import Money, Quantity

Direction = Literal["me_deben", "debo"]


# --- Personas y compartidos ------------------------------------------------------------
class PersonIn(BaseModel):
    name: str = Field(min_length=1, max_length=80)
    notes: str | None = None


class PersonPatch(BaseModel):
    name: str | None = Field(default=None, min_length=1, max_length=80)
    notes: str | None = None
    archived: bool | None = None


class PersonOut(BaseModel):
    id: uuid.UUID
    name: str
    notes: str | None
    archived: bool
    owed_to_me: Money  # me deben (pendiente)
    i_owe: Money  # debo (pendiente)
    net: Money  # positivo = me deben


class ShareIn(BaseModel):
    person_id: uuid.UUID | None = None
    person_name: str | None = Field(default=None, max_length=80)
    amount: Money
    direction: Direction = "me_deben"

    @model_validator(mode="after")
    def _who(self) -> "ShareIn":
        if not self.person_id and not (self.person_name or "").strip():
            raise ValueError("Indica la persona (id o nombre)")
        if self.amount <= 0:
            raise ValueError("El importe debe ser positivo")
        return self


class ShareOut(BaseModel):
    id: uuid.UUID
    movement_id: uuid.UUID
    person_id: uuid.UUID
    person_name: str
    amount: Money
    direction: Direction
    status: Literal["pendiente", "saldada"]
    settled_by_movement_id: uuid.UUID | None
    movement_concept: str | None = None
    movement_date: dt.date | None = None


class SettleIn(BaseModel):
    create_movement: bool = Field(
        default=True, description="Crear el movimiento de reembolso (Bizum recibido/enviado)"
    )
    movement_id: uuid.UUID | None = Field(
        default=None, description="O vincular uno que ya existe (p. ej. importado del banco)"
    )
    date: dt.date | None = None


class SettleOut(BaseModel):
    share: ShareOut
    movement_id: uuid.UUID | None


# --- Deudas ------------------------------------------------------------------------------
class DebtIn(BaseModel):
    name: str = Field(max_length=120)
    person_name: str | None = Field(default=None, max_length=80)
    direction: Literal["debo", "me_deben"] = "debo"
    opening_balance: Money
    opening_date: dt.date
    interest_rate: str | None = None
    notes: str | None = None


class DebtPatch(BaseModel):
    name: str | None = Field(default=None, max_length=120)
    notes: str | None = None
    interest_rate: str | None = None


class DebtMovementOut(BaseModel):
    id: uuid.UUID
    date: dt.date | None
    concept: str
    amount: Money


class DebtOut(BaseModel):
    id: uuid.UUID
    name: str
    person_name: str | None
    direction: Literal["debo", "me_deben"]
    opening_balance: Money
    opening_date: dt.date
    remaining: Money
    paid: Money
    status: Literal["viva", "saldada"]
    interest_rate: str | None
    notes: str | None
    movements: list[DebtMovementOut]


class DebtPaymentIn(BaseModel):
    amount: Money = Field(description="Positivo: lo que pagas (debo) o te pagan (me deben)")
    date: dt.date | None = None
    concept: str | None = Field(default=None, max_length=160)


# --- Seguimientos --------------------------------------------------------------------------
class TrackerIn(BaseModel):
    name: str = Field(max_length=80)
    opening_balance: Money = Decimal(0)
    opening_date: dt.date
    category_ids: list[uuid.UUID] = Field(default_factory=list)
    keywords: list[str] = Field(default_factory=list)
    notes: str | None = None


class TrackerPatch(BaseModel):
    name: str | None = Field(default=None, max_length=80)
    opening_balance: Money | None = None
    opening_date: dt.date | None = None
    category_ids: list[uuid.UUID] | None = None
    keywords: list[str] | None = None
    archived: bool | None = None
    notes: str | None = None


class TrackerCycleOut(BaseModel):
    label: str
    amount: Money


class TrackerOut(BaseModel):
    id: uuid.UUID
    name: str
    opening_balance: Money
    opening_date: dt.date
    category_ids: list[uuid.UUID]
    keywords: list[str]
    archived: bool
    notes: str | None
    balance: Money
    movements_count: int
    by_cycle: list[TrackerCycleOut]


# --- Reglas y presupuestos ---------------------------------------------------------------
class RuleOut(BaseModel):
    id: uuid.UUID
    pattern: str
    category_id: uuid.UUID
    source: str
    hits: int


class BudgetIn(BaseModel):
    amount: Money


class BudgetOut(BaseModel):
    category_id: uuid.UUID
    amount: Money
    active: bool


# --- Estadísticas ------------------------------------------------------------------------
class CategoryAmountOut(BaseModel):
    category_id: uuid.UUID | None
    amount: Money


class CycleStatsOut(BaseModel):
    cycle_id: uuid.UUID
    label: str
    status: str
    payroll: Money
    income: Money
    spend: Money
    fixed: Money
    variable: Money
    installments: Money
    savings: Money
    savings_rate: str | None
    by_category: list[CategoryAmountOut]


class CategoryStatOut(BaseModel):
    category_id: uuid.UUID | None
    name: str
    current: Money
    average: Money
    budget: Money | None
    budget_used: str | None  # tanto por uno
    trend: list[Money]


class TopConceptOut(BaseModel):
    concept: str
    total: Money
    count: int


class StatsOut(BaseModel):
    cycles: list[CycleStatsOut]
    categories: list[CategoryStatOut]
    top_concepts: list[TopConceptOut]
    avg_spend: Money
    avg_savings_rate: str | None


# --- Fraccionadas (renombrar) ---------------------------------------------------------------
class InstallmentPlanPatch(BaseModel):
    description: str | None = Field(default=None, max_length=160)
    merchant: str | None = Field(default=None, max_length=80)
    category_id: uuid.UUID | None = None
    notes: str | None = None


# --- Panel de gastos fijos (fase 6) ---------------------------------------------------------------
class FixedItemOut(BaseModel):
    kind: Literal["recurrente", "cuota"]
    id: uuid.UUID
    name: str
    monthly: Money
    yearly: Money
    review: str | None
    est_saving_year: Money | None
    price_changes: int
    ends: dt.date | None
    category_id: uuid.UUID | None


class FixedSuggestionOut(BaseModel):
    concept: str
    amount: Money
    cycles: int
    day_of_month: int
    category_id: uuid.UUID | None


class FixedTrendOut(BaseModel):
    label: str
    fixed: Money


class FixedPanelOut(BaseModel):
    items: list[FixedItemOut]
    monthly_total: Money
    yearly_total: Money
    payroll: Money | None
    share_of_payroll: Quantity | None
    trend: list[FixedTrendOut]
    goal_max: Money | None
    goal_name: str | None
    saved_year: Money
    to_review_saving: Money
    suggestions: list[FixedSuggestionOut]
    review_due: bool
    last_review: dt.date | None
