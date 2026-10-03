"""Extractos de cuenta en PDF. Por ahora: Trade Republic (España), el "Extracto de cuenta" que
genera la app (Perfil → Extractos). Formato visto en un fichero real de 2026-10.

Cada movimiento ocupa varias líneas: "14 mar" / "2026 Tipo Descripción … 150,00 € 1.150,00 €",
donde los dos últimos importes son el del movimiento y el saldo tras él. El PDF no dice si es
entrada o salida en una columna fiable (el texto pierde la posición), así que el signo sale del
saldo: saldo_anterior ± importe = saldo. Si no cuadra, se avisa y no se adivina.
"""

import io
import re
from datetime import date
from decimal import Decimal

from pypdf import PdfReader

from app.importers.bank import BankLine

MESES = {m: i + 1 for i, m in enumerate(
    ["ene", "feb", "mar", "abr", "may", "jun", "jul", "ago", "sep", "oct", "nov", "dic"]
)}  # fmt: skip
EUR = r"(-?[\d.]+,\d{2})\s?€"
ENTRY = re.compile(
    r"(?P<d>\d{1,2}) (?P<m>" + "|".join(MESES) + r")\s*\n?\s*(?P<y>\d{4})\s+(?P<body>.*?)\s"
    + EUR + r"\s+" + EUR,
    re.S,
)  # fmt: skip
TYPES = ("Transacción con tarjeta", "Transferencia", "Interés", "Operación", "Comisión", "Bono")


class StatementError(ValueError):
    pass


def pdf_text(content: bytes) -> str:
    try:
        reader = PdfReader(io.BytesIO(content))
        return "\n".join(p.extract_text() or "" for p in reader.pages)
    except Exception as e:  # PDF dañado o cifrado
        raise StatementError(f"No puedo leer el PDF: {type(e).__name__}") from None


def _eur(s: str) -> Decimal:
    return Decimal(s.replace(".", "").replace(",", "."))


def is_trade_republic(text: str) -> bool:
    return "TRADE REPUBLIC" in text.upper() and "TRANSACCIONES DE CUENTA" in text.upper()


def trade_republic(text: str) -> tuple[list[BankLine], list[str]]:
    """Movimientos del extracto (con signo) y avisos."""
    up = text.upper()
    start = up.find("TRANSACCIONES DE CUENTA")
    end = up.find("RESUMEN DEL BALANCE")
    if start < 0:
        raise StatementError("No es un extracto de cuenta de Trade Republic")
    head = text[:start]
    body = text[start : end if end > start else len(text)]
    # Saldo inicial: primer importe de la fila "Cuenta corriente" del resumen
    m0 = re.search(r"Cuenta corriente\s+" + EUR, head)
    prev = _eur(m0.group(1)) if m0 else None
    lines: list[BankLine] = []
    warnings: list[str] = []
    for i, m in enumerate(ENTRY.finditer(body), start=1):
        d = date(int(m.group("y")), MESES[m.group("m")], int(m.group("d")))
        desc = " ".join(m.group("body").split())
        # Las cabeceras repetidas de página no son movimientos
        desc = re.sub(r"^FECHA TIPO DESCRIPCI.N .*?BALANCE\s*", "", desc)
        amount, balance = _eur(m.group(5)), _eur(m.group(6))
        kind = next((t for t in TYPES if desc.startswith(t)), "")
        concept = desc[len(kind) :].strip() if kind else desc
        concept = f"{kind}: {concept}" if kind else concept
        if prev is not None and prev + amount == balance:
            signed = amount
        elif prev is not None and prev - amount == balance:
            signed = -amount
        else:
            warnings.append(f"{d.isoformat()}: no cuadra con el saldo anterior ({concept[:60]})")
            prev = balance
            continue
        prev = balance
        lines.append(BankLine(index=i, date=d, concept=concept[:160], amount=signed,
                              balance=balance, notes=None))  # fmt: skip
    if not lines:
        raise StatementError("No encuentro movimientos en el extracto")
    return lines, warnings
