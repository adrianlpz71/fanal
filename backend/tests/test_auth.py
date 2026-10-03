import pyotp

from tests.conftest import PASSWORD, auth_header, enroll


def test_login_wrong_password_is_401_and_generic(client, make_user):
    make_user()
    r = client.post("/api/auth/login", json={"email": "ana@example.com", "password": "mala"})
    assert r.status_code == 401
    r2 = client.post("/api/auth/login", json={"email": "nadie@example.com", "password": "mala"})
    assert r2.status_code == 401
    assert r.json() == r2.json()  # no revela si el email existe


def test_first_login_requires_2fa_setup_then_tokens(client, make_user):
    make_user()
    r = client.post("/api/auth/login", json={"email": "ana@example.com", "password": PASSWORD})
    assert r.json()["status"] == "setup"
    t = enroll(client, "ana@example.com")
    assert len(t["recovery_codes"]) == 10
    assert t["refresh_token"]  # cliente nativo: refresh en el cuerpo
    me = client.get("/api/me", headers=auth_header(t))
    assert me.status_code == 200
    assert me.json()["email"] == "ana@example.com"
    assert me.json()["onboarding_completed"] is False


def test_second_login_requires_totp(client, make_user):
    make_user()
    t = enroll(client, "ana@example.com")
    r = client.post("/api/auth/login", json={"email": "ana@example.com", "password": PASSWORD})
    assert r.json()["status"] == "verify"
    mfa = r.json()["mfa_token"]
    bad = client.post("/api/auth/2fa/verify", json={"mfa_token": mfa, "code": "000000"})
    assert bad.status_code == 401
    ok = client.post(
        "/api/auth/2fa/verify", json={"mfa_token": mfa, "code": pyotp.TOTP(t["secret"]).now()}
    )
    assert ok.status_code == 200


def test_recovery_code_works_once(client, make_user):
    make_user()
    t = enroll(client, "ana@example.com")
    code = t["recovery_codes"][0]
    for expected in (200, 401):
        mfa = client.post(
            "/api/auth/login", json={"email": "ana@example.com", "password": PASSWORD}
        ).json()["mfa_token"]
        r = client.post("/api/auth/2fa/verify", json={"mfa_token": mfa, "code": code.upper()})
        assert r.status_code == expected


def test_access_token_cannot_be_used_as_mfa_and_vice_versa(client, make_user):
    make_user()
    t = enroll(client, "ana@example.com")
    r = client.post("/api/auth/2fa/verify", json={"mfa_token": t["access_token"], "code": "123456"})
    assert r.status_code == 401
    mfa = client.post(
        "/api/auth/login", json={"email": "ana@example.com", "password": PASSWORD}
    ).json()["mfa_token"]
    assert client.get("/api/me", headers={"Authorization": f"Bearer {mfa}"}).status_code == 401


def test_me_requires_auth(client):
    assert client.get("/api/me").status_code == 401


def test_profile_update_and_onboarding(client, make_user):
    make_user()
    t = enroll(client, "ana@example.com")
    r = client.patch(
        "/api/me",
        json={"birth_date": "1995-03-14", "tax_region": "ES-CN", "complete_onboarding": True},
        headers=auth_header(t),
    )
    assert r.status_code == 200
    assert r.json()["birth_date"] == "1995-03-14"
    assert r.json()["onboarding_completed"] is True


def test_reserved_test_domains_work_end_to_end(client, make_user):
    make_user("demo@faro.test")
    r = client.post("/api/auth/login", json={"email": "Demo@Faro.test", "password": PASSWORD})
    assert r.status_code == 200
    t = enroll(client, "demo@faro.test")
    assert client.get("/api/me", headers=auth_header(t)).json()["email"] == "demo@faro.test"


def test_mfa_disabled_dev_login_returns_tokens(client, make_user, monkeypatch):
    from app.config import get_settings

    monkeypatch.setattr(get_settings(), "mfa_disabled", True)
    make_user()
    r = client.post("/api/auth/login", json={"email": "ana@example.com", "password": PASSWORD})
    assert r.status_code == 200
    body = r.json()
    assert body["status"] == "done" and body["mfa_token"] is None
    me = client.get("/api/me", headers={"Authorization": f"Bearer {body['access_token']}"})
    assert me.status_code == 200
