"""Patrimonio, rentabilidad y exposición (fase 4).

La serie diaria de la cartera se RECONSTRUYE a partir de las transacciones y del histórico de
precios (no de fotos guardadas): así una importación o una corrección se reflejan hacia atrás al
momento. Las fotos diarias del worker quedan como registro.

Flujos (dinero que entra o sale de la cartera desde fuera):
  · compra / aportación periódica: + importe + comisión
  · venta: − (importe − comisión)
  · posición inicial: + participaciones × PMP (capital que ya estaba)
  · traspaso: solo es flujo si se mira un activo o una categoría y el otro lado queda fuera
  · recompensas, dividendos e intereses que se quedan dentro: NO son flujo, son rentabilidad
"""

import uuid
from collections import defaultdict
from dataclasses import dataclass, field
from datetime import date, timedelta
from decimal import Decimal
from typing import Any

from sqlalchemy import select
from sqlalchemy.orm import Session

from app.domain import performance as perf
from app.domain.money import ZERO
from app.models import (
    Account,
    Asset,
    AssetExposure,
    Debt,
    InvTransaction,
    Platform,
    PositionCorrection,
    PriceHistory,
    TaxParameter,
)
from app.services import gastos as gsvc
from app.services import inversiones as inv

ONE = Decimal(1)
UNIT_IN = {"compra", "aportacion_periodica", "recompensa", "posicion_inicial", "traspaso_entrada"}
UNIT_OUT = {"venta", "traspaso_salida"}


# --- Serie diaria de la cartera ------------------------------------------------------------------
@dataclass
class Series:
    points: list[perf.Point]  # un punto por día con valor o flujo
    first: date | None
    contributed: Decimal  # suma de flujos
    # Valor de cada activo en los días pedidos (`per_asset_on`): para la evolución por componente
    by_asset: dict[date, dict[uuid.UUID, Decimal]] = field(default_factory=dict)


def portfolio_series(
    db: Session,
    user_id: uuid.UUID,
    asset_ids: set[uuid.UUID] | None = None,
    until: date | None = None,
    per_asset_on: set[date] | None = None,
) -> Series:
    until = until or date.today()
    assets = {a.id: a for a in inv.assets(db, user_id, include_archived=True) if not a.watchlist}
    scope = set(assets) if asset_ids is None else (asset_ids & set(assets))
    txs = list(
        db.scalars(
            select(InvTransaction)
            .where(
                InvTransaction.user_id == user_id,
                InvTransaction.status == "liquidada",
                InvTransaction.asset_id.in_(scope),
            )
            .order_by(InvTransaction.trade_date, InvTransaction.created_at)
        )
    )
    if not txs:
        return Series([], None, ZERO)
    corrections = list(
        db.scalars(
            select(PositionCorrection).where(
                PositionCorrection.user_id == user_id, PositionCorrection.asset_id.in_(scope)
            )
        )
    )
    pair_asset = {
        t.id: t.asset_id
        for t in db.scalars(
            select(InvTransaction).where(
                InvTransaction.user_id == user_id,
                InvTransaction.kind.in_(("traspaso_entrada", "traspaso_salida")),
            )
        )
    }

    # Precios: histórico + precio de cada operación (sirve hasta que haya histórico)
    prices: dict[uuid.UUID, dict[date, Decimal]] = defaultdict(dict)
    for p in db.scalars(
        select(PriceHistory).where(
            PriceHistory.user_id == user_id, PriceHistory.asset_id.in_(scope)
        )
    ):
        prices[p.asset_id][p.date] = p.price
    for t in txs:
        px = t.avg_cost if t.kind == "posicion_inicial" else t.price
        if px and t.trade_date not in prices[t.asset_id]:
            prices[t.asset_id][t.trade_date] = px

    by_day: dict[date, list[InvTransaction]] = defaultdict(list)
    for t in txs:
        by_day[t.trade_date].append(t)
    corr_by_day: dict[date, list[PositionCorrection]] = defaultdict(list)
    for c in corrections:
        corr_by_day[c.effective_date].append(c)
    price_days = {aid: sorted(d.items()) for aid, d in prices.items()}
    cursor = {aid: 0 for aid in price_days}
    last_price: dict[uuid.UUID, Decimal] = {}

    units: dict[uuid.UUID, Decimal] = defaultdict(lambda: ZERO)
    by_asset: dict[date, dict[uuid.UUID, Decimal]] = {}
    first = txs[0].trade_date
    points: list[perf.Point] = []
    contributed = ZERO
    day = first
    while day <= until:
        flow = ZERO
        for t in by_day.get(day, []):
            u = t.units or ZERO
            if t.kind in UNIT_IN:
                units[t.asset_id] += u
            elif t.kind in UNIT_OUT:
                units[t.asset_id] -= u
            if t.kind in ("compra", "aportacion_periodica"):
                flow += t.amount_eur + t.fee
            elif t.kind == "venta":
                flow -= t.amount_eur - t.fee
            elif t.kind == "posicion_inicial":
                flow += u * (t.avg_cost or ZERO)
            elif t.kind in ("traspaso_entrada", "traspaso_salida"):
                other = pair_asset.get(t.pair_id) if t.pair_id else None
                if other not in scope:  # el otro lado queda fuera de lo que se mira
                    flow += t.amount_eur if t.kind == "traspaso_entrada" else -t.amount_eur
        for c in corr_by_day.get(day, []):
            units[c.asset_id] = c.units_after
        for aid, rows in price_days.items():
            i = cursor[aid]
            while i < len(rows) and rows[i][0] <= day:
                last_price[aid] = rows[i][1]
                i += 1
            cursor[aid] = i
        value = sum((u * last_price.get(aid, ZERO) for aid, u in units.items() if u), ZERO)
        if per_asset_on and day in per_asset_on:
            by_asset[day] = {aid: u * last_price.get(aid, ZERO) for aid, u in units.items() if u}
        contributed += flow
        points.append(perf.Point(day, value, flow))
        day += timedelta(days=1)
    return Series(points, first, contributed, by_asset)


# --- Inicio del seguimiento --------------------------------------------------------------------
@dataclass
class Before:
    """Resumen de lo anterior al inicio del seguimiento."""

    until: date  # último día antes del inicio
    contributed: Decimal  # aportado neto hasta entonces
    value: Decimal  # lo que valía ese día (capital de partida del seguimiento)


def track_start(db: Session, user_id: uuid.UUID) -> date | None:
    v = inv.get_settings(db, user_id).get("track_start")
    return date.fromisoformat(v) if v else None


def rebase(s: Series, start: date | None) -> tuple[Series, Before | None]:
    """Recorta la serie al inicio del seguimiento: lo que valía la víspera entra como aportación
    de partida, así la rentabilidad empieza de cero ese día y no hay meses vacíos antes."""
    if start is None or s.first is None or s.first >= start:
        return s, None
    before = [p for p in s.points if p.on < start]
    after = [p for p in s.points if p.on >= start]
    eve = start - timedelta(days=1)
    v0 = before[-1].value
    summary = Before(eve, sum((p.flow for p in before), ZERO), v0)
    if not after:  # inicio en el futuro: todavía no hay seguimiento
        return Series([], None, ZERO), summary
    points = [perf.Point(eve, v0, v0), *after]
    return Series(points, start, v0 + sum((p.flow for p in after), ZERO)), summary


# --- Rentabilidad ---------------------------------------------------------------------------------
@dataclass
class Performance:
    first: date | None
    days: int
    value: Decimal
    contributed: Decimal
    gain: Decimal
    twr: Decimal | None
    twr_annual: Decimal | None
    ytd: Decimal | None
    xirr: Decimal | None
    max_drawdown: Decimal | None
    volatility: Decimal | None
    best: perf.MonthRow | None
    worst: perf.MonthRow | None
    positive_months: int
    negative_months: int
    months: list[perf.MonthRow]
    weekly: list[tuple[date, Decimal, Decimal]]  # (día, valor, aportado acumulado)
    before: Before | None = None  # lo anterior al inicio del seguimiento, resumido


def performance(
    db: Session, user_id: uuid.UUID, asset_ids: set[uuid.UUID] | None = None
) -> Performance:
    start = track_start(db, user_id)
    s, before = rebase(portfolio_series(db, user_id, asset_ids), start)
    if not s.points:
        return Performance(
            None,
            0,
            ZERO,
            ZERO,
            ZERO,
            None,
            None,
            None,
            None,
            None,
            None,
            None,
            None,
            0,
            0,
            [],
            [],
            before,
        )
    today = s.points[-1].on
    months = perf.monthly(s.points)
    if before is not None:  # el mes de la víspera solo lleva el capital de partida
        months = [m for m in months if (m.year, m.month) >= (s.first.year, s.first.month)]
    rets = [m.ret for m in months if m.ret is not None]
    twr = perf.chain(rets) if rets else None
    days = (today - s.first).days if s.first else 0
    ytd_rets = [m.ret for m in months if m.ret is not None and m.year == today.year]
    index = [i for _, i, _ in perf.daily_index(s.points)]
    flows = [perf.Flow(p.on, -p.flow) for p in s.points if p.flow]
    flows.append(perf.Flow(today, s.points[-1].value))
    with_ret = [m for m in months if m.ret is not None]
    best = max(with_ret, key=lambda m: m.ret or ZERO) if with_ret else None
    worst = min(with_ret, key=lambda m: m.ret or ZERO) if with_ret else None
    contributed = ZERO
    weekly = []
    for i, p in enumerate(s.points):
        contributed += p.flow
        if p.on.weekday() == 6 or i == len(s.points) - 1 or p.flow:
            weekly.append((p.on, p.value, contributed))
    value = s.points[-1].value
    return Performance(
        s.first,
        days,
        value,
        s.contributed,
        value - s.contributed,
        twr,
        perf.annualize(twr, days) if twr is not None else None,
        perf.chain(ytd_rets) if ytd_rets else None,
        perf.xirr(flows) if days >= 30 else None,
        perf.max_drawdown(index),
        perf.volatility(rets),
        best,
        worst,
        sum(1 for r in rets if r > 0),
        sum(1 for r in rets if r < 0),
        months,
        weekly,
        before,
    )


# --- Patrimonio neto ------------------------------------------------------------------------------
def tax_parameter(
    db: Session, user_id: uuid.UUID, key: str, on: date | None = None, region: str = "ES"
) -> TaxParameter | None:
    """El del año más reciente que no sea posterior al pedido (override del usuario primero)."""
    year = (on or date.today()).year
    rows = db.scalars(
        select(TaxParameter)
        .where(
            TaxParameter.key == key,
            TaxParameter.region == region,
            TaxParameter.year <= year,
            (TaxParameter.user_id == user_id) | TaxParameter.user_id.is_(None),
        )
        .order_by(TaxParameter.year.desc(), TaxParameter.user_id.is_(None))
    ).all()
    return rows[0] if rows else None


def savings_tax(base: Decimal, scale: dict[str, Any]) -> Decimal:
    """Cuota de la base del ahorro por tramos.

    `scale` = {"tramos": [{"hasta": "6000", "tipo": "0.19"}, …, {"hasta": None, "tipo": …}]}
    """
    if base <= 0:
        return ZERO
    tax, prev = ZERO, ZERO
    for t in scale["tramos"]:
        top = Decimal(t["hasta"]) if t["hasta"] is not None else None
        chunk = (min(base, top) if top is not None else base) - prev
        if chunk <= 0:
            break
        tax += chunk * Decimal(t["tipo"])
        if top is None or base <= top:
            break
        prev = top
    return tax


@dataclass
class NetWorth:
    total: Decimal
    accounts: list[tuple[Account, Decimal]]
    investments: Decimal
    pending: Decimal  # aportaciones pendientes de VL (dinero en tránsito)
    by_type: dict[str, Decimal]  # fondo | etf | cripto | accion | …
    debts: Decimal
    installments: Decimal
    receivable: Decimal  # préstamos que me deben
    unrealized_gain: Decimal  # según FIFO (coste fiscal)
    tax_if_sold: Decimal | None
    after_tax: Decimal | None
    tax_source: str | None
    tax_year: int | None
    by_kind: dict[str, Decimal] = field(default_factory=dict)


def networth(db: Session, user_id: uuid.UUID) -> NetWorth:
    accounts = [
        (a, gsvc.account_balance(db, a))
        for a in db.scalars(
            select(Account)
            .where(Account.user_id == user_id, Account.archived.is_(False))
            .order_by(Account.sort)
        )
    ]
    p = inv.portfolio(db, user_id)
    by_type: dict[str, Decimal] = defaultdict(lambda: ZERO)
    gain = ZERO
    for r in p.rows:
        by_type[r.asset.type] += r.value
        if r.position.units > 0:
            gain += r.value - r.position.cost_fifo
    debts, receivable = _debts(db, user_id)
    inst = gsvc.live_installment_debt(db, user_id)
    acc_total = sum((b for _, b in accounts), ZERO)
    total = acc_total + p.value + p.pending + receivable - debts - inst
    param = tax_parameter(db, user_id, "ahorro_escala")
    tax = savings_tax(gain, param.value) if param is not None else None
    by_kind: dict[str, Decimal] = defaultdict(lambda: ZERO)
    for a, b in accounts:
        by_kind[a.kind] += b
    return NetWorth(
        total,
        accounts,
        p.value,
        p.pending,
        dict(by_type),
        debts,
        inst,
        receivable,
        gain,
        tax,
        (total - tax) if tax is not None else None,
        param.source_url if param else None,
        param.year if param else None,
        dict(by_kind),
    )


def _debts(db: Session, user_id: uuid.UUID) -> tuple[Decimal, Decimal]:
    """(lo que debo, lo que me deben) en préstamos vivos."""
    from app.services import gastos_extra as ex

    owe, owed = ZERO, ZERO
    for d in db.scalars(select(Debt).where(Debt.user_id == user_id)):
        rem, _ = ex.debt_remaining(db, d)
        if rem > 0:
            if d.direction == "debo":
                owe += rem
            else:
                owed += rem
    return owe, owed


def networth_history(db: Session, user_id: uuid.UUID) -> list[tuple[date, Decimal, Decimal]]:
    """(día, cuentas, inversiones): la serie reconstruida de `services.networth` (D9)."""
    from app.services import networth as nw  # importa este módulo

    return [(p.on, p.accounts, p.investments) for p in nw.history(db, user_id).points]


# --- Exposición -----------------------------------------------------------------------------------
DIMENSIONS = ("tipo", "plataforma", "sector", "region", "pais", "divisa")


def exposure(db: Session, user_id: uuid.UUID) -> dict[str, list[tuple[str, Decimal, Decimal]]]:
    """Por dimensión: [(clave, peso, valor)], ponderado por el valor de cada posición. Lo que no
    tiene composición conocida sale como "Sin datos" (nunca se inventa)."""
    p = inv.portfolio(db, user_id)
    rows = [r for r in p.rows if r.value > 0]
    total = sum((r.value for r in rows), ZERO)
    if total == 0:
        return {d: [] for d in DIMENSIONS}
    platforms = {
        x.id: x.name for x in db.scalars(select(Platform).where(Platform.user_id == user_id))
    }
    expo: dict[uuid.UUID, dict[str, list[AssetExposure]]] = defaultdict(lambda: defaultdict(list))
    for e in db.scalars(select(AssetExposure).where(AssetExposure.user_id == user_id)):
        expo[e.asset_id][e.dimension].append(e)
    acc: dict[str, dict[str, Decimal]] = {d: defaultdict(lambda: ZERO) for d in DIMENSIONS}
    types = {
        "fondo": "Fondos",
        "etf": "ETF",
        "accion": "Acciones",
        "cripto": "Cripto",
        "cuenta": "Cuentas",
        "otro": "Otros",
    }
    for r in rows:
        a: Asset = r.asset
        acc["tipo"][types.get(a.type, a.type)] += r.value
        acc["plataforma"][
            platforms.get(a.platform_id, "Sin plataforma") if a.platform_id else "Sin plataforma"
        ] += r.value
        acc["divisa"][a.currency] += r.value
        for dim in ("sector", "region", "pais"):
            items = expo[a.id][dim]
            manual = [e for e in items if e.source == "manual"]
            items = manual or items
            if items:
                known = sum((e.weight for e in items), ZERO)
                for e in items:
                    acc[dim][e.key] += r.value * e.weight
                if known < ONE:
                    acc[dim]["Sin datos" if dim != "sector" else "Otros / sin datos"] += r.value * (
                        ONE - known
                    )
            elif a.type == "cripto":
                acc[dim]["Cripto" if dim == "sector" else "Global (cripto)"] += r.value
            elif a.type == "accion" and dim == "sector" and a.sector:
                acc[dim][a.sector] += r.value
            elif a.type == "accion" and dim == "pais" and a.country:
                acc[dim][a.country] += r.value
            else:
                acc[dim]["Sin datos"] += r.value
    return {
        d: sorted(((k, v / total, v) for k, v in vals.items() if v > 0), key=lambda x: -x[1])
        for d, vals in acc.items()
    }


def refresh_exposures(
    db: Session, client: Any, user_id: uuid.UUID | None = None
) -> tuple[int, list[str]]:
    """Composición automática de los fondos desde FT. Las filas manuales no se tocan."""
    from app.services import prices as px

    q = select(Asset).where(Asset.type.in_(("fondo", "etf")), Asset.archived.is_(False))
    if user_id is not None:
        q = q.where(Asset.user_id == user_id)
    n, errors = 0, []
    for a in db.scalars(q).all():
        ref = a.price_ref or (f"{a.isin}:{a.currency}" if a.isin else None)
        if not ref:
            continue
        try:
            items = px.ft_exposure(client, ref)
        except (px.PriceError, Exception) as e:
            errors.append(f"{a.name}: {e}")
            continue
        for old in db.scalars(
            select(AssetExposure).where(
                AssetExposure.asset_id == a.id, AssetExposure.source == "auto"
            )
        ):
            db.delete(old)
        db.flush()
        for e in items:
            db.add(
                AssetExposure(
                    user_id=a.user_id,
                    asset_id=a.id,
                    dimension=e.dimension,
                    key=e.key,
                    weight=e.weight,
                    source="auto",
                    as_of=e.as_of,
                )
            )
        n += 1
    db.flush()
    return n, errors


def backfill_prices(
    db: Session, client: Any, user_id: uuid.UUID | None = None
) -> tuple[int, list[str]]:
    """Histórico de precios desde la primera operación de cada activo (sin pisar lo que ya hay)."""
    from datetime import UTC, datetime

    from app.services import prices as px

    q = select(Asset).where(Asset.archived.is_(False), Asset.price_provider != "manual")
    if user_id is not None:
        q = q.where(Asset.user_id == user_id)
    added, errors = 0, []
    today = date.today()
    for a in db.scalars(q).all():
        first = db.scalar(
            select(InvTransaction.trade_date)
            .where(InvTransaction.asset_id == a.id)
            .order_by(InvTransaction.trade_date)
            .limit(1)
        )
        if first is None:
            continue
        have = set(db.scalars(select(PriceHistory.date).where(PriceHistory.asset_id == a.id)))
        try:
            if a.price_provider == "ft":
                ref = a.price_ref or f"{a.isin}:{a.currency}"
                hist = px.ft_history(client, ref, first - timedelta(days=7), today)
                source = "ft"
            elif a.price_provider == "coingecko" and a.coingecko_id:
                hist = px.coingecko_history(
                    client, a.coingecko_id, (today - first).days + 2, a.currency
                )
                source = "coingecko"
            else:
                continue
        except (px.PriceError, Exception) as e:
            errors.append(f"{a.name}: {e}")
            continue
        now = datetime.now(UTC)
        for d, price in hist:
            if d not in have and price > 0:
                db.add(
                    PriceHistory(
                        user_id=a.user_id,
                        asset_id=a.id,
                        date=d,
                        price=price,
                        currency=a.currency,
                        source=source,
                        fetched_at=now,
                    )
                )
                added += 1
    db.flush()
    return added, errors
