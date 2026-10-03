"""Resumen de un ciclo de nómina (equivale a B1/E1 del Excel, más lo que el Excel no daba)."""

from dataclasses import dataclass
from datetime import date
from decimal import Decimal

from app.domain.money import ZERO, floor2


@dataclass(frozen=True)
class Mov:
    amount: Decimal
    posted: bool
    kind: str = "gasto"  # gasto | ingreso | nomina | transferencia | reembolso | ajuste
    fixed: bool = False  # categoría de gasto fijo
    installment: bool = False  # cuota de compra fraccionada
    to_savings: bool = False  # transferencia a refugio/inversión (cuenta para la tasa de ahorro)


@dataclass(frozen=True)
class CycleSummary:
    carried: Decimal  # saldo real arrastrado del ciclo anterior (C1)
    payroll: Decimal  # nómina del ciclo
    opening: Decimal  # carried + payroll  (B1)
    available_now: Decimal  # opening + movimientos cargados (sin la nómina)
    expected_end: Decimal  # opening + todos los movimientos previstos y cargados  (E1)
    net_movements: Decimal  # E2 del Excel
    pending_total: Decimal
    fixed_spend: Decimal
    variable_spend: Decimal
    installments: Decimal
    savings: Decimal
    savings_rate: Decimal | None  # ahorro / nómina
    days_to_payday: int | None
    per_day: Decimal | None  # lo que se puede gastar al día hasta el cobro


def summarize(
    carried: Decimal,
    payroll: Decimal,
    movements: list[Mov],
    today: date | None = None,
    next_payday: date | None = None,
) -> CycleSummary:
    """`movements` NO incluye la nómina (va aparte, como en el Excel)."""
    opening = carried + payroll
    posted = sum((m.amount for m in movements if m.posted), ZERO)
    pending = sum((m.amount for m in movements if not m.posted), ZERO)
    spend = [m for m in movements if m.kind in ("gasto", "reembolso") and not m.installment]
    fixed = -sum((m.amount for m in spend if m.fixed), ZERO)
    variable = -sum((m.amount for m in spend if not m.fixed), ZERO)
    inst = -sum((m.amount for m in movements if m.installment), ZERO)
    savings = -sum((m.amount for m in movements if m.to_savings), ZERO)
    expected_end = opening + posted + pending

    days = per_day = None
    if today and next_payday:
        days = max((next_payday - today).days, 0)
        per_day = floor2(max(expected_end, ZERO) / days) if days > 0 else None

    return CycleSummary(
        carried=carried,
        payroll=payroll,
        opening=opening,
        available_now=opening + posted,
        expected_end=expected_end,
        net_movements=posted + pending,
        pending_total=pending,
        fixed_spend=fixed,
        variable_spend=variable,
        installments=inst,
        savings=savings,
        savings_rate=(savings / payroll) if payroll > 0 else None,
        days_to_payday=days,
        per_day=per_day,
    )
