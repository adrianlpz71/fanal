"""Esquemas de la fase 5: FIRE, interés compuesto, simulador fiscal y objetivos."""

import datetime as dt
import uuid
from decimal import Decimal
from typing import Literal

from pydantic import BaseModel, Field

from app.schemas.types import Money, Quantity

GoalKind = Literal[
    "edad_fi", "fondo_emergencia", "patrimonio", "cartera_en_fecha", "fijos_max", "tasa_ahorro_min"
]


class FireSettingsIn(BaseModel):
    target_age: int | None = Field(default=None, ge=18, le=100)
    monthly_spend: Money | None = None
    swr: Quantity | None = None
    nominal_return: Quantity | None = None
    inflation: Quantity | None = None
    costs: Quantity | None = None
    contribution_growth: Quantity | None = None
    pension_monthly: Money | None = None
    pension_age: int | None = Field(default=None, ge=50, le=80)
    include_taxes: bool | None = None
    home_value: Money | None = None
    volatility: Quantity | None = None
    horizon_age: int | None = Field(default=None, ge=60, le=110)
    capital_override: Money | None = None
    contribution_override: Money | None = None
    clear_capital_override: bool = False
    clear_contribution_override: bool = False


class FireSettingsOut(BaseModel):
    configured: bool
    target_age: int
    monthly_spend: Money
    swr: Quantity
    nominal_return: Quantity
    inflation: Quantity
    costs: Quantity
    contribution_growth: Quantity
    pension_monthly: Money
    pension_age: int
    include_taxes: bool
    home_value: Money
    volatility: Quantity
    horizon_age: int
    capital_override: Money | None
    contribution_override: Money | None


class FireResultOut(BaseModel):
    real_return: Quantity
    needed: Money
    needed_nominal: Money
    progress: Quantity
    required_monthly: Money
    fi_age: Quantity | None
    coast: Money
    coast_reached: bool
    bridge: Money


class ProjectionPointOut(BaseModel):
    age: Quantity
    pessimistic: Money
    base: Money
    optimistic: Money


class CutEffectOut(BaseModel):
    cut: Money
    fi_age: Quantity | None


class FirePlanOut(BaseModel):
    settings: FireSettingsOut
    age: Quantity
    capital: Money
    capital_auto: Money
    monthly_contribution: Money
    contribution_auto: Money
    cycles_used: int
    avg_spend: Money | None
    gain_ratio: Quantity | None
    gross_annual: Money
    tax_annual: Money
    base: FireResultOut
    pessimistic: FireResultOut
    optimistic: FireResultOut
    projection: list[ProjectionPointOut]
    cut_effect: list[CutEffectOut]


class CompoundIn(BaseModel):
    initial: Money = Decimal(0)
    contribution: Money = Decimal(0)
    periods: Literal[12, 1] = 12
    timing: Literal["inicio", "final"] = "final"
    annual_increase: Quantity = Decimal(0)
    annual_rate: Quantity
    years: int = Field(ge=1, le=80)
    convention: Literal["nominal", "efectivo"] = "nominal"
    inflation: Quantity = Decimal(0)
    tax_on_withdrawal: bool = False


class CompoundYearOut(BaseModel):
    year: int
    contributed: Money
    interest: Money
    total: Money
    real_total: Money


class CompoundOut(BaseModel):
    rows: list[CompoundYearOut]
    total: Money
    contributed: Money
    interest: Money
    real_total: Money
    tax_if_withdrawn: Money | None
    net_if_withdrawn: Money | None
    convention_note: str


class TaxIn(BaseModel):
    base_general: Money = Decimal(0)
    base_savings: Money = Decimal(0)
    net_wealth: Money | None = None
    home_value: Money | None = None
    remember_base_general: bool = Field(
        default=False, description="Guardar la base general para prellenarla la próxima vez"
    )


class TaxBracketOut(BaseModel):
    lo: Money
    hi: Money | None
    rate: Quantity
    amount: Money = Field(description="Lo que cae en este tramo")
    tax: Money


class TaxOut(BaseModel):
    year: int
    region: str
    irpf_general_state: Money
    irpf_general_regional: Money
    irpf_savings: Money
    irpf_total: Money
    wealth_taxable: Money
    wealth_quota_before_limit: Money
    wealth_quota: Money
    wealth_joint_limit_applied: bool
    wealth_obliged: bool
    solidarity_warning: bool
    # Paso a paso
    base_general: Money
    base_savings: Money
    minimum_state: Money
    minimum_regional: Money
    minimum_quota: Money = Field(description="Cuota que corresponde al mínimo personal (se resta)")
    general_brackets: list[TaxBracketOut] = Field(description="Escala estatal + autonómica")
    savings_brackets: list[TaxBracketOut]
    average_rate: Quantity | None
    marginal_general: Quantity
    marginal_savings: Quantity


class TaxPrefillOut(BaseModel):
    year: int
    payroll_net: Money = Field(description="Nóminas cobradas en el año, de los ciclos (referencia)")
    base_general: Money | None = Field(description="La que guardaste la última vez")
    realized_gains: Money
    income: Money
    base_savings: Money
    sales: int


class SellPreviewIn(BaseModel):
    amount: Money = Field(gt=0)
    asset_id: uuid.UUID | None = Field(default=None, description="Sin activo: toda la cartera")
    base_general: Money = Decimal(0)
    base_savings: Money = Decimal(0)


class SalePartOut(BaseModel):
    asset_id: uuid.UUID
    name: str
    amount: Money
    units: Quantity
    cost: Money
    gain: Money


class SellPreviewOut(BaseModel):
    amount: Money
    gain: Money
    tax: Money = Field(description="Lo que la venta añade a tu IRPF del año")
    net: Money
    available: Money
    parts: list[SalePartOut]


class GoalIn(BaseModel):
    id: uuid.UUID | None = None
    kind: GoalKind
    name: str = Field(min_length=1, max_length=120)
    target_value: Quantity | None = None
    target_date: dt.date | None = None


class GoalOut(BaseModel):
    id: uuid.UUID
    kind: GoalKind
    name: str
    target_value: Quantity | None
    target_date: dt.date | None
    current: Quantity | None
    progress: Quantity | None
    on_track: bool | None
    detail: str


class BandOut(BaseModel):
    age: int
    p10: Money
    p50: Money
    p90: Money


class MonteCarloOut(BaseModel):
    simulations: int
    volatility: Quantity
    horizon_age: int
    target_age: int
    success: Quantity  # probabilidad de que el dinero dure hasta el horizonte
    reach: Quantity  # probabilidad de tener el capital necesario a la edad objetivo
    fi_age_p10: int | None
    fi_age_p50: int | None
    fi_age_p90: int | None
    depletion_median_age: int | None
    bands: list[BandOut]
