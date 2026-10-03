"""Exportación de todos los datos de un usuario (JSON o Excel, una hoja por tabla) e informe
fiscal anual de inversiones y cuentas.

No se exporta nada de seguridad (contraseñas, 2FA, tokens, intentos de login).
"""

import io
import json
import re
import uuid
from dataclasses import dataclass
from datetime import date, datetime
from decimal import Decimal
from typing import Any

import openpyxl
from sqlalchemy import select
from sqlalchemy.orm import Session

from app import models as m
from app.domain.portfolio import replay
from app.services import inversiones as inv
from app.services.categories_seed import normalize

# Tablas con user_id que se exportan (en este orden)
USER_TABLES = [
    m.Account,
    m.Category,
    m.PayCycle,
    m.Movement,
    m.RecurringTemplate,
    m.InstallmentPlan,
    m.Person,
    m.MovementShare,
    m.Debt,
    m.Tracker,
    m.CategoryRule,
    m.Budget,
    m.ImportBatch,
    m.Platform,
    m.AssetClass,
    m.Asset,
    m.AllocationTarget,
    m.InvTransaction,
    m.PositionCorrection,
    m.PriceHistory,
    m.PortfolioSnapshot,
    m.ContributionPlan,
    m.AssetExposure,
    m.Goal,
    m.UserSetting,
]
# Tablas hijas sin user_id: (modelo, columna FK, modelo padre)
CHILD_TABLES = [
    (m.MovementLine, "movement_id", m.Movement),
    (m.Installment, "plan_id", m.InstallmentPlan),
    (m.RecurringPriceChange, "template_id", m.RecurringTemplate),
]
PROFILE_FIELDS = ("email", "display_name", "birth_date", "tax_region", "created_at")


def _plain(v: Any) -> Any:
    if isinstance(v, Decimal | uuid.UUID):
        return str(v)
    if isinstance(v, datetime | date):
        return v.isoformat()
    return v


def _rows(objs: Any, model: Any) -> list[dict[str, Any]]:
    cols = [c.key for c in model.__table__.columns if c.key != "user_id"]
    return [{c: _plain(getattr(o, c)) for c in cols} for o in objs]


def collect(db: Session, user: m.User) -> dict[str, list[dict[str, Any]]]:
    data: dict[str, list[dict[str, Any]]] = {
        "perfil": [{f: _plain(getattr(user, f)) for f in PROFILE_FIELDS}]
    }
    ids: dict[Any, set[uuid.UUID]] = {}
    for model in USER_TABLES:
        objs = list(db.scalars(select(model).where(model.user_id == user.id)))
        ids[model] = {o.id for o in objs}
        data[model.__tablename__] = _rows(objs, model)
    for model, fk, parent in CHILD_TABLES:
        parent_ids = ids.get(parent, set())
        objs = (
            list(db.scalars(select(model).where(getattr(model, fk).in_(parent_ids))))
            if parent_ids
            else []
        )
        data[model.__tablename__] = _rows(objs, model)
    return data


def to_json(data: dict[str, Any]) -> bytes:
    payload = {"faro_export": 1, "generated_at": datetime.now().isoformat(), "data": data}
    return json.dumps(payload, ensure_ascii=False, indent=1).encode()


def to_xlsx(data: dict[str, list[dict[str, Any]]]) -> bytes:
    wb = openpyxl.Workbook()
    wb.remove(wb.active)
    for name, rows in data.items():
        ws = wb.create_sheet(name[:31])
        if not rows:
            ws.append(["(vacía)"])
            continue
        cols = list(rows[0].keys())
        ws.append(cols)
        for r in rows:
            ws.append(
                [
                    json.dumps(v, ensure_ascii=False) if isinstance(v, dict | list) else v
                    for v in (r[c] for c in cols)
                ]
            )
    buf = io.BytesIO()
    wb.save(buf)
    return buf.getvalue()


# --- Informe fiscal anual -------------------------------------------------------------------------
@dataclass
class SaleLine:
    asset: str
    date: date
    units: Decimal
    proceeds: Decimal  # valor de transmisión (neto de comisiones)
    cost: Decimal  # valor de adquisición FIFO
    gain: Decimal


@dataclass
class IncomeLine:
    source: str
    date: date
    amount: Decimal
    kind: str  # interes_cuenta | dividendo | interes | recompensa_cripto


@dataclass
class YearEndLine:
    name: str
    kind: str  # cuenta | activo
    value: Decimal
    foreign_hint: bool  # entidad/plataforma extranjera (para el modelo 720 si se supera el umbral)


@dataclass
class TaxReport:
    year: int
    sales: list[SaleLine]
    transfers: list[tuple[str, date, Decimal]]  # traspasos: no tributan
    income: list[IncomeLine]
    year_end: list[YearEndLine]

    @property
    def gains_total(self) -> Decimal:
        return sum((s.gain for s in self.sales), Decimal(0))

    @property
    def income_total(self) -> Decimal:
        return sum((i.amount for i in self.income), Decimal(0))


INTEREST_RX = re.compile(r"\b(interes|intereses|interest|remuneracion)\b")


def tax_report(db: Session, user_id: uuid.UUID, year: int) -> TaxReport:
    sales: list[SaleLine] = []
    transfers: list[tuple[str, date, Decimal]] = []
    income: list[IncomeLine] = []
    year_end: list[YearEndLine] = []
    end = date(year, 12, 31)
    for a in inv.assets(db, user_id, include_archived=True):
        txs = inv._txs(db, a)
        pos = replay(txs)
        for r in pos.realized:
            if r.on.year == year:
                sales.append(SaleLine(a.name, r.on, r.units, r.proceeds, r.cost_fifo, r.gain_fifo))
        for t in db.scalars(
            select(m.InvTransaction).where(
                m.InvTransaction.asset_id == a.id, m.InvTransaction.status == "liquidada"
            )
        ):
            if t.trade_date.year != year:
                continue
            if t.kind == "traspaso_salida":
                transfers.append((a.name, t.trade_date, t.units or Decimal(0)))
            elif t.kind in ("dividendo", "interes"):
                income.append(IncomeLine(a.name, t.trade_date, t.amount_eur, t.kind))
            elif t.kind == "recompensa":
                income.append(IncomeLine(a.name, t.trade_date, t.amount_eur, "recompensa_cripto"))
        at_end = replay([t for t in txs if t.on <= end])
        if at_end.units > 0:
            price = db.scalar(
                select(m.PriceHistory.price)
                .where(m.PriceHistory.asset_id == a.id, m.PriceHistory.date <= end)
                .order_by(m.PriceHistory.date.desc())
                .limit(1)
            )
            value = at_end.units * price if price is not None else at_end.cost
            plat = db.get(m.Platform, a.platform_id) if a.platform_id else None
            foreign = bool(a.isin and not a.isin.startswith("ES")) or (
                plat is not None and plat.kind == "exchange"
            )
            year_end.append(YearEndLine(a.name, "activo", value, foreign))
    for acc in db.scalars(select(m.Account).where(m.Account.user_id == user_id)):
        for mv in db.scalars(
            select(m.Movement).where(
                m.Movement.account_id == acc.id,
                m.Movement.status == "posted",
                m.Movement.amount > 0,
            )
        ):
            if mv.date and mv.date.year == year and INTEREST_RX.search(normalize(mv.concept)):
                income.append(IncomeLine(acc.name, mv.date, mv.amount, "interes_cuenta"))
        if acc.opening_date <= end:
            # Sin fecha (p. ej. importados del Excel): cuentan el día que empezó su ciclo
            starts = {
                c.id: c.start_date
                for c in db.scalars(select(m.PayCycle).where(m.PayCycle.account_id == acc.id))
            }
            bal = acc.opening_balance
            for mv in db.scalars(
                select(m.Movement).where(
                    m.Movement.account_id == acc.id, m.Movement.status == "posted"
                )
            ):
                d = mv.date or starts.get(mv.cycle_id)
                if d is not None and d <= end:
                    bal += mv.amount
            year_end.append(YearEndLine(acc.name, "cuenta", bal, False))
    sales.sort(key=lambda s: s.date)
    income.sort(key=lambda i: i.date)
    return TaxReport(year, sales, transfers, income, year_end)
