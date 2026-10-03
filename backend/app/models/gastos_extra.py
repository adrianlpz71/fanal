"""Fase 2b: personas y gastos compartidos, deudas, seguimientos, reglas de categorización,
presupuestos e importaciones (extractos bancarios)."""

import datetime as dt
import uuid
from decimal import Decimal
from typing import Any

from sqlalchemy import (
    Boolean,
    CheckConstraint,
    Date,
    DateTime,
    ForeignKey,
    Integer,
    Numeric,
    String,
    Text,
    UniqueConstraint,
    func,
)
from sqlalchemy.dialects.postgresql import ARRAY, JSONB, UUID
from sqlalchemy.orm import Mapped, mapped_column

from app.models.base import Base, IdMixin, TimestampMixin
from app.models.gastos import Money, _check, _uid


class Person(IdMixin, TimestampMixin, Base):
    __tablename__ = "people"
    __table_args__ = (UniqueConstraint("user_id", "name"),)

    user_id: Mapped[uuid.UUID] = _uid()
    name: Mapped[str] = mapped_column(String(80), nullable=False)
    notes: Mapped[str | None] = mapped_column(Text)
    archived: Mapped[bool] = mapped_column(Boolean, nullable=False, default=False)


class MovementShare(IdMixin, TimestampMixin, Base):
    """Parte de un movimiento que corresponde a otra persona.
    me_deben: pagué yo y me deben `amount` · debo: pagó otro y le debo `amount`."""

    __tablename__ = "movement_shares"
    __table_args__ = (
        _check("direction", ("me_deben", "debo")),
        _check("status", ("pendiente", "saldada")),
        CheckConstraint("amount > 0", name="amount_positive"),
    )

    user_id: Mapped[uuid.UUID] = _uid()
    movement_id: Mapped[uuid.UUID] = mapped_column(
        UUID(as_uuid=True), ForeignKey("movements.id", ondelete="CASCADE"), nullable=False,
        index=True,
    )  # fmt: skip
    person_id: Mapped[uuid.UUID] = mapped_column(
        UUID(as_uuid=True), ForeignKey("people.id", ondelete="CASCADE"), nullable=False, index=True
    )
    amount: Mapped[Decimal] = mapped_column(Money, nullable=False)
    direction: Mapped[str] = mapped_column(String(10), nullable=False, default="me_deben")
    status: Mapped[str] = mapped_column(String(10), nullable=False, default="pendiente")
    settled_by_movement_id: Mapped[uuid.UUID | None] = mapped_column(
        UUID(as_uuid=True), ForeignKey("movements.id", ondelete="SET NULL")
    )
    settled_at: Mapped[dt.datetime | None] = mapped_column(DateTime(timezone=True))


class Debt(IdMixin, TimestampMixin, Base):
    """Préstamo real (no gastos compartidos). Saldo pendiente:
    debo     → opening + Σ importes vinculados (pagar = salida negativa → baja la deuda)
    me_deben → opening − Σ importes vinculados (me pagan = entrada positiva → baja)"""

    __tablename__ = "debts"
    __table_args__ = (
        _check("direction", ("debo", "me_deben")),
        _check("status", ("viva", "saldada")),
    )

    user_id: Mapped[uuid.UUID] = _uid()
    name: Mapped[str] = mapped_column(String(120), nullable=False)
    person_id: Mapped[uuid.UUID | None] = mapped_column(
        UUID(as_uuid=True), ForeignKey("people.id", ondelete="SET NULL")
    )
    direction: Mapped[str] = mapped_column(String(10), nullable=False, default="debo")
    opening_balance: Mapped[Decimal] = mapped_column(Money, nullable=False)
    opening_date: Mapped[dt.date] = mapped_column(Date, nullable=False)
    interest_rate: Mapped[Decimal | None] = mapped_column(Numeric(7, 4))
    status: Mapped[str] = mapped_column(String(8), nullable=False, default="viva")
    notes: Mapped[str | None] = mapped_column(Text)


class Tracker(IdMixin, TimestampMixin, Base):
    """Seguimiento: saldo con nombre que se alimenta solo de los movimientos de ciertas
    categorías o conceptos (p. ej. un bote común). No resta del patrimonio."""

    __tablename__ = "trackers"
    __table_args__ = (UniqueConstraint("user_id", "name"),)

    user_id: Mapped[uuid.UUID] = _uid()
    name: Mapped[str] = mapped_column(String(80), nullable=False)
    opening_balance: Mapped[Decimal] = mapped_column(Money, nullable=False, default=Decimal(0))
    opening_date: Mapped[dt.date] = mapped_column(Date, nullable=False)
    category_ids: Mapped[list[uuid.UUID]] = mapped_column(
        ARRAY(UUID(as_uuid=True)), nullable=False, default=list
    )
    keywords: Mapped[list[str]] = mapped_column(ARRAY(String(80)), nullable=False, default=list)
    archived: Mapped[bool] = mapped_column(Boolean, nullable=False, default=False)
    notes: Mapped[str | None] = mapped_column(Text)


class CategoryRule(IdMixin, TimestampMixin, Base):
    """Regla de autocategorización por concepto normalizado. Se aprende de las correcciones."""

    __tablename__ = "category_rules"
    __table_args__ = (
        UniqueConstraint("user_id", "pattern"),
        _check("source", ("learned", "manual")),
    )

    user_id: Mapped[uuid.UUID] = _uid()
    pattern: Mapped[str] = mapped_column(String(160), nullable=False)  # concepto normalizado
    category_id: Mapped[uuid.UUID] = mapped_column(
        UUID(as_uuid=True), ForeignKey("categories.id", ondelete="CASCADE"), nullable=False
    )
    source: Mapped[str] = mapped_column(String(8), nullable=False, default="learned")
    hits: Mapped[int] = mapped_column(Integer, nullable=False, default=1)


class Budget(IdMixin, TimestampMixin, Base):
    """Presupuesto por categoría (por ciclo)."""

    __tablename__ = "budgets"
    __table_args__ = (UniqueConstraint("user_id", "category_id"),)

    user_id: Mapped[uuid.UUID] = _uid()
    category_id: Mapped[uuid.UUID] = mapped_column(
        UUID(as_uuid=True), ForeignKey("categories.id", ondelete="CASCADE"), nullable=False
    )
    amount: Mapped[Decimal] = mapped_column(Money, nullable=False)  # positivo, por ciclo
    active: Mapped[bool] = mapped_column(Boolean, nullable=False, default=True)


class ImportProfile(IdMixin, TimestampMixin, Base):
    """Mapeo de columnas guardado por banco/plataforma (se reutiliza en cada importación)."""

    __tablename__ = "import_profiles"
    __table_args__ = (UniqueConstraint("user_id", "name"),)

    user_id: Mapped[uuid.UUID] = _uid()
    name: Mapped[str] = mapped_column(String(80), nullable=False)
    kind: Mapped[str] = mapped_column(String(16), nullable=False, default="bank")
    config: Mapped[dict[str, Any]] = mapped_column(JSONB, nullable=False, default=dict)


class ImportBatch(IdMixin, Base):
    __tablename__ = "import_batches"
    __table_args__ = (_check("status", ("committed", "undone")),)

    user_id: Mapped[uuid.UUID] = _uid()
    kind: Mapped[str] = mapped_column(String(16), nullable=False, default="bank")
    account_id: Mapped[uuid.UUID | None] = mapped_column(
        UUID(as_uuid=True), ForeignKey("accounts.id", ondelete="CASCADE")
    )
    filename: Mapped[str] = mapped_column(String(255), nullable=False)
    file_sha256: Mapped[str] = mapped_column(String(64), nullable=False)
    status: Mapped[str] = mapped_column(String(10), nullable=False, default="committed")
    summary: Mapped[dict[str, Any]] = mapped_column(JSONB, nullable=False, default=dict)
    created_at: Mapped[dt.datetime] = mapped_column(
        DateTime(timezone=True), server_default=func.now(), nullable=False
    )
