"""Esquemas de la API de inversiones. Importes como Money (2 decimales) y participaciones,
precios y porcentajes como Quantity (string decimal sin redondear)."""

import datetime as dt
import uuid
from decimal import Decimal
from typing import Literal

from pydantic import BaseModel, Field

from app.schemas.types import Money, Quantity

AssetType = Literal["fondo", "etf", "accion", "cripto", "cuenta", "otro"]
PriceProvider = Literal["ft", "coingecko", "manual"]
PlatformKind = Literal["broker", "exchange", "banco", "otro"]
TxKind = Literal[
    "posicion_inicial", "compra", "venta", "aportacion_periodica", "traspaso_salida",
    "traspaso_entrada", "dividendo", "interes", "comision", "recompensa",
]  # fmt: skip
TxStatus = Literal["pendiente_vl", "liquidada", "cancelada"]


# --- Plataformas y categorías ------------------------------------------------------------------
class PlatformIn(BaseModel):
    id: uuid.UUID | None = None
    name: str = Field(min_length=1, max_length=80)
    kind: PlatformKind = "broker"
    units_decimals: int = Field(default=4, ge=0, le=10)
    default_fee: Money = Decimal(0)
    notes: str | None = None


class PlatformOut(BaseModel):
    id: uuid.UUID
    name: str
    kind: PlatformKind
    units_decimals: int
    default_fee: Money
    notes: str | None


class AssetClassOut(BaseModel):
    id: uuid.UUID
    name: str
    default_tolerance_pp: Quantity
    sort: int


class AssetClassIn(BaseModel):
    name: str = Field(min_length=1, max_length=60)
    default_tolerance_pp: Quantity = Decimal(1)


# --- Activos ----------------------------------------------------------------------------------
class AssetIn(BaseModel):
    id: uuid.UUID | None = None
    name: str = Field(min_length=1, max_length=120)
    type: AssetType
    asset_class_id: uuid.UUID | None = None
    platform_id: uuid.UUID | None = None
    isin: str | None = Field(default=None, max_length=12)
    ticker: str | None = Field(default=None, max_length=20)
    coingecko_id: str | None = Field(default=None, max_length=60)
    currency: str = Field(default="EUR", min_length=3, max_length=3)
    price_provider: PriceProvider = "manual"
    price_ref: str | None = Field(default=None, max_length=120)
    units_decimals: int | None = Field(default=None, ge=0, le=10)
    sector: str | None = None
    country: str | None = None
    watchlist: bool = False
    notes: str | None = None


class AssetPatch(BaseModel):
    name: str | None = Field(default=None, max_length=120)
    asset_class_id: uuid.UUID | None = None
    platform_id: uuid.UUID | None = None
    isin: str | None = Field(default=None, max_length=12)
    ticker: str | None = Field(default=None, max_length=20)
    coingecko_id: str | None = Field(default=None, max_length=60)
    price_provider: PriceProvider | None = None
    price_ref: str | None = Field(default=None, max_length=120)
    units_decimals: int | None = Field(default=None, ge=0, le=10)
    sector: str | None = None
    country: str | None = None
    watchlist: bool | None = None
    archived: bool | None = None
    notes: str | None = None


class AssetOut(BaseModel):
    id: uuid.UUID
    name: str
    type: AssetType
    asset_class_id: uuid.UUID | None
    platform_id: uuid.UUID | None
    isin: str | None
    ticker: str | None
    coingecko_id: str | None
    currency: str
    price_provider: PriceProvider
    price_ref: str | None
    units_decimals: int | None
    sector: str | None
    country: str | None
    watchlist: bool
    archived: bool
    notes: str | None


# --- Objetivos --------------------------------------------------------------------------------
class MacroTargetIn(BaseModel):
    asset_class_id: uuid.UUID
    target: Quantity = Field(description="Tanto por uno (0.9 = 90 %)")
    min: Quantity | None = None
    max: Quantity | None = None
    tolerance_pp: Quantity | None = None


class AssetTargetIn(BaseModel):
    asset_id: uuid.UUID
    target: Quantity


class TargetsIn(BaseModel):
    macro: list[MacroTargetIn] = Field(default_factory=list)
    assets: list[AssetTargetIn] = Field(default_factory=list)
    valid_from: dt.date | None = None


class MacroTargetOut(BaseModel):
    asset_class_id: uuid.UUID
    target: Quantity
    min: Quantity | None
    max: Quantity | None
    tolerance_pp: Quantity | None
    valid_from: dt.date


class AssetTargetOut(BaseModel):
    asset_id: uuid.UUID
    target: Quantity
    valid_from: dt.date


class TargetsOut(BaseModel):
    macro: list[MacroTargetOut]
    assets: list[AssetTargetOut]


# --- Cartera ----------------------------------------------------------------------------------
class PositionOut(BaseModel):
    asset: AssetOut
    units: Quantity
    avg_cost: Quantity
    cost: Money
    price: Quantity | None
    price_date: dt.date | None
    price_source: str | None
    stale: bool
    value: Money
    pnl: Money
    pnl_pct: Quantity | None
    pending: Money
    inner_weight: Quantity
    inner_target: Quantity | None
    inner_status: Literal["comprar", "no_comprar", "ok"] | None


class ClassOut(BaseModel):
    asset_class: AssetClassOut
    value: Money
    pending: Money
    weight: Quantity
    target: Quantity | None
    min: Quantity | None
    max: Quantity | None
    tolerance_pp: Quantity
    status: Literal["bajo", "alto", "ok"] | None
    positions: list[PositionOut]


class EmergencyOut(BaseModel):
    target: Money
    current: Money
    coverage: Quantity
    missing: Money
    suggested_monthly: Money


class PortfolioOut(BaseModel):
    value: Money
    cost: Money
    pnl: Money
    pnl_pct: Quantity | None
    pending: Money
    stale: int
    classes: list[ClassOut]
    unclassified: list[PositionOut]
    emergency: EmergencyOut | None


class LotOut(BaseModel):
    acquired: dt.date
    units: Quantity
    cost: Money


class RealizedOut(BaseModel):
    date: dt.date
    units: Quantity
    proceeds: Money
    gain_fifo: Money
    gain_pmp: Money


class AssetDetailOut(BaseModel):
    position: PositionOut
    lots: list[LotOut]
    realized: list[RealizedOut]
    income: Money
    transactions: list["TxOut"]


# --- Transacciones ------------------------------------------------------------------------------
class TxIn(BaseModel):
    id: uuid.UUID | None = None
    asset_id: uuid.UUID
    kind: TxKind
    trade_date: dt.date
    amount_eur: Money = Decimal(0)
    units: Quantity | None = None
    price: Quantity | None = None
    avg_cost: Quantity | None = None
    fee: Money = Decimal(0)
    pending: bool = Field(default=False, description="Aportación pendiente de valor liquidativo")
    notes: str | None = None


class TxOut(BaseModel):
    id: uuid.UUID
    asset_id: uuid.UUID
    kind: TxKind
    status: TxStatus
    trade_date: dt.date
    settle_date: dt.date | None
    amount_eur: Money
    units: Quantity | None
    price: Quantity | None
    avg_cost: Quantity | None
    fee: Money
    pair_id: uuid.UUID | None
    movement_id: uuid.UUID | None
    notes: str | None


class TxSettleIn(BaseModel):
    units: Quantity | None = None
    price: Quantity | None = None
    fee: Money | None = None


class TransferIn(BaseModel):
    """Traspaso entre fondos: no tributa; los lotes pasan con su fecha y coste."""

    from_asset_id: uuid.UUID
    to_asset_id: uuid.UUID
    trade_date: dt.date
    units_out: Quantity
    units_in: Quantity
    amount_eur: Money = Field(description="Valor del traspaso (informativo)")


class CorrectionIn(BaseModel):
    units: Quantity
    avg_cost: Quantity
    reason: str = Field(min_length=3, max_length=500)
    effective_date: dt.date | None = None


class PriceIn(BaseModel):
    date: dt.date
    price: Quantity


class PriceOut(BaseModel):
    date: dt.date
    price: Quantity
    source: str


# --- Motor de aportaciones ----------------------------------------------------------------------
class SuggestIn(BaseModel):
    amount: Money
    round_to: Money | None = Field(
        default=None,
        gt=0,
        description="Redondea cada orden a múltiplos de este importe (1, 5, 10 €…); suma igual",
    )


class OrderOut(BaseModel):
    asset_id: uuid.UUID
    asset_name: str
    amount: Money
    price: Quantity | None
    approx_units: Quantity | None


class ClassAmountOut(BaseModel):
    asset_class_id: uuid.UUID
    amount: Money


class ContributionOut(BaseModel):
    amount: Money
    by_class: list[ClassAmountOut]
    orders: list[OrderOut]
    unassigned: Money


class OrderIn(BaseModel):
    asset_id: uuid.UUID
    amount: Money


class OrdersIn(BaseModel):
    orders: list[OrderIn] = Field(min_length=1)
    trade_date: dt.date
    from_account_id: uuid.UUID | None = Field(
        default=None,
        description="Cuenta de gastos de la que sale el dinero (anota la transferencia)",
    )


# --- Ajustes, alta e historial --------------------------------------------------------------------
class InvSettingsIn(BaseModel):
    min_operation: Money | None = None
    monthly_contribution: Money | None = None
    track_start: dt.date | None = None
    clear_track_start: bool = False  # volver a mirar desde la primera operación


class InvSettingsOut(BaseModel):
    configured: bool
    min_operation: Money
    monthly_contribution: Money | None
    track_start: dt.date | None


class SnapshotOut(BaseModel):
    date: dt.date
    value: Money
    cost: Money | None
    net_flow: Money
    manual: bool


class SnapshotIn(BaseModel):
    """Historial anterior a Faro (p. ej. meses del Excel)."""

    date: dt.date
    value: Money
    cost: Money | None = None


AssetDetailOut.model_rebuild()


class PriceRefreshOut(BaseModel):
    asset_id: uuid.UUID
    asset_name: str
    ok: bool
    price: Quantity | None
    date: dt.date | None
    source: str | None
    errors: list[str]


class PlanIn(BaseModel):
    id: uuid.UUID | None = None
    asset_id: uuid.UUID
    amount: Money
    every_months: int = Field(default=1, ge=1, le=12)
    day_of_month: int = Field(default=1, ge=1, le=31)
    start_date: dt.date
    end_date: dt.date | None = None
    active: bool = True
    from_account_id: uuid.UUID | None = Field(
        default=None, description="Cuenta de gastos de la que sale (crea un recurrente enlazado)"
    )
    notes: str | None = None


class PlanOut(BaseModel):
    id: uuid.UUID
    asset_id: uuid.UUID
    amount: Money
    every_months: int
    day_of_month: int
    start_date: dt.date
    end_date: dt.date | None
    active: bool
    from_account_id: uuid.UUID | None
    next_date: dt.date | None
    notes: str | None


# --- Importación de plataformas ------------------------------------------------------------------
class PlatformOpOut(BaseModel):
    row: int
    date: dt.date
    kind: TxKind
    key: str
    asset_name: str
    units: Quantity
    amount: Money
    outcome: Literal["new", "duplicate", "complete_pending"]
    note: str | None


class NewAssetOut(BaseModel):
    key: str
    name: str


class PlatformPositionOut(BaseModel):
    key: str
    name: str
    units_now: Quantity
    units_after: Quantity
    avg_cost_after: Quantity
    replaced_initial: bool


class PlatformPreviewOut(BaseModel):
    source: Literal["myinvestor", "neverless", "generic"]
    platform: str
    counts: dict[str, int]
    warnings: list[str]
    ops: list[PlatformOpOut]
    create_assets: list[NewAssetOut]
    positions: list[PlatformPositionOut]


class PlatformBatchOut(BaseModel):
    id: uuid.UUID
    filename: str
    status: str
    counts: dict[str, int]
