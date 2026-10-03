"""Calendario de ciclos de nómina.

El "mes" de Faro es el ciclo entre dos cobros. Convención (configurable por usuario): el ciclo se
nombra por el mes que se vive con esa nómina, así que la nómina de finales de septiembre abre
"Octubre". Una fecha pertenece al ciclo cuyo cobro estimado es el último anterior o igual a ella.
"""

import calendar
from dataclasses import dataclass
from datetime import date, timedelta

MONTHS_ES = [
    "Enero", "Febrero", "Marzo", "Abril", "Mayo", "Junio",
    "Julio", "Agosto", "Septiembre", "Octubre", "Noviembre", "Diciembre",
]  # fmt: skip


@dataclass(frozen=True, order=True)
class CycleKey:
    year: int
    month: int  # mes que "se vive"

    @property
    def label(self) -> str:
        return f"{MONTHS_ES[self.month - 1]} {self.year % 100:02d}"

    def next(self) -> "CycleKey":
        return CycleKey(self.year + self.month // 12, self.month % 12 + 1)

    def prev(self) -> "CycleKey":
        return CycleKey(self.year - (self.month == 1), (self.month - 2) % 12 + 1)


def estimated_payday(year: int, month: int, payday_day: int) -> date:
    """Cobro estimado del mes natural (year, month): día `payday_day` (acotado al fin de mes);
    si cae en fin de semana, el lunes siguiente."""
    last = calendar.monthrange(year, month)[1]
    d = date(year, month, min(payday_day, last))
    while d.weekday() >= 5:
        d += timedelta(days=1)
    return d


def cycle_start(key: CycleKey, payday_day: int) -> date:
    """El ciclo "Octubre" empieza con el cobro estimado de septiembre."""
    p = key.prev()
    return estimated_payday(p.year, p.month, payday_day)


def cycle_for_date(d: date, payday_day: int) -> CycleKey:
    """Ciclo al que pertenece una fecha según los cobros estimados."""
    pay_this_month = estimated_payday(d.year, d.month, payday_day)
    this = CycleKey(d.year, d.month)
    return this.next() if d >= pay_this_month else this


def key_from_label(label: str) -> CycleKey | None:
    parts = label.strip().split()
    if len(parts) != 2 or parts[0].capitalize() not in MONTHS_ES or not parts[1].isdigit():
        return None
    year = int(parts[1])
    return CycleKey(year + 2000 if year < 100 else year, MONTHS_ES.index(parts[0].capitalize()) + 1)


def add_months(d: date, months: int) -> date:
    m = d.month - 1 + months
    y = d.year + m // 12
    m = m % 12 + 1
    return date(y, m, min(d.day, calendar.monthrange(y, m)[1]))
