"""API de la fase 5 con los parámetros fiscales reales sembrados por la migración."""

from decimal import Decimal as D

import pytest

from tests.conftest import auth_header, enroll
from tests.test_api_gastos import setup_gastos


@pytest.fixture
def h(client, make_user):
    make_user("ana@example.com")
    return auth_header(enroll(client, "ana@example.com"))


def test_fire_needs_birth_date_then_calculates(client, h):
    assert client.get("/api/planes/fire", headers=h).status_code == 409
    client.patch("/api/me", headers=h, json={"birth_date": "1995-03-14", "tax_region": "ES-CN"})
    r = client.put(
        "/api/planes/fire/settings",
        headers=h,
        json={
            "target_age": 42,
            "monthly_spend": "2500",
            "swr": "0.0325",
            "include_taxes": False,
            "capital_override": "2000",
            "contribution_override": "500",
        },
    )
    assert r.status_code == 200 and r.json()["configured"] is True
    resp = client.get("/api/planes/fire", headers=h)
    assert resp.status_code == 200, resp.text
    p = resp.json()
    assert p["base"]["needed"] == "923076.92"  # 2.500 × 12 / 3,25 %
    assert p["capital"] == "2000.00" and p["monthly_contribution"] == "500.00"
    assert D(p["pessimistic"]["needed"]) == D(p["base"]["needed"])
    assert D(p["pessimistic"]["required_monthly"]) > D(p["base"]["required_monthly"])
    assert len(p["cut_effect"]) == 3 and len(p["projection"]) > 10
    # Con impuestos hace falta más (se retira bruto) y el impuesto anual sale > 0
    t = client.post("/api/planes/fire/simulate", headers=h, json={"include_taxes": True}).json()
    assert D(t["base"]["needed"]) > D(p["base"]["needed"]) and D(t["tax_annual"]) > 0
    # El simulador no guarda
    assert client.get("/api/planes/fire/settings", headers=h).json()["include_taxes"] is False
    # Comparar (pantalla "Comparar"): solo se mandan los cambios, el resto es el plan guardado
    c = client.post(
        "/api/planes/fire/simulate",
        headers=h,
        json={"monthly_spend": "3500", "contribution_override": "1000"},
    ).json()
    assert c["base"]["needed"] == "1292307.69"  # 3.500 × 12 / 3,25 %
    assert c["monthly_contribution"] == "1000.00" and c["settings"]["target_age"] == 42
    assert c["settings"]["monthly_spend"] == "3500.00"  # la tabla muestra el de la alternativa
    s = client.get("/api/planes/fire/settings", headers=h).json()
    assert s["monthly_spend"] == "2500.00" and s["contribution_override"] == "500.00"


def test_compound_endpoint_acceptance(client, h):
    body = {"initial": "10000", "contribution": "300", "annual_rate": "0.07", "years": 20}
    a = client.post("/api/planes/compound", headers=h, json=body).json()
    b = client.post(
        "/api/planes/compound", headers=h, json={**body, "convention": "efectivo"}
    ).json()
    assert a["total"] == "196665.39" and b["total"] == "190957.76"
    assert "anual / 12" in a["convention_note"] and "(1 + anual)^(1/12)" in b["convention_note"]
    assert len(a["rows"]) == 20 and a["contributed"] == "82000.00"


def test_tax_simulator_canarias_2026(client, h):
    client.patch("/api/me", headers=h, json={"tax_region": "ES-CN"})
    r = client.post(
        "/api/planes/tax", headers=h, json={"base_general": "30000", "net_wealth": "100000"}
    )
    assert r.status_code == 200, r.text
    t = r.json()
    # Estatal: 3.582,75 − 527,25 (mínimo 5.550) · Canarias: 3.370,75 − 504,54 (mínimo 5.606)
    assert t["irpf_general_state"] == "3055.50"
    assert t["irpf_general_regional"] == "2866.21"
    assert t["irpf_savings"] == "0.00" and t["region"] == "ES-CN"
    assert t["wealth_quota"] == "0.00" and t["wealth_obliged"] is False
    rich = client.post(
        "/api/planes/tax", headers=h, json={"base_general": "30000", "net_wealth": "1000000"}
    ).json()
    # 1 M − 700.000 de mínimo exento = 300.000: 334,26 + 132.870,55 × 0,3 %
    assert rich["wealth_quota_before_limit"] == "732.87" and rich["wealth_obliged"] is True


def test_goals_progress_and_isolation(client, h, make_user):
    setup_gastos(client, h, balance="1000.00")
    g = client.post(
        "/api/planes/goals",
        headers=h,
        json={"kind": "patrimonio", "name": "Primeros 10.000", "target_value": "10000"},
    )
    assert g.status_code == 201, g.text
    goal = g.json()
    assert goal["current"] is not None and D(goal["progress"]) > 0
    edad = client.post(
        "/api/planes/goals",
        headers=h,
        json={"kind": "edad_fi", "name": "Libre a los 42", "target_value": "42"},
    ).json()
    assert "nacimiento" in edad["detail"]  # sin fecha de nacimiento no se puede calcular
    assert len(client.get("/api/planes/goals", headers=h).json()) == 2
    make_user("eva@example.com")
    h2 = auth_header(enroll(client, "eva@example.com"))
    assert client.get("/api/planes/goals", headers=h2).json() == []
    assert client.delete(f"/api/planes/goals/{goal['id']}", headers=h2).status_code == 404
    assert client.delete(f"/api/planes/goals/{goal['id']}", headers=h).status_code == 204


def test_montecarlo_endpoint(client, h):
    client.patch("/api/me", headers=h, json={"birth_date": "1990-01-01"})
    client.put(
        "/api/planes/fire/settings",
        headers=h,
        json={
            "target_age": 50,
            "monthly_spend": "1500",
            "swr": "0.04",
            "include_taxes": False,
            "capital_override": "200000",
            "contribution_override": "1500",
        },
    )
    r = client.post("/api/planes/fire/montecarlo", headers=h, json={})
    assert r.status_code == 200, r.text
    m = r.json()
    assert 0 <= D(m["success"]) <= 1 and m["horizon_age"] == 95 and m["simulations"] == 2000
    assert m["bands"][0]["p50"] == "200000.00"
    # Gastar el triple hace bajar la probabilidad de éxito
    worse = client.post(
        "/api/planes/fire/montecarlo", headers=h, json={"monthly_spend": "4500"}
    ).json()
    assert D(worse["success"]) < D(m["success"])
    # Misma semilla: mismo resultado
    assert client.post("/api/planes/fire/montecarlo", headers=h, json={}).json() == m
