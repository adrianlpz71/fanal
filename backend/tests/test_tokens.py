from tests.conftest import enroll


def test_refresh_rotates_and_old_token_is_rejected(client, make_user):
    make_user()
    t = enroll(client, "ana@example.com")
    r1 = client.post("/api/auth/refresh", json={"refresh_token": t["refresh_token"]})
    assert r1.status_code == 200
    new_rt = r1.json()["refresh_token"]
    assert new_rt != t["refresh_token"]


def test_refresh_reuse_revokes_whole_family(client, make_user):
    make_user()
    t = enroll(client, "ana@example.com")
    r1 = client.post("/api/auth/refresh", json={"refresh_token": t["refresh_token"]})
    new_rt = r1.json()["refresh_token"]
    # Un atacante reutiliza el token viejo → se revoca la familia...
    assert (
        client.post("/api/auth/refresh", json={"refresh_token": t["refresh_token"]}).status_code
        == 401
    )
    # ...y el legítimo también deja de valer (la revocación se ha persistido).
    assert client.post("/api/auth/refresh", json={"refresh_token": new_rt}).status_code == 401


def test_web_client_gets_httponly_cookie_not_body(client, make_user):
    make_user()
    t = enroll(client, "ana@example.com", web=True)
    assert t["refresh_token"] is None
    cookie = client.cookies.get("faro_rt")
    assert cookie
    r = client.post("/api/auth/refresh", json={}, headers={"X-Faro-Client": "web"})
    assert r.status_code == 200
    assert r.json()["refresh_token"] is None
    assert client.cookies.get("faro_rt") != cookie


def test_logout_revokes(client, make_user):
    make_user()
    t = enroll(client, "ana@example.com")
    assert (
        client.post("/api/auth/logout", json={"refresh_token": t["refresh_token"]}).status_code
        == 204
    )
    assert (
        client.post("/api/auth/refresh", json={"refresh_token": t["refresh_token"]}).status_code
        == 401
    )
