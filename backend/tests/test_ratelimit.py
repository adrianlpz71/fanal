from tests.conftest import PASSWORD, enroll


def test_login_blocked_after_five_failures_even_with_right_password(client, make_user):
    make_user()
    for _ in range(5):
        assert (
            client.post(
                "/api/auth/login", json={"email": "ana@example.com", "password": "mala"}
            ).status_code
            == 401
        )
    r = client.post("/api/auth/login", json={"email": "ana@example.com", "password": PASSWORD})
    assert r.status_code == 429


def test_totp_failures_count_towards_block(client, make_user):
    make_user()
    enroll(client, "ana@example.com")
    mfa = client.post(
        "/api/auth/login", json={"email": "ana@example.com", "password": PASSWORD}
    ).json()["mfa_token"]
    codes = [
        client.post("/api/auth/2fa/verify", json={"mfa_token": mfa, "code": "000000"}).status_code
        for _ in range(6)
    ]
    assert codes[:5] == [401] * 5
    assert codes[5] == 429


def test_other_user_not_blocked(client, make_user):
    make_user()
    make_user("bea@example.com")
    for _ in range(5):
        client.post("/api/auth/login", json={"email": "ana@example.com", "password": "mala"})
    r = client.post("/api/auth/login", json={"email": "bea@example.com", "password": PASSWORD})
    assert r.status_code == 200
