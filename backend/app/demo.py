"""Datos de demostración: un usuario ficticio con un año de gastos, una cartera y un plan FIRE.

Sirve para enseñar la app (capturas, versión pública) sin datos reales. Todo es inventado y
determinista (misma semilla → mismos datos), con fechas relativas a hoy. Pasa por los mismos
servicios que la app (ciclos, recurrentes, cuotas, objetivos de cartera…).

    python -m app.demo --email demo@faro.example --password-stdin [--reset]

No se puede ejecutar en producción.
"""

import argparse
import random
import sys
from dataclasses import dataclass
from datetime import UTC, date, datetime, timedelta
from decimal import Decimal

from sqlalchemy import delete, select
from sqlalchemy.orm import Session

from app.config import get_settings as app_settings
from app.domain import calendar as cal
from app.domain.recurring import occurrences
from app.models import (
    Account,
    Asset,
    AssetExposure,
    ContributionPlan,
    Goal,
    InvTransaction,
    Movement,
    PayCycle,
    Platform,
    RecurringTemplate,
    User,
)
from app.schemas.inversiones import AssetTargetIn, MacroTargetIn
from app.security.passwords import hash_password
from app.services import gastos as gsvc
from app.services import inversiones as isvc
from app.services import planes as psvc

# Las categorías genéricas (las de la versión pública), nunca las personales del repo privado
from app.services.categories_seed_generic import category_index, seed_categories

D = Decimal
CENT = D("0.01")
PAYDAY = 28
CYCLES = 12  # ciclos cerrados antes del actual
SEED = 20240601
PRICE_SEED = 11  # elegida para que los precios evolucionen de forma verosímil


def eur(x: float | Decimal) -> Decimal:
    return D(str(x)).quantize(CENT)


@dataclass(frozen=True)
class Fixed:
    concept: str
    amount: str
    category: str
    day: int
    estimate: bool = False
    kind: str = "gasto"


FIXED = [
    Fixed("Alquiler", "-750", "Casa y familia", 1),
    Fixed("Fibra y móvil", "-35", "Telefonía e internet", 5),
    Fixed("Gimnasio", "-39.90", "Deporte y salud", 3),
    Fixed("Netflix", "-13.99", "Suscripciones/Streaming", 12),
    Fixed("Spotify", "-11.99", "Suscripciones/Streaming", 20),
    Fixed("Luz", "-55", "Casa y familia", 10, estimate=True),
    Fixed("Aportación a la cartera", "-340", "Transferencias/A inversión", 2, kind="transferencia"),
    Fixed(
        "A la cuenta remunerada", "-400", "Transferencias/Entre cuentas", 3, kind="transferencia"
    ),
    Fixed("A fondo de emergencia", "-150", "Transferencias/A refugio", 3, kind="transferencia"),
]

# (concepto, categoría, mínimo, máximo, veces por ciclo [mín, máx], probabilidad)
VARIABLE = [
    ("Supermercado", "Casa y familia", 35, 95, (3, 5), 1.0),
    ("Cena con amigos", "Comida fuera/Restaurantes", 18, 55, (1, 3), 1.0),
    ("Abono transporte", "Transporte", 20, 20, (1, 1), 1.0),
    ("Farmacia", "Deporte y salud", 6, 25, (0, 1), 0.6),
    ("Ropa", "Ropa", 25, 80, (1, 1), 0.5),
    ("Amazon", "Compras online y hogar", 12, 60, (1, 2), 0.6),
    ("Cine", "Ocio y social", 9, 24, (1, 1), 0.4),
    ("Libros", "Libros y cultura", 12, 30, (1, 1), 0.3),
]
TRIPS = {4: ("Vuelo Lisboa", "Hotel Lisboa"), 9: ("Vuelo Roma", "Hotel Roma")}  # nº de ciclo


@dataclass(frozen=True)
class DemoAsset:
    name: str
    type: str
    klass: str
    platform: str
    start: Decimal  # precio hace dos años
    drift: float  # rentabilidad anual esperada
    vol: float  # volatilidad anual
    monthly: Decimal  # aportación mensual
    target: Decimal  # peso dentro de su categoría
    decimals: str


ASSETS = [
    DemoAsset(
        "Fondo indexado mundial",
        "fondo",
        "Fondos",
        "Broker",
        D("21.40"),
        0.07,
        0.15,
        D(225),
        D("0.75"),
        "0.0001",
    ),
    DemoAsset(
        "Fondo indexado emergentes",
        "fondo",
        "Fondos",
        "Broker",
        D("11.80"),
        0.05,
        0.18,
        D(30),
        D("0.10"),
        "0.0001",
    ),
    DemoAsset(
        "Fondo renta fija euro",
        "fondo",
        "Fondos",
        "Broker",
        D("9.95"),
        0.025,
        0.04,
        D(45),
        D("0.15"),
        "0.0001",
    ),
    DemoAsset(
        "Bitcoin", "cripto", "Cripto", "Exchange", D(38000), 0.15, 0.60, D(40), D(1), "0.00000001"
    ),
]
EXPOSURE = {
    "region": {
        "Norteamérica": "0.64",
        "Europa": "0.15",
        "Japón": "0.06",
        "Asia desarrollada": "0.04",
        "Emergentes": "0.08",
        "Otros": "0.03",
    },
    "sector": {
        "Tecnología": "0.25",
        "Financiero": "0.16",
        "Salud": "0.11",
        "Industria": "0.11",
        "Consumo cíclico": "0.10",
        "Otros": "0.27",
    },
}


def _prices(rng: random.Random, a: DemoAsset, start: date, today: date) -> dict[date, Decimal]:
    """Paseo aleatorio lognormal diario (los fondos no publican valor en fin de semana)."""
    out: dict[date, Decimal] = {}
    price, d = a.start, start
    daily_drift, daily_vol = a.drift / 252, a.vol / (252**0.5)
    while d <= today:
        if d == start or a.type == "cripto" or d.weekday() < 5:
            # El sorteo es float (como en Monte Carlo); el precio se guarda en Decimal
            shock = D(str(round(rng.gauss(daily_drift, daily_vol), 6)))
            price = (price * (1 + shock)).quantize(D("0.0001"))
            out[d] = price
        d += timedelta(days=1)
    return out


def _price_on(prices: dict[date, Decimal], d: date) -> tuple[date, Decimal]:
    while d not in prices:
        d -= timedelta(days=1)
    return d, prices[d]


def seed(db: Session, email: str, password: str, today: date | None = None) -> User:
    today = today or date.today()
    rng = random.Random(SEED)  # noqa: S311 (datos inventados, no criptografía)
    user = User(
        email=email,
        display_name="Lucía (demo)",
        password_hash=hash_password(password),
        birth_date=date(1995, 3, 14),
        tax_region="ES-CN",
        onboarding_completed_at=datetime.now(UTC),
    )
    db.add(user)
    db.flush()
    uid = user.id
    seed_categories(db, uid)
    cats = category_index(db, uid)

    # --- Gastos: cuentas, ajustes y recurrentes ------------------------------------------------
    cur_key = cal.cycle_for_date(today, PAYDAY)
    first_key = cur_key
    for _ in range(CYCLES):
        first_key = first_key.prev()
    first_start = cal.cycle_start(first_key, PAYDAY)
    since = today - timedelta(days=730)  # la cartera y las cuentas de ahorro vienen de antes
    main = Account(
        user_id=uid,
        kind="gastos",
        name="Cuenta de gastos",
        bank="Banco Demo",
        opening_balance=D(1200),
        opening_date=first_start,
    )
    refugio = Account(
        user_id=uid,
        kind="refugio",
        name="Fondo de emergencia",
        bank="Banco Demo",
        opening_balance=D(5000),
        opening_date=since,
        sort=1,
    )
    ahorro = Account(
        user_id=uid,
        kind="ahorro",
        name="Cuenta remunerada",
        bank="Banco Online",
        opening_balance=D(2000),
        opening_date=since,
        apy=D("0.02"),
        sort=2,
    )
    db.add_all([main, refugio, ahorro])
    db.flush()
    gsvc.save_settings(
        db,
        uid,
        {
            "payday_day": PAYDAY,
            "main_account_id": main.id,
            "refugio_account_id": refugio.id,
            "usual_payroll": "2010",
            "emergency_target": "7500",
            "monthly_refugio": "150",
        },
    )
    to_account = {"A la cuenta remunerada": ahorro, "A fondo de emergencia": refugio}
    templates = []
    for f in FIXED:
        t = RecurringTemplate(
            user_id=uid,
            account_id=main.id,
            concept=f.concept,
            amount=D(f.amount),
            amount_is_estimate=f.estimate,
            kind=f.kind,
            category_id=cats.get(f.category),
            day_of_month=f.day,
            start_date=first_start,
        )
        db.add(t)
        templates.append(t)
    db.flush()

    # --- Ciclos (el arrastre de cada uno se calcula al final) ------------------------------------
    key = first_key
    for n in range(CYCLES + 1):
        start, until = cal.cycle_start(key, PAYDAY), cal.cycle_start(key.next(), PAYDAY)
        is_current = key == cur_key
        payroll = D(1950) if n < 7 else D(2010)  # subida a mitad de año
        if key.month in (7, 12):
            payroll += D(1950)  # paga extra
        cyc = gsvc.create_cycle(
            db, uid, main, key.label, start, D(0), payroll, payroll_date=start, generate=False
        )
        last_day = (
            min(until - timedelta(days=1), today) if is_current else until - timedelta(days=1)
        )
        moves: list[Movement] = []
        for t in templates:
            for d in occurrences(
                t.start_date, t.every_months, t.day_of_month, start, until, t.end_date
            ):
                amount = t.amount
                if t.amount_is_estimate:
                    amount = eur(-rng.uniform(38, 72))
                posted = d <= last_day
                moves.append(
                    Movement(
                        user_id=uid,
                        account_id=main.id,
                        cycle_id=cyc.id,
                        date=d if posted else None,
                        due_date=d,
                        kind=t.kind,
                        status="posted" if posted else "planned",
                        concept=t.concept,
                        amount=amount,
                        category_id=t.category_id,
                        source="recurring",
                        source_ref=t.id,
                        external_ref=f"rec:{t.id}:{d.isoformat()}",
                    )
                )
        span = (last_day - start).days
        for concept, cat, lo, hi, (kmin, kmax), p in VARIABLE:
            if rng.random() > p:
                continue
            times = rng.randint(kmin, kmax)
            if is_current:
                times = max(0, round(times * span / max((until - start).days, 1)))
            for _ in range(times):
                d = start + timedelta(days=rng.randint(0, max(span, 0)))
                moves.append(
                    Movement(
                        user_id=uid,
                        account_id=main.id,
                        cycle_id=cyc.id,
                        date=d,
                        kind="gasto",
                        status="posted",
                        concept=concept,
                        amount=eur(-rng.uniform(lo, hi)),
                        category_id=cats.get(cat),
                    )
                )
        if n in TRIPS and not is_current:
            flight, hotel = TRIPS[n]
            d = start + timedelta(days=12)
            moves += [
                Movement(
                    user_id=uid,
                    account_id=main.id,
                    cycle_id=cyc.id,
                    date=d,
                    kind="gasto",
                    status="posted",
                    concept=flight,
                    amount=eur(-rng.uniform(110, 190)),
                    category_id=cats.get("Viajes/Vuelos"),
                ),
                Movement(
                    user_id=uid,
                    account_id=main.id,
                    cycle_id=cyc.id,
                    date=d,
                    kind="gasto",
                    status="posted",
                    concept=hotel,
                    amount=eur(-rng.uniform(180, 260)),
                    category_id=cats.get("Viajes/Alojamiento"),
                ),
            ]
        db.add_all(moves)
        db.flush()
        # Los traspasos entre cuentas propias llevan su pareja en la cuenta de destino
        for m in moves:
            dest = to_account.get(m.concept)
            if dest is None or m.status != "posted":
                continue
            other = Movement(
                user_id=uid,
                account_id=dest.id,
                date=m.date,
                kind="transferencia",
                status="posted",
                concept=f"{m.concept} (desde {main.name})",
                amount=-m.amount,
                category_id=m.category_id,
                transfer_pair_id=m.id,
            )
            db.add(other)
            db.flush()
            m.transfer_pair_id = other.id
        db.flush()
        if not is_current:
            cyc.status, cyc.end_date = "closed", until
            key = key.next()
    db.flush()

    # Compra fraccionada: un portátil en 6 cuotas, con 3 ya pagadas (en sus ciclos)
    first_due = cal.cycle_start(cur_key.prev().prev().prev(), PAYDAY) + timedelta(days=5)
    plan = gsvc.create_installment_plan(
        db,
        uid,
        main,
        "Portátil",
        D(900),
        6,
        first_due,
        provider="tarjeta",
        merchant="Tienda Demo",
        category_id=cats.get("Compras online y hogar"),
        paid_seqs={1, 2, 3},
    )
    for inst in plan.installments:
        if inst.status != "pagada":
            continue
        label = cal.cycle_for_date(inst.due_date, PAYDAY).label
        cyc = db.scalar(select(PayCycle).where(PayCycle.user_id == uid, PayCycle.label == label))
        mv = Movement(
            user_id=uid,
            account_id=main.id,
            cycle_id=cyc.id if cyc else None,
            date=inst.due_date,
            kind="gasto",
            status="posted",
            concept=f"Portátil ({inst.seq}/6)",
            amount=-inst.amount,
            category_id=plan.category_id,
            source="installment",
            source_ref=plan.id,
        )
        db.add(mv)
        db.flush()
        inst.movement_id = mv.id
    # Las cuotas pagadas ya salieron de la cuenta: se corrige el arrastre de los ciclos siguientes
    _recompute_carried(db, uid, main)

    # --- Inversiones -------------------------------------------------------------------------
    classes = isvc.ensure_classes(db, uid)
    platforms = {
        "Broker": Platform(user_id=uid, name="Broker Demo", kind="broker", units_decimals=4),
        "Exchange": Platform(user_id=uid, name="Exchange Demo", kind="exchange", units_decimals=8),
    }
    db.add_all(platforms.values())
    db.flush()
    inv_start = since
    assets: dict[str, Asset] = {}
    for i, a in enumerate(ASSETS):
        asset = Asset(
            user_id=uid,
            name=a.name,
            type=a.type,
            asset_class_id=classes[a.klass].id,
            platform_id=platforms[a.platform].id,
            currency="EUR",
            price_provider="manual",
        )
        db.add(asset)
        db.flush()
        assets[a.name] = asset
        prices = _prices(random.Random(PRICE_SEED * 100 + i), a, inv_start, today)  # noqa: S311
        for d, p in prices.items():
            isvc.set_price(db, asset, d, p, "demo")
        q = D(a.decimals)
        # Una posición de partida en el fondo principal y después compras mensuales
        if a.name == "Fondo indexado mundial":
            d0, p0 = _price_on(prices, inv_start + timedelta(days=3))
            units = (D(3000) / p0).quantize(q)
            db.add(
                InvTransaction(
                    user_id=uid,
                    asset_id=asset.id,
                    kind="posicion_inicial",
                    trade_date=d0,
                    settle_date=d0,
                    amount_eur=D(3000),
                    units=units,
                    price=p0,
                    avg_cost=p0,
                )
            )
        month = inv_start.replace(day=1)
        while month <= today:
            day = month + timedelta(days=1)
            if inv_start < day <= today:
                d, p = _price_on(prices, day)
                db.add(
                    InvTransaction(
                        user_id=uid,
                        asset_id=asset.id,
                        kind="aportacion_periodica",
                        trade_date=d,
                        settle_date=d,
                        amount_eur=a.monthly,
                        units=(a.monthly / p).quantize(q),
                        price=p,
                    )
                )
            month = cal.add_months(month, 1)
    db.flush()
    for dim, weights in EXPOSURE.items():
        for k, w in weights.items():
            db.add(
                AssetExposure(
                    user_id=uid,
                    asset_id=assets["Fondo indexado mundial"].id,
                    dimension=dim,
                    key=k,
                    weight=D(w),
                    source="manual",
                    as_of=today,
                )
            )
    isvc.set_targets(
        db,
        uid,
        [
            MacroTargetIn(
                asset_class_id=classes["Fondos"].id, target=D("0.9"), min=D("0.85"), max=D("0.95")
            ),
            MacroTargetIn(
                asset_class_id=classes["Cripto"].id, target=D("0.1"), min=D("0.05"), max=D("0.15")
            ),
        ],
        [AssetTargetIn(asset_id=assets[a.name].id, target=a.target) for a in ASSETS],
        valid_from=inv_start,
    )
    nxt = cal.add_months(today.replace(day=1), 1) + timedelta(days=1)
    isvc.save_plan(
        db,
        ContributionPlan(
            user_id=uid,
            asset_id=assets["Fondo indexado mundial"].id,
            amount=D(225),
            every_months=1,
            day_of_month=2,
            start_date=nxt,
        ),
        None,
    )
    isvc.save_settings(db, uid, {"configured": True, "monthly_contribution": "340"})

    # --- Estados que las capturas tienen que poder enseñar -------------------------------------
    # Un cargo sin fecha y otro sin categoría en el ciclo actual, una compra pendiente de VL, un
    # activo en seguimiento (watchlist) y una venta (ganancia realizada en el Informe fiscal)
    cur = db.scalar(select(PayCycle).where(PayCycle.user_id == uid, PayCycle.status == "open"))
    if cur is not None:
        db.add_all(
            [
                Movement(
                    user_id=uid,
                    account_id=main.id,
                    cycle_id=cur.id,
                    kind="gasto",
                    status="posted",
                    concept="Mercadillo",
                    amount=D("-18.50"),
                    category_id=cats.get("Compras online y hogar"),
                ),
                Movement(
                    user_id=uid,
                    account_id=main.id,
                    cycle_id=cur.id,
                    date=today,
                    kind="gasto",
                    status="posted",
                    concept="Bizum cena",
                    amount=D("-22.00"),
                ),
            ]
        )
    world = assets["Fondo indexado mundial"]
    db.add(
        InvTransaction(
            user_id=uid,
            asset_id=world.id,
            kind="compra",
            status="pendiente_vl",
            trade_date=today,
            amount_eur=D(100),
        )
    )
    btc = assets["Bitcoin"]
    sold_on, sold_price = _price_on(
        _prices(random.Random(PRICE_SEED * 100 + 3), ASSETS[3], inv_start, today),  # noqa: S311
        today - timedelta(days=120),
    )
    db.add(
        InvTransaction(
            user_id=uid,
            asset_id=btc.id,
            kind="venta",
            trade_date=sold_on,
            settle_date=sold_on,
            amount_eur=(D("0.0015") * sold_price).quantize(D("0.01")),
            units=D("0.0015"),
            price=sold_price,
        )
    )
    small = Asset(
        user_id=uid,
        name="Fondo pequeñas empresas",
        type="fondo",
        asset_class_id=classes["Fondos"].id,
        platform_id=platforms["Broker"].id,
        currency="EUR",
        price_provider="manual",
        watchlist=True,
    )
    db.add(small)
    db.flush()
    for k in range(30, -1, -5):
        isvc.set_price(db, small, today - timedelta(days=k), D("14.20") + D(k) / D(50), "demo")

    # --- Planes ------------------------------------------------------------------------------
    psvc.save_settings(
        db,
        uid,
        {
            "configured": True,
            "target_age": 50,
            "monthly_spend": "2000",
            "swr": "0.035",
            "nominal_return": "0.07",
            "inflation": "0.025",
            "costs": "0.002",
            "include_taxes": True,
        },
    )
    db.add_all(
        [
            Goal(user_id=uid, kind="fondo_emergencia", name="Fondo de emergencia de 6 meses"),
            Goal(
                user_id=uid, kind="patrimonio", name="50.000 € de patrimonio", target_value=D(50000)
            ),
            Goal(
                user_id=uid,
                kind="fijos_max",
                name="Fijos por debajo de 1.000 €/mes",
                target_value=D(1000),
            ),
            Goal(
                user_id=uid,
                kind="tasa_ahorro_min",
                name="Ahorrar al menos el 20 %",
                target_value=D("0.2"),
            ),
        ]
    )
    db.flush()
    return user


def _recompute_carried(db: Session, uid, account: Account) -> None:  # type: ignore[no-untyped-def]
    """Arrastre de cada ciclo = el anterior + todo lo cargado en él (así no hay descuadres)."""
    cycles = db.scalars(
        select(PayCycle).where(PayCycle.user_id == uid).order_by(PayCycle.start_date)
    ).all()
    carried = account.opening_balance
    for c in cycles:
        c.carried_real = carried
        posted = db.scalars(
            select(Movement.amount).where(Movement.cycle_id == c.id, Movement.status == "posted")
        ).all()
        carried = carried + sum(posted, D(0))
    db.flush()


def main() -> None:
    from app.db import SessionLocal

    ap = argparse.ArgumentParser(prog="app.demo", description=__doc__)
    ap.add_argument("--email", default="demo@faro.example")
    ap.add_argument("--password-stdin", action="store_true", help="leer la contraseña de stdin")
    ap.add_argument("--reset", action="store_true", help="borrar el usuario demo si ya existe")
    args = ap.parse_args()
    if app_settings().env == "prod":
        sys.exit("Los datos demo no se pueden crear en producción")
    password = sys.stdin.readline().strip() if args.password_stdin else "demo-faro-2026"
    with SessionLocal() as db:
        existing = db.scalar(select(User).where(User.email == args.email))
        if existing is not None:
            if not args.reset:
                sys.exit(f"Ya existe {args.email} (usa --reset para regenerarlo)")
            db.execute(delete(User).where(User.id == existing.id))
            db.flush()
        u = seed(db, args.email, password)
        db.commit()
        print(f"Usuario demo listo: {u.email}")


if __name__ == "__main__":
    main()
