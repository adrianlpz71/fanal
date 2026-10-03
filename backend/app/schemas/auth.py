import uuid
from datetime import date
from typing import Literal

from pydantic import BaseModel, Field


class LoginIn(BaseModel):
    # Sin EmailStr: en el login solo se busca el usuario; validar "entregabilidad" aquí
    # rechazaría dominios válidos para pruebas (.test) y no aporta seguridad.
    email: str = Field(min_length=3, max_length=320)
    password: str = Field(min_length=1, max_length=512)


class LoginOut(BaseModel):
    # verify = pedir TOTP · setup = alta de 2FA · done = sesión iniciada (solo dev sin 2FA)
    status: Literal["verify", "setup", "done"]
    mfa_token: str | None = None
    access_token: str | None = None
    expires_in: int | None = None
    refresh_token: str | None = None


class MfaTokenIn(BaseModel):
    mfa_token: str


class MfaSetupOut(BaseModel):
    secret: str
    otpauth_uri: str


class MfaCodeIn(BaseModel):
    mfa_token: str
    code: str = Field(min_length=6, max_length=12, description="Código TOTP o de recuperación")


class TokenOut(BaseModel):
    access_token: str
    expires_in: int
    refresh_token: str | None = Field(
        default=None, description="Solo para clientes nativos; en web va en cookie HttpOnly"
    )


class MfaEnabledOut(TokenOut):
    recovery_codes: list[str]


class RefreshIn(BaseModel):
    refresh_token: str | None = None


class UserOut(BaseModel):
    id: uuid.UUID
    email: str  # salida: no se revalida (EmailStr rechazaría dominios .test)
    display_name: str
    birth_date: date | None
    locale: str
    currency: str
    timezone: str
    tax_region: str
    onboarding_completed: bool


class ProfileIn(BaseModel):
    display_name: str | None = Field(default=None, max_length=120)
    birth_date: date | None = None
    tax_region: str | None = Field(default=None, max_length=10)
    complete_onboarding: bool = False
