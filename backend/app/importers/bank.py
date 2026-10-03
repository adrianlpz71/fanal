"""Importación de extractos bancarios (CSV/XLSX) en una cuenta.

Flujo: leer tabla → detectar/aplicar mapeo de columnas → líneas normalizadas → plan:
  · duplicate        la línea ya se importó (huella `bank_ref`)
  · match_planned    casa con un movimiento PREVISTO (importe exacto, fecha ±7 días) → se marca
                     como cargado con la fecha real
  · match_posted     casa con un movimiento ya CARGADO a mano sin huella (importe exacto,
                     fecha ±3 días) → solo se le añade la huella (evita duplicarlo)
  · new              se crea, con categoría por reglas aprendidas / palabras clave
Deshacer un lote revierte exactamente lo que hizo (guardado en import_batches.summary).

El mapeo concreto de cada banco se guarda como perfil; NO se inventa: se ajusta con
ficheros reales."""

import hashlib
import uuid
from collections import defaultdict
from dataclasses import dataclass, field
from datetime import date, datetime
from decimal import Decimal, InvalidOperation
from typing import Any

from sqlalchemy import select
from sqlalchemy.orm import Session

from app.domain import calendar as cal
from app.domain.money import parse_es_amount, q2
from app.importers.tabular import Row, TableError, find_header, norm
from app.models import Account, ImportBatch, Movement, PayCycle
from app.services import gastos as svc
from app.services import gastos_extra as ex
from app.services.categories_seed import category_index, guess_category_path, normalize

# Palabras que identifican cada columna (normalizadas, sin tildes)
COLUMN_HINTS: dict[str, list[str]] = {
    "date": ["fecha operacion", "f. operacion", "f.operacion", "fecha"],
    "value_date": ["fecha valor", "f. valor", "f.valor"],
    "concept": ["concepto", "descripcion", "movimiento", "detalle"],
    "notes": ["observaciones", "mas datos", "informacion adicional"],
    "amount": ["importe", "cantidad"],
    "debit": ["cargo", "debe", "gasto"],
    "credit": ["abono", "haber", "ingreso"],
    "balance": ["saldo", "disponible"],
}


@dataclass
class Mapping:
    date: int
    concept: list[int]
    amount: int | None = None
    debit: int | None = None
    credit: int | None = None
    value_date: int | None = None
    balance: int | None = None
    notes: int | None = None
    header_row: int = 0
    date_format: str | None = None  # p. ej. "%d/%m/%Y"; None = automático

    def as_dict(self) -> dict[str, Any]:
        return self.__dict__.copy()


def detect_mapping(rows: list[Row]) -> Mapping:
    h = find_header(rows, [["fecha", "f. operacion", "f.operacion", "f. valor"],
                           ["concepto", "descripcion", "movimiento", "detalle"],
                           ["importe", "cantidad", "cargo", "abono"]])  # fmt: skip
    headers = [norm(c) for c in rows[h]]
    used: set[int] = set()

    def pick(key: str, multi: bool = False) -> Any:
        found = []
        for hint in COLUMN_HINTS[key]:
            for i, c in enumerate(headers):
                if i not in used and hint in c and i not in found:
                    found.append(i)
                    if not multi:
                        used.add(i)
                        return i
        used.update(found)
        return found if multi else None

    value_date = pick("value_date")
    date_col = pick("date")
    concept = pick("concept", multi=True)
    notes = pick("notes")
    amount = pick("amount")
    debit = credit = None
    if amount is None:
        debit, credit = pick("debit"), pick("credit")
    balance = pick("balance")
    if date_col is None or not concept or (amount is None and debit is None and credit is None):
        raise TableError("No reconozco las columnas (fecha, concepto, importe)")
    return Mapping(date=date_col, concept=concept, amount=amount, debit=debit, credit=credit,
                   value_date=value_date, balance=balance, notes=notes, header_row=h)  # fmt: skip


def mapping_from_dict(d: dict[str, Any]) -> Mapping:
    return Mapping(**{k: v for k, v in d.items() if k in Mapping.__dataclass_fields__})


def _to_date(v: Any, fmt: str | None) -> date | None:
    if isinstance(v, datetime):
        return v.date()
    if isinstance(v, date):
        return v
    s = str(v or "").strip()
    if not s:
        return None
    for f in ([fmt] if fmt else []) + ["%d/%m/%Y", "%d-%m-%Y", "%Y-%m-%d", "%d/%m/%y", "%d.%m.%Y"]:
        try:
            return datetime.strptime(s[:10] if f == "%Y-%m-%d" else s, f).date()
        except ValueError:
            continue
    return None


def _to_amount(v: Any) -> Decimal | None:
    if v is None or v == "":
        return None
    if isinstance(v, int | float) and not isinstance(v, bool):
        return q2(Decimal(str(v)))
    a = parse_es_amount(str(v))
    try:
        return q2(a) if a is not None else None
    except InvalidOperation:
        return None


@dataclass
class BankLine:
    index: int  # fila en el fichero (1-based, para mensajes)
    date: date
    concept: str
    amount: Decimal
    balance: Decimal | None
    notes: str | None
    ref: str = ""


@dataclass
class ParseResult:
    lines: list[BankLine]
    errors: list[str] = field(default_factory=list)


def parse_lines(rows: list[Row], m: Mapping) -> ParseResult:
    out: list[BankLine] = []
    errors: list[str] = []
    for i, row in enumerate(rows[m.header_row + 1 :], start=m.header_row + 2):
        cells = list(row) + [None] * 20
        if all(c in (None, "") for c in row):
            continue
        d = _to_date(cells[m.date], m.date_format)
        if m.amount is not None:
            amt = _to_amount(cells[m.amount])
        else:
            deb = _to_amount(cells[m.debit]) if m.debit is not None else None
            cre = _to_amount(cells[m.credit]) if m.credit is not None else None
            amt = (cre or Decimal(0)) - abs(deb or Decimal(0)) if (deb or cre) else None
        concept = " · ".join(str(cells[c]).strip() for c in m.concept if cells[c] not in (None, ""))
        if d is None or amt is None:
            if any(c not in (None, "") for c in row):
                errors.append(f"Fila {i}: no entiendo la fecha o el importe ({row[:6]})")
            continue
        out.append(BankLine(
            index=i, date=d, concept=concept[:160] or "(sin concepto)", amount=amt,
            balance=_to_amount(cells[m.balance]) if m.balance is not None else None,
            notes=str(cells[m.notes]).strip() if m.notes is not None and cells[m.notes] else None,
        ))  # fmt: skip
    return ParseResult(out, errors)


def fingerprint(account_id: uuid.UUID, lines: list[BankLine]) -> None:
    """Huella estable por línea: cuenta + fecha + importe + concepto + nº de aparición de esa
    misma combinación en el fichero (dos cafés iguales el mismo día no se funden en uno)."""
    seen: dict[tuple, int] = defaultdict(int)
    for ln in sorted(lines, key=lambda x: (x.date, x.index)):
        key = (ln.date.isoformat(), str(ln.amount), normalize(ln.concept))
        seen[key] += 1
        raw = f"{account_id}|{'|'.join(key)}|{seen[key]}"
        ln.ref = hashlib.sha256(raw.encode()).hexdigest()[:40]


@dataclass
class PlannedLine:
    line: BankLine
    outcome: str  # before_opening | duplicate | match_planned | match_posted | new
    movement_id: uuid.UUID | None = None
    category_id: uuid.UUID | None = None


def _similarity(a: str, b: str) -> float:
    ta, tb = set(normalize(a).split()), set(normalize(b).split())
    return len(ta & tb) / max(len(ta | tb), 1)


def plan(
    db: Session, user_id: uuid.UUID, account: Account, lines: list[BankLine]
) -> list[PlannedLine]:
    fingerprint(account.id, lines)
    existing = set(db.scalars(select(Movement.bank_ref).where(
        Movement.user_id == user_id, Movement.account_id == account.id,
        Movement.bank_ref.is_not(None))))  # fmt: skip
    planned = list(db.scalars(select(Movement).where(
        Movement.user_id == user_id, Movement.account_id == account.id,
        Movement.status == "planned")))  # fmt: skip
    posted_free = list(db.scalars(select(Movement).where(
        Movement.user_id == user_id, Movement.account_id == account.id,
        Movement.status == "posted", Movement.bank_ref.is_(None),
        Movement.kind != "nomina", Movement.date.is_not(None))))  # fmt: skip
    cats = category_index(db, user_id)
    taken: set[uuid.UUID] = set()
    out: list[PlannedLine] = []
    for ln in lines:
        if ln.ref in existing:
            out.append(PlannedLine(ln, "duplicate"))
            continue

        def best(
            cands: list[Movement], days: int, use_due: bool, ln: BankLine = ln
        ) -> Movement | None:
            ok = []
            for mv in cands:
                if mv.id in taken or mv.amount != ln.amount:
                    continue
                ref_date = (mv.due_date or mv.date) if use_due else mv.date
                if ref_date is not None and abs((ref_date - ln.date).days) > days:
                    continue
                ok.append(mv)
            ok.sort(key=lambda mv: -_similarity(mv.concept, ln.concept))
            return ok[0] if ok else None

        mv = best(planned, 7, use_due=True)
        if mv is not None:
            taken.add(mv.id)
            out.append(PlannedLine(ln, "match_planned", mv.id, mv.category_id))
            continue
        mv = best(posted_free, 3, use_due=False)
        if mv is not None:
            taken.add(mv.id)
            out.append(PlannedLine(ln, "match_posted", mv.id, mv.category_id))
            continue
        if ln.date < account.opening_date:
            # Sin pareja y anterior al saldo inicial de la cuenta: ya está dentro de ese saldo;
            # crearlo lo contaría dos veces
            out.append(PlannedLine(ln, "before_opening"))
            continue
        cid = ex.rule_category(db, user_id, ln.concept)
        if cid is None and (path := guess_category_path(ln.concept)):
            cid = cats.get(path)
        out.append(PlannedLine(ln, "new", None, cid))
    return out


def _cycle_for(db: Session, user_id: uuid.UUID, account: Account, d: date) -> uuid.UUID | None:
    payday = int(svc.get_settings(db, user_id)["payday_day"])
    label = cal.cycle_for_date(d, payday).label
    c = db.scalar(select(PayCycle).where(PayCycle.user_id == user_id,
                                         PayCycle.account_id == account.id,
                                         PayCycle.label == label))  # fmt: skip
    if c is not None:
        return c.id
    cur = svc.open_cycle(db, user_id, account.id)
    return cur.id if cur else None


def commit(
    db: Session, user_id: uuid.UUID, account: Account, planned: list[PlannedLine],
    filename: str, sha256: str,
) -> ImportBatch:  # fmt: skip
    batch = ImportBatch(user_id=user_id, kind="bank", account_id=account.id, filename=filename,
                        file_sha256=sha256, summary={})  # fmt: skip
    db.add(batch)
    db.flush()
    changes: list[dict[str, Any]] = []
    counts: dict[str, int] = defaultdict(int)
    for p in planned:
        counts[p.outcome] += 1
        ln = p.line
        if p.outcome in ("duplicate", "before_opening"):
            continue
        if p.outcome in ("match_planned", "match_posted") and p.movement_id:
            mv = db.get(Movement, p.movement_id)
            if mv is None:
                continue
            changes.append({"op": p.outcome, "id": str(mv.id), "status": mv.status,
                            "date": mv.date.isoformat() if mv.date else None})  # fmt: skip
            mv.bank_ref, mv.import_batch_id = ln.ref, batch.id
            if p.outcome == "match_planned":
                mv.status, mv.date, mv.matched_planned = "posted", ln.date, True
                svc.sync_installment_from_movement(db, mv)
            continue
        mv = Movement(
            user_id=user_id, account_id=account.id, cycle_id=_cycle_for(db, user_id, account, ln.date),
            date=ln.date, kind="ingreso" if ln.amount > 0 else "gasto", status="posted",
            concept=ln.concept, amount=ln.amount, category_id=p.category_id, notes=ln.notes,
            source="bank_import", bank_ref=ln.ref, import_batch_id=batch.id,
        )  # fmt: skip
        db.add(mv)
        db.flush()
        changes.append({"op": "new", "id": str(mv.id)})
    batch.summary = {"counts": dict(counts), "changes": changes,
                     "file_balance": next((str(p.line.balance) for p in reversed(
                         sorted(planned, key=lambda x: (x.line.date, x.line.index)))
                         if p.line.balance is not None), None)}  # fmt: skip
    db.flush()
    return batch


def undo(db: Session, batch: ImportBatch) -> int:
    n = 0
    for ch in reversed(batch.summary.get("changes", [])):
        mv = db.get(Movement, uuid.UUID(ch["id"]))
        if mv is None or mv.user_id != batch.user_id:
            continue
        if ch["op"] == "new":
            db.delete(mv)
        else:
            mv.bank_ref = None
            mv.import_batch_id = None
            if ch["op"] == "match_planned":
                mv.status, mv.matched_planned = ch["status"], False
                mv.date = date.fromisoformat(ch["date"]) if ch["date"] else None
                svc.sync_installment_from_movement(db, mv)
        n += 1
    batch.status = "undone"
    db.flush()
    return n


def lines_for_preview(planned: list[PlannedLine]) -> list[dict[str, Any]]:
    return [
        {"row": p.line.index, "date": p.line.date, "concept": p.line.concept,
         "amount": p.line.amount, "balance": p.line.balance, "outcome": p.outcome,
         "movement_id": p.movement_id, "category_id": p.category_id}
        for p in sorted(planned, key=lambda x: (x.line.date, x.line.index))
    ]  # fmt: skip
