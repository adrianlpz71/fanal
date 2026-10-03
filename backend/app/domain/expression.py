"""Expresiones de importe tipo hoja de cálculo: "=-60+20+12" → submovimientos [-60, 20, 12].

Solo se admiten sumas y restas de constantes (con paréntesis alrededor de un número, p. ej.
"(-2500)"). Cualquier referencia a celdas o función devuelve None: no se adivina.
"""

import re
from decimal import Decimal

from app.domain.money import parse_es_amount

_NUM = r"\(?\s*[+-]?\s*\d+(?:[.,]\d+)?\s*\)?"
_FULL = re.compile(rf"^\s*=?\s*[+-]?\s*{_NUM}(\s*[+-]\s*{_NUM})*\s*$")
_TERM = re.compile(r"([+-]?)\s*\(?\s*([+-]?)\s*(\d+(?:[.,]\d+)?)\s*\)?")


def parse_expression(expr: str) -> list[Decimal] | None:
    """Devuelve los términos con signo, o None si la expresión no es una suma de constantes."""
    if not _FULL.match(expr):
        return None
    body = expr.strip().lstrip("=").strip()
    terms: list[Decimal] = []
    for outer, inner, num in _TERM.findall(body):
        value = parse_es_amount(num)
        if value is None:
            return None
        sign = -1 if (outer == "-") != (inner == "-") else 1
        terms.append(value * sign)
    return terms or None


def format_expression(terms: list[Decimal]) -> str:
    """Inversa aproximada: [-60, 20, 12] → "=-60+20+12"."""
    out = "="
    for i, t in enumerate(terms):
        s = format(t.normalize(), "f")
        if i > 0 and t >= 0:
            out += "+"
        out += s
    return out
