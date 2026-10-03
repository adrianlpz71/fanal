from functools import lru_cache

from pydantic import Field
from pydantic_settings import BaseSettings, SettingsConfigDict


class Settings(BaseSettings):
    """Configuración por variables de entorno (prefijo FARO_). Los secretos nunca tienen valor
    por defecto utilizable en producción: `check_production()` lo verifica al arrancar."""

    model_config = SettingsConfigDict(env_prefix="FARO_", env_file=None, extra="ignore")

    env: str = "dev"  # dev | test | prod
    database_url: str = "postgresql+psycopg://faro:faro@db:5432/faro"

    jwt_secret: str = "dev-insecure-jwt-secret-change-me-0123456789"  # noqa: S105 (solo dev)
    totp_encryption_key: str = Field(
        default="ZGV2LWluc2VjdXJlLWZlcm5ldC1rZXktMDEyMzQ1Njc=",  # Fernet (urlsafe b64, 32 bytes)
        description="Clave Fernet para cifrar los secretos TOTP en reposo",
    )
    access_token_minutes: int = 10
    refresh_token_days: int = 30
    mfa_token_minutes: int = 5

    cookie_secure: bool = True
    cookie_name: str = "faro_rt"

    # Rate limiting de login (ventana deslizante)
    login_window_minutes: int = 15
    login_max_failures_per_email: int = 5
    login_max_failures_per_ip: int = 20

    cors_origins: list[str] = []  # solo dev: la web en prod es mismo origen
    release_info_path: str = "/release/latest.json"
    totp_issuer: str = "Fanal"
    # SOLO desarrollo: login sin 2FA. En prod la API se niega a arrancar si está activo.
    mfa_disabled: bool = False

    def check_production(self) -> None:
        if self.env != "prod":
            return
        if self.mfa_disabled:
            raise RuntimeError("FARO_MFA_DISABLED no está permitido en producción")
        insecure = [
            name
            for name, value in (
                ("FARO_JWT_SECRET", self.jwt_secret),
                ("FARO_TOTP_ENCRYPTION_KEY", self.totp_encryption_key),
            )
            if "dev-insecure" in value or value == Settings.model_fields[name[5:].lower()].default
        ]
        if insecure:
            raise RuntimeError(f"Secretos sin configurar en producción: {', '.join(insecure)}")
        if len(self.jwt_secret) < 32:
            raise RuntimeError("FARO_JWT_SECRET debe tener al menos 32 caracteres")


@lru_cache
def get_settings() -> Settings:
    s = Settings()
    s.check_production()
    return s
