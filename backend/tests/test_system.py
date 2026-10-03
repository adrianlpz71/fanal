import json
from decimal import Decimal

import pytest
from pydantic import BaseModel, ValidationError

from app.config import Settings, get_settings
from app.ids import uuid7
from app.schemas.types import Money, Quantity


def test_health(client):
    r = client.get("/api/health")
    assert r.status_code == 200
    assert r.json()["db"] is True


def test_version_without_release_file(client):
    r = client.get("/api/version")
    assert r.status_code == 200
    assert r.json()["app"] is None


def test_version_reads_release_file(client, tmp_path, monkeypatch):
    f = tmp_path / "latest.json"
    f.write_text(
        json.dumps({"version": "0.1.0", "build": 3, "apk_url": "/descargar/faro-0.1.0.apk"})
    )
    monkeypatch.setattr(get_settings(), "release_info_path", str(f))
    assert client.get("/api/version").json()["app"]["build"] == 3


def test_uuid7_is_version_7_and_time_ordered():
    ids = [uuid7() for _ in range(200)]
    assert all(u.version == 7 for u in ids)
    assert all(u.variant == "specified in RFC 4122" for u in ids)
    stamps = [u.int >> 80 for u in ids]
    assert stamps == sorted(stamps)


class _M(BaseModel):
    amount: Money
    units: Quantity


def test_money_serializes_as_string_never_float():
    m = _M(amount="1234.5", units="3.49650000")
    assert m.model_dump(mode="json") == {"amount": "1234.50", "units": "3.4965"}
    assert m.amount == Decimal("1234.5")
    with pytest.raises(ValidationError):
        _M(amount=0.1, units="1")
    schema = _M.model_json_schema()["properties"]["amount"]
    assert schema["type"] == "string" and schema["format"] == "decimal"


def test_prod_refuses_default_secrets():
    with pytest.raises(RuntimeError):
        Settings(env="prod").check_production()


def test_openapi_does_not_expose_client_header(client):
    """Regresión: si X-Faro-Client sale en el OpenAPI, el cliente Dart generado la envía como
    `null` y pisa la cabecera global → la web no recibe la cookie de refresh."""
    spec = client.get("/api/openapi.json").json()
    params = [
        p["name"].lower()
        for path in spec["paths"].values()
        for op in path.values()
        for p in op.get("parameters", [])
    ]
    assert "x-faro-client" not in params


def test_prod_refuses_mfa_disabled():
    s = Settings(
        env="prod",
        jwt_secret="x" * 40,
        totp_encryption_key="cHJvZC1rZXktcHJvZC1rZXktcHJvZC1rZXktMDEyMzQ=",
        mfa_disabled=True,
    )
    with pytest.raises(RuntimeError, match="MFA_DISABLED"):
        s.check_production()
