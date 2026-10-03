"""Importación de operaciones de plataformas de inversión: vista previa → confirmar → deshacer.

Formatos (vistos en ficheros reales de 2026-10; nunca inventados):

· MyInvestor — "Consulta de órdenes" en CSV (`;`):
    Fecha de la orden;ISIN;Importe estimado;Nº de participaciones;Estado
    15/03/2026;IE00B03HCZ61;50 EUR;0,95;Finalizada
  Ojo: el importe usa punto decimal ("12.50 EUR") y las participaciones coma ("1,234"). No hay
  columna de compra/venta: todo son suscripciones salvo los traspasos, que se reconocen porque
  ese día sale TODA la posición de un fondo y entra otro (confirmado por el usuario).
  Las órdenes canceladas o rechazadas se ignoran; una finalizada sin participaciones se avisa.

· Neverless — "Download transactions" en CSV (`,`):
    Type,Date,Amount received,Asset received,Amount sent,Asset sent,Fee,Asset of the fee,
    Description,USD price of asset received,USD price of asset sent,USD price of fee asset,…,ID
  Deposit de EUR y Trade EUR→EURC (conversión automática) no afectan a la cartera.
  Trade EURC→BTC = compra (EURC cuenta 1:1 como euros). Deposit de cripto con "interest" =
  recompensa, valorada en euros con el precio en USD del fichero y el cambio oficial del BCE.

Cada operación lleva una huella (`dedupe_hash`) a partir de su id externo: reimportar el mismo
fichero (o uno que se solape) no duplica nada.
"""

import hashlib
import html
import re
import uuid
from collections import defaultdict
from collections.abc import Callable
from dataclasses import dataclass, field
from datetime import date
from decimal import Decimal, InvalidOperation
from typing import Any

from sqlalchemy import func, select
from sqlalchemy.orm import Session

from app.domain.portfolio import Tx, lots_for_transfer, replay
from app.importers import generic_broker as gb
from app.importers.tabular import Row, TableError, find_header, norm, read_table
from app.models import Asset, ImportBatch, InvTransaction, Platform
from app.services import inversiones as svc

ZERO = Decimal(0)
FIAT = {"EUR", "EURC"}  # EURC: euro digital 1:1 de Circle, lo usa Neverless al depositar
COINGECKO_IDS = {"BTC": "bitcoin", "ETH": "ethereum", "SOL": "solana", "ADA": "cardano"}
PLATFORM_NAMES = {"myinvestor": "MyInvestor", "neverless": "Neverless"}


class ImportFormatError(ValueError):
    pass


@dataclass
class Op:
    row: int
    kind: str  # compra | venta | recompensa | traspaso_salida | traspaso_entrada
    on: date
    key: str  # ISIN o ticker
    units: Decimal
    amount_eur: Decimal
    ref: str  # id externo estable
    fee: Decimal = ZERO
    note: str | None = None
    pair: int | None = None  # índice (en ops) del otro lado de un traspaso


@dataclass
class Parsed:
    source: str  # myinvestor | neverless | generic
    ops: list[Op]
    warnings: list[str] = field(default_factory=list)
    # Solo en el importador genérico (lo elige el usuario en el mapeo)
    platform_name: str | None = None
    key_kind: str | None = None  # isin | ticker
    asset_type: str | None = None  # fondo | etf | accion | cripto
    names: dict[str, str] = field(default_factory=dict)  # clave → nombre del fichero

    @property
    def key_type(self) -> str:
        if self.key_kind:
            return self.key_kind
        return "isin" if self.source == "myinvestor" else "ticker"

    @property
    def kind_of_asset(self) -> str:
        if self.asset_type:
            return self.asset_type
        return "fondo" if self.key_type == "isin" else "cripto"

    @property
    def platform(self) -> str:
        return self.platform_name or PLATFORM_NAMES[self.source]


# --- Detección y lectura ------------------------------------------------------------------
def detect(rows: list[Row]) -> str:
    for r in rows[:10]:
        cells = [norm(c) for c in r]
        if "fecha de la orden" in cells and "isin" in cells:
            return "myinvestor"
        if {"type", "amount received", "asset received", "amount sent"} <= set(cells):
            return "neverless"
    raise ImportFormatError(
        "No reconozco el fichero. Hoy Fanal lee: MyInvestor (consulta de órdenes, CSV) y "
        "Neverless (descargar transacciones, CSV)."
    )


def _dec(s: Any, decimal_comma: bool) -> Decimal | None:
    if s is None:
        return None
    t = str(s).strip().replace("EUR", "").replace("€", "").strip()
    if not t:
        return None
    t = t.replace(".", "").replace(",", ".") if decimal_comma else t.replace(",", "")
    try:
        return Decimal(t)
    except InvalidOperation:
        return None


def _date_es(s: Any) -> date | None:
    m = re.match(r"(\d{1,2})/(\d{1,2})/(\d{4})", str(s or "").strip())
    return date(int(m.group(3)), int(m.group(2)), int(m.group(1))) if m else None


def parse_myinvestor(rows: list[Row]) -> Parsed:
    h = find_header(rows, [["fecha de la orden"], ["isin"]])
    cols = {norm(c): i for i, c in enumerate(rows[h])}
    ci = {k: cols.get(k) for k in ("fecha de la orden", "isin", "importe estimado", "estado")}
    ui = next((i for c, i in cols.items() if c.startswith("n") and "participaciones" in c), None)
    if None in ci.values() or ui is None:
        raise ImportFormatError("Faltan columnas de MyInvestor (fecha, ISIN, importe, nº de "
                                "participaciones, estado)")  # fmt: skip
    p = Parsed("myinvestor", [])
    seen: dict[tuple, int] = defaultdict(int)
    raw: list[Op] = []
    for n, r in enumerate(rows[h + 1 :], start=h + 2):
        cells = list(r) + [None] * 8
        if all(c in (None, "") for c in r):
            continue
        d, isin = _date_es(cells[ci["fecha de la orden"]]), str(cells[ci["isin"]] or "").strip()
        state = norm(cells[ci["estado"]])
        amount = _dec(cells[ci["importe estimado"]], decimal_comma=False)
        units = _dec(cells[ui], decimal_comma=True)
        if d is None or len(isin) != 12 or amount is None:
            p.warnings.append(f"Fila {n}: no la entiendo ({list(r)[:5]})")
            continue
        if state in ("cancelada", "rechazada"):
            continue
        if state != "finalizada":
            p.warnings.append(f"Fila {n}: orden '{cells[ci['estado']]}' sin terminar, se ignora")
            continue
        if not units:
            p.warnings.append(
                f"Fila {n}: orden finalizada de {amount} € en {isin} el {d:%d/%m/%Y} sin "
                "participaciones; se ignora (revísala en MyInvestor)"
            )
            continue
        key = (d, isin, amount, units)
        seen[key] += 1
        ref = f"{d.isoformat()}|{isin}|{amount}|{units}|{seen[key]}"
        raw.append(Op(n, "compra", d, isin, units, amount, ref))
    # Cronológico y traspasos: el día que sale toda la posición de un fondo y entra otro
    raw.sort(key=lambda o: (o.on, o.row))
    held: dict[str, Decimal] = defaultdict(lambda: ZERO)
    by_day: dict[date, list[Op]] = defaultdict(list)
    for o in raw:
        by_day[o.on].append(o)
    for day in sorted(by_day):
        group = by_day[day]
        outs = [o for o in group if held[o.key] > 0 and abs(o.units - held[o.key]) <= Decimal("0.001")
                and any(x.key != o.key for x in group)]  # fmt: skip
        for o in outs:
            o.kind = "traspaso_salida"
            cands = [x for x in group if x.key != o.key and x.kind == "compra"]
            dest = min(cands, key=lambda x: abs(x.amount_eur - o.amount_eur))
            dest.kind = "traspaso_entrada"
            o.note = f"Traspaso a {dest.key}"
            dest.note = f"Traspaso desde {o.key}"
        for o in group:
            held[o.key] += -o.units if o.kind == "traspaso_salida" else o.units
        p.ops.extend(group)
    index = {id(o): i for i, o in enumerate(p.ops)}
    for o in p.ops:
        if o.kind == "traspaso_salida":
            dest = next(x for x in p.ops if x.on == o.on and x.kind == "traspaso_entrada"
                        and x.note == f"Traspaso desde {o.key}")  # fmt: skip
            o.pair, dest.pair = index[id(dest)], index[id(o)]
    return p


EurPerUsd = Callable[[date], Decimal | None]


def parse_neverless(rows: list[Row], eur_per_usd: EurPerUsd | None = None) -> Parsed:
    h = find_header(rows, [["type"], ["amount received"], ["asset received"]])
    cols = {norm(c): i for i, c in enumerate(rows[h])}

    def col(name: str) -> int:
        if name not in cols:
            raise ImportFormatError(f"Falta la columna '{name}' de Neverless")
        return cols[name]

    c = {k: col(k) for k in (
        "type", "date", "amount received", "asset received", "amount sent", "asset sent",
        "fee", "asset of the fee", "description", "usd price of asset received", "id",
    )}  # fmt: skip
    body = [list(r) + [None] * 20 for r in rows[h + 1 :] if any(x not in (None, "") for x in r)]
    # Respaldo del cambio: el propio fichero da el precio en USD del euro en los depósitos
    file_fx: list[tuple[date, Decimal]] = []
    for r in body:
        if str(r[c["asset received"]]).upper() == "EUR" and r[c["usd price of asset received"]]:
            usd = _dec(r[c["usd price of asset received"]], decimal_comma=False)
            if usd:
                file_fx.append((date.fromisoformat(str(r[c["date"]])[:10]), 1 / usd))
    p = Parsed("neverless", [])
    fallback_used = False
    for n, r in enumerate(body, start=h + 2):
        typ = str(r[c["type"]] or "").strip().lower()
        d = date.fromisoformat(str(r[c["date"]])[:10])
        got, got_asset = (
            _dec(r[c["amount received"]], False),
            str(r[c["asset received"]] or "").upper(),
        )
        sent, sent_asset = _dec(r[c["amount sent"]], False), str(r[c["asset sent"]] or "").upper()
        fee = _dec(r[c["fee"]], False) or ZERO
        fee_asset = str(r[c["asset of the fee"]] or "").upper()
        desc = str(r[c["description"]] or "")
        rid = str(r[c["id"]] or f"fila{n}")
        fee_eur = fee if fee_asset in FIAT else ZERO
        if typ == "deposit":
            if got_asset in FIAT:
                continue  # entrada de euros a la plataforma
            if "interest" in desc.lower() or "reward" in desc.lower():
                usd = _dec(r[c["usd price of asset received"]], False)
                rate = eur_per_usd(d) if eur_per_usd else None
                if rate is None and file_fx:
                    rate = min(file_fx, key=lambda x: abs((x[0] - d).days))[1]
                    fallback_used = True
                if not got or not usd or rate is None:
                    p.warnings.append(f"Fila {n}: interés sin precio para valorarlo; se ignora")
                    continue
                value = (got * usd * rate).quantize(Decimal("0.0001"))
                p.ops.append(Op(n, "recompensa", d, got_asset, got, value, f"{rid}|in",
                                note=desc or "Interés"))  # fmt: skip
            else:
                p.warnings.append(f"Fila {n}: depósito de {got} {got_asset} desde fuera; no se "
                                  "importa (añádelo como traspaso si viene de otra plataforma)")  # fmt: skip
        elif typ == "trade":
            if got_asset in FIAT and sent_asset in FIAT:
                continue  # EUR ↔ EURC
            if sent_asset in FIAT and got:
                p.ops.append(Op(n, "compra", d, got_asset, got, sent or ZERO, f"{rid}|buy",
                                fee=fee_eur))  # fmt: skip
            elif got_asset in FIAT and sent:
                p.ops.append(Op(n, "venta", d, sent_asset, sent, got or ZERO, f"{rid}|sell",
                                fee=fee_eur))  # fmt: skip
            else:
                p.warnings.append(f"Fila {n}: permuta {sent_asset}→{got_asset}; aún no se "
                                  "importa (es una venta y una compra a efectos fiscales)")  # fmt: skip
        elif typ == "withdrawal":
            if got_asset not in FIAT and sent_asset not in FIAT:
                p.warnings.append(f"Fila {n}: retirada de {sent} {sent_asset}; no se importa")
        else:
            p.warnings.append(f"Fila {n}: tipo '{r[c['type']]}' desconocido; se ignora")
    if fallback_used:
        p.warnings.append("Algún interés se ha valorado con el cambio EUR/USD del propio fichero "
                          "porque no se pudo consultar el del BCE")  # fmt: skip
    p.ops.sort(key=lambda o: (o.on, o.row))
    return p


def read(
    content: bytes,
    filename: str,
    eur_per_usd: EurPerUsd | None = None,
    mapping: dict[str, Any] | None = None,
) -> Parsed:
    try:
        rows = read_table(content, filename)
    except TableError as e:
        raise ImportFormatError(str(e)) from None
    if mapping is not None:
        return parse_generic(rows, mapping)
    src = detect(rows)
    return parse_myinvestor(rows) if src == "myinvestor" else parse_neverless(rows, eur_per_usd)


def parse_generic(rows: list[Row], mapping: dict[str, Any]) -> Parsed:
    """Cualquier fichero de operaciones, con el mapeo de columnas del usuario."""
    try:
        m = gb.mapping_from_dict(mapping)
    except gb.MappingError as e:
        raise ImportFormatError(str(e)) from None
    gops, warnings = gb.parse(rows, m)
    names: dict[str, str] = {}
    ops = []
    for g in gops:
        ops.append(Op(g.row, g.kind, g.on, g.key, g.units, g.amount_eur, g.ref, g.fee))
        if g.name and g.key not in names:
            names[g.key] = g.name
    return Parsed("generic", ops, warnings, m.platform, m.key_type, m.asset_type, names)


# --- Plan --------------------------------------------------------------------------------------
def dedupe_hash(user_id: uuid.UUID, source: str, ref: str) -> str:
    return hashlib.sha256(f"{user_id}|{source}|{ref}".encode()).hexdigest()


@dataclass
class PlannedOp:
    op: Op
    outcome: str  # new | duplicate | complete_pending
    asset: Asset | None  # None = se crea
    hash: str
    pending_id: uuid.UUID | None = None  # compra pendiente de VL que esta orden completa


@dataclass
class PositionPreview:
    key: str
    name: str
    units_now: Decimal
    units_after: Decimal
    avg_cost_after: Decimal
    replaced_initial: bool


@dataclass
class Plan:
    parsed: Parsed
    platform: str
    ops: list[PlannedOp]
    create: dict[str, str]  # clave → nombre del activo a crear
    initial: list[InvTransaction]  # posiciones iniciales que se sustituyen
    positions: list[PositionPreview]

    @property
    def counts(self) -> dict[str, int]:
        out: dict[str, int] = defaultdict(int)
        for p in self.ops:
            out[p.outcome] += 1
        return dict(out)


def _find_asset(
    db: Session, user_id: uuid.UUID, key: str, key_type: str, asset_type: str = "cripto"
) -> Asset | None:
    q = select(Asset).where(Asset.user_id == user_id, Asset.archived.is_(False))
    if key_type == "isin":
        q = q.where(Asset.isin == key)
    else:
        q = q.where(func.upper(Asset.ticker) == key.upper(), Asset.type == asset_type)
    return db.scalars(q.order_by(Asset.created_at)).first()


def plan(
    db: Session,
    user_id: uuid.UUID,
    parsed: Parsed,
    replace_initial: bool,
    name_for: Callable[[str], str | None] | None = None,
) -> Plan:
    keys = sorted({o.key for o in parsed.ops})
    assets = {k: _find_asset(db, user_id, k, parsed.key_type, parsed.kind_of_asset) for k in keys}
    create = {k: parsed.names.get(k)
              or (name_for(k) if name_for and parsed.key_type == "isin" else None)
              or (f"Fondo {k}" if parsed.key_type == "isin" else k)
              for k, a in assets.items() if a is None}  # fmt: skip
    existing = set(db.scalars(select(InvTransaction.dedupe_hash).where(
        InvTransaction.user_id == user_id, InvTransaction.dedupe_hash.is_not(None))))  # fmt: skip
    pending = list(db.scalars(select(InvTransaction).where(
        InvTransaction.user_id == user_id, InvTransaction.status == "pendiente_vl")))  # fmt: skip
    taken: set[uuid.UUID] = set()
    planned = []
    for o in parsed.ops:
        hsh = dedupe_hash(user_id, parsed.source, o.ref)
        a = assets[o.key]
        if hsh in existing:
            planned.append(PlannedOp(o, "duplicate", a, hsh))
            continue
        # Una orden que ya se anotó en Faro como pendiente de VL ("Generar órdenes", plan
        # periódico): se completa con los datos reales en vez de duplicarla
        match = next((t for t in pending if a is not None and t.asset_id == a.id
                      and t.id not in taken and o.kind == "compra" and o.amount_eur
                      and abs((t.trade_date - o.on).days) <= 7
                      and abs(t.amount_eur - o.amount_eur) <= o.amount_eur * Decimal("0.02")),
                     None)  # fmt: skip
        if match is not None:
            taken.add(match.id)
            planned.append(PlannedOp(o, "complete_pending", a, hsh, match.id))
        else:
            planned.append(PlannedOp(o, "new", a, hsh))
    initial: list[InvTransaction] = []
    if replace_initial:
        ids = [a.id for a in assets.values() if a is not None]
        initial = list(db.scalars(select(InvTransaction).where(
            InvTransaction.user_id == user_id, InvTransaction.asset_id.in_(ids),
            InvTransaction.kind == "posicion_inicial")))  # fmt: skip
    # Posición resultante por activo (lo que habrá tras confirmar)
    replaced_ids = {t.id for t in initial}
    new = [p.op for p in planned if p.outcome in ("new", "complete_pending")]

    def simulated(k: str, until: Op | None = None) -> list[Tx]:
        a = assets[k]
        txs = svc._txs(db, a, exclude=replaced_ids) if a else []
        for o in new:
            if o.key != k or (until is not None and (o is until or o.on > until.on)):
                continue
            if o.kind == "traspaso_entrada" and o.pair is not None:
                src = parsed.ops[o.pair]
                lots = lots_for_transfer(replay(simulated(src.key, until=src)), src.units)
                txs.append(Tx("traspaso_entrada", o.on, units=o.units, lots=tuple(lots)))
            else:
                txs.append(Tx(o.kind, o.on, units=o.units, amount=o.amount_eur, fee=o.fee))
        return sorted(txs, key=lambda t: t.on)

    positions = []
    for k in keys:
        a = assets[k]
        after = replay(simulated(k))
        positions.append(PositionPreview(
            k, a.name if a else create[k], svc.position(db, a).units if a else ZERO,
            after.units, after.avg_cost,
            a is not None and any(t.asset_id == a.id for t in initial),
        ))  # fmt: skip
    return Plan(parsed, parsed.platform, planned, create, initial, positions)


# --- Confirmar y deshacer ------------------------------------------------------------------------
def commit(db: Session, user_id: uuid.UUID, pl: Plan, filename: str, sha256: str) -> ImportBatch:
    batch = ImportBatch(user_id=user_id, kind="platform", filename=filename, file_sha256=sha256,
                        summary={})  # fmt: skip
    db.add(batch)
    db.flush()
    platform = db.scalar(select(Platform).where(Platform.user_id == user_id,
                                                Platform.name == pl.platform))  # fmt: skip
    crypto = pl.parsed.kind_of_asset == "cripto"
    if platform is None:
        platform = Platform(user_id=user_id, name=pl.platform,
                            kind="exchange" if crypto else "broker",
                            units_decimals=8 if crypto else 4)  # fmt: skip
        db.add(platform)
        db.flush()
    classes = svc.ensure_classes(db, user_id)
    created: list[str] = []
    assets: dict[str, Asset] = {p.op.key: p.asset for p in pl.ops if p.asset is not None}
    kind = pl.parsed.kind_of_asset
    by_isin = pl.parsed.key_type == "isin"
    klass = {"fondo": "Fondos", "etf": "Fondos", "cripto": "Cripto", "accion": "Acciones"}[kind]
    for key, name in pl.create.items():
        # Precio automático: fondos y ETF por ISIN en FT; cripto conocida en CoinGecko
        ft = by_isin and kind in ("fondo", "etf")
        gecko = kind == "cripto" and not by_isin and key in COINGECKO_IDS
        a = Asset(
            user_id=user_id, name=name, type=kind,
            asset_class_id=classes[klass].id if classes and klass in classes else None,
            platform_id=platform.id, isin=key if by_isin else None, ticker=None if by_isin else key,
            coingecko_id=COINGECKO_IDS.get(key) if gecko else None,
            price_provider="ft" if ft else ("coingecko" if gecko else "manual"),
            price_ref=f"{key}:EUR" if ft else None,
        )  # fmt: skip
        db.add(a)
        db.flush()
        assets[key] = a
        created.append(str(a.id))
    removed = []
    for t in pl.initial:
        removed.append({k: (str(v) if v is not None else None) for k, v in {
            "id": t.id, "asset_id": t.asset_id, "trade_date": t.trade_date.isoformat(),
            "units": t.units, "avg_cost": t.avg_cost, "amount_eur": t.amount_eur,
            "dedupe_hash": t.dedupe_hash, "external_id": t.external_id, "notes": t.notes,
        }.items()})  # fmt: skip
        db.delete(t)
    db.flush()
    by_index: dict[int, InvTransaction] = {}
    tx_ids = []
    completed = []
    for i, p in enumerate(pl.ops):
        if p.outcome == "complete_pending" and p.pending_id:
            t = db.get(InvTransaction, p.pending_id)
            if t is None or t.status != "pendiente_vl":
                continue
            completed.append({"id": str(t.id), "trade_date": t.trade_date.isoformat(),
                              "amount_eur": str(t.amount_eur), "fee": str(t.fee)})  # fmt: skip
            o = p.op
            t.status, t.units, t.trade_date, t.amount_eur = "liquidada", o.units, o.on, q_eur(o)
            t.price = (o.amount_eur / o.units).quantize(Decimal("1E-10")) if o.units else None
            t.dedupe_hash, t.external_id, t.settle_date = p.hash, o.ref[:120], date.today()
            by_index[i] = t
            continue
        if p.outcome != "new":
            continue
        o = p.op
        t = InvTransaction(
            user_id=user_id, asset_id=assets[o.key].id, kind=o.kind, status="liquidada",
            trade_date=o.on, amount_eur=o.amount_eur.quantize(Decimal("0.01")), units=o.units,
            price=(o.amount_eur / o.units).quantize(Decimal("1E-10")) if o.units else None,
            fee=o.fee, dedupe_hash=p.hash, external_id=o.ref[:120], import_batch_id=batch.id,
            notes=o.note,
        )  # fmt: skip
        db.add(t)
        db.flush()
        by_index[i] = t
        tx_ids.append(str(t.id))
    for i, t in by_index.items():
        o = pl.ops[i].op
        if o.pair is not None and o.pair in by_index:
            t.pair_id = by_index[o.pair].id
    batch.summary = {"counts": pl.counts, "source": pl.parsed.source, "created_assets": created,
                     "removed_initial": removed, "transactions": tx_ids,
                     "completed_pending": completed}  # fmt: skip
    db.flush()
    return batch


def undo(db: Session, batch: ImportBatch) -> int:
    n = 0
    for t in db.scalars(select(InvTransaction).where(InvTransaction.import_batch_id == batch.id)):
        t.pair_id = None
    db.flush()
    for t in db.scalars(select(InvTransaction).where(InvTransaction.import_batch_id == batch.id)):
        db.delete(t)
        n += 1
    db.flush()
    for r in batch.summary.get("removed_initial", []):
        db.add(InvTransaction(
            id=uuid.UUID(r["id"]), user_id=batch.user_id, asset_id=uuid.UUID(r["asset_id"]),
            kind="posicion_inicial", status="liquidada",
            trade_date=date.fromisoformat(r["trade_date"]), units=Decimal(r["units"]),
            avg_cost=Decimal(r["avg_cost"]) if r["avg_cost"] else None,
            amount_eur=Decimal(r["amount_eur"] or 0), dedupe_hash=r["dedupe_hash"],
            external_id=r["external_id"], notes=r["notes"],
        ))  # fmt: skip
    db.flush()
    for aid in batch.summary.get("created_assets", []):
        a = db.get(Asset, uuid.UUID(aid))
        has = db.scalar(
            select(InvTransaction.id).where(InvTransaction.asset_id == uuid.UUID(aid)).limit(1)
        )
        if a is not None and not has:
            db.delete(a)
    for r in batch.summary.get("completed_pending", []):
        t = db.get(InvTransaction, uuid.UUID(r["id"]))
        if t is not None and t.user_id == batch.user_id:
            t.status, t.units, t.price, t.dedupe_hash, t.external_id = (
                "pendiente_vl", None, None, None, None)  # fmt: skip
            t.trade_date, t.amount_eur = (
                date.fromisoformat(r["trade_date"]),
                Decimal(r["amount_eur"]),
            )
            t.fee, t.settle_date = Decimal(r["fee"]), None
            n += 1
    batch.status = "undone"
    db.flush()
    return n


def fund_name_ft(client: Any, isin: str) -> str | None:
    """Nombre de un fondo por su ISIN (cabecera de la ficha de FT). Solo para bautizar activos."""
    try:
        r = client.get("https://markets.ft.com/data/funds/tearsheet/summary",
                       params={"s": f"{isin}:EUR"}, follow_redirects=False)  # fmt: skip
        m = re.search(r'mod-tearsheet-overview__header__name[^"]*">([^<]+)<', r.text)
        return html.unescape(m.group(1)).strip() if r.status_code == 200 and m else None
    except Exception:
        return None


def q_eur(o: Op) -> Decimal:
    return o.amount_eur.quantize(Decimal("0.01"))
