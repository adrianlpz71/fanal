"""Aislamiento multiusuario: cada endpoint autenticado solo puede ver/tocar datos del usuario del
token. Este test crece con cada módulo: al añadir recursos, se crean como usuario A y se verifica
que el usuario B recibe 404 (nunca 200 ni 403, que revelaría la existencia)."""

from fastapi.routing import APIRoute

from app.main import create_app
from tests.conftest import auth_header, enroll

PUBLIC = {
    "/api/health",
    "/api/version",
    "/api/auth/login",
    "/api/auth/2fa/setup",
    "/api/auth/2fa/enable",
    "/api/auth/2fa/verify",
    "/api/auth/refresh",
    "/api/auth/logout",
}


def test_every_non_public_route_requires_auth(client):
    app = create_app()
    for route in app.routes:
        if not isinstance(route, APIRoute) or route.path in PUBLIC:
            continue
        for method in route.methods - {"HEAD", "OPTIONS"}:
            path = route.path.replace("{", "").replace("}", "")  # ids falsos
            r = client.request(method, path, json={})
            assert r.status_code == 401, f"{method} {route.path} no exige autenticación"


def test_me_returns_only_own_user(client, make_user):
    make_user("ana@example.com")
    make_user("bea@example.com")
    a = enroll(client, "ana@example.com")
    b = enroll(client, "bea@example.com")
    assert client.get("/api/me", headers=auth_header(a)).json()["email"] == "ana@example.com"
    assert client.get("/api/me", headers=auth_header(b)).json()["email"] == "bea@example.com"
