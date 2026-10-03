"""Tests contra Postgres real (servicio `db` de compose, BD `faro_test`). Las migraciones se
aplican al empezar la sesión (así también se prueban), y entre tests se vacían las tablas.

SEGURIDAD: los tests BORRAN el esquema. Nunca deben heredar FARO_DATABASE_URL (dentro del
contenedor de desarrollo apunta a la BD de dev). Se usa FARO_TEST_DATABASE_URL y se aborta si
el nombre de la BD no termina en `_test`."""

import json
import os
from urllib.parse import urlparse

_TEST_URL = os.environ.get(
    "FARO_TEST_DATABASE_URL", "postgresql+psycopg://faro:faro@db:5432/faro_test"
)
if not urlparse(_TEST_URL).path.rstrip("/").endswith("_test"):
    raise RuntimeError(f"Los tests solo corren contra una BD *_test, no {urlparse(_TEST_URL).path}")
os.environ["FARO_DATABASE_URL"] = _TEST_URL  # forzado, no setdefault
os.environ["FARO_ENV"] = "test"
os.environ["FARO_COOKIE_SECURE"] = "false"
os.environ["FARO_MFA_DISABLED"] = "false"  # el contenedor de dev lo activa

from collections.abc import Iterator

import pyotp
import pytest
from alembic import command
from alembic.config import Config
from fastapi.testclient import TestClient
from sqlalchemy import text

from app.db import SessionLocal, engine
from app.main import create_app
from app.models import Base, User
from app.security.passwords import hash_password

PASSWORD = "Contraseña-de-test-1"


@pytest.fixture(scope="session", autouse=True)
def _migrate() -> Iterator[None]:
    with engine.begin() as c:
        c.execute(text("DROP SCHEMA public CASCADE; CREATE SCHEMA public;"))
    cfg = Config(os.path.join(os.path.dirname(__file__), "..", "alembic.ini"))
    cfg.set_main_option("script_location", os.path.join(os.path.dirname(__file__), "..", "alembic"))
    cfg.set_main_option("sqlalchemy.url", os.environ["FARO_DATABASE_URL"])
    command.upgrade(cfg, "head")
    yield


@pytest.fixture(autouse=True)
def _clean() -> Iterator[None]:
    yield
    tables = ", ".join(f'"{t.name}"' for t in Base.metadata.sorted_tables)
    with engine.begin() as c:
        # Los parámetros fiscales globales son datos de referencia (los siembra una migración):
        # se conservan, aunque el TRUNCATE en cascada desde users los arrastraría
        keep = (
            c.execute(text("SELECT * FROM tax_parameters WHERE user_id IS NULL")).mappings().all()
        )
        c.execute(text(f"TRUNCATE {tables} RESTART IDENTITY CASCADE"))
        if keep:
            cols = list(keep[0].keys())
            values = ", ".join("CAST(:value AS jsonb)" if k == "value" else f":{k}" for k in cols)
            rows = [{k: json.dumps(v) if k == "value" else v for k, v in r.items()} for r in keep]
            # Columnas leídas del propio esquema, no de datos externos
            sql = f"INSERT INTO tax_parameters ({', '.join(cols)}) VALUES ({values})"  # noqa: S608
            c.execute(text(sql), rows)


@pytest.fixture
def client() -> TestClient:
    return TestClient(create_app())


@pytest.fixture
def make_user():
    def _make(email: str = "ana@example.com", password: str = PASSWORD) -> User:
        with SessionLocal() as db:
            u = User(email=email, display_name="Ana", password_hash=hash_password(password))
            db.add(u)
            db.commit()
            return u

    return _make


def enroll(client: TestClient, email: str, password: str = PASSWORD, web: bool = False) -> dict:
    """Login + alta de 2FA. Devuelve los tokens, el secreto TOTP y los códigos de recuperación."""
    headers = {"X-Faro-Client": "web"} if web else {}
    r = client.post("/api/auth/login", json={"email": email, "password": password})
    assert r.status_code == 200, r.text
    mfa = r.json()["mfa_token"]
    secret = client.post("/api/auth/2fa/setup", json={"mfa_token": mfa}).json()["secret"]
    r = client.post(
        "/api/auth/2fa/enable",
        json={"mfa_token": mfa, "code": pyotp.TOTP(secret).now()},
        headers=headers,
    )
    assert r.status_code == 200, r.text
    return {**r.json(), "secret": secret}


def auth_header(tokens: dict) -> dict:
    return {"Authorization": f"Bearer {tokens['access_token']}"}
