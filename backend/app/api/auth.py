"""Autenticación: contraseña → (alta de 2FA la primera vez | código TOTP) → access + refresh.

Flujo:
  POST /auth/login           → {status: verify | setup, mfa_token}
  POST /auth/2fa/setup       → {secret, otpauth_uri}            (solo si aún no hay 2FA)
  POST /auth/2fa/enable      → tokens + códigos de recuperación (activa la 2FA)
  POST /auth/2fa/verify      → tokens                           (código TOTP o de recuperación)
  POST /auth/refresh         → tokens rotados
  POST /auth/logout          → revoca la familia del refresh

Los fallos de contraseña y TOTP se registran y se hace COMMIT antes de responder con error
(si no, el rollback de la sesión borraría el registro y el rate limit no funcionaría).
"""

from datetime import UTC, datetime

from fastapi import APIRouter, HTTPException, Request, Response, status
from sqlalchemy import select

from app.api.deps import DB, Client, client_ip
from app.config import get_settings
from app.models import AuditLog, RecoveryCode, User
from app.schemas.auth import (
    LoginIn,
    LoginOut,
    MfaCodeIn,
    MfaEnabledOut,
    MfaSetupOut,
    MfaTokenIn,
    RefreshIn,
    TokenOut,
)
from app.security import ratelimit, totp
from app.security.passwords import hash_password, needs_rehash, verify_password
from app.security.tokens import (
    TokenError,
    create_access_token,
    create_mfa_token,
    decode_mfa_token,
    issue_refresh_token,
    revoke_by_raw,
    rotate_refresh_token,
)

router = APIRouter(prefix="/auth", tags=["auth"])

INVALID = "Credenciales incorrectas"
TOO_MANY = "Demasiados intentos. Espera unos minutos."


def _fail(db: DB, code: int, detail: str) -> HTTPException:
    db.commit()
    return HTTPException(code, detail)


def _user_from_mfa(db: DB, mfa_token: str) -> User:
    try:
        user_id = decode_mfa_token(mfa_token)
    except TokenError:
        raise HTTPException(
            status.HTTP_401_UNAUTHORIZED, "Sesión de verificación caducada"
        ) from None
    user = db.get(User, user_id)
    if user is None or not user.is_active:
        raise HTTPException(status.HTTP_401_UNAUTHORIZED, INVALID)
    return user


def _tokens(db: DB, response: Response, user: User, client: str) -> TokenOut:
    s = get_settings()
    refresh = issue_refresh_token(db, user.id, client)
    out = TokenOut(
        access_token=create_access_token(user.id), expires_in=s.access_token_minutes * 60
    )
    if client == "web":
        _set_cookie(response, refresh.raw, refresh.expires_at)
    else:
        out.refresh_token = refresh.raw
    return out


def _set_cookie(response: Response, raw: str, expires_at: datetime) -> None:
    s = get_settings()
    response.set_cookie(
        s.cookie_name,
        raw,
        expires=expires_at,
        httponly=True,
        secure=s.cookie_secure,
        samesite="strict",
        path="/api/auth",
    )


@router.post("/login", response_model=LoginOut)
def login(body: LoginIn, request: Request, response: Response, db: DB, client: Client) -> LoginOut:
    email = body.email.lower()
    ip = client_ip(request)
    if ratelimit.is_blocked(db, email, ip):
        raise HTTPException(status.HTTP_429_TOO_MANY_REQUESTS, TOO_MANY)
    user = db.scalar(select(User).where(User.email == email))
    ok = verify_password(user.password_hash if user else None, body.password)
    if not ok or user is None or not user.is_active:
        ratelimit.record(db, email, ip, "password", False)
        raise _fail(db, status.HTTP_401_UNAUTHORIZED, INVALID)
    ratelimit.record(db, email, ip, "password", True)
    if needs_rehash(user.password_hash):
        user.password_hash = hash_password(body.password)
    if get_settings().mfa_disabled:  # solo dev (check_production lo impide en prod)
        t = _tokens(db, response, user, client)
        return LoginOut(
            status="done",
            access_token=t.access_token,
            expires_in=t.expires_in,
            refresh_token=t.refresh_token,
        )
    return LoginOut(
        status="verify" if user.totp_enabled else "setup",
        mfa_token=create_mfa_token(user.id),
    )


@router.post("/2fa/setup", response_model=MfaSetupOut)
def mfa_setup(body: MfaTokenIn, db: DB) -> MfaSetupOut:
    user = _user_from_mfa(db, body.mfa_token)
    if user.totp_enabled:
        raise HTTPException(status.HTTP_409_CONFLICT, "La 2FA ya está activada")
    secret = totp.new_secret()
    user.totp_secret_enc = totp.encrypt_secret(secret)
    return MfaSetupOut(secret=secret, otpauth_uri=totp.provisioning_uri(secret, user.email))


@router.post("/2fa/enable", response_model=MfaEnabledOut)
def mfa_enable(body: MfaCodeIn, request: Request, response: Response, db: DB, client: Client):
    user = _user_from_mfa(db, body.mfa_token)
    ip = client_ip(request)
    if user.totp_enabled or not user.totp_secret_enc:
        raise HTTPException(status.HTTP_409_CONFLICT, "Primero inicia el alta de la 2FA")
    if ratelimit.is_blocked(db, user.email, ip):
        raise HTTPException(status.HTTP_429_TOO_MANY_REQUESTS, TOO_MANY)
    if not totp.verify_code(totp.decrypt_secret(user.totp_secret_enc), body.code):
        ratelimit.record(db, user.email, ip, "totp", False)
        raise _fail(db, status.HTTP_401_UNAUTHORIZED, "Código incorrecto")
    ratelimit.record(db, user.email, ip, "totp", True)
    user.totp_enabled = True
    codes = totp.new_recovery_codes()
    for c in codes:
        db.add(RecoveryCode(user_id=user.id, code_hash=totp.hash_recovery_code(c)))
    db.add(AuditLog(user_id=user.id, entity="auth", action="2fa.enabled"))
    tokens = _tokens(db, response, user, client)
    return MfaEnabledOut(**tokens.model_dump(), recovery_codes=codes)


@router.post("/2fa/verify", response_model=TokenOut)
def mfa_verify(body: MfaCodeIn, request: Request, response: Response, db: DB, client: Client):
    user = _user_from_mfa(db, body.mfa_token)
    ip = client_ip(request)
    if not user.totp_enabled or not user.totp_secret_enc:
        raise HTTPException(status.HTTP_409_CONFLICT, "La 2FA no está activada")
    if ratelimit.is_blocked(db, user.email, ip):
        raise HTTPException(status.HTTP_429_TOO_MANY_REQUESTS, TOO_MANY)

    ok = False
    if totp.looks_like_recovery_code(body.code):
        for rc in db.scalars(
            select(RecoveryCode).where(
                RecoveryCode.user_id == user.id, RecoveryCode.used_at.is_(None)
            )
        ):
            if totp.verify_recovery_code(rc.code_hash, body.code):
                rc.used_at = datetime.now(UTC)
                db.add(AuditLog(user_id=user.id, entity="auth", action="recovery_code.used"))
                ok = True
                break
    else:
        ok = totp.verify_code(totp.decrypt_secret(user.totp_secret_enc), body.code)

    if not ok:
        ratelimit.record(db, user.email, ip, "totp", False)
        raise _fail(db, status.HTTP_401_UNAUTHORIZED, "Código incorrecto")
    ratelimit.record(db, user.email, ip, "totp", True)
    return _tokens(db, response, user, client)


@router.post("/refresh", response_model=TokenOut)
def refresh(body: RefreshIn, request: Request, response: Response, db: DB, client: Client):
    s = get_settings()
    raw = body.refresh_token or request.cookies.get(s.cookie_name)
    if not raw:
        raise HTTPException(status.HTTP_401_UNAUTHORIZED, "Sin sesión")
    try:
        user_id, issued = rotate_refresh_token(db, raw)
    except TokenError:
        if client == "web":
            response.delete_cookie(s.cookie_name, path="/api/auth")
        # commit: persiste la revocación de la familia si fue una reutilización
        raise _fail(db, status.HTTP_401_UNAUTHORIZED, "Sesión caducada") from None
    user = db.get(User, user_id)
    if user is None or not user.is_active:
        raise _fail(db, status.HTTP_401_UNAUTHORIZED, "Sesión caducada")
    out = TokenOut(
        access_token=create_access_token(user_id), expires_in=s.access_token_minutes * 60
    )
    if client == "web":
        _set_cookie(response, issued.raw, issued.expires_at)
    else:
        out.refresh_token = issued.raw
    return out


@router.post("/logout", status_code=status.HTTP_204_NO_CONTENT)
def logout(body: RefreshIn, request: Request, response: Response, db: DB) -> Response:
    s = get_settings()
    raw = body.refresh_token or request.cookies.get(s.cookie_name)
    if raw:
        revoke_by_raw(db, raw)
    response.status_code = status.HTTP_204_NO_CONTENT
    response.delete_cookie(s.cookie_name, path="/api/auth")
    return response
