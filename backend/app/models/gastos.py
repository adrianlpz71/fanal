"""Módulo de gastos (fase 2a): cuentas, ciclos, movimientos, categorías, recurrentes y
compras fraccionadas. Ver docs/02-modelo-datos.md §1.

Convenciones: importes NUMERIC(14,2) con signo (negativo = sale dinero); enums como texto con
CHECK (migraciones más simples que los ENUM de Postgres); todo lleva user_id."""

import datetime as dt
import uuid
from datetime import datetime
from decimal import Decimal

from sqlalchemy import (
    Boolean,
    CheckConstraint,
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
)
from sqlalchemy.dialects.postgresql import UUID
from sqlalchemy.orm import Mapped, mapped_column, relationship

from app.models.base import Base, IdMixin, TimestampMixin

Money = Numeric(14, 2)


def _uid() -> Mapped[uuid.UUID]:
    return mapped_column(
        UUID(as_uuid=True), ForeignKey("users.id", ondelete="CASCADE"), nullable=False, index=True
    )


def _check(col: str, values: tuple[str, ...]) -> CheckConstraint:
    allowed = ", ".join(f"'{v}'" for v in values)
    return CheckConstraint(f"{col} IN ({allowed})", name=f"{col}_valid")


ACCOUNT_KINDS = ("gastos", "refugio", "ahorro", "inversion", "efectivo", "otra")
MOVEMENT_KINDS = ("gasto", "ingreso", "nomina", "transferencia", "reembolso", "ajuste")
MOVEMENT_STATUS = ("planned", "posted", "cancelled")
MOVEMENT_SOURCES = ("manual", "recurring", "installment", "savings_plan", "excel", "bank_import")
CATEGORY_KINDS = ("gasto", "ingreso", "transferencia")
PROVIDERS = ("paypal", "klarna", "tarjeta", "amazon", "eci", "otro")


class Account(IdMixin, TimestampMixin, Base):
    __tablename__ = "accounts"
    __table_args__ = (_check("kind", ACCOUNT_KINDS),)

    user_id: Mapped[uuid.UUID] = _uid()
    kind: Mapped[str] = mapped_column(String(16), nullable=False)
    name: Mapped[str] = mapped_column(String(80), nullable=False)
    bank: Mapped[str] = mapped_column(String(80), nullable=False, default="")
    opening_balance: Mapped[Decimal] = mapped_column(Money, nullable=False, default=Decimal(0))
    opening_date: Mapped[dt.date] = mapped_column(Date, nullable=False)
    apy: Mapped[Decimal | None] = mapped_column(Numeric(7, 4))  # TAE en tanto por uno
    currency: Mapped[str] = mapped_column(String(3), nullable=False, default="EUR")
    archived: Mapped[bool] = mapped_column(Boolean, nullable=False, default=False)
    sort: Mapped[int] = mapped_column(Integer, nullable=False, default=0)


class Category(IdMixin, TimestampMixin, Base):
    __tablename__ = "categories"
    __table_args__ = (
        _check("kind", CATEGORY_KINDS),
        UniqueConstraint("user_id", "parent_id", "name"),
    )

    user_id: Mapped[uuid.UUID] = _uid()
    parent_id: Mapped[uuid.UUID | None] = mapped_column(
        UUID(as_uuid=True), ForeignKey("categories.id", ondelete="CASCADE")
    )
    name: Mapped[str] = mapped_column(String(80), nullable=False)
    kind: Mapped[str] = mapped_column(String(16), nullable=False, default="gasto")
    icon: Mapped[str] = mapped_column(String(40), nullable=False, default="category")
    color: Mapped[str] = mapped_column(String(9), nullable=False, default="#607D8B")
    fixed: Mapped[bool] = mapped_column(Boolean, nullable=False, default=False)
    archived: Mapped[bool] = mapped_column(Boolean, nullable=False, default=False)
    sort: Mapped[int] = mapped_column(Integer, nullable=False, default=0)


class PayCycle(IdMixin, TimestampMixin, Base):
    """Ciclo entre dos cobros. opening = carried_real + payroll_amount."""

    __tablename__ = "pay_cycles"
    __table_args__ = (
        _check("status", ("open", "closed")),
        UniqueConstraint("user_id", "account_id", "label"),
        # Como mucho un ciclo abierto por cuenta
        Index(
            "uq_pay_cycles_one_open",
            "user_id",
            "account_id",
            unique=True,
            postgresql_where="status = 'open'",
        ),
    )

    user_id: Mapped[uuid.UUID] = _uid()
    account_id: Mapped[uuid.UUID] = mapped_column(
        UUID(as_uuid=True), ForeignKey("accounts.id", ondelete="CASCADE"), nullable=False
    )
    label: Mapped[str] = mapped_column(String(40), nullable=False)
    start_date: Mapped[dt.date] = mapped_column(Date, nullable=False)
    end_date: Mapped[dt.date | None] = mapped_column(Date)
    payroll_amount: Mapped[Decimal] = mapped_column(Money, nullable=False, default=Decimal(0))
    carried_real: Mapped[Decimal] = mapped_column(Money, nullable=False, default=Decimal(0))
    carried_expected: Mapped[Decimal | None] = mapped_column(Money)
    discrepancy: Mapped[Decimal | None] = mapped_column(Money)
    status: Mapped[str] = mapped_column(String(8), nullable=False, default="open")
    payroll_movement_id: Mapped[uuid.UUID | None] = mapped_column(UUID(as_uuid=True))
    external_ref: Mapped[str | None] = mapped_column(String(200))


class Movement(IdMixin, TimestampMixin, Base):
    __tablename__ = "movements"
    __table_args__ = (
        _check("kind", MOVEMENT_KINDS),
        _check("status", MOVEMENT_STATUS),
        _check("source", MOVEMENT_SOURCES),
        UniqueConstraint("user_id", "external_ref", name="uq_movements_external_ref"),
        UniqueConstraint("user_id", "account_id", "bank_ref", name="uq_movements_bank_ref"),
        Index("ix_movements_user_cycle", "user_id", "cycle_id"),
        Index("ix_movements_user_concept", "user_id", "concept"),
    )

    user_id: Mapped[uuid.UUID] = _uid()
    account_id: Mapped[uuid.UUID] = mapped_column(
        UUID(as_uuid=True), ForeignKey("accounts.id", ondelete="CASCADE"), nullable=False
    )
    cycle_id: Mapped[uuid.UUID | None] = mapped_column(
        UUID(as_uuid=True), ForeignKey("pay_cycles.id", ondelete="SET NULL")
    )
    date: Mapped[dt.date | None] = mapped_column(Date)  # opcional (el Excel no tenía fechas)
    due_date: Mapped[dt.date | None] = mapped_column(Date)  # para previstos (cuotas, recurrentes)
    kind: Mapped[str] = mapped_column(String(16), nullable=False, default="gasto")
    status: Mapped[str] = mapped_column(String(10), nullable=False, default="posted")
    concept: Mapped[str] = mapped_column(String(160), nullable=False)
    amount: Mapped[Decimal] = mapped_column(Money, nullable=False)
    expression: Mapped[str | None] = mapped_column(Text)
    category_id: Mapped[uuid.UUID | None] = mapped_column(
        UUID(as_uuid=True), ForeignKey("categories.id", ondelete="SET NULL")
    )
    transfer_pair_id: Mapped[uuid.UUID | None] = mapped_column(UUID(as_uuid=True))
    refund_of_id: Mapped[uuid.UUID | None] = mapped_column(
        UUID(as_uuid=True), ForeignKey("movements.id", ondelete="SET NULL")
    )
    source: Mapped[str] = mapped_column(String(16), nullable=False, default="manual")
    source_ref: Mapped[uuid.UUID | None] = mapped_column(UUID(as_uuid=True))
    external_ref: Mapped[str | None] = mapped_column(String(200))
    notes: Mapped[str | None] = mapped_column(Text)
    sort: Mapped[int] = mapped_column(Integer, nullable=False, default=0)
    debt_id: Mapped[uuid.UUID | None] = mapped_column(
        UUID(as_uuid=True), ForeignKey("debts.id", ondelete="SET NULL"), index=True
    )
    # Importación de extractos: lote que lo creó o que lo emparejó (para poder deshacer)
    import_batch_id: Mapped[uuid.UUID | None] = mapped_column(UUID(as_uuid=True), index=True)
    bank_ref: Mapped[str | None] = mapped_column(String(80))  # huella de la línea del extracto
    matched_planned: Mapped[bool] = mapped_column(
        Boolean, nullable=False, default=False, server_default=false()
    )

    lines: Mapped[list["MovementLine"]] = relationship(
        back_populates="movement",
        cascade="all, delete-orphan",
        order_by="MovementLine.seq",
        lazy="selectin",
    )


class MovementLine(IdMixin, Base):
    """Submovimientos ("=-60+20+12"). Si existen, movement.amount = suma de las líneas."""

    __tablename__ = "movement_lines"

    movement_id: Mapped[uuid.UUID] = mapped_column(
        UUID(as_uuid=True), ForeignKey("movements.id", ondelete="CASCADE"), nullable=False,
        index=True,
    )  # fmt: skip
    seq: Mapped[int] = mapped_column(Integer, nullable=False)
    amount: Mapped[Decimal] = mapped_column(Money, nullable=False)
    note: Mapped[str | None] = mapped_column(String(160))

    movement: Mapped[Movement] = relationship(back_populates="lines")


class RecurringTemplate(IdMixin, TimestampMixin, Base):
    __tablename__ = "recurring_templates"
    __table_args__ = (
        _check("review", ("ok", "revisar", "cancelar")),
        _check("kind", MOVEMENT_KINDS),
    )

    user_id: Mapped[uuid.UUID] = _uid()
    account_id: Mapped[uuid.UUID] = mapped_column(
        UUID(as_uuid=True), ForeignKey("accounts.id", ondelete="CASCADE"), nullable=False
    )
    concept: Mapped[str] = mapped_column(String(160), nullable=False)
    amount: Mapped[Decimal] = mapped_column(Money, nullable=False)  # con signo
    amount_is_estimate: Mapped[bool] = mapped_column(Boolean, nullable=False, default=False)
    kind: Mapped[str] = mapped_column(String(16), nullable=False, default="gasto")
    category_id: Mapped[uuid.UUID | None] = mapped_column(
        UUID(as_uuid=True), ForeignKey("categories.id", ondelete="SET NULL")
    )
    every_months: Mapped[int] = mapped_column(Integer, nullable=False, default=1)
    day_of_month: Mapped[int] = mapped_column(Integer, nullable=False, default=1)
    start_date: Mapped[dt.date] = mapped_column(Date, nullable=False)
    end_date: Mapped[dt.date | None] = mapped_column(Date)
    active: Mapped[bool] = mapped_column(Boolean, nullable=False, default=True)
    review: Mapped[str] = mapped_column(String(10), nullable=False, default="ok")
    est_saving_year: Mapped[Decimal | None] = mapped_column(Money)
    notes: Mapped[str | None] = mapped_column(Text)


class RecurringPriceChange(IdMixin, Base):
    __tablename__ = "recurring_price_changes"

    template_id: Mapped[uuid.UUID] = mapped_column(
        UUID(as_uuid=True), ForeignKey("recurring_templates.id", ondelete="CASCADE"),
        nullable=False, index=True,
    )  # fmt: skip
    detected_at: Mapped[datetime] = mapped_column(DateTime(timezone=True), nullable=False)
    old_amount: Mapped[Decimal] = mapped_column(Money, nullable=False)
    new_amount: Mapped[Decimal] = mapped_column(Money, nullable=False)
    acknowledged: Mapped[bool] = mapped_column(Boolean, nullable=False, default=False)


class InstallmentPlan(IdMixin, TimestampMixin, Base):
    __tablename__ = "installment_plans"
    __table_args__ = (
        _check("provider", PROVIDERS),
        _check("status", ("activa", "liquidada", "cancelada")),
        UniqueConstraint("user_id", "external_ref"),
    )

    user_id: Mapped[uuid.UUID] = _uid()
    account_id: Mapped[uuid.UUID] = mapped_column(
        UUID(as_uuid=True), ForeignKey("accounts.id", ondelete="CASCADE"), nullable=False
    )
    description: Mapped[str] = mapped_column(String(160), nullable=False)
    merchant: Mapped[str] = mapped_column(String(80), nullable=False, default="")
    provider: Mapped[str] = mapped_column(String(12), nullable=False, default="otro")
    total: Mapped[Decimal] = mapped_column(Money, nullable=False)  # positivo
    n: Mapped[int] = mapped_column(Integer, nullable=False)
    every_months: Mapped[int] = mapped_column(Integer, nullable=False, default=1)
    first_due: Mapped[dt.date] = mapped_column(Date, nullable=False)
    fee: Mapped[Decimal] = mapped_column(Money, nullable=False, default=Decimal(0))
    status: Mapped[str] = mapped_column(String(10), nullable=False, default="activa")
    category_id: Mapped[uuid.UUID | None] = mapped_column(
        UUID(as_uuid=True), ForeignKey("categories.id", ondelete="SET NULL")
    )
    notes: Mapped[str | None] = mapped_column(Text)
    external_ref: Mapped[str | None] = mapped_column(String(200))

    installments: Mapped[list["Installment"]] = relationship(
        back_populates="plan", cascade="all, delete-orphan", order_by="Installment.seq",
        lazy="selectin",
    )  # fmt: skip


class Installment(IdMixin, Base):
    __tablename__ = "installments"
    __table_args__ = (
        _check("status", ("pendiente", "pagada", "adelantada", "cancelada")),
        UniqueConstraint("plan_id", "seq"),
    )

    plan_id: Mapped[uuid.UUID] = mapped_column(
        UUID(as_uuid=True), ForeignKey("installment_plans.id", ondelete="CASCADE"),
        nullable=False,
    )  # fmt: skip
    seq: Mapped[int] = mapped_column(Integer, nullable=False)
    due_date: Mapped[dt.date] = mapped_column(Date, nullable=False)
    amount: Mapped[Decimal] = mapped_column(Money, nullable=False)  # positivo
    status: Mapped[str] = mapped_column(String(10), nullable=False, default="pendiente")
    movement_id: Mapped[uuid.UUID | None] = mapped_column(
        UUID(as_uuid=True), ForeignKey("movements.id", ondelete="SET NULL")
    )

    plan: Mapped[InstallmentPlan] = relationship(back_populates="installments")
