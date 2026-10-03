"""Módulo de inversiones (fase 3a): plataformas, activos, objetivos de asignación, transacciones,
correcciones, precios y snapshots. Ver docs/02-modelo-datos.md §2.

Las transacciones son la fuente de verdad: la posición (PMP y lotes FIFO) se calcula
repitiéndolas (`app.domain.portfolio.replay`). Participaciones, precios y FX en NUMERIC(24,10)."""

import datetime as dt
import uuid
from datetime import datetime
from decimal import Decimal
from typing import Any

from sqlalchemy import (
    Boolean,
    Date,
    DateTime,
    ForeignKey,
    Index,
    Integer,
    Numeric,
    String,
    Text,
    UniqueConstraint,
    false,
    true,
)
from sqlalchemy.dialects.postgresql import JSONB, UUID
from sqlalchemy.orm import Mapped, mapped_column

from app.models.base import Base, IdMixin, TimestampMixin
from app.models.gastos import Money, _check, _uid

Qty = Numeric(24, 10)
Pct = Numeric(7, 4)  # tanto por uno: 0.7000 = 70 %

PLATFORM_KINDS = ("broker", "exchange", "banco", "otro")
ASSET_TYPES = ("fondo", "etf", "accion", "cripto", "cuenta", "otro")
PRICE_PROVIDERS = ("ft", "coingecko", "manual")
TX_KINDS = (
    "posicion_inicial", "compra", "venta", "aportacion_periodica", "traspaso_salida",
    "traspaso_entrada", "dividendo", "interes", "comision", "recompensa",
)  # fmt: skip
TX_STATUS = ("pendiente_vl", "liquidada", "cancelada")
TARGET_LEVELS = ("macro", "asset")


class Platform(IdMixin, TimestampMixin, Base):
    __tablename__ = "platforms"
    __table_args__ = (
        _check("kind", PLATFORM_KINDS),
        UniqueConstraint("user_id", "name", name="uq_platforms_user_name"),
    )

    user_id: Mapped[uuid.UUID] = _uid()
    name: Mapped[str] = mapped_column(String(80), nullable=False)
    kind: Mapped[str] = mapped_column(String(10), nullable=False, default="broker")
    units_decimals: Mapped[int] = mapped_column(Integer, nullable=False, default=4)
    default_fee: Mapped[Decimal] = mapped_column(Money, nullable=False, default=Decimal(0))
    account_id: Mapped[uuid.UUID | None] = mapped_column(
        UUID(as_uuid=True), ForeignKey("accounts.id", ondelete="SET NULL")
    )
    notes: Mapped[str | None] = mapped_column(Text)


class AssetClass(IdMixin, TimestampMixin, Base):
    """Categoría macro (Fondos, Cripto, Acciones…)."""

    __tablename__ = "asset_classes"
    __table_args__ = (UniqueConstraint("user_id", "name", name="uq_asset_classes_user_name"),)

    user_id: Mapped[uuid.UUID] = _uid()
    name: Mapped[str] = mapped_column(String(60), nullable=False)
    default_tolerance_pp: Mapped[Decimal] = mapped_column(
        Numeric(6, 2), nullable=False, default=Decimal(1)
    )
    sort: Mapped[int] = mapped_column(Integer, nullable=False, default=0)


class Asset(IdMixin, TimestampMixin, Base):
    __tablename__ = "assets"
    __table_args__ = (
        _check("type", ASSET_TYPES),
        _check("price_provider", PRICE_PROVIDERS),
        Index("ix_assets_user_isin", "user_id", "isin"),
    )

    user_id: Mapped[uuid.UUID] = _uid()
    name: Mapped[str] = mapped_column(String(120), nullable=False)
    type: Mapped[str] = mapped_column(String(8), nullable=False)
    asset_class_id: Mapped[uuid.UUID | None] = mapped_column(
        UUID(as_uuid=True), ForeignKey("asset_classes.id", ondelete="SET NULL")
    )
    platform_id: Mapped[uuid.UUID | None] = mapped_column(
        UUID(as_uuid=True), ForeignKey("platforms.id", ondelete="SET NULL")
    )
    isin: Mapped[str | None] = mapped_column(String(12))
    ticker: Mapped[str | None] = mapped_column(String(20))
    coingecko_id: Mapped[str | None] = mapped_column(String(60))
    currency: Mapped[str] = mapped_column(String(3), nullable=False, default="EUR")
    price_provider: Mapped[str] = mapped_column(String(10), nullable=False, default="manual")
    price_ref: Mapped[str | None] = mapped_column(String(120))  # p. ej. "IE00B03HCZ61:EUR"
    units_decimals: Mapped[int | None] = mapped_column(Integer)  # None = el de la plataforma
    sector: Mapped[str | None] = mapped_column(String(60))
    country: Mapped[str | None] = mapped_column(String(60))
    watchlist: Mapped[bool] = mapped_column(
        Boolean, nullable=False, default=False, server_default=false()
    )
    archived: Mapped[bool] = mapped_column(
        Boolean, nullable=False, default=False, server_default=false()
    )
    notes: Mapped[str | None] = mapped_column(Text)


class AllocationTarget(IdMixin, TimestampMixin, Base):
    """Objetivo versionado por `valid_from`: macro (por categoría) o interno (por activo)."""

    __tablename__ = "allocation_targets"
    __table_args__ = (
        _check("level", TARGET_LEVELS),
        Index("ix_targets_user_level", "user_id", "level", "valid_from"),
    )

    user_id: Mapped[uuid.UUID] = _uid()
    level: Mapped[str] = mapped_column(String(6), nullable=False)
    asset_class_id: Mapped[uuid.UUID | None] = mapped_column(
        UUID(as_uuid=True), ForeignKey("asset_classes.id", ondelete="CASCADE")
    )
    asset_id: Mapped[uuid.UUID | None] = mapped_column(
        UUID(as_uuid=True), ForeignKey("assets.id", ondelete="CASCADE")
    )
    target_pct: Mapped[Decimal] = mapped_column(Pct, nullable=False)
    min_pct: Mapped[Decimal | None] = mapped_column(Pct)
    max_pct: Mapped[Decimal | None] = mapped_column(Pct)
    tolerance_pp: Mapped[Decimal | None] = mapped_column(Numeric(6, 2))
    valid_from: Mapped[dt.date] = mapped_column(Date, nullable=False)


class InvTransaction(IdMixin, TimestampMixin, Base):
    __tablename__ = "inv_transactions"
    __table_args__ = (
        _check("kind", TX_KINDS),
        _check("status", TX_STATUS),
        Index("ix_inv_tx_user_asset_date", "user_id", "asset_id", "trade_date"),
        UniqueConstraint("user_id", "dedupe_hash", name="uq_inv_tx_dedupe"),
    )

    user_id: Mapped[uuid.UUID] = _uid()
    asset_id: Mapped[uuid.UUID] = mapped_column(
        UUID(as_uuid=True), ForeignKey("assets.id", ondelete="CASCADE"), nullable=False
    )
    kind: Mapped[str] = mapped_column(String(20), nullable=False)
    status: Mapped[str] = mapped_column(String(12), nullable=False, default="liquidada")
    trade_date: Mapped[dt.date] = mapped_column(Date, nullable=False)
    settle_date: Mapped[dt.date | None] = mapped_column(Date)
    amount_eur: Mapped[Decimal] = mapped_column(Money, nullable=False, default=Decimal(0))
    units: Mapped[Decimal | None] = mapped_column(Qty)  # None mientras está pendiente de VL
    price: Mapped[Decimal | None] = mapped_column(Qty)
    avg_cost: Mapped[Decimal | None] = mapped_column(Qty)  # solo posicion_inicial
    fee: Mapped[Decimal] = mapped_column(Money, nullable=False, default=Decimal(0))
    fx_rate: Mapped[Decimal | None] = mapped_column(Qty)
    pair_id: Mapped[uuid.UUID | None] = mapped_column(
        UUID(as_uuid=True), ForeignKey("inv_transactions.id", ondelete="SET NULL")
    )
    movement_id: Mapped[uuid.UUID | None] = mapped_column(
        UUID(as_uuid=True), ForeignKey("movements.id", ondelete="SET NULL")
    )
    external_id: Mapped[str | None] = mapped_column(String(120))
    dedupe_hash: Mapped[str | None] = mapped_column(String(64))
    import_batch_id: Mapped[uuid.UUID | None] = mapped_column(
        UUID(as_uuid=True), ForeignKey("import_batches.id", ondelete="SET NULL")
    )
    notes: Mapped[str | None] = mapped_column(Text)


class PositionCorrection(IdMixin, TimestampMixin, Base):
    """Ajuste manual de participaciones y/o PMP (con motivo; también va al audit_log)."""

    __tablename__ = "position_corrections"

    user_id: Mapped[uuid.UUID] = _uid()
    asset_id: Mapped[uuid.UUID] = mapped_column(
        UUID(as_uuid=True), ForeignKey("assets.id", ondelete="CASCADE"), nullable=False
    )
    effective_date: Mapped[dt.date] = mapped_column(Date, nullable=False)
    units_before: Mapped[Decimal] = mapped_column(Qty, nullable=False)
    units_after: Mapped[Decimal] = mapped_column(Qty, nullable=False)
    avg_cost_before: Mapped[Decimal] = mapped_column(Qty, nullable=False)
    avg_cost_after: Mapped[Decimal] = mapped_column(Qty, nullable=False)
    reason: Mapped[str] = mapped_column(Text, nullable=False)


class PriceHistory(IdMixin, Base):
    __tablename__ = "price_history"
    __table_args__ = (UniqueConstraint("asset_id", "date", name="uq_price_asset_date"),)

    user_id: Mapped[uuid.UUID] = _uid()
    asset_id: Mapped[uuid.UUID] = mapped_column(
        UUID(as_uuid=True), ForeignKey("assets.id", ondelete="CASCADE"), nullable=False
    )
    date: Mapped[dt.date] = mapped_column(Date, nullable=False)
    price: Mapped[Decimal] = mapped_column(Qty, nullable=False)
    currency: Mapped[str] = mapped_column(String(3), nullable=False, default="EUR")
    source: Mapped[str] = mapped_column(String(20), nullable=False)
    fetched_at: Mapped[datetime] = mapped_column(DateTime(timezone=True), nullable=False)


class AssetSnapshot(IdMixin, Base):
    """Foto diaria por activo (la hace el worker; también manuales para el historial)."""

    __tablename__ = "asset_snapshots"
    __table_args__ = (UniqueConstraint("asset_id", "date", name="uq_snapshot_asset_date"),)

    user_id: Mapped[uuid.UUID] = _uid()
    asset_id: Mapped[uuid.UUID] = mapped_column(
        UUID(as_uuid=True), ForeignKey("assets.id", ondelete="CASCADE"), nullable=False
    )
    date: Mapped[dt.date] = mapped_column(Date, nullable=False)
    units: Mapped[Decimal] = mapped_column(Qty, nullable=False)
    price: Mapped[Decimal | None] = mapped_column(Qty)
    value_eur: Mapped[Decimal] = mapped_column(Money, nullable=False)
    cost_eur: Mapped[Decimal] = mapped_column(Money, nullable=False)
    net_flow_eur: Mapped[Decimal] = mapped_column(Money, nullable=False, default=Decimal(0))


class PortfolioSnapshot(IdMixin, Base):
    """Total de la cartera por día. `manual` = historial anterior a Faro (meses del Excel)."""

    __tablename__ = "portfolio_snapshots"
    __table_args__ = (UniqueConstraint("user_id", "date", name="uq_portfolio_snapshot_day"),)

    user_id: Mapped[uuid.UUID] = _uid()
    date: Mapped[dt.date] = mapped_column(Date, nullable=False)
    value_eur: Mapped[Decimal] = mapped_column(Money, nullable=False)
    cost_eur: Mapped[Decimal | None] = mapped_column(Money)
    net_flow_eur: Mapped[Decimal] = mapped_column(Money, nullable=False, default=Decimal(0))
    manual: Mapped[bool] = mapped_column(
        Boolean, nullable=False, default=False, server_default=false()
    )


class ContributionPlan(IdMixin, TimestampMixin, Base):
    """Aportación periódica (p. ej. el plan automático mensual de un broker). Cada fecha genera
    una compra pendiente de VL; si sale de una cuenta de gastos, lleva un recurrente enlazado
    para que la transferencia aparezca en los ciclos y en los meses vista."""

    __tablename__ = "contribution_plans"

    user_id: Mapped[uuid.UUID] = _uid()
    asset_id: Mapped[uuid.UUID] = mapped_column(
        UUID(as_uuid=True), ForeignKey("assets.id", ondelete="CASCADE"), nullable=False
    )
    amount: Mapped[Decimal] = mapped_column(Money, nullable=False)  # positivo
    every_months: Mapped[int] = mapped_column(Integer, nullable=False, default=1)
    day_of_month: Mapped[int] = mapped_column(Integer, nullable=False, default=1)
    start_date: Mapped[dt.date] = mapped_column(Date, nullable=False)
    end_date: Mapped[dt.date | None] = mapped_column(Date)
    active: Mapped[bool] = mapped_column(
        Boolean, nullable=False, default=True, server_default=true()
    )
    recurring_template_id: Mapped[uuid.UUID | None] = mapped_column(
        UUID(as_uuid=True), ForeignKey("recurring_templates.id", ondelete="SET NULL")
    )
    # Última fecha ya generada: al crear el plan es ayer (no se rellena el pasado, que ya está en
    # la posición)
    last_generated: Mapped[dt.date | None] = mapped_column(Date)
    notes: Mapped[str | None] = mapped_column(Text)


class AssetExposure(IdMixin, Base):
    """Composición de un activo por sector, región, país o divisa (look-through de fondos).
    `auto` = leída de FT; `manual` = editada (una manual nunca la pisa la automática)."""

    __tablename__ = "asset_exposures"
    __table_args__ = (
        _check("dimension", ("sector", "region", "pais", "divisa")),
        _check("source", ("auto", "manual")),
        UniqueConstraint("asset_id", "dimension", "key", name="uq_exposure_asset_dim_key"),
    )

    user_id: Mapped[uuid.UUID] = _uid()
    asset_id: Mapped[uuid.UUID] = mapped_column(
        UUID(as_uuid=True), ForeignKey("assets.id", ondelete="CASCADE"), nullable=False
    )
    dimension: Mapped[str] = mapped_column(String(8), nullable=False)
    key: Mapped[str] = mapped_column(String(60), nullable=False)
    weight: Mapped[Decimal] = mapped_column(Pct, nullable=False)
    source: Mapped[str] = mapped_column(String(6), nullable=False, default="auto")
    as_of: Mapped[dt.date | None] = mapped_column(Date)


class TaxParameter(IdMixin, TimestampMixin, Base):
    """Parámetros fiscales por año y región, siempre con su fuente oficial (nunca en el código).
    `user_id` NULL = global; un usuario puede sobreescribir uno para sí."""

    __tablename__ = "tax_parameters"
    __table_args__ = (UniqueConstraint("year", "region", "key", "user_id", name="uq_tax_param"),)

    year: Mapped[int] = mapped_column(Integer, nullable=False)
    region: Mapped[str] = mapped_column(String(8), nullable=False)  # ES | ES-CN …
    key: Mapped[str] = mapped_column(String(60), nullable=False)
    value: Mapped[Any] = mapped_column(JSONB, nullable=False)
    source_url: Mapped[str] = mapped_column(Text, nullable=False)
    reviewed_at: Mapped[dt.date] = mapped_column(Date, nullable=False)
    user_id: Mapped[uuid.UUID | None] = mapped_column(
        UUID(as_uuid=True), ForeignKey("users.id", ondelete="CASCADE")
    )
    notes: Mapped[str | None] = mapped_column(Text)


class Goal(IdMixin, TimestampMixin, Base):
    """Objetivo con progreso calculado (no se guarda: sale de los datos de cada momento)."""

    __tablename__ = "goals"
    __table_args__ = (
        _check(
            "kind",
            (
                "edad_fi",
                "fondo_emergencia",
                "patrimonio",
                "cartera_en_fecha",
                "fijos_max",
                "tasa_ahorro_min",
            ),
        ),
    )

    user_id: Mapped[uuid.UUID] = _uid()
    kind: Mapped[str] = mapped_column(String(20), nullable=False)
    name: Mapped[str] = mapped_column(String(120), nullable=False)
    target_value: Mapped[Decimal | None] = mapped_column(Numeric(14, 4))
    target_date: Mapped[dt.date | None] = mapped_column(Date)
    archived: Mapped[bool] = mapped_column(
        Boolean, nullable=False, default=False, server_default=false()
    )


class QuarterlyReview(IdMixin, TimestampMixin, Base):
    """Revisión trimestral: foto de las métricas al guardarla y las respuestas del usuario.
    La foto permite comparar el trimestre siguiente con lo que había entonces."""

    __tablename__ = "quarterly_reviews"
    __table_args__ = (UniqueConstraint("user_id", "quarter", name="uq_quarterly_reviews_quarter"),)

    user_id: Mapped[uuid.UUID] = _uid()
    quarter: Mapped[str] = mapped_column(String(7), nullable=False)  # "2026-Q3"
    metrics: Mapped[Any] = mapped_column(JSONB, nullable=False)
    changed: Mapped[str] = mapped_column(Text, nullable=False, default="")
    next_steps: Mapped[str] = mapped_column(Text, nullable=False, default="")
