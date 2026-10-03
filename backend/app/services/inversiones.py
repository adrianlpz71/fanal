"""Servicios de inversiones. Toda consulta filtra por user_id.

La posición de cada activo se calcula repitiendo sus transacciones liquidadas más las
correcciones manuales (`app.domain.portfolio`). Las aportaciones pendientes de VL cuentan en el
motor de aportaciones (para no repartir dos veces el mismo dinero), pero no en la posición.
"""

import hashlib
import uuid
from dataclasses import dataclass, field
from datetime import UTC, date, datetime, timedelta
from decimal import Decimal
from typing import Any

from fastapi import HTTPException, status
from sqlalchemy import func, select
from sqlalchemy.orm import Session

from app.domain import allocation as al
from app.domain.money import ZERO, q2
from app.domain.portfolio import Lot, Position, Tx, lots_for_transfer, qunits, replay
from app.domain.recurring import occurrences
from app.models import (
    Account,
    AllocationTarget,
    Asset,
    AssetClass,
    AuditLog,
    ContributionPlan,
    InvTransaction,
    Movement,
    Platform,
    PortfolioSnapshot,
    PositionCorrection,
    PriceHistory,
    RecurringTemplate,
    UserSetting,
)
from app.services import gastos as gsvc

SETTINGS_KEY = "inversiones"
DEFAULT_SETTINGS: dict[str, Any] = {
    "configured": False,
    "min_operation": "0",  # importe mínimo por orden en el motor de aportaciones
    "monthly_contribution": None,  # aportación mensual habitual (str decimal)
    # Inicio del seguimiento (ISO): la rentabilidad y las gráficas empiezan aquí; lo anterior se
    # resume en un bloque. Las operaciones no se tocan (lotes y fechas para Hacienda intactos).
    "track_start": None,
}
DEFAULT_CLASSES = (("Fondos", Decimal(1)), ("Cripto", Decimal(2)), ("Acciones", Decimal(2)))
# Días sin precio nuevo a partir de los cuales se avisa (los fondos publican VL en días hábiles)
STALE_DAYS = {"cripto": 2, "fondo": 5, "etf": 5, "accion": 5}


def bad(msg: str, code: int = status.HTTP_422_UNPROCESSABLE_ENTITY) -> HTTPException:
    return HTTPException(code, msg)


# --- Ajustes y catálogo ---------------------------------------------------------------------
def get_settings(db: Session, user_id: uuid.UUID) -> dict[str, Any]:
    row = db.scalar(
        select(UserSetting).where(UserSetting.user_id == user_id, UserSetting.key == SETTINGS_KEY)
    )
    return {**DEFAULT_SETTINGS, **(row.value if row else {})}


def save_settings(db: Session, user_id: uuid.UUID, values: dict[str, Any]) -> dict[str, Any]:
    row = db.scalar(
        select(UserSetting).where(UserSetting.user_id == user_id, UserSetting.key == SETTINGS_KEY)
    )
    merged = {**DEFAULT_SETTINGS, **(row.value if row else {}), **values}
    clean = {k: (str(v) if isinstance(v, Decimal | uuid.UUID) else v) for k, v in merged.items()}
    if row:
        row.value = clean
    else:
        db.add(UserSetting(user_id=user_id, key=SETTINGS_KEY, value=clean))
    db.flush()
    return clean


def ensure_classes(db: Session, user_id: uuid.UUID) -> dict[str, AssetClass]:
    rows = db.scalars(select(AssetClass).where(AssetClass.user_id == user_id)).all()
    if not rows:
        rows = [
            AssetClass(user_id=user_id, name=n, default_tolerance_pp=tol, sort=i)
            for i, (n, tol) in enumerate(DEFAULT_CLASSES)
        ]
        db.add_all(rows)
        db.flush()
    return {c.name: c for c in rows}


def classes(db: Session, user_id: uuid.UUID) -> list[AssetClass]:
    return list(
        db.scalars(
            select(AssetClass)
            .where(AssetClass.user_id == user_id)
            .order_by(AssetClass.sort, AssetClass.name)
        )
    )


def assets(db: Session, user_id: uuid.UUID, include_archived: bool = False) -> list[Asset]:
    q = select(Asset).where(Asset.user_id == user_id)
    if not include_archived:
        q = q.where(Asset.archived.is_(False))
    return list(db.scalars(q.order_by(Asset.name)))


def units_decimals(db: Session, asset: Asset) -> int:
    if asset.units_decimals is not None:
        return asset.units_decimals
    if asset.platform_id and (p := db.get(Platform, asset.platform_id)):
        return p.units_decimals
    return 8 if asset.type == "cripto" else 4


# --- Posición ---------------------------------------------------------------------------------
def _txs(db: Session, asset: Asset, exclude: uuid.UUID | set[uuid.UUID] | None = None) -> list[Tx]:
    rows = db.scalars(
        select(InvTransaction)
        .where(
            InvTransaction.user_id == asset.user_id,
            InvTransaction.asset_id == asset.id,
            InvTransaction.status == "liquidada",
        )
        .order_by(InvTransaction.trade_date, InvTransaction.created_at)
    ).all()
    corrections = db.scalars(
        select(PositionCorrection)
        .where(PositionCorrection.user_id == asset.user_id, PositionCorrection.asset_id == asset.id)
        .order_by(PositionCorrection.effective_date, PositionCorrection.created_at)
    ).all()
    events: list[tuple[date, datetime, Tx]] = []
    for t in rows:
        if t.id == exclude or (isinstance(exclude, set) and t.id in exclude):
            continue
        lots: tuple[Lot, ...] = ()
        if t.kind == "traspaso_entrada" and t.pair_id:
            lots = tuple(_transfer_lots(db, t))
        events.append((t.trade_date, t.created_at, Tx(
            t.kind, t.trade_date, units=t.units or ZERO, amount=t.amount_eur, fee=t.fee,
            avg_cost=t.avg_cost, lots=lots,
        )))  # fmt: skip
    for c in corrections:
        events.append((c.effective_date, c.created_at, Tx(
            "correccion", c.effective_date, units=c.units_after, avg_cost=c.avg_cost_after,
        )))  # fmt: skip
    events.sort(key=lambda e: (e[0], e[1]))
    return [e[2] for e in events]


def _transfer_lots(db: Session, entrada: InvTransaction) -> list[Lot]:
    """Lotes que llegan con un traspaso: los FIFO del fondo de origen en la fecha de salida."""
    salida = db.get(InvTransaction, entrada.pair_id)
    if salida is None or salida.user_id != entrada.user_id:
        return []
    src = db.get(Asset, salida.asset_id)
    if src is None:
        return []
    before = replay([t for t in _txs(db, src, exclude=salida.id) if t.on <= salida.trade_date])
    return lots_for_transfer(before, salida.units or ZERO)


def position(db: Session, asset: Asset) -> Position:
    return replay(_txs(db, asset))


def latest_price(db: Session, asset: Asset) -> PriceHistory | None:
    return db.scalar(
        select(PriceHistory)
        .where(PriceHistory.user_id == asset.user_id, PriceHistory.asset_id == asset.id)
        .order_by(PriceHistory.date.desc())
        .limit(1)
    )


def set_price(
    db: Session, asset: Asset, on: date, price: Decimal, source: str, currency: str = "EUR"
) -> PriceHistory:
    row = db.scalar(
        select(PriceHistory).where(PriceHistory.asset_id == asset.id, PriceHistory.date == on)
    )
    if row is None:
        row = PriceHistory(user_id=asset.user_id, asset_id=asset.id, date=on)
        db.add(row)
    row.price, row.source, row.currency = price, source, currency
    row.fetched_at = datetime.now(UTC)
    db.flush()
    return row


def pending_amount(db: Session, asset: Asset) -> Decimal:
    total = db.scalar(
        select(func.coalesce(func.sum(InvTransaction.amount_eur), 0)).where(
            InvTransaction.user_id == asset.user_id,
            InvTransaction.asset_id == asset.id,
            InvTransaction.status == "pendiente_vl",
        )
    )
    return Decimal(total)


# --- Objetivos ---------------------------------------------------------------------------------
def current_targets(
    db: Session, user_id: uuid.UUID, on: date | None = None
) -> tuple[dict[uuid.UUID, AllocationTarget], dict[uuid.UUID, AllocationTarget]]:
    """Objetivo vigente (el último con valid_from <= hoy) por categoría y por activo."""
    on = on or date.today()
    rows = db.scalars(
        select(AllocationTarget)
        .where(AllocationTarget.user_id == user_id, AllocationTarget.valid_from <= on)
        .order_by(AllocationTarget.valid_from, AllocationTarget.created_at)
    ).all()
    macro: dict[uuid.UUID, AllocationTarget] = {}
    inner: dict[uuid.UUID, AllocationTarget] = {}
    for r in rows:  # los posteriores pisan a los anteriores
        if r.level == "macro" and r.asset_class_id:
            macro[r.asset_class_id] = r
        elif r.level == "asset" and r.asset_id:
            inner[r.asset_id] = r
    return macro, inner


@dataclass
class MacroTargetIn:
    asset_class_id: uuid.UUID
    target: Decimal
    min: Decimal | None = None
    max: Decimal | None = None
    tolerance_pp: Decimal | None = None


@dataclass
class AssetTargetIn:
    asset_id: uuid.UUID
    target: Decimal


def set_targets(
    db: Session,
    user_id: uuid.UUID,
    macro: list[MacroTargetIn],
    inner: list[AssetTargetIn],
    valid_from: date | None = None,
) -> None:
    """Guarda una versión nueva de los objetivos (el historial se conserva)."""
    valid_from = valid_from or date.today()
    by_id = {c.id: c for c in classes(db, user_id)}
    if macro:
        if any(m.asset_class_id not in by_id for m in macro):
            raise gsvc.not_found("Categoría")
        if sum((m.target for m in macro), ZERO) != Decimal(1):
            raise bad("Los objetivos macro deben sumar 100 %")
        for m in macro:
            lo, hi = (
                m.min if m.min is not None else m.target,
                m.max if m.max is not None else m.target,
            )
            if not (ZERO <= lo <= m.target <= hi <= Decimal(1)):
                raise bad(f"{by_id[m.asset_class_id].name}: debe cumplirse mín ≤ objetivo ≤ máx")
            db.add(AllocationTarget(
                user_id=user_id, level="macro", asset_class_id=m.asset_class_id,
                target_pct=m.target, min_pct=lo, max_pct=hi, tolerance_pp=m.tolerance_pp,
                valid_from=valid_from,
            ))  # fmt: skip
    if inner:
        owned = {a.id: a for a in assets(db, user_id, include_archived=True)}
        if any(t.asset_id not in owned for t in inner):
            raise gsvc.not_found("Activo")
        per_class: dict[uuid.UUID | None, Decimal] = {}
        for t in inner:
            cid = owned[t.asset_id].asset_class_id
            per_class[cid] = per_class.get(cid, ZERO) + t.target
        for cid, total in per_class.items():
            if total not in (ZERO, Decimal(1)):
                name = by_id[cid].name if cid in by_id else "Sin categoría"
                raise bad(f"Los objetivos dentro de {name} deben sumar 100 %")
        for t in inner:
            db.add(AllocationTarget(
                user_id=user_id, level="asset", asset_id=t.asset_id, target_pct=t.target,
                valid_from=valid_from,
            ))  # fmt: skip
    db.flush()


# --- Cartera ------------------------------------------------------------------------------------
@dataclass
class AssetRow:
    asset: Asset
    position: Position
    price: Decimal | None
    price_date: date | None
    price_source: str | None
    stale: bool
    value: Decimal
    cost: Decimal
    pnl: Decimal
    pnl_pct: Decimal | None
    pending: Decimal
    inner_weight: Decimal = ZERO
    inner_target: Decimal | None = None
    inner_status: str | None = None


@dataclass
class ClassRow:
    cls: AssetClass
    value: Decimal
    pending: Decimal
    weight: Decimal
    target: Decimal | None
    min: Decimal | None
    max: Decimal | None
    tolerance_pp: Decimal
    status: str | None
    assets: list[AssetRow] = field(default_factory=list)


@dataclass
class Portfolio:
    rows: list[AssetRow]
    classes: list[ClassRow]
    value: Decimal
    cost: Decimal
    pnl: Decimal
    pnl_pct: Decimal | None
    pending: Decimal
    stale: int
    emergency: al.EmergencyFund | None


def asset_row(db: Session, a: Asset, today: date | None = None) -> AssetRow:
    today = today or date.today()
    pos = position(db, a)
    lp = latest_price(db, a)
    price = lp.price if lp else None
    held = pos.units > 0
    stale = bool(held and (lp is None or (today - lp.date).days > STALE_DAYS.get(a.type, 5)))
    value = pos.units * price if price is not None else pos.cost
    pnl = value - pos.cost
    return AssetRow(
        a, pos, price, lp.date if lp else None, lp.source if lp else None, stale, value,
        pos.cost, pnl, (pnl / pos.cost) if pos.cost else None, pending_amount(db, a),
    )  # fmt: skip


def emergency(db: Session, user_id: uuid.UUID) -> al.EmergencyFund | None:
    s = gsvc.get_settings(db, user_id)
    if not s.get("emergency_target") or not s.get("refugio_account_id"):
        return None
    acc = db.get(Account, uuid.UUID(str(s["refugio_account_id"])))
    if acc is None or acc.user_id != user_id:
        return None
    monthly = Decimal(s["monthly_refugio"]) if s.get("monthly_refugio") else None
    return al.emergency_fund(Decimal(s["emergency_target"]), gsvc.account_balance(db, acc),
                             monthly_contribution=monthly)  # fmt: skip


def portfolio(db: Session, user_id: uuid.UUID) -> Portfolio:
    macro_t, inner_t = current_targets(db, user_id)
    rows = [asset_row(db, a) for a in assets(db, user_id) if not a.watchlist]
    total = sum((r.value for r in rows), ZERO)
    cls_rows: list[ClassRow] = []
    for c in classes(db, user_id):
        mine = [r for r in rows if r.asset.asset_class_id == c.id]
        value = sum((r.value for r in mine), ZERO)
        t = macro_t.get(c.id)
        weight = value / total if total else ZERO
        st = al.macro_status(weight, t.min_pct, t.max_pct) if t and total else None
        tol = t.tolerance_pp if t and t.tolerance_pp is not None else c.default_tolerance_pp
        for r in mine:
            r.inner_weight = r.value / value if value else ZERO
            it = inner_t.get(r.asset.id)
            r.inner_target = it.target_pct if it else None
            if it and value:
                r.inner_status = al.internal_status(r.inner_weight, it.target_pct, tol)
        cls_rows.append(ClassRow(
            c, value, sum((r.pending for r in mine), ZERO), weight,
            t.target_pct if t else None, t.min_pct if t else None, t.max_pct if t else None,
            tol, st, mine,
        ))  # fmt: skip
    cost = sum((r.cost for r in rows), ZERO)
    return Portfolio(
        rows, cls_rows, total, cost, total - cost, ((total - cost) / cost) if cost else None,
        sum((r.pending for r in rows), ZERO), sum(1 for r in rows if r.stale),
        emergency(db, user_id),
    )  # fmt: skip


# --- Motor de aportaciones ---------------------------------------------------------------------
@dataclass
class Order:
    asset: Asset
    amount: Decimal
    price: Decimal | None
    approx_units: Decimal | None


@dataclass
class Suggestion:
    amount: Decimal
    by_class: dict[uuid.UUID, Decimal]
    orders: list[Order]
    unassigned: Decimal  # categorías con objetivo pero sin activos con objetivo


def suggest(
    db: Session, user_id: uuid.UUID, amount: Decimal, round_to: Decimal | None = None
) -> Suggestion:
    if amount <= 0:
        raise bad("El importe debe ser positivo")
    p = portfolio(db, user_id)
    macro_t, inner_t = current_targets(db, user_id)
    if not macro_t:
        raise bad("Define antes los objetivos de la cartera", status.HTTP_409_CONFLICT)
    min_op = Decimal(get_settings(db, user_id)["min_operation"] or 0)
    macro_items, inner_items = [], {}
    rows_by_asset: dict[uuid.UUID, AssetRow] = {}
    for c in p.classes:
        if c.cls.id not in macro_t:
            continue
        key = str(c.cls.id)
        # Lo pendiente de VL ya está "comprado": cuenta para no repartirlo dos veces
        macro_items.append(al.Item(key, c.value + c.pending, macro_t[c.cls.id].target_pct))
        inner_items[key] = []
        for r in c.assets:
            rows_by_asset[r.asset.id] = r
            if r.asset.id in inner_t:
                inner_items[key].append(
                    al.Item(str(r.asset.id), r.value + r.pending, inner_t[r.asset.id].target_pct)
                )
        # Activos con objetivo pero sin posición (aún no comprados)
        for a in assets(db, user_id):
            if a.asset_class_id == c.cls.id and a.id in inner_t and a.id not in rows_by_asset:
                rows_by_asset[a.id] = asset_row(db, a)
                inner_items[key].append(al.Item(str(a.id), ZERO, inner_t[a.id].target_pct))
    top, per = al.cascade(amount, macro_items, inner_items, min_op, round_to or al.CENT)
    unassigned = sum((v for k, v in top.items() if not inner_items.get(k)), ZERO)
    orders = []
    for _cls_key, split in per.items():
        for aid, amt in split.items():
            if amt <= 0:
                continue
            r = rows_by_asset[uuid.UUID(aid)]
            approx = qunits(amt / r.price, units_decimals(db, r.asset)) if r.price else None
            orders.append(Order(r.asset, amt, r.price, approx))
    orders.sort(key=lambda o: -o.amount)
    return Suggestion(amount, {uuid.UUID(k): v for k, v in top.items()}, orders, unassigned)


def create_orders(
    db: Session,
    user_id: uuid.UUID,
    orders: list[tuple[uuid.UUID, Decimal]],
    trade_date: date,
    from_account_id: uuid.UUID | None = None,
) -> list[InvTransaction]:
    """'Generar órdenes': una compra pendiente de VL por activo. Si se indica la cuenta de
    gastos de origen, se anota además la transferencia (prevista) para que cuadre el ciclo."""
    out: list[InvTransaction] = []
    total = ZERO
    for aid, amount in orders:
        a = gsvc.get_owned(db, Asset, aid, user_id)
        if amount <= 0:
            continue
        tx = InvTransaction(
            user_id=user_id, asset_id=a.id, kind="compra", status="pendiente_vl",
            trade_date=trade_date, amount_eur=q2(amount), fee=ZERO,
        )  # fmt: skip
        db.add(tx)
        out.append(tx)
        total += q2(amount)
    db.flush()
    if from_account_id and total > 0:
        acc = gsvc.get_owned(db, Account, from_account_id, user_id)
        cyc = gsvc.open_cycle(db, user_id, acc.id)
        names = ", ".join(sorted({db.get(Asset, t.asset_id).name for t in out}))  # type: ignore[union-attr]
        m = Movement(
            user_id=user_id, account_id=acc.id, cycle_id=cyc.id if cyc else None,
            due_date=trade_date, kind="transferencia", status="planned",
            concept=f"Aportación inversión ({names})"[:160], amount=-total, source="manual",
        )  # fmt: skip
        db.add(m)
        gsvc.place_planned(db, m)
        db.flush()
        for t in out:
            t.movement_id = m.id
    return out


def settle(
    db: Session,
    tx: InvTransaction,
    units: Decimal | None = None,
    price: Decimal | None = None,
    fee: Decimal | None = None,
) -> InvTransaction:
    """Liquida una aportación pendiente con las participaciones o con el VL del día."""
    if tx.status != "pendiente_vl":
        raise bad("Esta operación ya está liquidada", status.HTTP_409_CONFLICT)
    if fee is not None:
        tx.fee = fee
    net = tx.amount_eur - tx.fee
    a = db.get(Asset, tx.asset_id)
    assert a is not None
    if units is not None and units > 0:
        tx.units = units
        tx.price = (net / units).quantize(Decimal("1E-10"))
    elif price is not None and price > 0:
        tx.price = price
        tx.units = qunits(net / price, units_decimals(db, a))
    else:
        raise bad("Indica las participaciones o el valor liquidativo")
    tx.status = "liquidada"
    tx.settle_date = tx.settle_date or date.today()
    if price is not None:
        set_price(db, a, tx.trade_date, price, "operacion")
    db.flush()
    return tx


def check_sell(db: Session, asset: Asset, units: Decimal, on: date) -> None:
    pos = replay([t for t in _txs(db, asset) if t.on <= on])
    if units > pos.units:
        raise bad(f"Solo hay {pos.units.normalize()} participaciones en esa fecha")


def correct_position(
    db: Session,
    asset: Asset,
    units_after: Decimal,
    avg_cost_after: Decimal,
    reason: str,
    effective_date: date | None = None,
) -> PositionCorrection:
    if not reason.strip():
        raise bad("Indica el motivo de la corrección")
    pos = position(db, asset)
    c = PositionCorrection(
        user_id=asset.user_id, asset_id=asset.id, effective_date=effective_date or date.today(),
        units_before=pos.units, units_after=units_after, avg_cost_before=pos.avg_cost,
        avg_cost_after=avg_cost_after, reason=reason.strip(),
    )  # fmt: skip
    db.add(c)
    db.add(AuditLog(
        user_id=asset.user_id, entity="asset", entity_id=str(asset.id), action="position.corrected",
        before={"units": str(pos.units), "avg_cost": str(pos.avg_cost)},
        after={"units": str(units_after), "avg_cost": str(avg_cost_after)}, reason=c.reason,
    ))  # fmt: skip
    db.flush()
    return c


# --- Snapshots ---------------------------------------------------------------------------------
def snapshot_day(db: Session, user_id: uuid.UUID, on: date | None = None) -> PortfolioSnapshot:
    """Foto del día (la hace el worker cada noche; idempotente)."""
    from app.models import AssetSnapshot

    on = on or date.today()
    p = portfolio(db, user_id)
    flows = db.scalar(
        select(func.coalesce(func.sum(InvTransaction.amount_eur), 0)).where(
            InvTransaction.user_id == user_id,
            InvTransaction.status == "liquidada",
            InvTransaction.trade_date == on,
            InvTransaction.kind.in_(("compra", "aportacion_periodica")),
        )
    ) - db.scalar(
        select(func.coalesce(func.sum(InvTransaction.amount_eur), 0)).where(
            InvTransaction.user_id == user_id,
            InvTransaction.status == "liquidada",
            InvTransaction.trade_date == on,
            InvTransaction.kind == "venta",
        )
    )
    for r in p.rows:
        if r.position.units <= 0 and r.value == 0:
            continue
        s = db.scalar(
            select(AssetSnapshot).where(
                AssetSnapshot.asset_id == r.asset.id, AssetSnapshot.date == on
            )
        )
        if s is None:
            s = AssetSnapshot(user_id=user_id, asset_id=r.asset.id, date=on)
            db.add(s)
        s.units, s.price, s.value_eur, s.cost_eur = (
            r.position.units,
            r.price,
            q2(r.value),
            q2(r.cost),
        )
    snap = db.scalar(
        select(PortfolioSnapshot).where(
            PortfolioSnapshot.user_id == user_id, PortfolioSnapshot.date == on
        )
    )
    if snap is None:
        snap = PortfolioSnapshot(user_id=user_id, date=on)
        db.add(snap)
    snap.value_eur, snap.cost_eur, snap.net_flow_eur = q2(p.value), q2(p.cost), q2(Decimal(flows))
    snap.manual = False
    db.flush()
    return snap


def history(db: Session, user_id: uuid.UUID, days: int = 3650) -> list[PortfolioSnapshot]:
    since = date.today() - timedelta(days=days)
    return list(
        db.scalars(
            select(PortfolioSnapshot)
            .where(PortfolioSnapshot.user_id == user_id, PortfolioSnapshot.date >= since)
            .order_by(PortfolioSnapshot.date)
        )
    )


def auto_settle(db: Session, user_id: uuid.UUID | None = None) -> int:
    """Liquida las aportaciones a fondos pendientes cuando ya hay un VL automático de su fecha
    de operación. Las de cripto y acciones se confirman a mano (el precio cambia en el día)."""
    q = select(InvTransaction).where(InvTransaction.status == "pendiente_vl")
    if user_id is not None:
        q = q.where(InvTransaction.user_id == user_id)
    n = 0
    for tx in db.scalars(q).all():
        a = db.get(Asset, tx.asset_id)
        if a is None or a.type not in ("fondo", "etf"):
            continue
        p = db.scalar(
            select(PriceHistory).where(
                PriceHistory.asset_id == a.id,
                PriceHistory.date == tx.trade_date,
                PriceHistory.source.in_(("ft", "quefondos", "yahoo")),
            )
        )
        if p is not None:
            settle(db, tx, price=p.price)
            n += 1
    return n


def users_with_assets(db: Session) -> list[uuid.UUID]:
    return list(db.scalars(select(Asset.user_id).distinct()))


# --- Aportaciones periódicas -------------------------------------------------------------------
def _plan_template(db: Session, plan: ContributionPlan, asset: Asset, account: Account) -> None:
    t = (
        db.get(RecurringTemplate, plan.recurring_template_id)
        if plan.recurring_template_id
        else None
    )
    if t is None:
        t = RecurringTemplate(user_id=plan.user_id, account_id=account.id, kind="transferencia")
        db.add(t)
    t.concept = f"Aportación periódica ({asset.name})"[:160]
    t.amount = -plan.amount
    t.every_months, t.day_of_month = plan.every_months, plan.day_of_month
    t.start_date, t.end_date, t.active = plan.start_date, plan.end_date, plan.active
    db.flush()
    plan.recurring_template_id = t.id


def save_plan(
    db: Session,
    plan: ContributionPlan,
    from_account_id: uuid.UUID | None,
) -> ContributionPlan:
    """Crea o actualiza un plan y, si sale de una cuenta de gastos, su recurrente enlazado."""
    asset = gsvc.get_owned(db, Asset, plan.asset_id, plan.user_id)
    if plan.amount <= 0:
        raise bad("El importe debe ser positivo")
    if plan.last_generated is None:
        plan.last_generated = date.today() - timedelta(days=1)
    db.add(plan)
    db.flush()
    if from_account_id:
        acc = gsvc.get_owned(db, Account, from_account_id, plan.user_id)
        _plan_template(db, plan, asset, acc)
        cur = gsvc.open_cycle(db, plan.user_id, acc.id)
        if cur:
            payday = int(gsvc.get_settings(db, plan.user_id)["payday_day"])
            gsvc.generate_recurring(db, cur, payday)
    elif plan.recurring_template_id:
        t = db.get(RecurringTemplate, plan.recurring_template_id)
        if t is not None:
            t.active = False
        plan.recurring_template_id = None
    db.flush()
    return plan


def delete_plan(db: Session, plan: ContributionPlan) -> None:
    if plan.recurring_template_id and (t := db.get(RecurringTemplate, plan.recurring_template_id)):
        t.active = False
        t.end_date = date.today()
        gsvc.end_recurring_after(db, t)
    db.delete(plan)


def generate_plans(db: Session, today: date | None = None, user_id: uuid.UUID | None = None) -> int:
    """Crea las compras pendientes de VL de las aportaciones periódicas que tocan hasta hoy."""
    today = today or date.today()
    q = select(ContributionPlan).where(ContributionPlan.active.is_(True))
    if user_id is not None:
        q = q.where(ContributionPlan.user_id == user_id)
    n = 0
    for p in db.scalars(q).all():
        since = (p.last_generated or today - timedelta(days=1)) + timedelta(days=1)
        for d in occurrences(p.start_date, p.every_months, p.day_of_month, since,
                             today + timedelta(days=1), p.end_date):  # fmt: skip
            key = hashlib.sha256(f"plan:{p.id}:{d.isoformat()}".encode()).hexdigest()
            exists = db.scalar(
                select(InvTransaction.id).where(
                    InvTransaction.user_id == p.user_id, InvTransaction.dedupe_hash == key
                )
            )
            if exists:
                continue
            db.add(InvTransaction(
                user_id=p.user_id, asset_id=p.asset_id, kind="aportacion_periodica",
                status="pendiente_vl", trade_date=d, amount_eur=p.amount, dedupe_hash=key,
                notes="Aportación periódica",
            ))  # fmt: skip
            n += 1
        p.last_generated = today
    db.flush()
    return n


def next_plan_date(p: ContributionPlan, today: date | None = None) -> date | None:
    today = today or date.today()
    nxt = occurrences(p.start_date, p.every_months, p.day_of_month, today + timedelta(days=1),
                      today + timedelta(days=800), p.end_date)  # fmt: skip
    return nxt[0] if nxt else None
