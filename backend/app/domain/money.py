from decimal import ROUND_DOWN, ROUND_HALF_EVEN, Decimal

CENT = Decimal("0.01")
ZERO = Decimal("0")


def q2(x: Decimal) -> Decimal:
    """Redondeo a céntimos (half-even, solo al persistir/presentar)."""
    return x.quantize(CENT, rounding=ROUND_HALF_EVEN)


def floor2(x: Decimal) -> Decimal:
    return x.quantize(CENT, rounding=ROUND_DOWN)


def parse_es_amount(text: str) -> Decimal | None:
    """Importes escritos a la española: "1.234,56", "-12,5", "12", "12.50" (punto decimal si no
    hay ambigüedad). Devuelve None si no es un número."""
    s = text.strip().replace(" ", "").replace("€", "").replace("−", "-")
    if not s:
        return None
    if "," in s:
        s = s.replace(".", "").replace(",", ".")
    else:
        parts = s.lstrip("+-").split(".")
        if len(parts) > 2 or (len(parts) == 2 and len(parts[1]) == 3):
            s = s.replace(".", "")  # "1.234" = mil doscientos treinta y cuatro
    try:
        return Decimal(s)
    except ArithmeticError:
        return None
