from datetime import date
from decimal import Decimal as D

import pytest
from hypothesis import given
from hypothesis import strategies as st

from app.domain.calendar import (
    CycleKey,
    cycle_for_date,
    cycle_start,
    estimated_payday,
    key_from_label,
)
from app.domain.cycles import Mov, summarize
from app.domain.expression import format_expression, parse_expression
from app.domain.installments import schedule
from app.domain.money import parse_es_amount
from app.domain.recurring import occurrences

# --- Criterio de aceptación (spec §12): ciclo de octubre ---------------------------------
# Importes de un ciclo de ejemplo (inventado). Pendientes: -12, -95, 0, +40.
OCT_POSTED = [-750, -35, -40, -14, -12, -52, -88, -64, -23, -45, -31, -120,
              -19, -27, -60, -15, -9, -42, -30, -75, -18]  # fmt: skip
OCT_PENDING = [-12, -95, 0, 40]


def test_october_cycle_acceptance():
    movs = [Mov(D(a), posted=True) for a in OCT_POSTED] + [
        Mov(D(a), posted=False) for a in OCT_PENDING
    ]
    s = summarize(carried=D(412), payroll=D(1950), movements=movs)
    assert s.opening == D(2362)
    assert s.expected_end == D(726)
    assert s.net_movements == D(-1636)
    assert s.available_now == D(2362) + sum(D(a) for a in OCT_POSTED)
    assert s.pending_total == D(-67)


def test_summary_breakdown_and_per_day():
    movs = [
        Mov(D(-200), True, kind="transferencia", to_savings=True),
        Mov(D(-9), True, fixed=True),
        Mov(D(-50), False),
        Mov(D(-107), False, installment=True),
        Mov(D(30), True, kind="ingreso"),
    ]
    s = summarize(D(100), D(1800), movs, today=date(2026, 10, 1), next_payday=date(2026, 10, 27))
    assert s.fixed_spend == D(9) and s.variable_spend == D(50) and s.installments == D(107)
    assert s.savings == D(200) and s.savings_rate == D(200) / D(1800)
    assert s.days_to_payday == 26
    # expected_end = 1900 - 200 - 9 - 50 - 107 + 30 = 1564 → 1564/26 = 60.1538… → 60.15 (trunca)
    assert s.expected_end == D(1564)
    assert s.per_day == D("60.15")


# --- Expresiones de varios términos (submovimientos) ----------------------------------------
@pytest.mark.parametrize(
    ("expr", "terms"),
    [
        ("=-60+20+12", [-60, 20, 12]),
        ("=-24+40-26", [-24, 40, -26]),
        ("=74", [74]),
        ("=+10+10+20", [10, 10, 20]),
        ("=(-2500)+100", [-2500, 100]),
        ("=-12,5+3.25", [D("-12.5"), D("3.25")]),
        ("-5-5", [-5, -5]),
    ],
)
def test_parse_expression(expr, terms):
    assert parse_expression(expr) == [D(t) for t in terms]


@pytest.mark.parametrize("expr", ["=(-2500)+B17", "=SUM(B1:B7)", "=2*3", "", "=abc", "=1+"])
def test_parse_expression_rejects_non_constant(expr):
    assert parse_expression(expr) is None


@given(st.lists(st.integers(min_value=-10_000, max_value=10_000), min_size=1, max_size=40))
def test_expression_roundtrip(nums):
    terms = [D(n) for n in nums]
    assert parse_expression(format_expression(terms)) == terms


def test_parse_es_amount():
    assert parse_es_amount("1.234,56") == D("1234.56")
    assert parse_es_amount("-12,5") == D("-12.5")
    assert parse_es_amount("1.234") == D("1234")
    assert parse_es_amount("12.50") == D("12.50")
    assert parse_es_amount(" 14,30 € ") == D("14.30")
    assert parse_es_amount("abc") is None


# --- Calendario de ciclos -------------------------------------------------------------------
def test_payday_moves_weekend_to_monday():
    assert estimated_payday(2026, 9, 27) == date(2026, 9, 28)  # 27-sep-2026 es domingo
    assert estimated_payday(2026, 10, 27) == date(2026, 10, 27)  # martes
    assert estimated_payday(2026, 2, 30) == date(2026, 3, 2)  # 28-feb sábado → lunes


def test_cycle_naming_convention():
    # Nómina de finales de septiembre abre "Octubre 26"
    assert cycle_for_date(date(2026, 9, 29), 27) == CycleKey(2026, 10)
    assert cycle_for_date(date(2026, 10, 15), 27) == CycleKey(2026, 10)
    assert cycle_for_date(date(2026, 10, 27), 27) == CycleKey(2026, 11)
    assert cycle_for_date(date(2026, 12, 30), 27) == CycleKey(2027, 1)
    assert CycleKey(2026, 10).label == "Octubre 26"
    assert key_from_label("Diciembre 26") == CycleKey(2026, 12)
    assert key_from_label("Hoja1") is None
    assert cycle_start(CycleKey(2026, 10), 27) == date(2026, 9, 28)


# --- Fraccionadas ------------------------------------------------------------------------------
def test_installments_remainder_goes_to_last():
    cs = schedule(D("476"), 3, date(2026, 9, 15))
    assert [c.amount for c in cs] == [D("158.66"), D("158.66"), D("158.68")]
    assert sum(c.amount for c in cs) == D("476")
    assert [c.due for c in cs] == [date(2026, 9, 15), date(2026, 10, 15), date(2026, 11, 15)]


def test_installments_custom_and_month_end():
    cs = schedule(D("476"), 3, date(2026, 1, 31), custom=[D(159), D(159), D(158)])
    assert [c.amount for c in cs] == [D(159), D(159), D(158)]
    assert [c.due for c in cs] == [date(2026, 1, 31), date(2026, 2, 28), date(2026, 3, 31)]
    with pytest.raises(ValueError):
        schedule(D("100"), 2, date(2026, 1, 1), custom=[D(50), D(40)])


@given(
    st.decimals(min_value="0.01", max_value="100000", places=2),
    st.integers(min_value=1, max_value=48),
)
def test_installments_always_sum_exactly(total, n):
    cs = schedule(total, n, date(2026, 1, 1))
    assert sum(c.amount for c in cs) == total
    assert all(c.amount > 0 for c in cs) or total < D("0.01") * n


# --- Recurrentes ---------------------------------------------------------------------------
def test_recurring_occurrences():
    occ = occurrences(date(2026, 1, 31), 1, 31, date(2026, 1, 1), date(2026, 5, 1))
    assert occ == [date(2026, 1, 31), date(2026, 2, 28), date(2026, 3, 31), date(2026, 4, 30)]
    yearly = occurrences(date(2025, 3, 10), 12, 10, date(2026, 1, 1), date(2027, 12, 31))
    assert yearly == [date(2026, 3, 10), date(2027, 3, 10)]
    ended = occurrences(
        date(2026, 1, 5), 1, 5, date(2026, 1, 1), date(2026, 12, 31), end=date(2026, 3, 1)
    )
    assert ended == [date(2026, 1, 5), date(2026, 2, 5)]
