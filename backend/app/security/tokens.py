import hashlib
import secrets
import uuid
from dataclasses import dataclass
from datetime import UTC, datetime, timedelta

import jwt
from sqlalchemy import select, update
from sqlalchemy.orm import Session

from app.config import get_settings
from app.ids import uuid7
from app.models import RefreshToken

ALGORITHM = "HS256"


class TokenError(Exception):
    pass


def _now() -> datetime:
    return datetime.now(UTC)


def _encode(sub: uuid.UUID, typ: str, minutes: int) -> str:
    s = get_settings()
    now = _now()
    payload = {
        "sub": str(sub),
        "typ": typ,
        "iat": int(now.timestamp()),
        "exp": int((now + timedelta(minutes=minutes)).timestamp()),
        "jti": secrets.token_hex(8),
    }
    return jwt.encode(payload, s.jwt_secret, algorithm=ALGORITHM)


def _decode(token: str, typ: str) -> uuid.UUID:
    try:
        payload = jwt.decode(
            token, get_settings().jwt_secret, algorithms=[ALGORITHM], options={"require": ["exp"]}
        )
    except jwt.PyJWTError as e:
        raise TokenError("token inválido") from e
    if payload.get("typ") != typ:
        raise TokenError("tipo de token incorrecto")
    return uuid.UUID(payload["sub"])


def create_access_token(user_id: uuid.UUID) -> str:
    return _encode(user_id, "access", get_settings().access_token_minutes)


def decode_access_token(token: str) -> uuid.UUID:
    return _decode(token, "access")


def create_mfa_token(user_id: uuid.UUID) -> str:
    """Token de un solo paso entre contraseña correcta y código TOTP. Vida corta."""
    return _encode(user_id, "mfa", get_settings().mfa_token_minutes)


def decode_mfa_token(token: str) -> uuid.UUID:
    return _decode(token, "mfa")


def _hash(raw: str) -> str:
    return hashlib.sha256(raw.encode()).hexdigest()


@dataclass
class IssuedRefresh:
    raw: str
    expires_at: datetime


def issue_refresh_token(
    db: Session, user_id: uuid.UUID, client: str, family_id: uuid.UUID | None = None
) -> IssuedRefresh:
    raw = secrets.token_urlsafe(32)
    expires = _now() + timedelta(days=get_settings().refresh_token_days)
    db.add(
        RefreshToken(
            user_id=user_id,
            family_id=family_id or uuid7(),
            token_hash=_hash(raw),
            client=client,
            expires_at=expires,
        )
    )
    db.flush()
    return IssuedRefresh(raw=raw, expires_at=expires)


def rotate_refresh_token(db: Session, raw: str) -> tuple[uuid.UUID, IssuedRefresh]:
    """Valida y rota. Si el token ya se había usado (o estaba revocado) se asume robo:
    se revoca toda la familia y se rechaza."""
    row = db.scalar(
        select(RefreshToken).where(RefreshToken.token_hash == _hash(raw)).with_for_update()
    )
    if row is None:
        raise TokenError("refresh desconocido")
    now = _now()
    if row.used_at is not None or row.revoked_at is not None:
        revoke_family(db, row.family_id)
        raise TokenError("refresh reutilizado: familia revocada")
    if row.expires_at <= now:
        raise TokenError("refresh caducado")
    row.used_at = now
    issued = issue_refresh_token(db, row.user_id, row.client, family_id=row.family_id)
    return row.user_id, issued


def revoke_family(db: Session, family_id: uuid.UUID) -> None:
    db.execute(
        update(RefreshToken)
        .where(RefreshToken.family_id == family_id, RefreshToken.revoked_at.is_(None))
        .values(revoked_at=_now())
    )


def revoke_by_raw(db: Session, raw: str) -> None:
    row = db.scalar(select(RefreshToken).where(RefreshToken.token_hash == _hash(raw)))
    if row is not None:
        revoke_family(db, row.family_id)
