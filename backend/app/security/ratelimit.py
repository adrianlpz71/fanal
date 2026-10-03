"""Rate limiting de autenticación en la BD (sin Redis). Cuenta fallos en una ventana deslizante
por email y por IP. Suficiente para una sola instancia de API."""

from datetime import UTC, datetime, timedelta

from sqlalchemy import func, select
from sqlalchemy.orm import Session

from app.config import get_settings
from app.models import LoginAttempt


def _since() -> datetime:
    return datetime.now(UTC) - timedelta(minutes=get_settings().login_window_minutes)


def is_blocked(db: Session, email: str, ip: str | None) -> bool:
    s = get_settings()
    since = _since()
    by_email = db.scalar(
        select(func.count())
        .select_from(LoginAttempt)
        .where(
            LoginAttempt.email == email, LoginAttempt.success.is_(False), LoginAttempt.at >= since
        )
    )
    if (by_email or 0) >= s.login_max_failures_per_email:
        return True
    if ip:
        by_ip = db.scalar(
            select(func.count())
            .select_from(LoginAttempt)
            .where(LoginAttempt.ip == ip, LoginAttempt.success.is_(False), LoginAttempt.at >= since)
        )
        if (by_ip or 0) >= s.login_max_failures_per_ip:
            return True
    return False


def record(db: Session, email: str, ip: str | None, stage: str, success: bool) -> None:
    db.add(LoginAttempt(email=email, ip=ip, stage=stage, success=success))
    db.flush()
