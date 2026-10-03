"""Ocurrencias de gastos recurrentes (mensual, bimestral, trimestral, semestral, anual)."""

import calendar
from datetime import date

from app.domain.calendar import add_months

FREQUENCIES = {"mensual": 1, "bimestral": 2, "trimestral": 3, "semestral": 6, "anual": 12}


def occurrences(
    start: date,
    every_months: int,
    day_of_month: int,
    window_from: date,
    window_to: date,
    end: date | None = None,
) -> list[date]:
    """Fechas de cargo dentro de [window_from, window_to). `start` fija el mes de la primera
    ocurrencia; `day_of_month` se acota al último día de cada mes."""
    out: list[date] = []
    i = 0
    while True:
        m = add_months(date(start.year, start.month, 1), i * every_months)
        d = date(m.year, m.month, min(day_of_month, calendar.monthrange(m.year, m.month)[1]))
        i += 1
        if d >= window_to or (end and d > end):
            break
        if d >= window_from and d >= start:
            out.append(d)
        if i > 1200:  # salvaguarda
            break
    return out
