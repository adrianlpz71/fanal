"""Worker de tareas programadas. En fase 1 solo hay latido (heartbeat) y limpieza; precios,
snapshots, recurrentes y cuotas se añaden en sus fases.

Cada tarea se ejecuta con un advisory lock de Postgres, de modo que dos workers (p. ej. durante
un deploy) nunca ejecutan la misma tarea a la vez, y queda registrada en `job_runs`."""

import logging
import zlib
from collections.abc import Callable
from datetime import UTC, datetime, timedelta

from apscheduler.schedulers.blocking import BlockingScheduler
from sqlalchemy import delete, text
from sqlalchemy.orm import Session

from app.db import SessionLocal, engine
from app.logs import setup_logging
from app.models import JobRun, LoginAttempt, RefreshToken

log = logging.getLogger("faro.worker")


def run_job(name: str, fn: Callable[[Session], str | None]) -> None:
    lock_id = zlib.crc32(name.encode())
    # El advisory lock es por conexión: se toma y se suelta en una conexión dedicada (la Session
    # puede cambiar de conexión del pool entre commits).
    with engine.connect() as lock_conn:
        if not lock_conn.scalar(text("select pg_try_advisory_lock(:id)"), {"id": lock_id}):
            log.info("job.skipped_locked", extra={"job": name})
            return
        try:
            with SessionLocal() as db:
                run = JobRun(job=name, started_at=datetime.now(UTC))
                db.add(run)
                db.commit()
                try:
                    run.detail = fn(db)
                    run.ok = True
                    db.commit()
                except Exception as e:
                    db.rollback()
                    run.ok = False
                    run.detail = f"{type(e).__name__}: {e}"[:2000]
                    log.exception("job.failed", extra={"job": name})
                finally:
                    run.finished_at = datetime.now(UTC)
                    db.add(run)
                    db.commit()
        finally:
            lock_conn.execute(text("select pg_advisory_unlock(:id)"), {"id": lock_id})
            lock_conn.commit()


def heartbeat(db: Session) -> str:
    return "ok"


def cleanup(db: Session) -> str:
    now = datetime.now(UTC)
    a = db.execute(delete(LoginAttempt).where(LoginAttempt.at < now - timedelta(days=30)))
    r = db.execute(delete(RefreshToken).where(RefreshToken.expires_at < now - timedelta(days=7)))
    j = db.execute(delete(JobRun).where(JobRun.started_at < now - timedelta(days=90)))
    return f"login_attempts={a.rowcount} refresh={r.rowcount} job_runs={j.rowcount}"  # type: ignore[attr-defined]


def plans(db: Session) -> str:
    from app.services import inversiones

    return f"created={inversiones.generate_plans(db)}"


def prices(db: Session) -> str:
    from app.services import inversiones
    from app.services import prices as px

    results = px.update(db)
    settled = inversiones.auto_settle(db)
    failed = [r for r in results if r.quote is None]
    # Solo recuentos en el detalle (sin importes ni nombres)
    return f"ok={len(results) - len(failed)} failed={len(failed)} settled={settled}"


def backfill(db: Session) -> str:
    import httpx

    from app.services import analytics
    from app.services import prices as px

    with httpx.Client(timeout=30, headers={"User-Agent": px.UA}) as client:
        n, errors = analytics.backfill_prices(db, client)
        m, errors2 = analytics.refresh_exposures(db, client)
    return f"prices={n} exposures={m} errors={len(errors) + len(errors2)}"


def snapshots(db: Session) -> str:
    from app.services import inversiones

    users = inversiones.users_with_assets(db)
    for uid in users:
        inversiones.snapshot_day(db, uid)
    return f"users={len(users)}"


def main() -> None:
    setup_logging()
    sched = BlockingScheduler(timezone="Atlantic/Canary")
    sched.add_job(
        run_job,
        "interval",
        minutes=5,
        args=["heartbeat", heartbeat],
        next_run_time=datetime.now(UTC),
    )
    sched.add_job(run_job, "cron", hour=4, minute=30, args=["cleanup", cleanup])
    # Los VL de los fondos salen por la mañana (del día anterior); la cripto cambia siempre
    sched.add_job(run_job, "cron", hour=7, minute=0, args=["plans", plans])
    sched.add_job(run_job, "cron", hour="8,12,16,20", minute=10, args=["prices", prices])
    sched.add_job(run_job, "cron", hour=23, minute=40, args=["snapshots", snapshots])
    # Histórico de precios que falte y composición de los fondos: semanal
    sched.add_job(run_job, "cron", day_of_week="sun", hour=6, minute=0, args=["backfill", backfill])
    log.info("worker.start")
    sched.start()


if __name__ == "__main__":
    main()
