import ipaddress
from typing import Annotated, Literal

from fastapi import Depends, Header, HTTPException, Request, status
from fastapi.security import HTTPAuthorizationCredentials, HTTPBearer
from sqlalchemy.orm import Session

from app.db import get_db
from app.models import User
from app.security.tokens import TokenError, decode_access_token

DB = Annotated[Session, Depends(get_db)]

_bearer = HTTPBearer(auto_error=False)


def current_user(
    db: DB, creds: Annotated[HTTPAuthorizationCredentials | None, Depends(_bearer)]
) -> User:
    unauthorized = HTTPException(
        status.HTTP_401_UNAUTHORIZED, "No autenticado", headers={"WWW-Authenticate": "Bearer"}
    )
    if creds is None:
        raise unauthorized
    try:
        user_id = decode_access_token(creds.credentials)
    except TokenError:
        raise unauthorized from None
    user = db.get(User, user_id)
    if user is None or not user.is_active:
        raise unauthorized
    return user


CurrentUser = Annotated[User, Depends(current_user)]

ClientKind = Literal["web", "android"]


def client_kind(
    # Fuera del OpenAPI: si no, el cliente generado la envía como parámetro (null) y pisa
    # la cabecera global que pone la app.
    x_faro_client: Annotated[str | None, Header(include_in_schema=False)] = None,
) -> ClientKind:
    """La web manda `X-Faro-Client: web` (recibe el refresh en cookie HttpOnly). El resto
    se trata como cliente nativo (recibe el refresh en el cuerpo). Además, la cabecera
    personalizada fuerza un preflight CORS, lo que protege el refresh por cookie frente a CSRF."""
    return "web" if (x_faro_client or "").lower() == "web" else "android"


Client = Annotated[ClientKind, Depends(client_kind)]


def client_ip(request: Request) -> str | None:
    # uvicorn con --proxy-headers ya resuelve X-Forwarded-For de Caddy en request.client
    host = request.client.host if request.client else None
    try:
        return str(ipaddress.ip_address(host)) if host else None
    except ValueError:
        return None
