import json
from datetime import UTC, datetime, timedelta
from pathlib import Path

from fastapi import APIRouter
from pydantic import BaseModel
from sqlalchemy import select, text

from app import __version__
from app.api.deps import DB
from app.config import get_settings
from app.models import JobRun

router = APIRouter(tags=["system"])


class HealthOut(BaseModel):
    status: str
    db: bool
    worker_seen: bool


class AppRelease(BaseModel):
    version: str
    build: int
    apk_url: str
    sha256: str | None = None
    min_supported_build: int = 0
    notes: str | None = None


class VersionOut(BaseModel):
    api_version: str
    app: AppRelease | None


@router.get("/health", response_model=HealthOut)
def health(db: DB) -> HealthOut:
    db_ok = db.scalar(text("select 1")) == 1
    since = datetime.now(UTC) - timedelta(minutes=15)
    worker_seen = (
        db.scalar(
            select(JobRun.id).where(JobRun.job == "heartbeat", JobRun.started_at >= since).limit(1)
        )
        is not None
    )
    return HealthOut(status="ok" if db_ok else "degraded", db=db_ok, worker_seen=worker_seen)


@router.get("/version", response_model=VersionOut)
def version() -> VersionOut:
    """Última versión publicada de la app (la escribe el deploy en latest.json)."""
    path = Path(get_settings().release_info_path)
    app = None
    if path.is_file():
        try:
            app = AppRelease.model_validate(json.loads(path.read_text(encoding="utf-8")))
        except (ValueError, OSError):
            app = None
    return VersionOut(api_version=__version__, app=app)
