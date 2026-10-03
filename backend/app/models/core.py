"""Tablas de núcleo (fase 1): usuarios, autenticación, ajustes, auditoría y ejecuciones del worker.
Las tablas de cada módulo se añaden en su fase (ver docs/02-modelo-datos.md)."""

import uuid
from datetime import date, datetime
from typing import Any

from sqlalchemy import (
    Boolean,
    Date,
    DateTime,
    ForeignKey,
    Index,
    String,
    Text,
    UniqueConstraint,
    func,
)
from sqlalchemy.dialects.postgresql import INET, JSONB, UUID
from sqlalchemy.orm import Mapped, mapped_column

from app.models.base import Base, IdMixin, TimestampMixin


class User(IdMixin, TimestampMixin, Base):
    __tablename__ = "users"

    email: Mapped[str] = mapped_column(String(320), unique=True, nullable=False)
    password_hash: Mapped[str] = mapped_column(Text, nullable=False)
    display_name: Mapped[str] = mapped_column(String(120), nullable=False, default="")
    is_active: Mapped[bool] = mapped_column(Boolean, nullable=False, default=True)

    totp_secret_enc: Mapped[str | None] = mapped_column(Text)
    totp_enabled: Mapped[bool] = mapped_column(Boolean, nullable=False, default=False)

    # Perfil (se rellena en el onboarding)
    birth_date: Mapped[date | None] = mapped_column(Date)
    locale: Mapped[str] = mapped_column(String(10), nullable=False, default="es-ES")
    currency: Mapped[str] = mapped_column(String(3), nullable=False, default="EUR")
    timezone: Mapped[str] = mapped_column(String(64), nullable=False, default="Atlantic/Canary")
    tax_region: Mapped[str] = mapped_column(String(10), nullable=False, default="ES-CN")
    onboarding_completed_at: Mapped[datetime | None] = mapped_column(DateTime(timezone=True))


class RefreshToken(IdMixin, Base):
    """Refresh tokens rotatorios. Solo se guarda el hash.
    Reutilizar uno ya usado revoca toda su familia."""

    __tablename__ = "refresh_tokens"

    user_id: Mapped[uuid.UUID] = mapped_column(
        UUID(as_uuid=True), ForeignKey("users.id", ondelete="CASCADE"), nullable=False, index=True
    )
    family_id: Mapped[uuid.UUID] = mapped_column(UUID(as_uuid=True), nullable=False, index=True)
    token_hash: Mapped[str] = mapped_column(String(64), nullable=False, unique=True)
    client: Mapped[str] = mapped_column(String(16), nullable=False, default="android")
    created_at: Mapped[datetime] = mapped_column(
        DateTime(timezone=True), server_default=func.now(), nullable=False
    )
    expires_at: Mapped[datetime] = mapped_column(DateTime(timezone=True), nullable=False)
    used_at: Mapped[datetime | None] = mapped_column(DateTime(timezone=True))
    revoked_at: Mapped[datetime | None] = mapped_column(DateTime(timezone=True))


class RecoveryCode(IdMixin, Base):
    __tablename__ = "recovery_codes"

    user_id: Mapped[uuid.UUID] = mapped_column(
        UUID(as_uuid=True), ForeignKey("users.id", ondelete="CASCADE"), nullable=False, index=True
    )
    code_hash: Mapped[str] = mapped_column(Text, nullable=False)
    used_at: Mapped[datetime | None] = mapped_column(DateTime(timezone=True))


class LoginAttempt(IdMixin, Base):
    __tablename__ = "login_attempts"
    __table_args__ = (
        Index("ix_login_attempts_email_at", "email", "at"),
        Index("ix_login_attempts_ip_at", "ip", "at"),
    )

    email: Mapped[str] = mapped_column(String(320), nullable=False)
    ip: Mapped[str | None] = mapped_column(INET)
    stage: Mapped[str] = mapped_column(String(16), nullable=False)  # password | totp
    success: Mapped[bool] = mapped_column(Boolean, nullable=False)
    at: Mapped[datetime] = mapped_column(
        DateTime(timezone=True), server_default=func.now(), nullable=False
    )


class UserSetting(IdMixin, Base):
    __tablename__ = "user_settings"
    __table_args__ = (UniqueConstraint("user_id", "key"),)

    user_id: Mapped[uuid.UUID] = mapped_column(
        UUID(as_uuid=True), ForeignKey("users.id", ondelete="CASCADE"), nullable=False
    )
    key: Mapped[str] = mapped_column(String(120), nullable=False)
    value: Mapped[Any] = mapped_column(JSONB, nullable=False)


class AuditLog(IdMixin, Base):
    """Correcciones manuales y eventos de seguridad. Nunca guarda contraseñas ni tokens."""

    __tablename__ = "audit_log"

    user_id: Mapped[uuid.UUID | None] = mapped_column(
        UUID(as_uuid=True), ForeignKey("users.id", ondelete="SET NULL"), index=True
    )
    entity: Mapped[str] = mapped_column(String(64), nullable=False)
    entity_id: Mapped[str | None] = mapped_column(String(64))
    action: Mapped[str] = mapped_column(String(64), nullable=False)
    before: Mapped[Any | None] = mapped_column(JSONB)
    after: Mapped[Any | None] = mapped_column(JSONB)
    reason: Mapped[str | None] = mapped_column(Text)
    at: Mapped[datetime] = mapped_column(
        DateTime(timezone=True), server_default=func.now(), nullable=False
    )


class JobRun(IdMixin, Base):
    """Ejecuciones del worker: base para alertas de 'tarea sin ejecutarse' y salud."""

    __tablename__ = "job_runs"
    __table_args__ = (Index("ix_job_runs_job_started", "job", "started_at"),)

    job: Mapped[str] = mapped_column(String(64), nullable=False)
    started_at: Mapped[datetime] = mapped_column(DateTime(timezone=True), nullable=False)
    finished_at: Mapped[datetime | None] = mapped_column(DateTime(timezone=True))
    ok: Mapped[bool | None] = mapped_column(Boolean)
    detail: Mapped[str | None] = mapped_column(Text)
