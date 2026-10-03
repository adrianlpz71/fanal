"""Revisión trimestral: qué pasó en el trimestre (ahorro, fijos, cartera, patrimonio) comparado con
el anterior, cómo va el plan de independencia y qué decide el usuario.

· Trimestre natural. Cada ciclo de nómina cuenta en el trimestre de su mes ("Octubre 26" → T4) y
  solo cuentan los ciclos cerrados.
· Al guardar la revisión se hace una foto de las métricas: el trimestre siguiente se compara con
  lo que había entonces (incluida la edad de independencia, que no se puede recalcular hacia atrás).
"""

import uuid
from dataclasses import asdict, dataclass, field
from datetime import date, timedelta
from decimal import Decimal
from typing import Any

from fastapi import HTTPException, status
from sqlalchemy import select
from sqlalchemy.orm import Session

from app.domain import calendar as cal
from app.domain import performance as perf
from app.domain.money import ZERO, q2
from app.models import Goal, PayCycle, QuarterlyReview, User
from app.services import analytics as an
from app.services import gastos_extra as ex
from app.services import inversiones as inv
from app.services import planes as pl


@dataclass(frozen=True, order=True)
class Quarter:
    year: int
    q: int

    @property
    def key(self) -> str:
        return f"{self.year}-Q{self.q}"

    @property
    def label(self) -> str:
        return f"T{self.q} {self.year}"

    @property
    def start(self) -> date:
        return date(self.year, 3 * (self.q - 1) + 1, 1)

    @property
    def end(self) -> date:
        return self.next().start - timedelta(days=1)

    def next(self) -> "Quarter":
        return Quarter(self.year + (self.q == 4), self.q % 4 + 1)

    def prev(self) -> "Quarter":
        return Quarter(self.year - (self.q == 1), (self.q - 2) % 4 + 1)

    def has_month(self, year: int, month: int) -> bool:
        return year == self.year and (month - 1) // 3 + 1 == self.q

    @staticmethod
    def of(d: date) -> "Quarter":
        return Quarter(d.year, (d.month - 1) // 3 + 1)

    @staticmethod
    def parse(s: str) -> "Quarter":
        try:
            y, q = s.split("-Q")
            out = Quarter(int(y), int(q))
        except ValueError:
            out = None
        if out is None or not 1 <= out.q <= 4 or not 2000 <= out.year <= 2100:
            raise HTTPException(
                status.HTTP_422_UNPROCESSABLE_ENTITY, "Trimestre no válido (AAAA-QN)"
            )
        return out


@dataclass
class GoalLine:
    name: str
    progress: Decimal | None
    on_track: bool | None


@dataclass
class Metrics:
    cycles: int = 0
    income: Decimal = ZERO  # nómina + otros ingresos
    spend: Decimal = ZERO
    surplus: Decimal = ZERO  # lo que sobró: ingresos − gasto
    savings_rate: Decimal | None = None
    fixed_avg: Decimal | None = None  # fijos + cuotas, media por ciclo
    categories: dict[str, Decimal] = field(default_factory=dict)  # gasto por categoría raíz
    portfolio_start: Decimal = ZERO
    portfolio_end: Decimal = ZERO
    contributed: Decimal = ZERO
    gain: Decimal = ZERO
    twr: Decimal | None = None
    networth_start: Decimal = ZERO
    networth_end: Decimal = ZERO
    # Estado del plan (el de hoy; en una revisión guardada, el de cuando se guardó)
    fire_needed: Decimal | None = None
    fire_progress: Decimal | None = None
    fire_age: Decimal | None = None
    out_of_range: list[str] = field(default_factory=list)
    goals: list[GoalLine] = field(default_factory=list)


def _value_at(points: list[tuple[date, Decimal]], d: date) -> Decimal:
    v = ZERO
    for on, value in points:
        if on > d:
            break
        v = value
    return v


def money_metrics(
    db: Session, user_id: uuid.UUID, q: Quarter, today: date | None = None
) -> Metrics:
    """Lo que pasó en el trimestre (no depende del momento en que se mire)."""
    today = today or date.today()
    m = Metrics()
    # Ahorro y gasto: ciclos cerrados cuyo mes cae en el trimestre
    try:
        stats = [s for s in ex.cycles_stats(db, user_id, 400) if s.status == "closed"]
    except HTTPException:  # gastos sin configurar
        stats = []
    in_q = [s for s in stats if (k := cal.key_from_label(s.label)) and q.has_month(k.year, k.month)]
    if in_q:
        _, cats = ex._root_map(db, user_id)
        m.cycles = len(in_q)
        m.income = sum((s.payroll + s.income for s in in_q), ZERO)
        m.spend = sum((s.spend for s in in_q), ZERO)
        m.surplus = m.income - m.spend
        m.savings_rate = (m.surplus / m.income) if m.income else None
        m.fixed_avg = sum((s.fixed + s.installments for s in in_q), ZERO) / len(in_q)
        by: dict[str, Decimal] = {}
        for s in in_q:
            for cid, amount in s.by_category.items():
                name = cats[cid].name if cid in cats else "Sin categoría"
                by[name] = by.get(name, ZERO) + amount
        m.categories = {k: v for k, v in by.items() if v}
    # Cartera
    end = min(q.end, today)
    series = an.portfolio_series(db, user_id)
    pts = [(p.on, p.value) for p in series.points]
    m.portfolio_start = q2(_value_at(pts, q.start - timedelta(days=1)))
    m.portfolio_end = q2(_value_at(pts, end))
    m.contributed = q2(sum((p.flow for p in series.points if q.start <= p.on <= end), ZERO))
    m.gain = m.portfolio_end - m.portfolio_start - m.contributed
    rets = [
        r.ret
        for r in perf.monthly(series.points)
        if q.has_month(r.year, r.month) and r.ret is not None
    ]
    m.twr = perf.chain(rets) if rets else None
    # Patrimonio (cuentas + inversiones)
    hist = [(d, acc + invest) for d, acc, invest in an.networth_history(db, user_id)]
    m.networth_start = q2(_value_at(hist, q.start - timedelta(days=1)))
    m.networth_end = q2(_value_at(hist, end))
    return m


def plan_state(db: Session, user: User, m: Metrics) -> Metrics:
    """Añade el estado actual del plan: independencia, cartera fuera de rango y objetivos."""
    try:
        f = pl.fire_plan(db, user)
        m.fire_needed, m.fire_progress, m.fire_age = f.base.needed, f.base.progress, f.base.fi_age
    except HTTPException:  # plan sin configurar o sin fecha de nacimiento
        pass
    try:
        p = inv.portfolio(db, user.id)
        m.out_of_range = [
            f"{c.cls.name} {'por debajo' if c.status == 'bajo' else 'por encima'}"
            for c in p.classes
            if c.status in ("bajo", "alto")
        ]
    except HTTPException:
        pass
    for g in db.scalars(select(Goal).where(Goal.user_id == user.id, Goal.archived.is_(False))):
        gp = pl.goal_progress(db, user, g)
        m.goals.append(GoalLine(g.name, gp.progress, gp.on_track))
    return m


# --- Foto (JSON) ---------------------------------------------------------------------------------
def to_json(m: Metrics) -> dict[str, Any]:
    def conv(v: Any) -> Any:
        if isinstance(v, Decimal):
            return str(v)
        if isinstance(v, dict):
            return {k: conv(x) for k, x in v.items()}
        if isinstance(v, list):
            return [conv(x) for x in v]
        return v

    return conv(asdict(m))


def from_json(d: dict[str, Any]) -> Metrics:
    def dec(v: Any) -> Decimal | None:
        return None if v is None else Decimal(v)

    m = Metrics()
    for k in (
        "income",
        "spend",
        "surplus",
        "portfolio_start",
        "portfolio_end",
        "contributed",
        "gain",
        "networth_start",
        "networth_end",
    ):
        setattr(m, k, Decimal(d.get(k, "0")))
    for k in ("savings_rate", "fixed_avg", "twr", "fire_needed", "fire_progress", "fire_age"):
        setattr(m, k, dec(d.get(k)))
    m.cycles = int(d.get("cycles", 0))
    m.categories = {k: Decimal(v) for k, v in d.get("categories", {}).items()}
    m.out_of_range = list(d.get("out_of_range", []))
    m.goals = [
        GoalLine(g["name"], dec(g.get("progress")), g.get("on_track")) for g in d.get("goals", [])
    ]
    return m


# --- Casos de uso --------------------------------------------------------------------------------
def first_quarter(db: Session, user_id: uuid.UUID, today: date) -> Quarter:
    starts = list(db.scalars(select(PayCycle.start_date).where(PayCycle.user_id == user_id)))
    s = an.portfolio_series(db, user_id)
    if s.first:
        starts.append(s.first)
    first = Quarter.of(min(starts)) if starts else Quarter.of(today)
    tracked = an.track_start(db, user_id)  # con inicio del seguimiento, las revisiones empiezan ahí
    return max(first, Quarter.of(min(tracked, today))) if tracked else first


def saved(db: Session, user_id: uuid.UUID, q: Quarter) -> QuarterlyReview | None:
    return db.scalar(
        select(QuarterlyReview).where(
            QuarterlyReview.user_id == user_id, QuarterlyReview.quarter == q.key
        )
    )


def quarters(
    db: Session, user_id: uuid.UUID, today: date | None = None
) -> list[tuple[Quarter, bool]]:
    """Del más reciente al más antiguo: (trimestre, guardado)."""
    today = today or date.today()
    done = set(
        db.scalars(select(QuarterlyReview.quarter).where(QuarterlyReview.user_id == user_id))
    )
    q, first, out = Quarter.of(today), first_quarter(db, user_id, today), []
    while q >= first:
        out.append((q, q.key in done))
        q = q.prev()
    return out


@dataclass
class Review:
    quarter: Quarter
    in_progress: bool
    metrics: Metrics
    previous: Metrics | None
    changed: str
    next_steps: str
    saved_at: Any  # datetime | None


def review(db: Session, user: User, q: Quarter, today: date | None = None) -> Review:
    today = today or date.today()
    row = saved(db, user.id, q)
    metrics = (
        from_json(row.metrics)
        if row
        else plan_state(db, user, money_metrics(db, user.id, q, today))
    )
    prev_row = saved(db, user.id, q.prev())
    if prev_row:
        previous = from_json(prev_row.metrics)
    elif q.prev() >= first_quarter(db, user.id, today):
        previous = money_metrics(db, user.id, q.prev(), today)
    else:
        previous = None
    return Review(
        q,
        q.end >= today,
        metrics,
        previous,
        row.changed if row else "",
        row.next_steps if row else "",
        row.updated_at if row else None,
    )


def save(db: Session, user: User, q: Quarter, changed: str, next_steps: str) -> QuarterlyReview:
    """Guarda (o rehace) la revisión con la foto de las métricas de este momento."""
    m = plan_state(db, user, money_metrics(db, user.id, q))
    row = saved(db, user.id, q)
    if row is None:
        row = QuarterlyReview(user_id=user.id, quarter=q.key)
        db.add(row)
    row.metrics, row.changed, row.next_steps = to_json(m), changed.strip(), next_steps.strip()
    db.flush()
    return row


def rising(
    current: Metrics, previous: Metrics | None, n: int = 3
) -> list[tuple[str, Decimal, Decimal]]:
    """Categorías que más subieron frente al trimestre anterior: (nombre, ahora, antes)."""
    if previous is None:
        return []
    diffs = [
        (name, amount, previous.categories.get(name, ZERO))
        for name, amount in current.categories.items()
        if amount > previous.categories.get(name, ZERO)
    ]
    return sorted(diffs, key=lambda x: x[1] - x[2], reverse=True)[:n]
