"""Importador del Excel de gastos por ciclos ("Calculador de gastos").

Formato esperado (una hoja por ciclo, nombrada "<Mes> <aa>"):
  · A1 = etiqueta · B1 = "=<nómina>+C1" · C1 = saldo arrastrado del ciclo anterior
  · Filas 2..n: A = concepto · B = importe (número o "=-60+20+12") · C = nota opcional
  · Relleno verde en A/B (por defecto FFB6D7A8) = movimiento ya cargado; sin color = previsto
  · Otras columnas = cálculos auxiliares (se ignoran y se listan en el informe)

Uso (CLI):
  python -m app.importers.excel_gastos --email X --file gastos.xlsx [--overrides o.json]
                                       [--report informe.md] [--commit]

Sin --commit solo genera el informe (vista previa). Es idempotente: cada fila lleva una
external_ref estable, así que reimportar no duplica (actualiza importe/estado si cambiaron).

Lo que depende del usuario (desde qué hoja importar, categorías de comercios concretos,
recurrentes confirmados, saldo real del banco…) va en un JSON de overrides, NUNCA en el código.
"""

from __future__ import annotations

import argparse
import json
import re
import sys
import uuid
from collections import defaultdict
from dataclasses import dataclass, field
from datetime import date, timedelta
from decimal import Decimal
from pathlib import Path
from typing import Any

import openpyxl
from sqlalchemy import select
from sqlalchemy.orm import Session

from app.domain import calendar as cal
from app.domain.expression import parse_expression
from app.domain.money import ZERO, q2
from app.domain.recurring import occurrences
from app.models import Account, InstallmentPlan, Movement, PayCycle, RecurringTemplate, User
from app.services import gastos as svc
from app.services.categories_seed import (
    category_index,
    guess_category_path,
    normalize,
    seed_categories,
)

GREEN = "FFB6D7A8"
INSTALLMENT_RX = re.compile(
    r"paypal fracci|\bklarna\b|amazon plan|el corte ingl|gasto fraccionado|\bfraccion", re.I
)
PROVIDER_RX = [
    (re.compile(r"paypal", re.I), "paypal"),
    (re.compile(r"klarna", re.I), "klarna"),
    (re.compile(r"amazon", re.I), "amazon"),
    (re.compile(r"corte ingl", re.I), "eci"),
    (re.compile(r"fraccionad", re.I), "tarjeta"),
]
TRANSFER_RX = re.compile(
    r"\b(ahorro|retiro ahorros|fondos? indexad\w*|inversiones|transferencia|traspaso)\b", re.I
)
PAYROLL_RX = re.compile(r"^=\s*([\d.,]+)\s*\+\s*C1\s*$", re.I)


# --- Lectura -------------------------------------------------------------------------------
@dataclass
class Row:
    sheet: str
    row: int
    concept: str
    amount: Decimal
    terms: list[Decimal] | None  # submovimientos si era una expresión
    expression: str | None
    posted: bool
    note: str | None
    ext: str  # external_ref estable


@dataclass
class Sheet:
    name: str
    key: cal.CycleKey
    payroll: Decimal
    carried: Decimal
    carried_blank: bool
    rows: list[Row]
    expected_end: Decimal  # E1 recalculado: arrastre + nómina + filas
    has_posted: bool
    aux_cells: list[str] = field(default_factory=list)
    skipped: list[str] = field(default_factory=list)


def _num(v: Any) -> Decimal | None:
    if isinstance(v, bool) or v is None:
        return None
    if isinstance(v, int | float):
        return q2(Decimal(str(v)))
    return None


def read_workbook(path: Path, skip_notes: list[str], green: str = GREEN) -> list[Sheet]:
    wb_f = openpyxl.load_workbook(path, data_only=False)
    wb_v = openpyxl.load_workbook(path, data_only=True)
    out: list[Sheet] = []
    for ws in wb_f.worksheets:
        key = cal.key_from_label(ws.title)
        if key is None:
            continue
        wv = wb_v[ws.title]
        b1 = ws["B1"].value
        m = PAYROLL_RX.match(str(b1)) if isinstance(b1, str) else None
        payroll = q2(Decimal(m.group(1).replace(",", "."))) if m else (_num(wv["B1"].value) or ZERO)
        c1 = _num(wv["C1"].value)
        sheet = Sheet(ws.title, key, payroll, c1 or ZERO, c1 is None, [], ZERO, False)
        seen: dict[str, int] = defaultdict(int)
        for r in range(2, ws.max_row + 1):
            a = ws.cell(r, 1).value
            if a is None or str(a).strip() == "":
                continue
            concept = str(a).strip()
            raw = ws.cell(r, 2).value
            note = ws.cell(r, 3).value
            note_s = str(note).strip() if note not in (None, "") else None
            if note_s and any(s.lower() in note_s.lower() for s in skip_notes):
                sheet.skipped.append(f"{ws.title}!A{r} «{concept}» (nota «{note_s}»)")
                continue
            terms = expr = None
            if isinstance(raw, str) and raw.startswith("="):
                terms = parse_expression(raw)
                if terms is None:
                    sheet.skipped.append(f"{ws.title}!B{r} «{concept}»: fórmula no soportada {raw}")
                    continue
                expr = raw
                amount = q2(sum(terms, ZERO))
            else:
                amount = _num(raw)
                if amount is None:
                    sheet.skipped.append(f"{ws.title}!B{r} «{concept}»: importe vacío")
                    continue
            if amount == 0:
                sheet.skipped.append(f"{ws.title}!A{r} «{concept}»: importe 0")
                continue
            fill = ws.cell(r, 1).fill
            posted = bool(fill and fill.fill_type and fill.fgColor.rgb == green)
            nk = normalize(concept)
            seen[nk] += 1
            sheet.rows.append(
                Row(ws.title, r, concept, amount, terms if terms and len(terms) > 1 else None,
                    expr if terms and len(terms) > 1 else None, posted, note_s,
                    f"xlsx:{ws.title}:{nk}:{seen[nk]}")
            )  # fmt: skip
            sheet.has_posted |= posted
        # Columnas auxiliares (todo lo que no sea A-C en filas de movimientos ni A-E en la fila 1)
        for row in ws.iter_rows():
            for c in row:
                if c.value is None:
                    continue
                if c.column <= 3 or (c.row <= 2 and c.column <= 5):
                    continue
                if c.column == 4 and str(ws.cell(c.row, 3).value or "").lower() == "deuda":
                    sheet.aux_cells.append(f"{c.coordinate} (saldo de la columna Deuda)")
                    continue
                sheet.aux_cells.append(c.coordinate)
        sheet.expected_end = (
            sheet.carried + sheet.payroll + sum((x.amount for x in sheet.rows), ZERO)
        )
        out.append(sheet)
    out.sort(key=lambda s: s.key)
    return out


# --- Reconstrucción de compras fraccionadas -----------------------------------------------
@dataclass
class Chain:
    provider: str
    rows: list[Row]
    first_purchase: Row | None = None
    closed_sheets: frozenset[str] = frozenset()  # hojas de ciclos cerrados: todo cuenta como pagado

    @property
    def amount(self) -> Decimal:
        return -self.rows[0].amount

    def paid(self, r: Row) -> bool:
        return r.posted or r.sheet in self.closed_sheets

    @property
    def live(self) -> bool:
        return any(not self.paid(r) for r in self.rows)


def _provider(concept: str) -> str:
    for rx, p in PROVIDER_RX:
        if rx.search(concept):
            return p
    return "otro"


def reconstruct_installments(
    sheets: list[Sheet], closed: frozenset[str] = frozenset()
) -> tuple[list[Chain], set[str]]:
    """Agrupa cuotas en ciclos consecutivos. Dos pasadas:

    1. Cadenas de importe EXACTO (aquí se admite cambiar de proveedor: p. ej. "El Corte Inglés 1"
       que sigue apuntándose como "PayPal Fracción 8" con el mismo importe).
    2. Solo extender el final de una cadena con ±1 € y el MISMO proveedor (redondeo de la última
       cuota). Nunca se fusionan dos cadenas ni se cruzan proveedores con importes distintos.

    Devuelve las cadenas y el conjunto de external_ref que pertenecen a alguna."""
    order = {s.key: i for i, s in enumerate(sheets)}
    cands = [
        (order[s.key], r) for s in sheets for r in s.rows if INSTALLMENT_RX.search(r.concept)
        and r.amount < 0
    ]  # fmt: skip
    by_sheet: dict[int, list[Row]] = defaultdict(list)
    for i, r in cands:
        by_sheet[i].append(r)
    used: set[str] = set()
    raw: list[tuple[int, list[Row]]] = []

    # Pasada 1: importe exacto
    for idx, r in sorted(cands, key=lambda x: (x[0], x[1].row)):
        if r.ext in used:
            continue
        chain = [r]
        used.add(r.ext)
        cur = idx
        while True:
            nxt = [
                c for c in by_sheet[cur + 1] if c.ext not in used and c.amount == chain[-1].amount
            ]
            if not nxt:
                break
            nxt.sort(key=lambda c: (_provider(c.concept) != _provider(r.concept), c.row))
            chain.append(nxt[0])
            used.add(nxt[0].ext)
            cur += 1
        raw.append((idx, chain))

    # Pasada 2: extender con ±1 € del mismo proveedor (redondeo de la última cuota). La cuota
    # extra suele haber formado en la pasada 1 una "cadena" de un solo elemento: se absorbe.
    singletons = {c[0].ext: k for k, (i, c) in enumerate(raw) if len(c) == 1}
    absorbed: set[int] = set()
    for k, (idx, chain) in sorted(enumerate(raw), key=lambda x: (x[1][0], x[1][1][0].row)):
        if k in absorbed:
            continue
        end = idx + len(chain) - 1
        prov = _provider(chain[0].concept)
        nxt_rows = [c for c in by_sheet[end + 1]
                    if c.ext in singletons and singletons[c.ext] not in absorbed
                    and singletons[c.ext] != k]  # fmt: skip
        if any(c.amount == chain[-1].amount for c in nxt_rows):
            continue  # hay una continuación exacta libre: no es redondeo
        ext = [c for c in nxt_rows
               if abs(c.amount - chain[-1].amount) <= 1 and _provider(c.concept) == prov]  # fmt: skip
        if ext:
            ext.sort(key=lambda c: (abs(c.amount - chain[-1].amount), c.row))
            chain.append(ext[0])
            absorbed.add(singletons[ext[0].ext])
    raw = [x for k, x in enumerate(raw) if k not in absorbed]

    chains: list[Chain] = []
    for idx, chain in raw:
        ch = Chain(_provider(chain[0].concept), chain, closed_sheets=closed)
        # Patrón "pago en 3 plazos": la compra aparece con su nombre el ciclo anterior.
        # Solo si hay UN candidato (exacto primero; si no, ±1 €).
        if idx > 0 and ch.live:
            prev = [
                x for x in sheets[idx - 1].rows
                if not INSTALLMENT_RX.search(x.concept) and x.amount < 0 and x.ext not in used
            ]  # fmt: skip
            exact = [x for x in prev if x.amount == chain[0].amount]
            near = [x for x in prev if abs(x.amount - chain[0].amount) <= 1]
            pick = exact if exact else near
            if len(pick) == 1:
                ch.first_purchase = pick[0]
                used.add(pick[0].ext)
        chains.append(ch)
    return chains, {r.ext for c in chains for r in c.rows}


# --- Plan de importación -------------------------------------------------------------------
@dataclass
class Plan:
    sheets: list[Sheet]  # importadas como ciclos (hasta la actual)
    future: list[Sheet]  # posteriores a la actual: solo previstos
    current: Sheet
    chains: list[Chain]
    chain_refs: set[str]
    recurring: list[dict[str, Any]]
    report: list[str]


def _estimated_due(key: cal.CycleKey, payday_day: int) -> date:
    return cal.cycle_start(key, payday_day) + timedelta(days=10)


def build_plan(sheets: list[Sheet], ov: dict[str, Any]) -> Plan:
    frm = cal.key_from_label(ov["from"]) if ov.get("from") else None
    sel = [s for s in sheets if frm is None or s.key >= frm]
    if not sel:
        raise SystemExit("No hay hojas de ciclo a partir de la indicada")
    with_posted = [s for s in sel if s.has_posted]
    if not with_posted:
        raise SystemExit("Ninguna hoja tiene movimientos cargados (verde): no sé cuál es la actual")
    current = with_posted[-1]
    imported = [s for s in sel if s.key <= current.key]
    future = [s for s in sel if s.key > current.key]
    closed = frozenset(s.name for s in imported if s is not current)
    chains, chain_refs = reconstruct_installments(imported + future, closed)
    rep: list[str] = [
        f"# Informe de importación — {len(imported)} ciclos + {len(future)} previstos",
        "",
    ]
    return Plan(imported, future, current, chains, chain_refs, ov.get("recurring", []), rep)


# --- Aplicación ----------------------------------------------------------------------------
@dataclass
class Stats:
    created: int = 0
    updated: int = 0
    unchanged: int = 0


def _resolve_category(
    concept: str, cats: dict[str, uuid.UUID], ov_concepts: dict[str, Any]
) -> tuple[uuid.UUID | None, str | None, dict[str, Any]]:
    n = normalize(concept)
    for key, val in ov_concepts.items():
        if normalize(key) in n:
            spec = val if isinstance(val, dict) else {"category": val}
            path = spec.get("category")
            return (cats.get(path) if path else None), path, spec
    path = guess_category_path(concept)
    return (cats.get(path) if path else None), path, {}


def _upsert_movement(db: Session, user_id: uuid.UUID, ext: str, values: dict[str, Any],
                     lines: list[Decimal] | None, expression: str | None, st: Stats) -> Movement:  # fmt: skip
    m = db.scalar(select(Movement).where(Movement.user_id == user_id, Movement.external_ref == ext))
    if m is None:
        m = Movement(user_id=user_id, external_ref=ext, **{"source": "excel", **values})
        if lines:
            svc.apply_amount(m, None, expression)
        db.add(m)
        st.created += 1
        return m
    changed = False
    values.setdefault("source", "excel")
    for k in ("amount", "status", "cycle_id", "source"):
        if getattr(m, k) != values[k] and not (k == "amount" and lines):
            setattr(m, k, values[k])
            changed = True
    if lines and m.expression != expression:
        svc.apply_amount(m, None, expression)
        changed = True
    st.updated += changed
    st.unchanged += not changed
    return m


def apply(db: Session, user: User, plan: Plan, ov: dict[str, Any]) -> list[str]:
    rep = plan.report
    seed_categories(db, user.id)
    cats = category_index(db, user.id)
    payday_day = int(ov.get("payday_day", 27))
    s = svc.get_settings(db, user.id)

    # Cuentas y ajustes (solo si el módulo no estaba configurado)
    if s["main_account_id"]:
        account = db.get(Account, uuid.UUID(s["main_account_id"]))
        assert account is not None
    else:
        first = plan.sheets[0]
        account = Account(user_id=user.id, kind="gastos", name="Cuenta de gastos",
                          bank=ov.get("bank", ""), opening_balance=first.carried,
                          opening_date=cal.cycle_start(first.key, payday_day))  # fmt: skip
        db.add(account)
        refugio = None
        if ov.get("refugio"):
            refugio = Account(user_id=user.id, kind="refugio", name="Fondo de emergencia",
                              bank=ov["refugio"].get("bank", ""),
                              opening_balance=Decimal(ov["refugio"].get("balance", "0")),
                              opening_date=date.today(), sort=1)  # fmt: skip
            db.add(refugio)
        db.flush()
        svc.save_settings(db, user.id, {
            "payday_day": payday_day, "main_account_id": account.id,
            "refugio_account_id": refugio.id if refugio else None,
            "usual_payroll": ov.get("usual_payroll") or str(plan.current.payroll),
            "emergency_target": ov.get("emergency_target"),
            "monthly_refugio": ov.get("monthly_refugio"),
        })  # fmt: skip
        rep.append(f"- Cuenta de gastos creada (banco: {account.bank or '—'}), saldo de apertura "
                   f"{first.carried} € (arrastre de {first.name}).")  # fmt: skip

    ov_concepts: dict[str, Any] = ov.get("concepts", {})
    st = Stats()
    uncategorized: dict[str, int] = defaultdict(int)
    rep += ["", "## Ciclos", "", "| Ciclo | Arrastre | Nómina | Previsto (E1) | Siguiente arrastre | Descuadre |",
            "|---|---|---|---|---|---|"]  # fmt: skip

    # Recurrentes confirmados en overrides (los demás solo se proponen)
    templates: dict[str, RecurringTemplate] = {}
    for spec in plan.recurring:
        nk = normalize(spec["concept"])
        t = db.scalar(select(RecurringTemplate).where(
            RecurringTemplate.user_id == user.id, RecurringTemplate.concept == spec["concept"]))  # fmt: skip
        if t is None:
            cid, _, _ = _resolve_category(spec["concept"], cats, ov_concepts)
            if spec.get("category"):
                cid = cats.get(spec["category"])
            t = RecurringTemplate(
                user_id=user.id, account_id=account.id, concept=spec["concept"],
                amount=Decimal(spec["amount"]), amount_is_estimate=bool(spec.get("estimate")),
                kind=spec.get("kind", "gasto"), category_id=cid,
                every_months=int(spec.get("every_months", 1)),
                day_of_month=int(spec.get("day", 1)),
                start_date=cal.cycle_start(plan.sheets[0].key, payday_day),
            )  # fmt: skip
            db.add(t)
            db.flush()
        templates[nk] = t

    cycles: dict[str, PayCycle] = {}
    for i, sh in enumerate(plan.sheets):
        is_current = sh is plan.current
        nxt = plan.sheets[i + 1] if i + 1 < len(plan.sheets) else None
        cyc = db.scalar(select(PayCycle).where(PayCycle.user_id == user.id,
                                               PayCycle.external_ref == f"xlsx:{sh.name}"))  # fmt: skip
        start = cal.cycle_start(sh.key, payday_day)
        if cyc is None:
            cyc = svc.create_cycle(db, user.id, account, sh.key.label, start, sh.carried,
                                   sh.payroll, payroll_date=start,
                                   external_ref=f"xlsx:{sh.name}", generate=False)  # fmt: skip
        else:
            cyc.carried_real, cyc.payroll_amount = sh.carried, sh.payroll
        cyc.status = "open" if is_current else "closed"
        cyc.end_date = None if is_current else cal.cycle_start(sh.key.next(), payday_day)
        cycles[sh.name] = cyc
        db.flush()

        for r in sh.rows:
            # Cuotas PENDIENTES de compras vivas: las genera el plan (no se importan sueltas).
            # Las ya pagadas sí se importan: son gasto real del ciclo.
            if r.ext in plan.chain_refs and any(
                r in c.rows and c.live and not c.paid(r) for c in plan.chains
            ):
                continue
            cid, _path, spec = _resolve_category(r.concept, cats, ov_concepts)
            kind = spec.get("kind") or (
                "transferencia" if TRANSFER_RX.search(r.concept) else
                ("ingreso" if r.amount > 0 else "gasto")
            )  # fmt: skip
            if cid is None:
                if not INSTALLMENT_RX.search(r.concept):  # las cuotas sueltas son esperables
                    uncategorized[r.concept] += 1
                cid = cats.get("Sin categoría") if kind == "gasto" else None
            # En ciclos cerrados, lo que no está en verde se asume cargado (se informa)
            posted = r.posted or not is_current
            values = dict(source="installment" if INSTALLMENT_RX.search(r.concept) else "excel",
                          account_id=account.id, cycle_id=cyc.id, kind=kind,
                          status="posted" if posted else "planned", concept=r.concept,
                          amount=r.amount, category_id=cid, notes=r.note,
                          date=None, due_date=None if posted else start + timedelta(days=10))  # fmt: skip
            t = templates.get(normalize(r.concept))
            occ = (
                occurrences(t.start_date, t.every_months, t.day_of_month, start,
                                cal.cycle_start(sh.key.next(), payday_day), t.end_date)
                if t is not None else []
            )  # fmt: skip
            m = _upsert_movement(db, user.id, r.ext, values, r.terms, r.expression, st)
            if t is not None and occ:
                # Vinculado a su plantilla: la generación de recurrentes no lo duplicará
                m.source, m.source_ref, m.due_date = "recurring", t.id, occ[0]
            if not r.posted and not is_current:
                rep.append(f"  - ⚠ {sh.name}: «{r.concept}» {r.amount} no estaba en verde; "
                           "se importa como cargado (ciclo cerrado)")  # fmt: skip

        # Descuadre con el arrastre real del ciclo siguiente → ajuste en este ciclo
        diff = None
        if nxt is not None and not nxt.carried_blank:
            diff = nxt.carried - sh.expected_end
            cyc.carried_expected = None
            if diff != 0:
                _upsert_movement(db, user.id, f"xlsx:{sh.name}:ajuste-cuadre", dict(
                    account_id=account.id, cycle_id=cyc.id, kind="ajuste", status="posted",
                    concept="Ajuste de cuadre", amount=diff, category_id=None,
                    notes=f"Arrastre real de {nxt.name}: {nxt.carried}", date=None,
                    due_date=None), None, None, st)  # fmt: skip
        elif nxt is not None and nxt.carried_blank:
            rep.append(f"  - ⚠ {nxt.name} no tiene arrastre (C1 vacío): no se calcula descuadre")
        rep.append(f"| {sh.name}{' (actual)' if is_current else ''} | {sh.carried} | {sh.payroll} "
                   f"| {sh.expected_end} | {nxt.carried if nxt else '—'} | "
                   f"{diff if diff is not None else '—'} |")  # fmt: skip
    db.flush()

    # Compras fraccionadas vivas → planes (las cuotas pagadas quedan como histórico)
    rep += ["", "## Compras fraccionadas reconstruidas (solo las vivas)", ""]
    live = [c for c in plan.chains if c.live]
    order = {s.name: s for s in plan.sheets + plan.future}
    for c in live:
        rows = list(c.rows)
        desc = (c.first_purchase.concept if c.first_purchase
                else f"{rows[0].concept.split(' Fracci')[0]} {c.amount:.0f} €")  # fmt: skip
        amounts = [-r.amount for r in rows]
        paid = {i + 1 for i, r in enumerate(rows) if c.paid(r)}
        if c.first_purchase:
            amounts.insert(0, -c.first_purchase.amount)
            paid = {1} | {s + 1 for s in paid}
        first_key = order[(c.first_purchase or rows[0]).sheet].key
        ext = f"xlsx:plan:{rows[0].sheet}:{rows[0].row}"
        exists = db.scalar(select(InstallmentPlan.id).where(
            InstallmentPlan.user_id == user.id, InstallmentPlan.external_ref == ext))  # fmt: skip
        status_txt = "ya existía" if exists else "creado"
        plan_obj = db.get(InstallmentPlan, exists) if exists else None
        if not exists:
            plan_obj = svc.create_installment_plan(
                db, user.id, account, desc, sum(amounts, ZERO), len(amounts),
                _estimated_due(first_key, payday_day), provider=c.provider,
                category_id=cats.get("Sin categoría"), custom=amounts, paid_seqs=paid,
                external_ref=ext,
            )  # fmt: skip
        # Las cuotas ya pagadas (importadas como movimientos) se enlazan a su plan
        paid_rows = ([c.first_purchase] if c.first_purchase else []) + rows
        for pos, pr in enumerate(paid_rows, start=1):
            if pos not in paid or plan_obj is None:
                continue
            mv = db.scalar(select(Movement).where(Movement.user_id == user.id,
                                                  Movement.external_ref == pr.ext))  # fmt: skip
            if mv is not None:
                mv.source, mv.source_ref = "installment", plan_obj.id
                inst = next((i for i in plan_obj.installments if i.seq == pos), None)
                if inst is not None:
                    inst.movement_id = mv.id
        seq = " · ".join(f"{r.sheet.split()[0][:3]} {-r.amount}{'✓' if c.paid(r) else ''}"
                         for r in rows)  # fmt: skip
        rep.append(f"- **{desc}** ({c.provider}) — {len(amounts)} cuotas, total "
                   f"{sum(amounts, ZERO)} €, pagadas {len(paid)}: {seq}"
                   f"{' · 1ª cuota = compra «' + c.first_purchase.concept + '»' if c.first_purchase else ''}"
                   f" → {status_txt}")  # fmt: skip

    # Previstos de hojas futuras que no son cuotas ni recurrentes
    rep += ["", "## Hojas futuras", ""]
    for sh in plan.future:
        for r in sh.rows:
            if r.ext in plan.chain_refs or normalize(r.concept) in templates:
                continue
            cid, _, spec = _resolve_category(r.concept, cats, ov_concepts)
            _upsert_movement(db, user.id, r.ext, dict(
                account_id=account.id, cycle_id=None, kind=spec.get("kind") or (
                    "ingreso" if r.amount > 0 else "gasto"),
                status="planned", concept=r.concept, amount=r.amount, category_id=cid,
                notes=r.note, date=None, due_date=_estimated_due(sh.key, payday_day)),
                r.terms, r.expression, st)  # fmt: skip
            rep.append(f"- {sh.name}: «{r.concept}» {r.amount} → previsto sin ciclo")
        for sk in sh.skipped:
            rep.append(f"- omitido: {sk}")

    # Proponer recurrentes no confirmados (conceptos en todas las hojas con el mismo importe)
    names_all = [{normalize(r.concept): r.amount for r in s.rows} for s in plan.sheets]
    common = set.intersection(*(set(n) for n in names_all)) if names_all else set()
    proposals = [c for c in sorted(common) if c not in templates
                 and not INSTALLMENT_RX.search(c)]  # fmt: skip
    rep += ["", "## Recurrentes", ""]
    rep += [
        f"- creado: **{t.concept}** {t.amount} € cada {t.every_months} mes(es)"
        f"{' (importe estimado)' if t.amount_is_estimate else ''}"
        for t in templates.values()
    ]
    rep += [f"- propuesta (no creada; añádela a overrides.recurring si lo es): «{c}»"
            for c in proposals]  # fmt: skip

    rep += ["", "## Sin categoría (añádelos a overrides.concepts)", ""]
    rep += [f"- «{c}» ×{n}" for c, n in sorted(uncategorized.items())] or ["- (ninguno)"]
    rep += ["", "## Omitido y columnas auxiliares", ""]
    for sh in plan.sheets:
        rep += [f"- omitido: {x}" for x in sh.skipped]
        if sh.aux_cells:
            rep.append(f"- {sh.name}: celdas auxiliares ignoradas: {', '.join(sh.aux_cells)}")

    db.flush()
    cur = cycles[plan.current.name]
    bal = svc.account_balance(db, account)
    bank_line = None
    if ov.get("bank_balance"):
        real = Decimal(ov["bank_balance"])
        bank_line = (f"- Saldo real del banco: {real} € · calculado {bal} € → ajuste de cuadre "
                     f"**{real - bal} €** en {cur.label}")  # fmt: skip
        if real != bal:
            _upsert_movement(db, user.id, f"xlsx:{plan.current.name}:cuadre-banco", dict(
                account_id=account.id, cycle_id=cur.id, kind="ajuste", status="posted",
                concept="Ajuste de cuadre (banco)", amount=real - bal, category_id=None,
                notes="Saldo real indicado al importar", date=date.today(), due_date=None),
                None, None, Stats())  # fmt: skip
            db.flush()
    summ = svc.cycle_summary(db, cur)
    rep += ["", "## Resultado", "",
            f"- Movimientos: {st.created} creados · {st.updated} actualizados · "
            f"{st.unchanged} sin cambios",
            f"- E1 del Excel ({plan.current.name}): {plan.current.expected_end} €"]  # fmt: skip
    if bank_line:
        rep.append(bank_line)
    rep += [f"- Ciclo actual **{cur.label}**: saldo inicial {summ.opening} € · disponible "
            f"**{summ.available_now} €** · previsto a fin de ciclo **{summ.expected_end} €** · "
            f"cuotas {summ.installments} €",
            f"- Saldo de la cuenta: {svc.account_balance(db, account)} €"]  # fmt: skip
    return rep


# --- CLI ---------------------------------------------------------------------------------
def main() -> None:
    from app.db import SessionLocal

    ap = argparse.ArgumentParser(prog="app.importers.excel_gastos")
    ap.add_argument("--email", required=True)
    ap.add_argument("--file", required=True, type=Path)
    ap.add_argument("--overrides", type=Path)
    ap.add_argument("--report", type=Path)
    ap.add_argument("--commit", action="store_true", help="Sin esto, solo vista previa")
    a = ap.parse_args()
    ov = json.loads(a.overrides.read_text(encoding="utf-8")) if a.overrides else {}
    sheets = read_workbook(a.file, ov.get("skip_notes", []), ov.get("green", GREEN))
    plan = build_plan(sheets, ov)
    with SessionLocal() as db:
        user = db.scalar(select(User).where(User.email == a.email.lower()))
        if user is None:
            sys.exit(f"No existe el usuario {a.email}")
        rep = apply(db, user, plan, ov)
        mode = "CONFIRMADO" if a.commit else "VISTA PREVIA (no se ha guardado nada)"
        rep.insert(1, f"_{mode}_")
        text = "\n".join(rep) + "\n"
        if a.commit:
            db.commit()
        else:
            db.rollback()
    if a.report:
        a.report.write_text(text, encoding="utf-8")
        print(f"Informe en {a.report}")
    else:
        print(text)


if __name__ == "__main__":
    main()
