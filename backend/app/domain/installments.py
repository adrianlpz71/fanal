"""Calendario de cuotas de una compra fraccionada ("meses vista")."""

from dataclasses import dataclass
from datetime import date
from decimal import Decimal

from app.domain.calendar import add_months
from app.domain.money import floor2


@dataclass(frozen=True)
class Cuota:
    seq: int
    due: date
    amount: Decimal  # positivo; el movimiento generado lo lleva en negativo


def schedule(
    total: Decimal,
    n: int,
    first_due: date,
    every_months: int = 1,
    custom: list[Decimal] | None = None,
) -> list[Cuota]:
    """Reparte `total` en `n` cuotas iguales truncadas a céntimos; la última absorbe el resto
    (así la suma es exacta). Con `custom`, se usan esos importes tal cual (deben sumar `total`)."""
    if n < 1:
        raise ValueError("n debe ser >= 1")
    if total <= 0:
        raise ValueError("el total debe ser positivo")
    if custom is not None:
        if len(custom) != n:
            raise ValueError("custom debe tener n importes")
        if sum(custom) != total:
            raise ValueError(f"las cuotas suman {sum(custom)} y el total es {total}")
        amounts = list(custom)
    else:
        base = floor2(total / n)
        amounts = [base] * (n - 1) + [total - base * (n - 1)]
    return [
        Cuota(seq=i + 1, due=add_months(first_due, i * every_months), amount=a)
        for i, a in enumerate(amounts)
    ]
