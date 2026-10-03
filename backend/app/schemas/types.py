"""Tipos compartidos de la API. El dinero viaja SIEMPRE como string decimal ("1234.56"),
nunca como número JSON (que el cliente leería como double)."""

from decimal import Decimal
from typing import Annotated

from pydantic import BeforeValidator, PlainSerializer, WithJsonSchema


def _to_decimal(v: object) -> Decimal:
    if isinstance(v, float):
        raise ValueError("el dinero no se acepta como float; envíalo como string")
    return Decimal(str(v))


Money = Annotated[
    Decimal,
    BeforeValidator(_to_decimal),
    PlainSerializer(
        lambda d: format(d.quantize(Decimal("0.01")), "f"), return_type=str, when_used="json"
    ),
    WithJsonSchema({"type": "string", "format": "decimal", "example": "1234.56"}),
]

# Participaciones / precios / tipos de cambio: hasta 10 decimales, sin redondear al serializar.
Quantity = Annotated[
    Decimal,
    BeforeValidator(_to_decimal),
    PlainSerializer(lambda d: format(d.normalize(), "f"), return_type=str, when_used="json"),
    WithJsonSchema({"type": "string", "format": "decimal", "example": "3.4965"}),
]
