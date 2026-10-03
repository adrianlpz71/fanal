import datetime as dt
import uuid
from decimal import Decimal
from typing import Literal

from pydantic import BaseModel, Field, model_validator

from app.schemas.types import Money

AccountKind = Literal["gastos", "refugio", "ahorro", "inversion", "efectivo", "otra"]
MovementKind = Literal["gasto", "ingreso", "nomina", "transferencia", "reembolso", "ajuste"]
MovementStatus = Literal["planned", "posted", "cancelled"]
Provider = Literal["paypal", "klarna", "tarjeta", "amazon", "eci", "otro"]


# --- Onboarding del módulo -------------------------------------------------------------
class GastosSetupIn(BaseModel):
    bank: str = Field(max_length=80, description="Banco de la cuenta donde cobras")
    current_balance: Money = Field(description="Saldo real hoy")
    payday_day: int = Field(ge=1, le=31, default=27)
    usual_payroll: Money | None = None
    refugio_bank: str | None = Field(default=None, max_length=80)
    refugio_balance: Money | None = None
    emergency_target: Money | None = None
    monthly_refugio: Money | None = None


class GastosSettingsOut(BaseModel):
    configured: bool
    payday_day: int
    usual_payroll: Money | None
    main_account_id: uuid.UUID | None
    refugio_account_id: uuid.UUID | None
    emergency_target: Money | None
    monthly_refugio: Money | None
    forecast_months: int


class GastosSettingsIn(BaseModel):
    payday_day: int | None = Field(default=None, ge=1, le=31)
    usual_payroll: Money | None = None
    emergency_target: Money | None = None
    monthly_refugio: Money | None = None
    forecast_months: int | None = Field(default=None, ge=1, le=24)


# --- Cuentas ---------------------------------------------------------------------------
class AccountIn(BaseModel):
    id: uuid.UUID | None = None  # UUIDv7 generado en el cliente (opcional)
    kind: AccountKind
    name: str = Field(max_length=80)
    bank: str = Field(default="", max_length=80)
    opening_balance: Money = Decimal(0)
    opening_date: dt.date | None = None
    apy: str | None = None


class AccountPatch(BaseModel):
    name: str | None = Field(default=None, max_length=80)
    bank: str | None = Field(default=None, max_length=80)
    archived: bool | None = None
    apy: str | None = None


class AccountOut(BaseModel):
    id: uuid.UUID
    kind: AccountKind
    name: str
    bank: str
    balance: Money
    balance_with_planned: Money
    archived: bool


class ReconcileIn(BaseModel):
    real_balance: Money
    create_adjustment: bool = True


class ReconcileOut(BaseModel):
    computed: Money
    real: Money
    difference: Money
    adjustment_id: uuid.UUID | None


# --- Categorías ------------------------------------------------------------------------
class CategoryOut(BaseModel):
    id: uuid.UUID
    parent_id: uuid.UUID | None
    name: str
    kind: str
    icon: str
    color: str
    fixed: bool
    archived: bool


class CategoryIn(BaseModel):
    parent_id: uuid.UUID | None = None
    name: str = Field(max_length=80)
    kind: Literal["gasto", "ingreso", "transferencia"] = "gasto"
    icon: str = "category"
    color: str = "#607D8B"
    fixed: bool = False


class CategoryPatch(BaseModel):
    name: str | None = Field(default=None, max_length=80)
    icon: str | None = None
    color: str | None = None
    fixed: bool | None = None
    archived: bool | None = None


# --- Movimientos -----------------------------------------------------------------------
MONTH_HELP = "Ciclo al que va (AAAA-MM): el actual o uno futuro, donde queda como previsto"


class MovementLineOut(BaseModel):
    seq: int
    amount: Money
    note: str | None


class ShareBriefOut(BaseModel):
    id: uuid.UUID
    person_name: str
    amount: Money
    direction: Literal["me_deben", "debo"]
    status: Literal["pendiente", "saldada"]


class MovementOut(BaseModel):
    id: uuid.UUID
    account_id: uuid.UUID
    cycle_id: uuid.UUID | None
    date: dt.date | None
    due_date: dt.date | None
    kind: MovementKind
    status: MovementStatus
    concept: str
    amount: Money
    expression: str | None
    lines: list[MovementLineOut]
    category_id: uuid.UUID | None
    source: str
    source_ref: uuid.UUID | None
    notes: str | None
    debt_id: uuid.UUID | None = None
    refund_of_id: uuid.UUID | None = None
    shares: list[ShareBriefOut]


class MovementIn(BaseModel):
    id: uuid.UUID | None = None  # UUIDv7 del cliente → crear dos veces no duplica
    concept: str = Field(min_length=1, max_length=160)
    amount: Money | None = None
    expression: str | None = Field(
        default=None, max_length=500, description="Alternativa al importe: '=-60+20+12'"
    )
    kind: MovementKind = "gasto"
    status: Literal["planned", "posted"] = "posted"
    date: dt.date | None = None
    due_date: dt.date | None = None
    account_id: uuid.UUID | None = None  # por defecto, la cuenta de gastos
    cycle_id: uuid.UUID | None = None  # por defecto, el ciclo abierto
    month: str | None = Field(default=None, pattern=r"^\d{4}-\d{2}$", description=MONTH_HELP)
    category_id: uuid.UUID | None = None
    notes: str | None = Field(default=None, max_length=2000)
    to_account_id: uuid.UUID | None = Field(
        default=None, description="Solo transferencias: cuenta propia de destino"
    )

    @model_validator(mode="after")
    def _amount_or_expression(self) -> "MovementIn":
        if (self.amount is None) == (not self.expression):
            raise ValueError("Indica el importe o una expresión, no ambos")
        return self


class MovementPatch(BaseModel):
    concept: str | None = Field(default=None, min_length=1, max_length=160)
    amount: Money | None = None
    expression: str | None = Field(default=None, max_length=500)
    kind: MovementKind | None = None
    status: MovementStatus | None = None
    date: dt.date | None = None
    due_date: dt.date | None = None
    cycle_id: uuid.UUID | None = None
    category_id: uuid.UUID | None = None
    notes: str | None = Field(default=None, max_length=2000)
    debt_id: uuid.UUID | None = None
    month: str | None = Field(default=None, pattern=r"^\d{4}-\d{2}$", description=MONTH_HELP)


class SuggestionOut(BaseModel):
    concept: str
    category_id: uuid.UUID | None
    amount: Money | None


# --- Ciclos ----------------------------------------------------------------------------
class CycleSummaryOut(BaseModel):
    carried: Money
    payroll: Money
    opening: Money
    available_now: Money
    expected_end: Money
    net_movements: Money
    pending_total: Money
    fixed_spend: Money
    variable_spend: Money
    installments: Money
    savings: Money
    savings_rate: str | None  # tanto por uno, string decimal
    days_to_payday: int | None
    per_day: Money | None


class CycleOut(BaseModel):
    id: uuid.UUID
    label: str
    status: Literal["open", "closed"]
    start_date: dt.date
    end_date: dt.date | None
    carried_expected: Money | None
    discrepancy: Money | None
    summary: CycleSummaryOut


class CycleDetailOut(CycleOut):
    movements: list[MovementOut]


class CycleStartIn(BaseModel):
    """Primer ciclo (sin Excel): se abre con el saldo actual como arrastre."""

    current_balance: Money
    payroll_amount: Money = Decimal(0)
    payroll_date: dt.date | None = None


class PaydayIn(BaseModel):
    payroll_amount: Money
    payroll_date: dt.date
    real_balance_before: Money = Field(description="Saldo real del banco ANTES de la nómina")
    pending_actions: dict[uuid.UUID, Literal["carry", "cancel"]] = Field(default_factory=dict)


class PaydayOut(BaseModel):
    closed_id: uuid.UUID
    opened: CycleOut
    discrepancy: Money
    carried_over: int
    cancelled: int


class PaydayUndoOut(BaseModel):
    available: bool
    reason: str | None = Field(default=None, description="Por qué no se puede, si no se puede")


# --- Recurrentes -----------------------------------------------------------------------
class RecurringIn(BaseModel):
    concept: str = Field(max_length=160)
    amount: Money
    amount_is_estimate: bool = False
    kind: MovementKind = "gasto"
    category_id: uuid.UUID | None = None
    every_months: int = Field(default=1, ge=1, le=24)
    day_of_month: int = Field(default=1, ge=1, le=31)
    start_date: dt.date
    end_date: dt.date | None = None
    account_id: uuid.UUID | None = None
    notes: str | None = None


class RecurringPatch(BaseModel):
    concept: str | None = Field(default=None, max_length=160)
    amount: Money | None = None
    amount_is_estimate: bool | None = None
    category_id: uuid.UUID | None = None
    every_months: int | None = Field(default=None, ge=1, le=24)
    day_of_month: int | None = Field(default=None, ge=1, le=31)
    end_date: dt.date | None = None
    active: bool | None = None
    review: Literal["ok", "revisar", "cancelar"] | None = None
    est_saving_year: Money | None = None
    notes: str | None = None


class PriceChangeOut(BaseModel):
    id: uuid.UUID
    old_amount: Money
    new_amount: Money
    detected_at: str


class RecurringOut(BaseModel):
    id: uuid.UUID
    concept: str
    amount: Money
    amount_is_estimate: bool
    kind: MovementKind
    category_id: uuid.UUID | None
    every_months: int
    day_of_month: int
    start_date: dt.date
    end_date: dt.date | None
    active: bool
    review: str
    est_saving_year: Money | None
    monthly_cost: Money
    yearly_cost: Money
    price_changes: list[PriceChangeOut]
    notes: str | None


# --- Fraccionadas ----------------------------------------------------------------------
class InstallmentPlanIn(BaseModel):
    description: str = Field(max_length=160)
    merchant: str = Field(default="", max_length=80)
    provider: Provider = "otro"
    total: Money
    n: int = Field(ge=1, le=120)
    first_due: dt.date
    every_months: int = Field(default=1, ge=1, le=12)
    fee: Money = Decimal(0)
    category_id: uuid.UUID | None = None
    custom_amounts: list[Money] | None = None
    paid_count: int = Field(default=0, ge=0, description="Cuotas ya pagadas antes de darla de alta")


class InstallmentOut(BaseModel):
    seq: int
    due_date: dt.date
    amount: Money
    status: str
    movement_id: uuid.UUID | None


class InstallmentPlanOut(BaseModel):
    id: uuid.UUID
    description: str
    merchant: str
    provider: Provider
    total: Money
    n: int
    every_months: int
    first_due: dt.date
    fee: Money
    status: str
    category_id: uuid.UUID | None
    paid: int
    remaining_amount: Money
    next_due: dt.date | None
    installments: list[InstallmentOut]


class AdvanceIn(BaseModel):
    merge: bool = Field(default=True, description="Agrupar las cuotas pendientes en un cargo")


class AdvanceOut(BaseModel):
    moved: int
    amount: Money


# --- Meses vista -----------------------------------------------------------------------
class ForecastMonthOut(BaseModel):
    label: str
    ym: str
    start: dt.date
    end: dt.date
    payroll: Money
    recurring: Money
    installments: Money
    other: Money
    free: Money
    cumulative: Money


class MonthItemOut(BaseModel):
    kind: Literal["movimiento", "recurrente"]
    date: dt.date
    concept: str
    amount: Money
    category_id: uuid.UUID | None
    source: str
    movement: MovementOut | None
    template_id: uuid.UUID | None


class MonthOut(ForecastMonthOut):
    items: list[MonthItemOut]


class OccurrenceIn(BaseModel):
    date: dt.date
    action: Literal["editar", "saltar"]


class ForecastOut(BaseModel):
    months: list[ForecastMonthOut]
    live_installment_debt: Money
