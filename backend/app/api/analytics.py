"""API de la fase 4: patrimonio neto, rentabilidad y exposición."""

import uuid
from decimal import Decimal

import httpx
from fastapi import APIRouter, HTTPException, Query, status
from sqlalchemy import select

from app.api.deps import DB, CurrentUser
from app.domain import performance as perf
from app.models import Asset, AssetExposure
from app.schemas.analytics import (
    AccountBalanceOut,
    AssetExposureIn,
    AssetExposureOut,
    ContributionDestinationOut,
    ContributionItemOut,
    ContributionMonthOut,
    ContributionsOut,
    EvolutionPointOut,
    ExposureItemOut,
    ExposureOut,
    IncomeOut,
    JobResultOut,
    MilestoneNextOut,
    MilestoneOut,
    MilestonesIn,
    MilestonesOut,
    NetWorthComponentOut,
    NetWorthEvolutionOut,
    NetWorthOut,
    NetWorthPointOut,
    PerformanceMonthOut,
    PerformanceOut,
    SaleOut,
    SeriesPointOut,
    TaxReportOut,
    TransferOut,
    YearEndOut,
)
from app.services import analytics as svc
from app.services import contributions as contrib
from app.services import gastos as gsvc
from app.services import inversiones as inv
from app.services import networth as nw
from app.services import prices as px

router = APIRouter(prefix="/analytics", tags=["analytics"])


@router.get("/networth", response_model=NetWorthOut)
def get_networth(db: DB, user: CurrentUser) -> NetWorthOut:
    n = svc.networth(db, user.id)
    return NetWorthOut(
        total=n.total,
        accounts=[
            AccountBalanceOut(id=a.id, name=a.name, kind=a.kind, balance=b) for a, b in n.accounts
        ],
        investments=n.investments,
        pending=n.pending,
        by_type=n.by_type,  # type: ignore[arg-type]
        receivable=n.receivable,
        debts=n.debts,
        installments=n.installments,
        unrealized_gain=n.unrealized_gain,
        tax_if_sold=n.tax_if_sold,
        after_tax=n.after_tax,
        tax_year=n.tax_year,
        tax_source=n.tax_source,
    )


@router.get("/networth/history", response_model=list[NetWorthPointOut])
def get_networth_history(db: DB, user: CurrentUser) -> list[NetWorthPointOut]:
    return [
        NetWorthPointOut(date=d, accounts=a, investments=i)
        for d, a, i in svc.networth_history(db, user.id)
    ]


@router.get("/networth/evolution", response_model=NetWorthEvolutionOut)
def get_networth_evolution(db: DB, user: CurrentUser) -> NetWorthEvolutionOut:
    """Evolución del patrimonio por componente (cada cuenta y cada activo), con deudas,
    fraccionadas y el neto. Las cuentas se reconstruyen desde el saldo de hoy (D9)."""
    h = nw.history(db, user.id)
    return NetWorthEvolutionOut(
        start=h.start,
        per_cycle_until=h.per_cycle_until,
        components=[NetWorthComponentOut(**c.__dict__) for c in h.components],
        points=[
            EvolutionPointOut(
                date=p.on,
                accounts=p.accounts,
                investments=p.investments,
                contributed=p.contributed,
                pending=p.pending,
                receivable=p.receivable,
                debts=p.debts,
                installments=p.installments,
                net=p.net,
                components=p.components,  # type: ignore[arg-type]
            )
            for p in h.points
        ],
    )


def _milestones_out(m: nw.Milestones) -> MilestonesOut:
    return MilestonesOut(
        thresholds=m.thresholds,
        items=[MilestoneOut(**x.__dict__) for x in m.items],
        next=MilestoneNextOut(**m.next.__dict__) if m.next else None,
        pace=m.pace,
        net=m.net,
        start=m.start,
    )


@router.get("/milestones", response_model=MilestonesOut)
def get_milestones(db: DB, user: CurrentUser) -> MilestonesOut:
    """Hitos del patrimonio neto: cuándo se cruzó cada umbral y una estimación del siguiente con
    la aportación media (sin rentabilidad: no es una previsión)."""
    return _milestones_out(nw.milestones(db, user.id))


@router.put("/milestones", response_model=MilestonesOut)
def put_milestones(body: MilestonesIn, db: DB, user: CurrentUser) -> MilestonesOut:
    try:
        nw.save_thresholds(db, user.id, list(body.thresholds))
    except ValueError as e:
        raise HTTPException(status.HTTP_422_UNPROCESSABLE_ENTITY, str(e)) from e
    return _milestones_out(nw.milestones(db, user.id))


def _month(m: perf.MonthRow | None) -> PerformanceMonthOut | None:
    if m is None:
        return None
    return PerformanceMonthOut(
        year=m.year,
        month=m.month,
        start_value=m.start_value,
        end_value=m.end_value,
        net_flow=m.net_flow,
        gain=m.gain,
        ret=m.ret,
        cumulative=m.cumulative,
    )


@router.get("/performance", response_model=PerformanceOut)
def get_performance(
    db: DB,
    user: CurrentUser,
    # Texto con "" por defecto: el cliente generado manda los opcionales vacíos (ver CLAUDE.md)
    asset_id: str = Query(default=""),
    class_id: str = Query(default=""),
) -> PerformanceOut:
    """Rentabilidad de toda la cartera, de una categoría o de un activo."""
    try:
        aid = uuid.UUID(asset_id) if asset_id else None
        cid = uuid.UUID(class_id) if class_id else None
    except ValueError:
        raise inv.bad("Identificador no válido") from None
    ids: set[uuid.UUID] | None = None
    if aid:
        ids = {gsvc.get_owned(db, Asset, aid, user.id).id}
    elif cid:
        ids = {
            a.id for a in inv.assets(db, user.id, include_archived=True) if a.asset_class_id == cid
        }
    p = svc.performance(db, user.id, ids)
    return PerformanceOut(
        first=p.first,
        days=p.days,
        value=p.value,
        contributed=p.contributed,
        gain=p.gain,
        twr=p.twr,
        twr_annual=p.twr_annual,
        ytd=p.ytd,
        xirr=p.xirr,
        max_drawdown=p.max_drawdown,
        volatility=p.volatility,
        best=_month(p.best),
        worst=_month(p.worst),
        positive_months=p.positive_months,
        negative_months=p.negative_months,
        months=[m for m in (_month(x) for x in p.months) if m is not None],
        series=[SeriesPointOut(date=d, value=v, contributed=c) for d, v, c in p.weekly],
        before_until=p.before.until if p.before else None,
        before_contributed=p.before.contributed if p.before else None,
        before_value=p.before.value if p.before else None,
    )


@router.get("/exposure", response_model=ExposureOut)
def get_exposure(db: DB, user: CurrentUser) -> ExposureOut:
    e = svc.exposure(db, user.id)
    return ExposureOut(
        **{
            d: [ExposureItemOut(key=k, weight=w, value=v) for k, w, v in items]
            for d, items in e.items()
        }
    )


@router.get("/exposure/{asset_id}", response_model=list[AssetExposureOut])
def get_asset_exposure(asset_id: uuid.UUID, db: DB, user: CurrentUser) -> list[AssetExposureOut]:
    a = gsvc.get_owned(db, Asset, asset_id, user.id)
    rows = db.scalars(
        select(AssetExposure)
        .where(AssetExposure.asset_id == a.id)
        .order_by(AssetExposure.dimension, AssetExposure.weight.desc())
    )
    return [
        AssetExposureOut(
            dimension=r.dimension, key=r.key, weight=r.weight, source=r.source, as_of=r.as_of
        )
        for r in rows
    ]


@router.put("/exposure/{asset_id}", response_model=list[AssetExposureOut])
def put_asset_exposure(
    asset_id: uuid.UUID, body: list[AssetExposureIn], db: DB, user: CurrentUser
) -> list[AssetExposureOut]:
    """Composición manual de un activo (sustituye a la manual anterior; la automática se queda
    pero deja de usarse en las dimensiones que tengan manual)."""
    a = gsvc.get_owned(db, Asset, asset_id, user.id)
    for dim in {b.dimension for b in body}:
        total = sum((b.weight for b in body if b.dimension == dim), Decimal(0))
        if total > Decimal("1.0001"):
            raise inv.bad(f"Los pesos de '{dim}' suman más del 100 %")
    for old in db.scalars(
        select(AssetExposure).where(
            AssetExposure.asset_id == a.id, AssetExposure.source == "manual"
        )
    ):
        db.delete(old)
    db.flush()
    for dim in {b.dimension for b in body}:
        for old in db.scalars(
            select(AssetExposure).where(
                AssetExposure.asset_id == a.id,
                AssetExposure.dimension == dim,
                AssetExposure.key.in_([b.key for b in body if b.dimension == dim]),
            )
        ):
            db.delete(old)
    db.flush()
    for b in body:
        db.add(
            AssetExposure(
                user_id=user.id,
                asset_id=a.id,
                dimension=b.dimension,
                key=b.key.strip(),
                weight=b.weight,
                source="manual",
            )
        )
    db.flush()
    return get_asset_exposure(asset_id, db, user)


@router.post("/exposure/refresh", response_model=JobResultOut)
def refresh_exposure(db: DB, user: CurrentUser) -> JobResultOut:
    with httpx.Client(timeout=20, headers={"User-Agent": px.UA}) as client:
        n, errors = svc.refresh_exposures(db, client, user.id)
    return JobResultOut(updated=n, errors=errors)


@router.post("/prices/backfill", response_model=JobResultOut)
def backfill(db: DB, user: CurrentUser) -> JobResultOut:
    """Histórico de precios desde la primera operación (para los gráficos y la rentabilidad)."""
    with httpx.Client(timeout=30, headers={"User-Agent": px.UA}) as client:
        n, errors = svc.backfill_prices(db, client, user.id)
    return JobResultOut(updated=n, errors=errors)


@router.get("/tax-report", response_model=TaxReportOut)
def tax_report(db: DB, user: CurrentUser, year: int = Query(default=0)) -> TaxReportOut:
    """Resumen anual para la Renta: ventas (FIFO), traspasos, rendimientos y saldos a 31/12."""
    from datetime import date

    from app.services import export

    r = export.tax_report(db, user.id, year or date.today().year)
    foreign = sum((y.value for y in r.year_end if y.foreign_hint), Decimal(0))
    return TaxReportOut(
        year=r.year,
        sales=[SaleOut(**s.__dict__) for s in r.sales],
        gains_total=r.gains_total,
        transfers=[TransferOut(asset=a, date=d, units=u) for a, d, u in r.transfers],
        income=[IncomeOut(**i.__dict__) for i in r.income],  # type: ignore[arg-type]
        income_total=r.income_total,
        savings_base=r.gains_total + r.income_total,
        year_end=[YearEndOut(**y.__dict__) for y in r.year_end],  # type: ignore[arg-type]
        foreign_total=foreign,
    )


@router.get("/contributions", response_model=ContributionsOut)
def get_contributions(db: DB, user: CurrentUser) -> ContributionsOut:
    """Historial de aportaciones a inversiones y ahorro, con ritmo mensual y racha."""
    h = contrib.history(db, user.id)
    t = h.totals
    return ContributionsOut(
        this_month=t.this_month,
        this_year=t.this_year,
        total=t.total,
        withdrawn=t.withdrawn,
        starting=t.starting,
        pace=t.pace,
        streak=t.streak,
        pace_investing=h.investing.pace,
        streak_investing=h.investing.streak,
        track_start=h.track_start,
        destinations=[
            ContributionDestinationOut(key=k, label=label, kind=kind)  # type: ignore[arg-type]
            for k, (label, kind) in h.destinations.items()
        ],
        months=[
            ContributionMonthOut(
                year=y, month=m, total=sum(v.values(), Decimal(0)), by_destination=v
            )
            for (y, m), v in sorted(h.months.items())
        ],
        items=[
            ContributionItemOut(
                date=i.on,
                type=i.type,  # type: ignore[arg-type]
                kind=i.kind,  # type: ignore[arg-type]
                destination=i.destination,
                destination_label=i.destination_label,
                amount=i.amount,
                origin=i.origin,
                status=i.status,  # type: ignore[arg-type]
                tx_id=i.tx_id,
                movement_id=i.movement_id,
                asset_id=i.asset_id,
                account_id=i.account_id,
            )
            for i in h.items
        ],
    )
