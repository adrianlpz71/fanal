"""Importador genérico de operaciones de inversión: cualquier CSV/Excel con una fila por
operación, con el mapeo de columnas que elige el usuario (y que se puede guardar como formato).

Columnas: fecha, activo (ISIN o ticker), participaciones e importe en euros; opcionales: tipo de
operación, comisión, nombre del activo y referencia de la operación. Sin columna de tipo, una
operación con participaciones o importe negativos es una venta. Cada operación lleva una huella
(la referencia, o el contenido de la fila y su nº de aparición), así reimportar no duplica.
"""

import hashlib
from dataclasses import dataclass
from decimal import Decimal, InvalidOperation
from typing import Any

from app.domain.money import ZERO, parse_es_amount
from app.importers.bank import _to_date
from app.importers.tabular import Row, norm

KEY_TYPES = ("isin", "ticker")
ASSET_TYPES = ("fondo", "etf", "accion", "cripto")
SELL_WORDS = ("venta", "vender", "sell", "reembolso", "rescate", "retirada")
BUY_WORDS = ("compra", "comprar", "buy", "suscripcion", "aportacion")


class MappingError(ValueError):
    pass


@dataclass
class BrokerMapping:
    platform: str  # nombre de la plataforma en Faro (se crea si no existe)
    date: int
    key: int  # columna con el ISIN o el ticker
    units: int
    amount: int
    key_type: str = "isin"
    asset_type: str = "fondo"
    kind: int | None = None  # columna con compra/venta (si no, por el signo)
    fee: int | None = None
    name: int | None = None  # nombre del activo (para los que se crean)
    ref: int | None = None  # id de la operación en la plataforma
    header_row: int = 0
    date_format: str | None = None
    decimal: str = "auto"  # auto | comma | point

    def as_dict(self) -> dict[str, Any]:
        return dict(self.__dict__)


def mapping_from_dict(d: dict[str, Any]) -> BrokerMapping:
    try:
        m = BrokerMapping(**{k: v for k, v in d.items() if k in BrokerMapping.__dataclass_fields__})
    except TypeError:
        raise MappingError("Faltan columnas: fecha, activo, participaciones e importe") from None
    if not str(m.platform or "").strip():
        raise MappingError("Indica el nombre de la plataforma")
    if m.key_type not in KEY_TYPES or m.asset_type not in ASSET_TYPES:
        raise MappingError("Tipo de clave o de activo no válido")
    if m.decimal not in ("auto", "comma", "point"):
        raise MappingError("Separador decimal no válido")
    cols = [c for c in (m.date, m.key, m.units, m.amount) if c is not None]
    if len(set(cols)) < 4:
        raise MappingError(
            "Fecha, activo, participaciones e importe tienen que ser columnas distintas"
        )
    m.platform = m.platform.strip()
    return m


# Pistas para sugerir columnas por el nombre de la cabecera (normalizado, sin tildes)
HINTS: dict[str, tuple[str, ...]] = {
    "date": ("fecha", "date"),
    "key": ("isin", "ticker", "simbolo", "symbol"),
    "units": (
        "participaciones",
        "titulos",
        "acciones",
        "cantidad",
        "unidades",
        "shares",
        "quantity",
        "qty",
    ),
    "amount": ("importe", "efectivo", "total", "amount", "valor"),
    "kind": ("operacion", "tipo", "type", "side"),
    "fee": ("comision", "gastos", "fee", "commission"),
    "name": ("producto", "nombre", "descripcion", "name", "valor"),
    "ref": ("referencia", "id", "order", "orden"),
}


def suggest(rows: list[Row]) -> dict[str, Any] | None:
    """Mapeo sugerido por los nombres de las cabeceras (el usuario lo revisa y completa)."""
    for h, row in enumerate(rows[:20]):
        cells = [norm(c) for c in row]
        if sum(1 for c in cells if c) < 3:
            continue
        out: dict[str, Any] = {"header_row": h}
        used: set[int] = set()
        for role, hints in HINTS.items():
            for i, c in enumerate(cells):
                if i not in used and c and any(c == k or c.startswith(k) for k in hints):
                    out[role] = i
                    used.add(i)
                    break
        if "date" in out and ("units" in out or "amount" in out):
            out["key_type"] = "isin" if "key" in out and "isin" in cells[out["key"]] else "ticker"
            return out
    return None


def _num(v: Any, mode: str) -> Decimal | None:
    if v is None or v == "":
        return None
    if isinstance(v, int | float) and not isinstance(v, bool):
        return Decimal(str(v))
    s = str(v).strip().replace(" ", "").replace("€", "").replace("EUR", "").replace("−", "-")
    if not s:
        return None
    try:
        if mode == "comma":
            return Decimal(s.replace(".", "").replace(",", "."))
        if mode == "point":
            return Decimal(s.replace(",", ""))
    except InvalidOperation:
        return None
    return parse_es_amount(s)


def _cell(r: Row, i: int | None) -> Any:
    return r[i] if i is not None and i < len(r) else None


@dataclass
class GenericOp:
    row: int
    kind: str  # compra | venta
    on: Any
    key: str
    units: Decimal
    amount_eur: Decimal
    fee: Decimal
    ref: str
    name: str | None


def parse(rows: list[Row], m: BrokerMapping) -> tuple[list[GenericOp], list[str]]:
    ops: list[GenericOp] = []
    warnings: list[str] = []
    seen: dict[str, int] = {}
    for i, r in enumerate(rows[m.header_row + 1 :], start=m.header_row + 2):
        if not any(str(c or "").strip() for c in r):
            continue
        on = _to_date(_cell(r, m.date), m.date_format)
        key = str(_cell(r, m.key) or "").strip().upper()
        units = _num(_cell(r, m.units), m.decimal)
        amount = _num(_cell(r, m.amount), m.decimal)
        if on is None or not key or units is None or amount is None:
            warnings.append(
                f"Fila {i}: falta la fecha, el activo, las participaciones o el importe"
            )
            continue
        if units == 0:
            warnings.append(f"Fila {i}: 0 participaciones, se ignora")
            continue
        if m.kind is not None:
            k = norm(_cell(r, m.kind))
            if any(w in k for w in SELL_WORDS):
                kind = "venta"
            elif any(w in k for w in BUY_WORDS) or not k:
                kind = "compra"
            else:
                warnings.append(f"Fila {i}: tipo «{_cell(r, m.kind)}» desconocido, se ignora")
                continue
        else:
            kind = "venta" if units < 0 or amount < 0 else "compra"
        fee = abs(_num(_cell(r, m.fee), m.decimal) or ZERO)
        name = str(_cell(r, m.name) or "").strip() or None
        if m.ref is not None and str(_cell(r, m.ref) or "").strip():
            ref = f"{m.platform}|{str(_cell(r, m.ref)).strip()}"
        else:
            base = f"{m.platform}|{on}|{key}|{abs(units)}|{abs(amount)}|{kind}"
            seen[base] = seen.get(base, 0) + 1
            ref = hashlib.sha256(f"{base}|{seen[base]}".encode()).hexdigest()[:40]
        ops.append(GenericOp(i, kind, on, key, abs(units), abs(amount), fee, ref, name))
    return ops, warnings
