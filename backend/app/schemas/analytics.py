"""Esquemas de patrimonio, rentabilidad y exposición (fase 4)."""

import datetime as dt
import uuid
from typing import Literal

from pydantic import BaseModel, Field

from app.schemas.types import Money, Quantity


class AccountBalanceOut(BaseModel):
    id: uuid.UUID
    name: str
    kind: str
    balance: Money


class NetWorthOut(BaseModel):
    total: Money
    accounts: list[AccountBalanceOut]
    investments: Money
    pending: Money
    by_type: dict[str, Money]
    receivable: Money
    debts: Money
    installments: Money
    unrealized_gain: Money
    tax_if_sold: Money | None
    after_tax: Money | None
    tax_year: int | None
    tax_source: str | None


class NetWorthPointOut(BaseModel):
    date: dt.date
    accounts: Money
    investments: Money


class NetWorthComponentOut(BaseModel):
    key: str = Field(description="c:<cuenta> o a:<activo>")
    label: str
    kind: Literal["cuenta", "inversion"]
    group: str = Field(description="Tipo de cuenta (gastos, ahorro, refugio) o de activo")
    entity: str = Field(description="Banco o plataforma")


class EvolutionPointOut(BaseModel):
    date: dt.date
    accounts: Money
    investments: Money
    contributed: Money = Field(description="Dinero puesto en inversiones hasta ese día")
    pending: Money = Field(description="Pendiente de VL (solo el punto de hoy)")
    receivable: Money
    debts: Money
    installments: Money
    net: Money
    components: dict[str, Money]


class NetWorthEvolutionOut(BaseModel):
    start: dt.date | None
    per_cycle_until: dt.date | None = Field(
        description="Hasta esta fecha, un punto por ciclo (movimientos sin fecha del Excel)"
    )
    components: list[NetWorthComponentOut]
    points: list[EvolutionPointOut]


class MilestoneOut(BaseModel):
    amount: Money
    reached_on: dt.date | None
    before_start: bool = Field(description="Ya se superaba al empezar la serie")


class MilestoneNextOut(BaseModel):
    amount: Money
    months: int | None = Field(description="Meses al ritmo de aportación actual (sin rentabilidad)")
    eta: dt.date | None


class MilestonesOut(BaseModel):
    thresholds: list[Money]
    items: list[MilestoneOut]
    next: MilestoneNextOut | None
    pace: Money = Field(description="Aportación media mensual (inversión + ahorro), 12 meses")
    net: Money
    start: dt.date | None


class MilestonesIn(BaseModel):
    thresholds: list[Money] = Field(max_length=20)


class PerformanceMonthOut(BaseModel):
    year: int
    month: int
    start_value: Money
    end_value: Money
    net_flow: Money
    gain: Money
    ret: Quantity | None
    cumulative: Quantity | None


class SeriesPointOut(BaseModel):
    date: dt.date
    value: Money
    contributed: Money


class PerformanceOut(BaseModel):
    first: dt.date | None
    days: int
    value: Money
    contributed: Money
    gain: Money
    twr: Quantity | None
    twr_annual: Quantity | None
    ytd: Quantity | None
    xirr: Quantity | None
    max_drawdown: Quantity | None
    volatility: Quantity | None
    best: PerformanceMonthOut | None
    worst: PerformanceMonthOut | None
    positive_months: int
    negative_months: int
    months: list[PerformanceMonthOut]
    series: list[SeriesPointOut]
    # Inicio del seguimiento: lo anterior, resumido (None si se mira desde la primera operación)
    before_until: dt.date | None = None
    before_contributed: Money | None = None
    before_value: Money | None = None


class ExposureItemOut(BaseModel):
    key: str
    weight: Quantity
    value: Money


class ExposureOut(BaseModel):
    tipo: list[ExposureItemOut]
    plataforma: list[ExposureItemOut]
    sector: list[ExposureItemOut]
    region: list[ExposureItemOut]
    pais: list[ExposureItemOut]
    divisa: list[ExposureItemOut]


class AssetExposureIn(BaseModel):
    dimension: Literal["sector", "region", "pais"]
    key: str = Field(min_length=1, max_length=60)
    weight: Quantity = Field(description="Tanto por uno")


class AssetExposureOut(BaseModel):
    dimension: str
    key: str
    weight: Quantity
    source: str
    as_of: dt.date | None


class JobResultOut(BaseModel):
    updated: int
    errors: list[str]


class SaleOut(BaseModel):
    asset: str
    date: dt.date
    units: Quantity
    proceeds: Money
    cost: Money
    gain: Money


class IncomeOut(BaseModel):
    source: str
    date: dt.date
    amount: Money
    kind: Literal["interes_cuenta", "dividendo", "interes", "recompensa_cripto"]


class TransferOut(BaseModel):
    asset: str
    date: dt.date
    units: Quantity


class YearEndOut(BaseModel):
    name: str
    kind: Literal["cuenta", "activo"]
    value: Money
    foreign_hint: bool


class TaxReportOut(BaseModel):
    year: int
    sales: list[SaleOut]
    gains_total: Money
    transfers: list[TransferOut]
    income: list[IncomeOut]
    income_total: Money
    savings_base: Money  # ganancias + rendimientos (antes de compensaciones)
    year_end: list[YearEndOut]
    foreign_total: Money


# --- Historial de aportaciones ------------------------------------------------------------------
class ContributionItemOut(BaseModel):
    date: dt.date
    type: Literal["aportacion", "retirada", "traspaso", "partida"]
    kind: Literal["inversion", "ahorro"]
    destination: str
    destination_label: str
    amount: Money
    origin: str
    status: Literal["confirmada", "pendiente"]
    tx_id: uuid.UUID | None
    movement_id: uuid.UUID | None
    asset_id: uuid.UUID | None
    account_id: uuid.UUID | None


class ContributionMonthOut(BaseModel):
    year: int
    month: int
    total: Money
    by_destination: dict[str, Money]


class ContributionDestinationOut(BaseModel):
    key: str
    label: str
    kind: Literal["inversion", "ahorro"]


class ContributionsOut(BaseModel):
    this_month: Money
    this_year: Money
    total: Money
    withdrawn: Money
    starting: Money = Field(description="Posiciones iniciales: saldo de partida, no aportación")
    pace: Money = Field(description="Media mensual de los últimos 12 meses")
    streak: int = Field(description="Meses seguidos aportando")
    pace_investing: Money = Field(description="Como pace, solo a inversiones (sin ahorro)")
    streak_investing: int = Field(description="Como streak, solo a inversiones (sin ahorro)")
    track_start: dt.date | None
    destinations: list[ContributionDestinationOut]
    months: list[ContributionMonthOut]
    items: list[ContributionItemOut]
