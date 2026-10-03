"""Monte Carlo: propiedades que deben cumplirse (el azar va con semilla fija)."""

from decimal import Decimal as D

from app.domain.montecarlo import MonteCarloInput, simulate

BASE = MonteCarloInput(
    age=30, target_age=50, horizon_age=95, capital=D(100000), annual_contribution=D(20000),
    contribution_growth=D(0), annual_spend_gross=D(30000), annual_pension_gross=D(0),
    pension_age=67, needed=D(750000), mean_real_return=D("0.04"), volatility=D("0.15"),
    simulations=400,
)  # fmt: skip


def test_without_volatility_matches_deterministic():
    r = simulate(BASE.__class__(**{**BASE.__dict__, "volatility": D("0.0001")}))
    assert r.success in (D(0), D(1)) and r.fi_age_p10 == r.fi_age_p90


def test_reproducible_and_bounded():
    a, b = simulate(BASE), simulate(BASE)
    assert a == b  # misma semilla, mismo resultado
    assert 0 <= a.success <= 1 and 0 <= a.reach <= 1
    assert a.fi_age_p10 is not None and a.fi_age_p10 <= a.fi_age_p50  # type: ignore[operator]
    age, p10, p50, p90 = a.bands[20]
    assert age == 50 and p10 <= p50 <= p90


def test_more_volatility_more_dispersion_and_spending_more_fails_more():
    calm = simulate(BASE.__class__(**{**BASE.__dict__, "volatility": D("0.05")}))
    wild = simulate(BASE.__class__(**{**BASE.__dict__, "volatility": D("0.25")}))
    spread = lambda r: r.bands[20][3] - r.bands[20][1]  # noqa: E731
    assert spread(wild) > spread(calm)
    lavish = simulate(BASE.__class__(**{**BASE.__dict__, "annual_spend_gross": D(60000)}))
    assert lavish.success < simulate(BASE).success
