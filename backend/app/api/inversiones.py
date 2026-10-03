"""API de inversiones (fase 3a): plataformas, activos, objetivos, cartera, transacciones,
correcciones, precios, motor de aportaciones e historial."""

import uuid
from datetime import date
from decimal import Decimal
from typing import Annotated

from fastapi import APIRouter, File, Form, Query, Response, UploadFile, status
from sqlalchemy import select

from app.api.deps import DB, CurrentUser
from app.domain.money import ZERO
from app.domain.portfolio import qunits
from app.models import (
    Asset,
    AssetClass,
    AuditLog,
    ContributionPlan,
    ImportProfile,
    InvTransaction,
    Platform,
    PortfolioSnapshot,
    RecurringTemplate,
)
from app.schemas.inversiones import (
    AssetClassIn,
    AssetClassOut,
    AssetDetailOut,
    AssetIn,
    AssetOut,
    AssetPatch,
    AssetTargetOut,
    ClassAmountOut,
    ClassOut,
    ContributionOut,
    CorrectionIn,
    EmergencyOut,
    InvSettingsIn,
    InvSettingsOut,
    LotOut,
    MacroTargetOut,
    NewAssetOut,
    OrderOut,
    OrdersIn,
    PlanIn,
    PlanOut,
    PlatformBatchOut,
    PlatformIn,
    PlatformOpOut,
    PlatformOut,
    PlatformPositionOut,
    PlatformPreviewOut,
    PortfolioOut,
    PositionOut,
    PriceIn,
    PriceOut,
    PriceRefreshOut,
    RealizedOut,
    SnapshotIn,
    SnapshotOut,
    SuggestIn,
    TargetsIn,
    TargetsOut,
    TransferIn,
    TxIn,
    TxOut,
    TxSettleIn,
)
from app.services import gastos as gsvc
from app.services import inversiones as svc

router = APIRouter(prefix="/inv", tags=["inversiones"])


def _asset_out(a: Asset) -> AssetOut:
    return AssetOut.model_validate(a, from_attributes=True)


def _class_out(c: AssetClass) -> AssetClassOut:
    return AssetClassOut.model_validate(c, from_attributes=True)


def _tx_out(t: InvTransaction) -> TxOut:
    return TxOut.model_validate(t, from_attributes=True)


def _pos_out(r: svc.AssetRow) -> PositionOut:
    return PositionOut(
        asset=_asset_out(r.asset), units=r.position.units, avg_cost=r.position.avg_cost,
        cost=r.cost, price=r.price, price_date=r.price_date, price_source=r.price_source,
        stale=r.stale, value=r.value, pnl=r.pnl, pnl_pct=r.pnl_pct, pending=r.pending,
        inner_weight=r.inner_weight, inner_target=r.inner_target,
        inner_status=r.inner_status,  # type: ignore[arg-type]
    )  # fmt: skip


# --- Ajustes ----------------------------------------------------------------------------------
def _settings_out(s: dict) -> InvSettingsOut:
    return InvSettingsOut(
        configured=bool(s["configured"]),
        min_operation=s["min_operation"] or ZERO,
        monthly_contribution=s["monthly_contribution"],
        track_start=s.get("track_start"),
    )


@router.get("/settings", response_model=InvSettingsOut)
def get_settings(db: DB, user: CurrentUser) -> InvSettingsOut:
    return _settings_out(svc.get_settings(db, user.id))


@router.put("/settings", response_model=InvSettingsOut)
def put_settings(body: InvSettingsIn, db: DB, user: CurrentUser) -> InvSettingsOut:
    values = body.model_dump(exclude_unset=True, exclude={"clear_track_start"})
    if values.get("track_start"):
        values["track_start"] = values["track_start"].isoformat()
    if body.clear_track_start:
        values["track_start"] = None
    svc.ensure_classes(db, user.id)
    return _settings_out(svc.save_settings(db, user.id, {**values, "configured": True}))


# --- Plataformas y categorías ------------------------------------------------------------------
@router.get("/platforms", response_model=list[PlatformOut])
def list_platforms(db: DB, user: CurrentUser):
    rows = db.scalars(select(Platform).where(Platform.user_id == user.id).order_by(Platform.name))
    return [PlatformOut.model_validate(p, from_attributes=True) for p in rows]


@router.post("/platforms", response_model=PlatformOut, status_code=status.HTTP_201_CREATED)
def create_platform(body: PlatformIn, db: DB, user: CurrentUser) -> PlatformOut:
    data = body.model_dump(exclude={"id"})
    p = Platform(user_id=user.id, **data)
    if body.id:
        p.id = body.id
    db.add(p)
    db.flush()
    return PlatformOut.model_validate(p, from_attributes=True)


@router.put("/platforms/{platform_id}", response_model=PlatformOut)
def update_platform(platform_id: uuid.UUID, body: PlatformIn, db: DB, user: CurrentUser):
    p = gsvc.get_owned(db, Platform, platform_id, user.id)
    for k, v in body.model_dump(exclude={"id"}).items():
        setattr(p, k, v)
    db.flush()
    return PlatformOut.model_validate(p, from_attributes=True)


@router.get("/classes", response_model=list[AssetClassOut])
def list_classes(db: DB, user: CurrentUser):
    svc.ensure_classes(db, user.id)
    return [_class_out(c) for c in svc.classes(db, user.id)]


@router.post("/classes", response_model=AssetClassOut, status_code=status.HTTP_201_CREATED)
def create_class(body: AssetClassIn, db: DB, user: CurrentUser) -> AssetClassOut:
    n = len(svc.classes(db, user.id))
    c = AssetClass(user_id=user.id, name=body.name.strip(),
                   default_tolerance_pp=body.default_tolerance_pp, sort=n)  # fmt: skip
    db.add(c)
    db.flush()
    return _class_out(c)


# --- Activos ----------------------------------------------------------------------------------
def _check_refs(db: DB, user_id: uuid.UUID, data: dict) -> None:
    if data.get("asset_class_id"):
        gsvc.get_owned(db, AssetClass, data["asset_class_id"], user_id)
    if data.get("platform_id"):
        gsvc.get_owned(db, Platform, data["platform_id"], user_id)


@router.get("/assets", response_model=list[AssetOut])
def list_assets(db: DB, user: CurrentUser, include_archived: bool = Query(default=False)):
    return [_asset_out(a) for a in svc.assets(db, user.id, include_archived)]


@router.post("/assets", response_model=AssetOut, status_code=status.HTTP_201_CREATED)
def create_asset(body: AssetIn, response: Response, db: DB, user: CurrentUser) -> AssetOut:
    if body.id and (existing := db.get(Asset, body.id)):
        if existing.user_id != user.id:
            raise gsvc.not_found("Asset")
        response.status_code = status.HTTP_200_OK
        return _asset_out(existing)
    data = body.model_dump(exclude={"id"})
    _check_refs(db, user.id, data)
    a = Asset(user_id=user.id, **data)
    if body.id:
        a.id = body.id
    if a.isin:
        a.isin = a.isin.upper()
    db.add(a)
    db.flush()
    return _asset_out(a)


@router.patch("/assets/{asset_id}", response_model=AssetOut)
def patch_asset(asset_id: uuid.UUID, body: AssetPatch, db: DB, user: CurrentUser) -> AssetOut:
    a = gsvc.get_owned(db, Asset, asset_id, user.id)
    data = body.model_dump(exclude_unset=True)
    _check_refs(db, user.id, data)
    for k, v in data.items():
        setattr(a, k, v)
    db.flush()
    return _asset_out(a)


@router.get("/assets/{asset_id}", response_model=AssetDetailOut)
def asset_detail(asset_id: uuid.UUID, db: DB, user: CurrentUser) -> AssetDetailOut:
    a = gsvc.get_owned(db, Asset, asset_id, user.id)
    r = svc.asset_row(db, a)
    txs = db.scalars(
        select(InvTransaction)
        .where(InvTransaction.user_id == user.id, InvTransaction.asset_id == a.id)
        .order_by(InvTransaction.trade_date.desc(), InvTransaction.created_at.desc())
    )
    return AssetDetailOut(
        position=_pos_out(r),
        lots=[
            LotOut(acquired=lot.acquired, units=lot.units, cost=lot.cost) for lot in r.position.lots
        ],
        realized=[
            RealizedOut(
                date=x.on,
                units=x.units,
                proceeds=x.proceeds,
                gain_fifo=x.gain_fifo,
                gain_pmp=x.gain_pmp,
            )
            for x in r.position.realized
        ],
        income=r.position.income,
        transactions=[_tx_out(t) for t in txs],
    )


@router.delete("/assets/{asset_id}", status_code=status.HTTP_204_NO_CONTENT)
def delete_asset(asset_id: uuid.UUID, db: DB, user: CurrentUser) -> Response:
    """Solo se borra un activo sin operaciones; si las tiene, se archiva."""
    a = gsvc.get_owned(db, Asset, asset_id, user.id)
    has_tx = db.scalar(select(InvTransaction.id).where(InvTransaction.asset_id == a.id).limit(1))
    if has_tx:
        a.archived = True
    else:
        db.delete(a)
    return Response(status_code=status.HTTP_204_NO_CONTENT)


# --- Objetivos --------------------------------------------------------------------------------
def _targets_out(db: DB, user_id: uuid.UUID) -> TargetsOut:
    macro, inner = svc.current_targets(db, user_id)
    return TargetsOut(
        macro=[
            MacroTargetOut(
                asset_class_id=k,
                target=t.target_pct,
                min=t.min_pct,
                max=t.max_pct,
                tolerance_pp=t.tolerance_pp,
                valid_from=t.valid_from,
            )
            for k, t in macro.items()
        ],
        assets=[
            AssetTargetOut(asset_id=k, target=t.target_pct, valid_from=t.valid_from)
            for k, t in inner.items()
        ],
    )


@router.get("/targets", response_model=TargetsOut)
def get_targets(db: DB, user: CurrentUser) -> TargetsOut:
    return _targets_out(db, user.id)


@router.put("/targets", response_model=TargetsOut)
def put_targets(body: TargetsIn, db: DB, user: CurrentUser) -> TargetsOut:
    svc.set_targets(
        db, user.id,
        [
            svc.MacroTargetIn(m.asset_class_id, m.target, m.min, m.max, m.tolerance_pp)
            for m in body.macro
        ],
        [svc.AssetTargetIn(t.asset_id, t.target) for t in body.assets],
        body.valid_from,
    )  # fmt: skip
    return _targets_out(db, user.id)


# --- Cartera ----------------------------------------------------------------------------------
@router.get("/portfolio", response_model=PortfolioOut)
def get_portfolio(db: DB, user: CurrentUser) -> PortfolioOut:
    svc.ensure_classes(db, user.id)
    p = svc.portfolio(db, user.id)
    classified = {r.asset.id for c in p.classes for r in c.assets}
    e = p.emergency
    return PortfolioOut(
        value=p.value,
        cost=p.cost,
        pnl=p.pnl,
        pnl_pct=p.pnl_pct,
        pending=p.pending,
        stale=p.stale,
        classes=[
            ClassOut(
                asset_class=_class_out(c.cls),
                value=c.value,
                pending=c.pending,
                weight=c.weight,
                target=c.target,
                min=c.min,
                max=c.max,
                tolerance_pp=c.tolerance_pp,
                status=c.status,  # type: ignore[arg-type]
                positions=[_pos_out(r) for r in c.assets],
            )
            for c in p.classes
        ],
        unclassified=[_pos_out(r) for r in p.rows if r.asset.id not in classified],
        emergency=EmergencyOut(
            target=e.target,
            current=e.current,
            coverage=e.coverage,
            missing=e.missing,
            suggested_monthly=e.suggested_monthly,
        )
        if e
        else None,
    )


# --- Transacciones ------------------------------------------------------------------------------
@router.get("/transactions", response_model=list[TxOut])
def list_transactions(
    db: DB,
    user: CurrentUser,
    pending_only: bool = Query(default=False),
    limit: int = Query(default=200, le=1000),
):
    q = select(InvTransaction).where(InvTransaction.user_id == user.id)
    if pending_only:
        q = q.where(InvTransaction.status == "pendiente_vl")
    q = q.order_by(InvTransaction.trade_date.desc(), InvTransaction.created_at.desc()).limit(limit)
    return [_tx_out(t) for t in db.scalars(q)]


@router.post("/transactions", response_model=TxOut, status_code=status.HTTP_201_CREATED)
def create_transaction(body: TxIn, response: Response, db: DB, user: CurrentUser) -> TxOut:
    if body.id and (existing := db.get(InvTransaction, body.id)):
        if existing.user_id != user.id:
            raise gsvc.not_found("InvTransaction")
        response.status_code = status.HTTP_200_OK
        return _tx_out(existing)
    a = gsvc.get_owned(db, Asset, body.asset_id, user.id)
    if body.kind in ("traspaso_salida", "traspaso_entrada"):
        raise svc.bad("Los traspasos se registran con /inv/transfers")
    t = InvTransaction(
        user_id=user.id, asset_id=a.id, kind=body.kind, trade_date=body.trade_date,
        amount_eur=body.amount_eur, units=body.units, price=body.price, avg_cost=body.avg_cost,
        fee=body.fee, notes=body.notes,
        status="pendiente_vl" if body.pending else "liquidada",
    )  # fmt: skip
    if body.id:
        t.id = body.id
    units_kinds = ("posicion_inicial", "compra", "aportacion_periodica", "venta", "recompensa")
    if t.status == "liquidada" and body.kind in units_kinds:
        if body.units is None and body.price and body.amount_eur:
            t.units = qunits((body.amount_eur - body.fee) / body.price, svc.units_decimals(db, a))
        if not t.units or t.units <= 0:
            raise svc.bad("Indica las participaciones (o el precio para calcularlas)")
        if body.kind == "posicion_inicial" and body.avg_cost is None:
            raise svc.bad("La posición inicial necesita el precio medio (PMP)")
        if t.price is None and body.amount_eur:
            t.price = (body.amount_eur / t.units).quantize(Decimal("1E-10"))
    if body.kind == "venta" and t.units:
        svc.check_sell(db, a, t.units, body.trade_date)
    db.add(t)
    db.flush()
    if t.price and t.kind in units_kinds:
        lp = svc.latest_price(db, a)
        if lp is None or lp.date <= t.trade_date:
            svc.set_price(db, a, t.trade_date, t.price, "operacion")
    return _tx_out(t)


@router.post("/transactions/{tx_id}/settle", response_model=TxOut)
def settle_transaction(tx_id: uuid.UUID, body: TxSettleIn, db: DB, user: CurrentUser) -> TxOut:
    t = gsvc.get_owned(db, InvTransaction, tx_id, user.id)
    return _tx_out(svc.settle(db, t, body.units, body.price, body.fee))


@router.delete("/transactions/{tx_id}", status_code=status.HTTP_204_NO_CONTENT)
def delete_transaction(tx_id: uuid.UUID, db: DB, user: CurrentUser) -> Response:
    t = gsvc.get_owned(db, InvTransaction, tx_id, user.id)
    pair = db.get(InvTransaction, t.pair_id) if t.pair_id else None
    if pair is not None and pair.user_id == user.id:
        db.delete(pair)
    db.delete(t)
    return Response(status_code=status.HTTP_204_NO_CONTENT)


@router.post("/transfers", response_model=list[TxOut], status_code=status.HTTP_201_CREATED)
def create_transfer(body: TransferIn, db: DB, user: CurrentUser) -> list[TxOut]:
    src = gsvc.get_owned(db, Asset, body.from_asset_id, user.id)
    dst = gsvc.get_owned(db, Asset, body.to_asset_id, user.id)
    if src.id == dst.id:
        raise svc.bad("Origen y destino iguales")
    svc.check_sell(db, src, body.units_out, body.trade_date)
    out = InvTransaction(user_id=user.id, asset_id=src.id, kind="traspaso_salida",
                         trade_date=body.trade_date, amount_eur=body.amount_eur,
                         units=body.units_out)  # fmt: skip
    db.add(out)
    db.flush()
    inn = InvTransaction(user_id=user.id, asset_id=dst.id, kind="traspaso_entrada",
                         trade_date=body.trade_date, amount_eur=body.amount_eur,
                         units=body.units_in, pair_id=out.id)  # fmt: skip
    db.add(inn)
    db.flush()
    out.pair_id = inn.id
    return [_tx_out(out), _tx_out(inn)]


@router.post("/assets/{asset_id}/correction", response_model=PositionOut)
def correct(asset_id: uuid.UUID, body: CorrectionIn, db: DB, user: CurrentUser) -> PositionOut:
    a = gsvc.get_owned(db, Asset, asset_id, user.id)
    svc.correct_position(db, a, body.units, body.avg_cost, body.reason, body.effective_date)
    return _pos_out(svc.asset_row(db, a))


# --- Precios ----------------------------------------------------------------------------------
@router.get("/assets/{asset_id}/prices", response_model=list[PriceOut])
def list_prices(asset_id: uuid.UUID, db: DB, user: CurrentUser, limit: int = Query(default=90)):
    from app.models import PriceHistory

    a = gsvc.get_owned(db, Asset, asset_id, user.id)
    rows = db.scalars(
        select(PriceHistory)
        .where(PriceHistory.asset_id == a.id)
        .order_by(PriceHistory.date.desc())
        .limit(limit)
    )
    return [PriceOut(date=r.date, price=r.price, source=r.source) for r in rows]


@router.put("/assets/{asset_id}/prices", response_model=PriceOut)
def put_price(asset_id: uuid.UUID, body: PriceIn, db: DB, user: CurrentUser) -> PriceOut:
    a = gsvc.get_owned(db, Asset, asset_id, user.id)
    r = svc.set_price(db, a, body.date, body.price, "manual")
    return PriceOut(date=r.date, price=r.price, source=r.source)


# --- Motor de aportaciones ----------------------------------------------------------------------
@router.post("/contribution/suggest", response_model=ContributionOut)
def suggest(body: SuggestIn, db: DB, user: CurrentUser) -> ContributionOut:
    s = svc.suggest(db, user.id, body.amount, body.round_to)
    return ContributionOut(
        amount=s.amount,
        by_class=[ClassAmountOut(asset_class_id=k, amount=v) for k, v in s.by_class.items()],
        orders=[
            OrderOut(
                asset_id=o.asset.id,
                asset_name=o.asset.name,
                amount=o.amount,
                price=o.price,
                approx_units=o.approx_units,
            )
            for o in s.orders
        ],
        unassigned=s.unassigned,
    )


@router.post("/contribution/orders", response_model=list[TxOut],
             status_code=status.HTTP_201_CREATED)  # fmt: skip
def create_orders(body: OrdersIn, db: DB, user: CurrentUser) -> list[TxOut]:
    txs = svc.create_orders(
        db, user.id, [(o.asset_id, o.amount) for o in body.orders], body.trade_date,
        body.from_account_id,
    )  # fmt: skip
    return [_tx_out(t) for t in txs]


# --- Historial --------------------------------------------------------------------------------
def _snap_out(s: PortfolioSnapshot) -> SnapshotOut:
    return SnapshotOut(date=s.date, value=s.value_eur, cost=s.cost_eur,
                       net_flow=s.net_flow_eur, manual=s.manual)  # fmt: skip


@router.get("/history", response_model=list[SnapshotOut])
def get_history(db: DB, user: CurrentUser, days: int = Query(default=3650, le=36500)):
    return [_snap_out(s) for s in svc.history(db, user.id, days)]


@router.put("/history", response_model=SnapshotOut)
def put_history(body: SnapshotIn, db: DB, user: CurrentUser) -> SnapshotOut:
    """Punto manual del historial (anterior a Faro). No pisa un snapshot automático."""
    if body.date >= date.today():
        raise svc.bad("El historial manual es para fechas pasadas")
    s = db.scalar(
        select(PortfolioSnapshot).where(
            PortfolioSnapshot.user_id == user.id, PortfolioSnapshot.date == body.date
        )
    )
    if s is not None and not s.manual:
        raise svc.bad("Ese día ya tiene una foto automática", status.HTTP_409_CONFLICT)
    if s is None:
        s = PortfolioSnapshot(user_id=user.id, date=body.date, manual=True, net_flow_eur=ZERO)
        db.add(s)
    s.value_eur, s.cost_eur = body.value, body.cost
    db.flush()
    return _snap_out(s)


@router.post("/prices/refresh", response_model=list[PriceRefreshOut])
def refresh_prices(db: DB, user: CurrentUser) -> list[PriceRefreshOut]:
    """Consulta ahora las fuentes de precios de mis activos (lo mismo que hace el worker)."""
    from app.services import prices as px

    results = px.update(db, user.id)
    svc.auto_settle(db, user.id)
    return [
        PriceRefreshOut(
            asset_id=r.asset.id,
            asset_name=r.asset.name,
            ok=r.quote is not None,
            price=r.quote.price if r.quote else None,
            date=r.quote.on if r.quote else None,
            source=r.quote.source if r.quote else None,
            errors=r.errors,
        )
        for r in results
    ]


# --- Aportaciones periódicas -------------------------------------------------------------------
def _plan_out(db: DB, p: ContributionPlan) -> PlanOut:
    t = db.get(RecurringTemplate, p.recurring_template_id) if p.recurring_template_id else None
    return PlanOut(
        id=p.id,
        asset_id=p.asset_id,
        amount=p.amount,
        every_months=p.every_months,
        day_of_month=p.day_of_month,
        start_date=p.start_date,
        end_date=p.end_date,
        active=p.active,
        from_account_id=t.account_id if t else None,
        next_date=svc.next_plan_date(p) if p.active else None,
        notes=p.notes,
    )


@router.get("/plans", response_model=list[PlanOut])
def list_plans(db: DB, user: CurrentUser) -> list[PlanOut]:
    rows = db.scalars(
        select(ContributionPlan)
        .where(ContributionPlan.user_id == user.id)
        .order_by(ContributionPlan.created_at)
    )
    return [_plan_out(db, p) for p in rows]


@router.post("/plans", response_model=PlanOut, status_code=status.HTTP_201_CREATED)
def create_plan(body: PlanIn, response: Response, db: DB, user: CurrentUser) -> PlanOut:
    if body.id and (existing := db.get(ContributionPlan, body.id)):
        if existing.user_id != user.id:
            raise gsvc.not_found("ContributionPlan")
        response.status_code = status.HTTP_200_OK
        return _plan_out(db, existing)
    p = ContributionPlan(user_id=user.id, **body.model_dump(exclude={"id", "from_account_id"}))
    if body.id:
        p.id = body.id
    return _plan_out(db, svc.save_plan(db, p, body.from_account_id))


@router.put("/plans/{plan_id}", response_model=PlanOut)
def update_plan(plan_id: uuid.UUID, body: PlanIn, db: DB, user: CurrentUser) -> PlanOut:
    p = gsvc.get_owned(db, ContributionPlan, plan_id, user.id)
    for k, v in body.model_dump(exclude={"id", "from_account_id"}).items():
        setattr(p, k, v)
    return _plan_out(db, svc.save_plan(db, p, body.from_account_id))


@router.delete("/plans/{plan_id}", status_code=status.HTTP_204_NO_CONTENT)
def delete_plan(plan_id: uuid.UUID, db: DB, user: CurrentUser) -> Response:
    svc.delete_plan(db, gsvc.get_owned(db, ContributionPlan, plan_id, user.id))
    return Response(status_code=status.HTTP_204_NO_CONTENT)


# --- Importación de plataformas ------------------------------------------------------------------
def _broker_mapping(
    db: DB, user_id: uuid.UUID, mapping: str | None, profile_id: uuid.UUID | None
) -> dict | None:
    """Mapeo de columnas del importador genérico: el enviado o el de un formato guardado."""
    import json

    if profile_id:
        return gsvc.get_owned(db, ImportProfile, profile_id, user_id).config
    if mapping:
        try:
            return json.loads(mapping)
        except ValueError:
            raise svc.bad("Mapeo de columnas no válido") from None
    return None


async def _platform_plan(
    db: DB,
    user_id: uuid.UUID,
    file: UploadFile,
    replace_initial: bool,
    mapping: dict | None = None,
):
    import hashlib

    import httpx

    from app.importers import platforms as pf
    from app.services import prices as px

    content = await file.read()
    if len(content) > 5 * 1024 * 1024:
        raise svc.bad("Fichero demasiado grande", status.HTTP_413_REQUEST_ENTITY_TOO_LARGE)
    with httpx.Client(timeout=15, headers={"User-Agent": px.UA}) as client:
        try:
            parsed = pf.read(
                content, file.filename or "fichero.csv", px.ecb_eur_per_usd(client), mapping
            )
        except pf.ImportFormatError as e:
            raise svc.bad(str(e)) from None
        if not parsed.ops:
            raise svc.bad("No hay operaciones que importar en el fichero")
        pl = pf.plan(
            db, user_id, parsed, replace_initial, lambda isin: pf.fund_name_ft(client, isin)
        )
    return pl, content, hashlib.sha256(content).hexdigest()


@router.post("/imports/preview", response_model=PlatformPreviewOut)
async def platform_preview(
    db: DB,
    user: CurrentUser,
    file: Annotated[UploadFile, File()],
    replace_initial: Annotated[bool, Form()] = False,
    mapping: Annotated[str | None, Form()] = None,
    profile_id: Annotated[uuid.UUID | None, Form()] = None,
) -> PlatformPreviewOut:
    m = _broker_mapping(db, user.id, mapping, profile_id)
    pl, _, _ = await _platform_plan(db, user.id, file, replace_initial, m)
    out = PlatformPreviewOut(
        source=pl.parsed.source,  # type: ignore[arg-type]
        platform=pl.platform,
        counts=pl.counts,
        warnings=pl.parsed.warnings,
        ops=[
            PlatformOpOut(
                row=p.op.row,
                date=p.op.on,
                kind=p.op.kind,
                key=p.op.key,  # type: ignore[arg-type]
                asset_name=p.asset.name if p.asset else pl.create[p.op.key],
                units=p.op.units,
                amount=p.op.amount_eur,
                outcome=p.outcome,
                note=p.op.note,  # type: ignore[arg-type]
            )
            for p in pl.ops
        ],
        create_assets=[NewAssetOut(key=k, name=v) for k, v in pl.create.items()],
        positions=[PlatformPositionOut(**x.__dict__) for x in pl.positions],
    )
    db.rollback()  # la vista previa nunca escribe
    return out


@router.post("/imports/commit", response_model=PlatformBatchOut)
async def platform_commit(
    db: DB,
    user: CurrentUser,
    file: Annotated[UploadFile, File()],
    replace_initial: Annotated[bool, Form()] = False,
    mapping: Annotated[str | None, Form()] = None,
    profile_id: Annotated[uuid.UUID | None, Form()] = None,
    save_profile_as: Annotated[str | None, Form()] = None,
) -> PlatformBatchOut:
    from app.importers import platforms as pf

    m = _broker_mapping(db, user.id, mapping, profile_id)
    pl, _, sha = await _platform_plan(db, user.id, file, replace_initial, m)
    b = pf.commit(db, user.id, pl, file.filename or "fichero.csv", sha)
    if save_profile_as and m is not None:
        name = save_profile_as.strip()[:80]
        prof = db.scalar(
            select(ImportProfile).where(
                ImportProfile.user_id == user.id, ImportProfile.name == name
            )
        )
        if prof is None:
            db.add(ImportProfile(user_id=user.id, name=name, kind="broker", config=m))
        else:
            prof.kind, prof.config = "broker", m
    if replace_initial and pl.initial:
        db.add(AuditLog(
            user_id=user.id, entity="inv_import", entity_id=str(b.id),
            action="initial_positions.replaced", reason="Sustituidas por el historial importado",
            before={"count": len(pl.initial)},
        ))  # fmt: skip
    return PlatformBatchOut(id=b.id, filename=b.filename, status=b.status,
                            counts=b.summary.get("counts", {}))  # fmt: skip
