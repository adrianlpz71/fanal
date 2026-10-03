"""Categorías iniciales GENÉRICAS y autocategorización básica por palabras clave.

Las usan la demo (capturas, versión pública) y, en la versión pública, sustituyen a
`categories_seed.py` (lo hace `scripts/export-public.sh`). Las de Adrián siguen en
`categories_seed.py`, solo en el repo privado.

Las palabras clave son genéricas (comercios y servicios comunes). Las reglas aprendidas de las
correcciones del usuario están en la tabla category_rules."""

import re
import unicodedata
import uuid

from sqlalchemy import select
from sqlalchemy.orm import Session

from app.models import Category

# (nombre, icono, color, fija, [subcategorías], tipo)
SEED: list[tuple[str, str, str, bool, list[str], str]] = [
    ("Casa y familia", "home", "#8D6E63", True, ["Supermercado", "Hogar"], "gasto"),
    ("Telefonía e internet", "phone_android", "#5C6BC0", True, [], "gasto"),
    ("Suscripciones", "subscriptions", "#7E57C2", True,
     ["Streaming", "Software", "Otras"], "gasto"),
    ("Hobbies", "palette", "#AB47BC", False, ["Compras", "Eventos", "Material"], "gasto"),
    ("Comida fuera", "restaurant", "#FF7043", False,
     ["Delivery", "Restaurantes", "Fast food"], "gasto"),
    ("Transporte", "directions_bus", "#42A5F5", False, [], "gasto"),
    ("Viajes", "flight", "#29B6F6", False, ["Vuelos", "Alojamiento", "En destino"], "gasto"),
    ("Deporte y salud", "fitness_center", "#66BB6A", False, [], "gasto"),
    ("Cuidado personal", "face", "#EC407A", False, [], "gasto"),
    ("Ropa", "checkroom", "#FFA726", False, [], "gasto"),
    ("Videojuegos", "sports_esports", "#5E35B1", False, [], "gasto"),
    ("Compras online y hogar", "shopping_bag", "#FFCA28", False, [], "gasto"),
    ("Ocio y social", "celebration", "#D4E157", False, [], "gasto"),
    ("Libros y cultura", "menu_book", "#8D6E63", False, [], "gasto"),
    ("Finanzas", "account_balance", "#78909C", False, [], "gasto"),
    ("Sin categoría", "help_outline", "#9E9E9E", False, [], "gasto"),
    ("Ingresos", "payments", "#2E7D32", False,
     ["Nómina", "Ventas", "Reembolsos", "Devoluciones", "Otros"], "ingreso"),
    ("Transferencias", "swap_horiz", "#546E7A", False,
     ["A refugio", "A inversión", "Entre cuentas"], "transferencia"),
]  # fmt: skip

# Palabra clave (sin tildes, minúsculas) → "Categoría" o "Categoría/Subcategoría"
KEYWORDS: list[tuple[str, str]] = [
    (r"\bnomina\b", "Ingresos/Nómina"),
    (r"\b(mercadona|lidl|carrefour|aldi|dia|eroski|alcampo|supermercado)\b",
     "Casa y familia/Supermercado"),
    (r"\b(movistar|vodafone|orange|digi|pepephone|simyo|fibra)\b", "Telefonía e internet"),
    (r"\b(netflix|spotify|prime|disney|hbo|max|filmin|audible)\b", "Suscripciones/Streaming"),
    (r"\b(chatgpt|openai|claude|copilot|github|dropbox|icloud|google one)\b",
     "Suscripciones/Software"),
    (r"\b(uber ?eats|glovo|just eat|deliveroo)\b", "Comida fuera/Delivery"),
    (r"\b(kfc|mcdonald\w*|burger|telepizza|domino\w*|five guys)\b", "Comida fuera/Fast food"),
    (r"\b(cena|comida|restaurante|bar|cafe|almuerzo)\b", "Comida fuera/Restaurantes"),
    (r"\b(uber|cabify|taxi|metro|bus|renfe|gasolina|parking|abono)\b", "Transporte"),
    (r"\b(vuelo|vueling|ryanair|iberia|easyjet)\b", "Viajes/Vuelos"),
    (r"\b(booking|airbnb|hotel|hostal)\b", "Viajes/Alojamiento"),
    (r"\b(padel|gimnasio|gym|farmacia)\b", "Deporte y salud"),
    (r"\b(peluquer\w*|perfume\w*)\b", "Cuidado personal"),
    (r"\b(zara|bershka|primark|nike|pull)\b", "Ropa"),
    (r"\b(steam|nintendo|playstation|xbox)\b", "Videojuegos"),
    (r"\b(amazon|aliexpress|ikea|temu|shein)\b", "Compras online y hogar"),
    (r"\b(cumple\w*|fiestas?|entradas?|cine|concierto)\b", "Ocio y social"),
    (r"\b(libro\w*|comic\w*|casa del libro)\b", "Libros y cultura"),
    (r"\b(comision\w*|intereses|hacienda)\b", "Finanzas"),
    (r"\b(venta|vendo)\b", "Ingresos/Ventas"),
    (r"\b(reembolso|refund)\b", "Ingresos/Reembolsos"),
    (r"\b(devolucion)\b", "Ingresos/Devoluciones"),
]  # fmt: skip

_COMPILED = [(re.compile(p), cat) for p, cat in KEYWORDS]


def normalize(text: str) -> str:
    t = unicodedata.normalize("NFKD", text.lower())
    return "".join(c for c in t if not unicodedata.combining(c)).strip()


def guess_category_path(concept: str) -> str | None:
    n = normalize(concept)
    for rx, cat in _COMPILED:
        if rx.search(n):
            return cat
    return None


def seed_categories(db: Session, user_id: uuid.UUID) -> int:
    """Crea las categorías iniciales si el usuario no tiene ninguna. Devuelve cuántas creó."""
    if db.scalar(select(Category.id).where(Category.user_id == user_id).limit(1)):
        return 0
    n = 0
    for sort, (name, icon, color, fixed, subs, kind) in enumerate(SEED):
        parent = Category(
            user_id=user_id, name=name, icon=icon, color=color, fixed=fixed, kind=kind, sort=sort
        )
        db.add(parent)
        db.flush()
        n += 1
        for j, sub in enumerate(subs):
            db.add(
                Category(
                    user_id=user_id, parent_id=parent.id, name=sub, icon=icon, color=color,
                    fixed=fixed, kind=kind, sort=j,
                )
            )  # fmt: skip
            n += 1
    db.flush()
    return n


def category_index(db: Session, user_id: uuid.UUID) -> dict[str, uuid.UUID]:
    """{"Categoría": id, "Categoría/Sub": id} para resolver rutas."""
    rows = db.scalars(select(Category).where(Category.user_id == user_id)).all()
    by_id = {c.id: c for c in rows}
    out: dict[str, uuid.UUID] = {}
    for c in rows:
        path = f"{by_id[c.parent_id].name}/{c.name}" if c.parent_id in by_id else c.name
        out[path] = c.id
    return out
