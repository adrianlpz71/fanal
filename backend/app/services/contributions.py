"""Historial de aportaciones (inversiones y ahorro) a partir de las operaciones y los traspasos.

Inversiones: `inv_transactions`. Compras y aportaciones periódicas = aportación (también las
pendientes de VL, marcadas); ventas = retirada; traspasos entre fondos = traspaso (no es dinero
nuevo); posición inicial = saldo de partida.

Ahorro: traspasos cargados que entran en (o salen de) una cuenta de tipo ahorro o refugio.
"""

import uuid
from dataclasses import dataclass
from datetime import date
from decimal import Decimal

from sqlalchemy import select
from sqlalchemy.orm import Session

from app.domain import contributions as dc
from app.models import Account, Asset, InvTransaction, Movement
from app.services import analytics

SAVINGS_KINDS = ("ahorro", "refugio")
TX_TYPE = {
    "compra": dc.APORTACION,
    "aportacion_periodica": dc.APORTACION,
    "venta": dc.RETIRADA,
    "traspaso_entrada": dc.TRASPASO,
    "traspaso_salida": dc.TRASPASO,
    "posicion_inicial": dc.PARTIDA,
}


@dataclass(frozen=True)
class Item:
    on: date
    type: str
    kind: str  # inversion | ahorro
    destination: str
    destination_label: str
    amount: Decimal
    origin: str  # cuenta de gastos | periódica | importación | manual | traspaso
    status: str  # confirmada | pendiente
    tx_id: uuid.UUID | None = None
    movement_id: uuid.UUID | None = None
    asset_id: uuid.UUID | None = None
    account_id: uuid.UUID | None = None


@dataclass(frozen=True)
class History:
    items: list[Item]
    totals: dc.Totals
    investing: dc.Totals  # solo inversiones (sin cuentas de ahorro), para la Cartera
    months: dict[tuple[int, int], dict[str, Decimal]]
    destinations: dict[str, tuple[str, str]]  # clave → (nombre, inversion|ahorro)
    track_start: date | None


def _tx_origin(t: InvTransaction) -> str:
    if t.movement_id:
        return "cuenta de gastos"
    if t.kind == "aportacion_periodica":
        return "periódica"
    if t.import_batch_id:
        return "importación"
    return "manual"


def history(db: Session, user_id: uuid.UUID, today: date | None = None) -> History:
    today = today or date.today()
    items: list[Item] = []
    assets = {a.id: a for a in db.scalars(select(Asset).where(Asset.user_id == user_id))}
    for t in db.scalars(select(InvTransaction).where(InvTransaction.user_id == user_id)):
        typ = TX_TYPE.get(t.kind)
        if typ is None:
            continue
        a = assets.get(t.asset_id)
        if typ == dc.PARTIDA:
            amount = (t.units or 0) * (t.avg_cost or 0)
        else:
            amount = abs(t.amount_eur) + (t.fee if typ == dc.APORTACION else Decimal(0))
        items.append(
            Item(
                on=t.trade_date,
                type=typ,
                kind="inversion",
                destination=f"a:{t.asset_id}",
                destination_label=a.name if a else "Activo",
                amount=Decimal(amount).quantize(Decimal("0.01")),
                origin="traspaso" if typ == dc.TRASPASO else _tx_origin(t),
                status="pendiente" if t.status == "pendiente_vl" else "confirmada",
                tx_id=t.id,
                asset_id=t.asset_id,
            )
        )
    accounts = {
        a.id: a
        for a in db.scalars(
            select(Account).where(Account.user_id == user_id, Account.kind.in_(SAVINGS_KINDS))
        )
    }
    if accounts:
        rows = db.scalars(
            select(Movement).where(
                Movement.user_id == user_id,
                Movement.account_id.in_(accounts),
                Movement.kind == "transferencia",
                Movement.status == "posted",
            )
        )
        for m in rows:
            on = m.date or m.due_date
            if on is None or m.amount == 0:
                continue
            acc = accounts[m.account_id]
            items.append(
                Item(
                    on=on,
                    type=dc.APORTACION if m.amount > 0 else dc.RETIRADA,
                    kind="ahorro",
                    destination=f"c:{acc.id}",
                    destination_label=acc.name,
                    amount=abs(m.amount),
                    origin="cuenta de gastos" if m.transfer_pair_id else "manual",
                    status="confirmada",
                    movement_id=m.id,
                    account_id=acc.id,
                )
            )
    items.sort(key=lambda i: (i.on, i.destination_label), reverse=True)
    flows = [dc.Flow(i.on, i.amount, i.type, i.destination) for i in items]
    return History(
        items=items,
        totals=dc.totals(flows, today),
        investing=dc.totals(
            [
                dc.Flow(i.on, i.amount, i.type, i.destination)
                for i in items
                if i.kind == "inversion"
            ],
            today,
        ),
        months=dc.by_month(flows),
        destinations={i.destination: (i.destination_label, i.kind) for i in items},
        track_start=analytics.track_start(db, user_id),
    )
