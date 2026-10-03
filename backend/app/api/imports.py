"""Importación de extractos bancarios: vista previa → confirmar → (deshacer). Perfiles de mapeo."""

import datetime as dt
import hashlib
import json
import uuid
from decimal import Decimal
from typing import Annotated, Any

from fastapi import APIRouter, File, Form, HTTPException, Query, Response, UploadFile, status
from pydantic import BaseModel, field_validator
from sqlalchemy import select

from app.api.deps import DB, CurrentUser
from app.importers import bank, pdf_statements
from app.importers.tabular import TableError, read_table
from app.models import Account, ImportBatch, ImportProfile
from app.schemas.types import Money
from app.services import gastos as svc

router = APIRouter(prefix="/imports", tags=["imports"])
MAX_BYTES = 5 * 1024 * 1024


class BankLineOut(BaseModel):
    row: int
    date: dt.date
    concept: str
    amount: Money
    balance: Money | None
    outcome: str  # duplicate | match_planned | match_posted | new
    movement_id: uuid.UUID | None
    category_id: uuid.UUID | None


def _no_nulls(d: dict[str, Any] | None) -> dict[str, Any] | None:
    """Los mapeos van sin claves vacías: el cliente generado (Dart) los tipa como
    `Map<String, Object>` y un `null` rompe la lectura de toda la respuesta."""
    return None if d is None else {k: v for k, v in d.items() if v is not None}


class BankPreviewOut(BaseModel):
    headers: list[str]
    mapping: dict[str, Any]
    counts: dict[str, int]
    errors: list[str]
    lines: list[BankLineOut]
    file_balance: Money | None  # saldo final según el extracto (si trae columna de saldo)
    balance_after: Money  # saldo calculado de la cuenta si se confirma

    @field_validator("mapping")
    @classmethod
    def _clean(cls, v: dict[str, Any] | None) -> dict[str, Any] | None:
        return _no_nulls(v)


class BatchOut(BaseModel):
    id: uuid.UUID
    kind: str  # bank | platform
    filename: str
    status: str
    created_at: dt.datetime
    counts: dict[str, int]
    file_balance: str | None


class BankProfileIn(BaseModel):
    name: str
    mapping: dict[str, Any]


class TableInspectOut(BaseModel):
    """Primeras filas del fichero (como texto) para elegir las columnas a mano."""

    rows: list[list[str]]
    suggested: dict[str, Any] | None  # mapeo detectado (si lo hay)
    message: str | None  # por qué no se reconoció

    @field_validator("suggested")
    @classmethod
    def _clean(cls, v: dict[str, Any] | None) -> dict[str, Any] | None:
        return _no_nulls(v)


def table_preview(rows: list[Any], n: int = 30) -> list[list[str]]:
    out = []
    for r in rows[:n]:
        out.append(["" if c is None else (c.isoformat()[:10] if hasattr(c, "isoformat") else str(c))
                    for c in r])  # fmt: skip
    return out


class BankProfileOut(BaseModel):
    id: uuid.UUID
    name: str
    mapping: dict[str, Any]

    @field_validator("mapping")
    @classmethod
    def _clean(cls, v: dict[str, Any] | None) -> dict[str, Any] | None:
        return _no_nulls(v)


async def _prepare(db: DB, user_id: uuid.UUID, file: UploadFile, account_id: uuid.UUID | None,
                   mapping_json: str | None, profile_id: uuid.UUID | None):  # fmt: skip
    content = await file.read()
    if len(content) > MAX_BYTES:
        raise HTTPException(status.HTTP_413_REQUEST_ENTITY_TOO_LARGE, "Fichero demasiado grande")
    account = (svc.get_owned(db, Account, account_id, user_id) if account_id
               else svc.main_account(db, user_id))  # fmt: skip
    if content[:5] == b"%PDF-":
        # Extractos en PDF con formato conocido (hoy: Trade Republic). Sin mapeo de columnas.
        try:
            text = pdf_statements.pdf_text(content)
            if not pdf_statements.is_trade_republic(text):
                raise pdf_statements.StatementError(
                    "Este PDF no es un extracto que Fanal sepa leer (hoy: Trade Republic). "
                    "Si tu banco permite descargar en Excel o CSV, usa ese formato."
                )
            lines, warnings = pdf_statements.trade_republic(text)
        except pdf_statements.StatementError as e:
            raise HTTPException(status.HTTP_422_UNPROCESSABLE_ENTITY, str(e)) from None
        m = bank.Mapping(date=0, concept=[])
        parsed = bank.ParseResult(lines, warnings)
        planned = bank.plan(db, user_id, account, parsed.lines)
        return account, content, [], m, parsed, planned, []
    try:
        rows = read_table(content, file.filename or "fichero.csv")
        if profile_id:
            prof = svc.get_owned(db, ImportProfile, profile_id, user_id)
            m = bank.mapping_from_dict(prof.config)
        elif mapping_json:
            m = bank.mapping_from_dict(json.loads(mapping_json))
        else:
            m = bank.detect_mapping(rows)
        parsed = bank.parse_lines(rows, m)
    except (TableError, ValueError, TypeError, IndexError) as e:
        # Formato desconocido o cambiado: error claro, nunca importar basura
        raise HTTPException(status.HTTP_422_UNPROCESSABLE_ENTITY, str(e)) from None
    if not parsed.lines:
        raise HTTPException(status.HTTP_422_UNPROCESSABLE_ENTITY,
                            "No hay movimientos reconocibles en el fichero")  # fmt: skip
    planned = bank.plan(db, user_id, account, parsed.lines)
    headers = [str(c or "") for c in rows[m.header_row]]
    return account, content, rows, m, parsed, planned, headers


def _counts(planned: list[bank.PlannedLine]) -> dict[str, int]:
    out: dict[str, int] = {}
    for p in planned:
        out[p.outcome] = out.get(p.outcome, 0) + 1
    return out


@router.post("/bank/preview", response_model=BankPreviewOut)
async def bank_preview(
    db: DB, user: CurrentUser,
    file: Annotated[UploadFile, File()],
    account_id: Annotated[uuid.UUID | None, Form()] = None,
    mapping: Annotated[str | None, Form()] = None,
    profile_id: Annotated[uuid.UUID | None, Form()] = None,
) -> BankPreviewOut:  # fmt: skip
    account, _, _, m, parsed, planned, headers = await _prepare(
        db, user.id, file, account_id, mapping, profile_id)  # fmt: skip
    delta = sum((p.line.amount for p in planned if p.outcome == "new"), Decimal(0))
    by_date = sorted(planned, key=lambda x: (x.line.date, x.line.index), reverse=True)
    file_bal = next((p.line.balance for p in by_date if p.line.balance is not None), None)
    planned_delta = sum(
        (p.line.amount for p in planned if p.outcome == "match_planned"), Decimal(0)
    )
    db.rollback()  # la vista previa nunca escribe
    return BankPreviewOut(
        headers=headers, mapping=m.as_dict(), counts=_counts(planned), errors=parsed.errors,
        lines=[BankLineOut(**x) for x in bank.lines_for_preview(planned)],
        file_balance=file_bal,
        balance_after=svc.account_balance(db, account) + delta + planned_delta,
    )  # fmt: skip


@router.post("/bank/commit", response_model=BatchOut)
async def bank_commit(
    db: DB, user: CurrentUser,
    file: Annotated[UploadFile, File()],
    account_id: Annotated[uuid.UUID | None, Form()] = None,
    mapping: Annotated[str | None, Form()] = None,
    profile_id: Annotated[uuid.UUID | None, Form()] = None,
    save_profile_as: Annotated[str | None, Form()] = None,
) -> BatchOut:  # fmt: skip
    account, content, _, m, _, planned, _ = await _prepare(
        db, user.id, file, account_id, mapping, profile_id)  # fmt: skip
    batch = bank.commit(db, user.id, account, planned, file.filename or "fichero",
                        hashlib.sha256(content).hexdigest())  # fmt: skip
    if save_profile_as:
        prof = db.scalar(
            select(ImportProfile).where(
                ImportProfile.user_id == user.id, ImportProfile.name == save_profile_as
            )
        )
        if prof is None:
            db.add(ImportProfile(user_id=user.id, name=save_profile_as, kind="bank",
                                 config=m.as_dict()))  # fmt: skip
        else:
            prof.config = m.as_dict()
    return _batch_out(batch)


def _batch_out(b: ImportBatch) -> BatchOut:
    return BatchOut(id=b.id, kind=b.kind, filename=b.filename, status=b.status,
                    created_at=b.created_at,
                    counts=b.summary.get("counts", {}),
                    file_balance=b.summary.get("file_balance"))  # fmt: skip


@router.get("", response_model=list[BatchOut])
def list_batches(db: DB, user: CurrentUser) -> list[BatchOut]:
    rows = db.scalars(select(ImportBatch).where(ImportBatch.user_id == user.id)
                      .order_by(ImportBatch.created_at.desc()).limit(50))  # fmt: skip
    return [_batch_out(b) for b in rows]


@router.post("/{batch_id}/undo", response_model=BatchOut)
def undo_batch(batch_id: uuid.UUID, db: DB, user: CurrentUser) -> BatchOut:
    b = svc.get_owned(db, ImportBatch, batch_id, user.id)
    if b.status == "undone":
        raise HTTPException(status.HTTP_409_CONFLICT, "Ese lote ya se deshizo")
    if b.kind == "platform":
        from app.importers import platforms

        platforms.undo(db, b)
    else:
        bank.undo(db, b)
    return _batch_out(b)


@router.get("/profiles", response_model=list[BankProfileOut])
def list_profiles(
    db: DB, user: CurrentUser, kind: str = Query(default="bank")
) -> list[BankProfileOut]:
    """Formatos guardados: `bank` (extractos) o `broker` (operaciones de inversión)."""
    rows = db.scalars(
        select(ImportProfile)
        .where(ImportProfile.user_id == user.id, ImportProfile.kind == kind)
        .order_by(ImportProfile.name)
    )
    return [BankProfileOut(id=p.id, name=p.name, mapping=p.config) for p in rows]


@router.delete("/profiles/{profile_id}", status_code=status.HTTP_204_NO_CONTENT)
def delete_profile(profile_id: uuid.UUID, db: DB, user: CurrentUser) -> Response:
    db.delete(svc.get_owned(db, ImportProfile, profile_id, user.id))
    return Response(status_code=status.HTTP_204_NO_CONTENT)


@router.post("/inspect", response_model=TableInspectOut)
async def inspect_table(
    user: CurrentUser,
    file: Annotated[UploadFile, File()],
    kind: Annotated[str, Form()] = "bank",
) -> TableInspectOut:
    """Para el editor de columnas: las primeras filas y, si se reconoce, el mapeo sugerido."""
    content = await file.read()
    if len(content) > MAX_BYTES:
        raise HTTPException(status.HTTP_413_REQUEST_ENTITY_TOO_LARGE, "Fichero demasiado grande")
    if content[:5] == b"%PDF-":
        raise HTTPException(status.HTTP_422_UNPROCESSABLE_ENTITY,
                            "Los PDF no tienen columnas que elegir")  # fmt: skip
    try:
        rows = read_table(content, file.filename or "fichero.csv")
    except TableError as e:
        raise HTTPException(status.HTTP_422_UNPROCESSABLE_ENTITY, str(e)) from None
    suggested, message = None, None
    if kind == "bank":
        try:
            suggested = bank.detect_mapping(rows).as_dict()
        except TableError as e:
            message = str(e)
    else:
        from app.importers import generic_broker

        suggested = generic_broker.suggest(rows)
    return TableInspectOut(rows=table_preview(rows), suggested=suggested, message=message)


@router.post("/profiles", response_model=BankProfileOut, status_code=status.HTTP_201_CREATED)
def create_profile(body: BankProfileIn, db: DB, user: CurrentUser) -> BankProfileOut:
    bank.mapping_from_dict(body.mapping)  # valida
    p = ImportProfile(user_id=user.id, name=body.name, kind="bank", config=body.mapping)
    db.add(p)
    db.flush()
    return BankProfileOut(id=p.id, name=p.name, mapping=p.config)
