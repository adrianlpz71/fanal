"""Aceptación de la fase 5 (spec §12) y casos del motor fiscal calculados a mano."""

from decimal import Decimal as D

from app.domain.compound import compound
from app.domain.fire import FireInput, calculate, fi_age, needed_capital, project
from app.domain.tax import IrpfParams, WealthParams, gross_up, irpf, progressive, wealth_tax

# Escalas de prueba (las reales vienen de tax_parameters, nunca del código)
SAVINGS = {"tramos": [{"hasta": "6000", "tipo": "0.19"}, {"hasta": "50000", "tipo": "0.21"},
                      {"hasta": None, "tipo": "0.23"}]}  # fmt: skip
GENERAL = {"tramos": [{"hasta": "10000", "tipo": "0.10"}, {"hasta": None, "tipo": "0.20"}]}
P = IrpfParams(GENERAL, GENERAL, SAVINGS, D(5000), D(5000))


def close(a, b, tol="0.01"):
    return abs(a - D(b)) <= D(tol)


# --- §12 ---------------------------------------------------------------------------------------
def test_fire_capital_needed_acceptance():
    base = FireInput(age=D(26), target_age=D(42), monthly_spend=D(2000), swr=D("0.04"),
                     nominal_return=D("0.07"), inflation=D("0.025"))  # fmt: skip
    assert needed_capital(base) == D(600000)
    from dataclasses import replace

    assert round(needed_capital(replace(base, swr=D("0.035"))), 2) == D("685714.29")


def test_compound_interest_acceptance():
    nominal = compound(D(10000), D(300), D("0.07"), 20, convention="nominal")
    effective = compound(D(10000), D(300), D("0.07"), 20, convention="efectivo")
    assert round(nominal[-1].total, 2) == D("196665.39")
    assert round(effective[-1].total, 2) == D("190957.76")
    assert nominal[-1].contributed == D(10000 + 300 * 240)


def test_compound_options():
    rows = compound(D(0), D(100), D(0), 2, periods=12, timing="inicio", annual_increase=D("0.1"),
                    inflation=D("0.02"))  # fmt: skip
    assert rows[0].total == D(1200) and rows[1].total == D(1200) + D(1320)
    assert close(rows[1].real_total, D(2520) / D("1.0404"))


# --- FIRE --------------------------------------------------------------------------------------
def test_fire_projection_and_age():
    i = FireInput(age=D(30), target_age=D(40), monthly_spend=D(1000), swr=D("0.04"),
                  nominal_return=D("0.05"), inflation=D(0), capital=D(100000),
                  monthly_contribution=D(1000))  # fmt: skip
    r = calculate(i)
    assert r.needed == D(300000) and close(r.progress, "0.3333", "0.0001")
    # Sin aportar, la proyección solo crece al 5 % real
    from dataclasses import replace

    assert close(project(replace(i, monthly_contribution=D(0)), 12), "105000", "0.5")
    # Con la aportación necesaria se llega justo a los 40
    assert close(project(replace(i, monthly_contribution=r.required_monthly), 120), "300000", "1")
    assert r.fi_age is not None and D(39) < r.fi_age < D(41)
    assert close(r.coast * D("1.05") ** 10, "300000", "1")


def test_pension_bridge_reduces_needed_capital():
    i = FireInput(age=D(40), target_age=D(57), monthly_spend=D(2000), swr=D("0.04"),
                  nominal_return=D("0.0"), inflation=D(0), pension_monthly=D(1000),
                  pension_age=D(67))  # fmt: skip
    # Perpetua de 1.000 €/mes (300.000) + puente de 1.000 €/mes durante 10 años al 0 % (120.000)
    assert needed_capital(i) == D(420000)
    assert calculate(i).bridge == D(120000)
    assert fi_age(FireInput(age=D(30), target_age=D(40), monthly_spend=D(1000), swr=D("0.04"),
                            nominal_return=D(0), inflation=D(0))) is None  # fmt: skip


def test_fire_with_taxes_needs_more_capital():
    def gross(net):
        return gross_up(net, D("0.5"), P)[0]

    i = FireInput(age=D(30), target_age=D(40), monthly_spend=D(2000), swr=D("0.04"),
                  nominal_return=D("0.05"), inflation=D(0), gross_up=gross)  # fmt: skip
    assert needed_capital(i) > D(600000)


# --- Impuestos ---------------------------------------------------------------------------------
def test_progressive_and_irpf_with_minimum():
    assert progressive(D(15000), GENERAL) == D(1000) + D(1000)
    r = irpf(D(15000), D(0), P)
    # (2.000 − 500) en cada parte (estatal y autonómica de prueba iguales)
    assert r.general_state == D(1500) and r.general_regional == D(1500) and r.savings == 0


def test_minimum_left_over_applies_to_savings():
    # Sin rentas del trabajo: el mínimo (5.000 + 5.000) se come los primeros 5.000 € del ahorro
    r = irpf(D(0), D(8000), P)
    # Cada mitad: 0,095 × 6.000 + 0,105 × 2.000 − 0,095 × 5.000 = 305 → 610
    assert r.savings == D(610)


def test_gross_up_withdrawal():
    gross, tax = gross_up(D(30000), D("0.5"), P)
    assert close(gross - tax, "30000")
    assert tax > 0 and gross > D(30000)


WEALTH = {"tramos": [{"hasta": "100000", "tipo": "0.01"}, {"hasta": None, "tipo": "0.02"}]}
WP = WealthParams(WEALTH, D(700000), D(300000), D("0.60"), D("0.80"))


def test_wealth_tax_with_exemptions_and_joint_limit():
    w = wealth_tax(D(1200000), D(400000), WP)
    # 1,2 M − 300.000 (vivienda, tope) − 700.000 = 200.000 → 1.000 + 2.000
    assert w.taxable == D(200000) and w.quota == D(3000) and not w.joint_limit_applied
    limited = wealth_tax(D(1200000), D(400000), WP, irpf_quota=D(5000), irpf_taxable_base=D(10000))
    # 60 % de 10.000 = 6.000 − 5.000 de IRPF = 1.000, pero la rebaja no pasa del 80 % → 600 mín.
    assert limited.joint_limit_applied and limited.quota == D(1000)
    floor = wealth_tax(D(1200000), D(400000), WP, irpf_quota=D(6000), irpf_taxable_base=D(10000))
    assert floor.quota == D(600)
