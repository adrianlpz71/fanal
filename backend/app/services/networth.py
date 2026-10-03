"""Evolución del patrimonio (D9 de docs/06-rediseno-ui.md, §1.3).

Las cuentas se reconstruyen HACIA ATRÁS desde el saldo de hoy (el mismo de la tarjeta):
saldo(d) = saldo de hoy − movimientos cargados posteriores a d. Así el último punto cuadra con
la tarjeta y el saldo inicial de cada cuenta existe desde el principio (no aparece de golpe el
día del alta).

Reglas:
  · Fecha de cada movimiento: la suya; sin fecha (Excel), el último día de su ciclo si está
    cerrado (lo que sobró al final del ciclo) o el primero si está abierto. Mientras haya ciclos
    sin fechas se pinta UN punto por ciclo; después, uno por semana.
  · Traspasos de UNA pata (el Excel) a una cuenta tuya, hechos ANTES de que esa cuenta se diera
    de alta en Faro: el dinero ya está en su saldo inicial, así que se apunta la entrada que
    falta en esa cuenta (el total de tus cuentas no cambia). Los que van a inversión sí salen:
    ya aparecen como aportación en la serie de inversiones.
  · Inversiones: serie diaria de la cartera (valor de cada activo en cada punto).
  · Deudas y préstamos: desde su fecha de alta, con lo pagado hasta cada día. Fraccionadas: lo
    pendiente en cada día según el calendario de cuotas. Pendientes de VL: solo hoy.
"""

import re
import uuid
from collections import defaultdict
from dataclasses import dataclass, field
from datetime import date, timedelta
from decimal import Decimal

from sqlalchemy import select
from sqlalchemy.orm import Session

from app.domain import milestones as ms
from app.domain.money import ZERO
from app.models import (
    Account,
    Debt,
    Installment,
    InstallmentPlan,
    InvTransaction,
    Movement,
    PayCycle,
    Platform,
    UserSetting,
)
from app.services import analytics as an
from app.services import contributions as contrib
from app.services import inversiones as inv

SAVE_RX = re.compile(r"\b(ahorros?|refugio|emergencia|colch[oó]n|hucha|remunerada)\b", re.I)
INVEST_RX = re.compile(
    r"\b(fondos? indexad\w*|inversi[oó]n(es)?|etf|msci|cripto\w*|bitcoin|acciones|bolsa)\b", re.I
)
REFUGIO_RX = re.compile(r"\b(refugio|emergencia|colch[oó]n)\b", re.I)


@dataclass(frozen=True)
class Component:
    key: str  # c:<cuenta> | a:<activo>
    label: str
    kind: str  # cuenta | inversion
    group: str  # tipo de cuenta (gastos, ahorro, refugio) o de activo (fondo, etf, cripto…)
    entity: str  # banco o plataforma


@dataclass
class Point:
    on: date
    components: dict[str, Decimal]
    accounts: Decimal
    investments: Decimal
    contributed: Decimal  # dinero puesto en inversiones hasta ese día
    pending: Decimal
    receivable: Decimal
    debts: Decimal
    installments: Decimal

    @property
    def net(self) -> Decimal:
        return (
            self.accounts
            + self.investments
            + self.pending
            + self.receivable
            - self.debts
            - self.installments
        )


@dataclass
class Transfer:
    """Traspaso de una pata reconocido como movimiento entre tus cuentas (para la auditoría)."""

    movement: Movement
    on: date
    to: Account


@dataclass
class History:
    points: list[Point]
    components: list[Component]
    start: date | None
    per_cycle_until: date | None  # hasta aquí, un punto por ciclo (movimientos sin fecha)
    own_transfers: list[Transfer] = field(default_factory=list)
    other_one_leg: list[tuple[Movement, date]] = field(default_factory=list)


def _effective(m: Movement, cycles: dict[uuid.UUID, PayCycle], today: date) -> date | None:
    c = cycles.get(m.cycle_id) if m.cycle_id else None
    close = (
        c.end_date - timedelta(days=1)
        if c is not None and c.status == "closed" and c.end_date is not None
        else None
    )
    if m.date is not None:
        # Lo de un ciclo cerrado cuenta como mucho al cierre (el "Ajuste de cuadre" del cobro va
        # fechado el día de la nómina siguiente, pero es del ciclo que se cierra)
        return min(m.date, close or m.date, today)
    if c is None:
        return None  # sin fecha ni ciclo: estaba desde siempre (no mueve la serie)
    return min(close or c.start_date, today)


def _counterpart(m: Movement, accounts: list[Account]) -> Account | None:
    """Cuenta tuya al otro lado de un traspaso de una pata, si se puede saber."""
    if INVEST_RX.search(m.concept):
        return None
    source = next((a for a in accounts if a.id == m.account_id), None)
    others = [a for a in accounts if a.id != m.account_id]
    named = [a for a in others if a.name.strip() and a.name.lower() in m.concept.lower()]
    if len(named) == 1:
        return named[0]
    if source is not None and source.kind != "gastos":
        main = [a for a in others if a.kind == "gastos"]
        return main[0] if len(main) == 1 else None
    if not SAVE_RX.search(m.concept):
        return None
    kind = "refugio" if REFUGIO_RX.search(m.concept) else "ahorro"
    same = [a for a in others if a.kind == kind]
    if len(same) == 1:
        return same[0]
    savings = [a for a in others if a.kind in ("ahorro", "refugio")]
    return savings[0] if len(savings) == 1 else None


def _sample_days(
    start: date,
    today: date,
    cycle_ends: list[date],
    per_cycle_until: date | None,
    first_cycle: date | None = None,
) -> list[date]:
    """Domingos (y hoy); mientras hay ciclos sin fechas, solo el cierre de cada ciclo. Antes del
    primer ciclo (p. ej. inversiones de antes de empezar con los gastos), semanal también."""
    days: set[date] = {today}

    def sundays(a: date, b: date) -> None:  # [a, b)
        d = a
        while d < b:
            if d.weekday() == 6:
                days.add(d)
            d += timedelta(days=1)

    if per_cycle_until is not None:
        days |= {d for d in cycle_ends if start <= d <= per_cycle_until}
        if first_cycle is not None and first_cycle > start:
            sundays(start, first_cycle)
        sundays(per_cycle_until + timedelta(days=1), today)
    else:
        sundays(start, today)
    return sorted(days)


def history(
    db: Session, user_id: uuid.UUID, today: date | None = None, extra_days: set[date] | None = None
) -> History:
    """`extra_days`: días que añadir a la serie (la auditoría pide todos los cierres)."""
    today = today or date.today()
    accounts = list(
        db.scalars(select(Account).where(Account.user_id == user_id).order_by(Account.sort))
    )
    cycles = {c.id: c for c in db.scalars(select(PayCycle).where(PayCycle.user_id == user_id))}
    linked = set(
        db.scalars(
            select(InvTransaction.movement_id).where(
                InvTransaction.user_id == user_id, InvTransaction.movement_id.is_not(None)
            )
        )
    )
    posted = list(
        db.scalars(select(Movement).where(Movement.user_id == user_id, Movement.status == "posted"))
    )

    # Saldos de hoy y cambios por cuenta y día
    balance = {a.id: a.opening_balance for a in accounts}
    deltas: dict[uuid.UUID, dict[date, Decimal]] = {
        a.id: defaultdict(lambda: ZERO) for a in accounts
    }
    own: list[Transfer] = []
    other: list[tuple[Movement, date]] = []
    undated_ends: list[date] = []
    firsts: list[date] = []
    for m in posted:
        if m.account_id not in balance:
            continue
        balance[m.account_id] += m.amount
        on = _effective(m, cycles, today)
        if on is None:
            continue
        firsts.append(on)
        deltas[m.account_id][on] += m.amount
        if m.date is None and m.cycle_id in cycles and cycles[m.cycle_id].status == "closed":
            undated_ends.append(on)
        one_leg = m.kind == "transferencia" and m.transfer_pair_id is None and m.id not in linked
        if not one_leg:
            continue
        to = _counterpart(m, accounts)
        if to is not None and on <= to.opening_date:
            deltas[to.id][on] -= m.amount  # la entrada (o salida) que no se apuntó
            own.append(Transfer(m, on, to))
        else:
            other.append((m, on))

    # Inversiones
    s0 = an.portfolio_series(db, user_id)
    if s0.first:
        firsts.append(s0.first)
    firsts += [a.opening_date for a in accounts]
    if not firsts:
        return History([], [], None, None)
    start = min(firsts)
    # El inicio del seguimiento NO recorta esta serie: solo cambia cómo se mide la rentabilidad.
    # El patrimonio de cada día es un hecho (decisión de Adrián, fase 4).
    per_cycle_until = max(undated_ends) if undated_ends else None
    if per_cycle_until is not None and per_cycle_until < start:
        per_cycle_until = None
    cycle_ends = sorted(
        {
            min(c.end_date - timedelta(days=1), today)
            for c in cycles.values()
            if c.status == "closed" and c.end_date is not None
        }
    )
    first_cycle = min((c.start_date for c in cycles.values()), default=None)
    days = _sample_days(start, today, cycle_ends, per_cycle_until, first_cycle)
    if extra_days:
        days = sorted(set(days) | {d for d in extra_days if start <= d <= today})
    series = an.portfolio_series(db, user_id, per_asset_on=set(days)) if s0.first else s0
    first = series.first
    contributed_by_day: dict[date, Decimal] = {}
    running = ZERO
    for p in series.points:
        running += p.flow
        contributed_by_day[p.on] = running

    # Saldo de cada cuenta en cada punto: hoy − lo posterior
    acc_at: dict[uuid.UUID, dict[date, Decimal]] = {}
    for a in accounts:
        later = sorted(deltas[a.id].items(), reverse=True)
        out: dict[date, Decimal] = {}
        bal, i = balance[a.id], 0
        for d in sorted(days, reverse=True):
            while i < len(later) and later[i][0] > d:
                bal -= later[i][1]
                i += 1
            out[d] = bal
        acc_at[a.id] = out

    # Deudas, préstamos y fraccionadas en cada punto
    debt_rows = list(db.scalars(select(Debt).where(Debt.user_id == user_id)))
    debt_moves: dict[uuid.UUID, list[tuple[date, Decimal]]] = defaultdict(list)
    for m in posted:
        if m.debt_id is not None and (on := _effective(m, cycles, today)) is not None:
            debt_moves[m.debt_id].append((on, m.amount))
    eff_by_movement = {m.id: _effective(m, cycles, today) for m in posted}
    plans = list(db.scalars(select(InstallmentPlan).where(InstallmentPlan.user_id == user_id)))
    insts = list(
        db.scalars(
            select(Installment).where(
                Installment.plan_id.in_([p.id for p in plans]),
                Installment.status != "cancelada",
            )
        )
    )
    plan_start = {p.id: min(p.first_due, p.created_at.date()) for p in plans}

    def debts_at(d: date) -> tuple[Decimal, Decimal]:
        owe, owed = ZERO, ZERO
        for x in debt_rows:
            if d < x.opening_date:
                continue
            moved = sum((a for on, a in debt_moves[x.id] if on <= d), ZERO)
            if x.direction == "debo":
                owe += max(x.opening_balance + moved, ZERO)
            else:
                owed += max(x.opening_balance - moved, ZERO)
        return owe, owed

    def installments_at(d: date) -> Decimal:
        total = ZERO
        for i in insts:
            if d < plan_start[i.plan_id]:
                continue
            if i.status == "pendiente":
                total += i.amount
                continue
            paid_on = eff_by_movement.get(i.movement_id) if i.movement_id else None
            if (paid_on or i.due_date) > d:
                total += i.amount
        return total

    # Componentes: cada cuenta y cada activo con algún valor en la serie
    assets = {a.id: a for a in inv.assets(db, user_id, include_archived=True)}
    platforms = {
        p.id: p.name for p in db.scalars(select(Platform).where(Platform.user_id == user_id))
    }
    pending_today = inv.portfolio(db, user_id).pending
    points: list[Point] = []
    for d in days:
        comps: dict[str, Decimal] = {f"c:{a.id}": acc_at[a.id][d] for a in accounts}
        if first is not None and d >= first:
            for aid, v in series.by_asset.get(d, {}).items():
                comps[f"a:{aid}"] = v
        acc_total = sum((acc_at[a.id][d] for a in accounts), ZERO)
        inv_total = sum((v for k, v in comps.items() if k.startswith("a:")), ZERO)
        owe, owed = debts_at(d)
        points.append(
            Point(
                on=d,
                components=comps,
                accounts=acc_total,
                investments=inv_total,
                contributed=contributed_by_day.get(d, ZERO) if first and d >= first else ZERO,
                pending=pending_today if d == today else ZERO,
                receivable=owed,
                debts=owe,
                installments=installments_at(d),
            )
        )
    used = {k for p in points for k, v in p.components.items() if v != 0}
    components = [
        Component(f"c:{a.id}", a.name, "cuenta", a.kind, a.bank or "")
        for a in accounts
        if f"c:{a.id}" in used
    ] + [
        Component(f"a:{a.id}", a.name, "inversion", a.type, platforms.get(a.platform_id, ""))
        for a in sorted(assets.values(), key=lambda x: x.name)
        if f"a:{a.id}" in used
    ]
    return History(points, components, start, per_cycle_until, own, other)


# --- Hitos ----------------------------------------------------------------------------------------
MILESTONES_KEY = "networth_milestones"


def thresholds(db: Session, user_id: uuid.UUID) -> list[Decimal]:
    row = db.scalar(
        select(UserSetting).where(UserSetting.user_id == user_id, UserSetting.key == MILESTONES_KEY)
    )
    if row is None:
        return list(ms.DEFAULT_THRESHOLDS)
    return [Decimal(x) for x in row.value.get("thresholds", [])]


def save_thresholds(db: Session, user_id: uuid.UUID, values: list[Decimal]) -> list[Decimal]:
    clean = ms.clean(values)
    row = db.scalar(
        select(UserSetting).where(UserSetting.user_id == user_id, UserSetting.key == MILESTONES_KEY)
    )
    value = {"thresholds": [str(v) for v in clean]}
    if row is None:
        db.add(UserSetting(user_id=user_id, key=MILESTONES_KEY, value=value))
    else:
        row.value = value
    db.flush()
    return clean


@dataclass
class Milestones:
    thresholds: list[Decimal]
    items: list[ms.Milestone]
    next: ms.Next | None
    pace: Decimal  # aportación media mensual (inversión + ahorro) de los últimos 12 meses
    net: Decimal
    start: date | None


def milestones(db: Session, user_id: uuid.UUID, today: date | None = None) -> Milestones:
    today = today or date.today()
    h = history(db, user_id, today)
    th = thresholds(db, user_id)
    series = [(p.on, p.net) for p in h.points]
    net = series[-1][1] if series else ZERO
    pace = contrib.history(db, user_id, today).totals.pace
    return Milestones(
        th, ms.reached(series, th), ms.next_one(net, th, pace, today), pace, net, h.start
    )
