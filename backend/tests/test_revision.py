"""Revisión trimestral sobre los datos demo (un año de ciclos y dos de cartera)."""

from datetime import date
from decimal import Decimal as D

import pytest

from app.db import SessionLocal
from app.demo import seed
from app.services.revision import Metrics, Quarter, rising
from tests.conftest import PASSWORD, auth_header, enroll


def test_quarter_arithmetic():
    q = Quarter.parse("2026-Q4")
    assert (q.label, q.start, q.end) == ("T4 2026", date(2026, 10, 1), date(2026, 12, 31))
    assert q.next().key == "2027-Q1" and q.prev().key == "2026-Q3"
    assert Quarter(2026, 1).prev().key == "2025-Q4"
    assert Quarter.of(date(2026, 9, 30)).key == "2026-Q3"
    assert q.has_month(2026, 11) and not q.has_month(2026, 9)


@pytest.mark.parametrize("bad", ["2026", "2026-Q5", "Q3-2026", "2026-Qx"])
def test_quarter_parse_rejects(bad):
    with pytest.raises(Exception) as e:
        Quarter.parse(bad)
    assert getattr(e.value, "status_code", None) == 422


def test_rising_categories():
    now = Metrics(categories={"Ocio": D(300), "Casa": D(900), "Ropa": D(50)})
    before = Metrics(categories={"Ocio": D(100), "Casa": D(950)})
    assert rising(now, before) == [("Ocio", D(300), D(100)), ("Ropa", D(50), D(0))]
    assert rising(now, None) == []


@pytest.fixture
def demo(client):
    with SessionLocal() as db:
        seed(db, "lucia@example.com", PASSWORD)
        db.commit()
    return auth_header(enroll(client, "lucia@example.com"))


def test_review_of_last_quarter_and_comparison(client, demo):
    qs = client.get("/api/planes/reviews", headers=demo).json()
    assert qs[0]["in_progress"] is True and not any(q["saved"] for q in qs)
    last = qs[1]  # el último trimestre completo
    r = client.get(f"/api/planes/reviews/{last['quarter']}", headers=demo).json()
    m = r["metrics"]
    assert r["in_progress"] is False and r["label"] == last["label"]
    assert m["cycles"] == 3  # tres ciclos cerrados en el trimestre
    assert D(m["surplus"]) == D(m["income"]) - D(m["spend"])
    assert D(0) < D(m["savings_rate"]) < D(1)
    assert D(m["fixed_avg"]) > D(800)  # alquiler, fibra, suscripciones…
    # Cartera: lo ganado es lo que subió el valor menos lo aportado
    assert D(m["contributed"]) > 0
    assert D(m["gain"]) == D(m["portfolio_end"]) - D(m["portfolio_start"]) - D(m["contributed"])
    assert m["twr"] is not None
    assert D(m["networth_end"]) > 0 and D(m["fire_needed"]) > 0 and m["fire_age"] is not None
    assert len(m["goals"]) == 4
    assert r["previous"] is not None and r["previous"]["cycles"] == 3
    assert r["saved_at"] is None


def test_saving_takes_a_snapshot_used_by_the_next_quarter(client, demo):
    qs = client.get("/api/planes/reviews", headers=demo).json()
    prev_q, last_q = qs[2]["quarter"], qs[1]["quarter"]
    body = {"changed": "Subí el alquiler", "next_steps": "Revisar suscripciones"}
    r = client.put(f"/api/planes/reviews/{prev_q}", json=body, headers=demo)
    assert r.status_code == 200, r.text
    saved = r.json()
    assert saved["changed"] == "Subí el alquiler" and saved["saved_at"]
    assert client.get("/api/planes/reviews", headers=demo).json()[2]["saved"] is True
    # El trimestre siguiente se compara con la foto guardada (incluido el plan de entonces)
    nxt = client.get(f"/api/planes/reviews/{last_q}", headers=demo).json()
    assert nxt["previous"] == saved["metrics"]
    assert nxt["previous"]["fire_age"] == saved["metrics"]["fire_age"] is not None
    # Rehacerla la actualiza (una por trimestre)
    client.put(f"/api/planes/reviews/{prev_q}", json={"changed": "Otra cosa"}, headers=demo)
    again = client.get(f"/api/planes/reviews/{prev_q}", headers=demo).json()
    assert again["changed"] == "Otra cosa" and again["next_steps"] == ""


def test_reviews_are_per_user(client, demo, make_user):
    qs = client.get("/api/planes/reviews", headers=demo).json()
    client.put(f"/api/planes/reviews/{qs[1]['quarter']}", json={"changed": "x"}, headers=demo)
    make_user("otro@example.com")
    other = auth_header(enroll(client, "otro@example.com"))
    mine = client.get("/api/planes/reviews", headers=other).json()
    assert mine and not any(q["saved"] for q in mine)
    assert client.get("/api/planes/reviews/2026-Q9", headers=other).status_code == 422
