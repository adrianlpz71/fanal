import logging
import time
import uuid

from fastapi import FastAPI, Request
from fastapi.middleware.cors import CORSMiddleware

from app import __version__
from app.api import (
    analytics,
    auth,
    export,
    gastos,
    gastos_extra,
    imports,
    inversiones,
    me,
    planes,
    revision,
    system,
)
from app.config import get_settings
from app.logs import setup_logging

log = logging.getLogger("faro.http")


def create_app() -> FastAPI:
    settings = get_settings()
    setup_logging()
    app = FastAPI(
        title="Fanal API",
        version=__version__,
        docs_url="/api/docs" if settings.env != "prod" else None,
        redoc_url=None,
        openapi_url="/api/openapi.json",
        # operationId = nombre de la función → métodos legibles en el cliente Dart generado
        generate_unique_id_function=lambda route: route.name,
    )

    if settings.cors_origins:  # solo dev (flutter web en otro puerto)
        app.add_middleware(
            CORSMiddleware,
            allow_origins=settings.cors_origins,
            allow_credentials=True,
            allow_methods=["*"],
            allow_headers=["*"],
        )

    @app.middleware("http")
    async def access_log(request: Request, call_next):  # type: ignore[no-untyped-def]
        # Solo método, ruta, estado y duración: nunca cuerpos, importes ni tokens.
        rid = request.headers.get("x-request-id") or uuid.uuid4().hex[:12]
        start = time.perf_counter()
        response = await call_next(request)
        log.info(
            "request",
            extra={
                "rid": rid,
                "method": request.method,
                "path": request.url.path,
                "status": response.status_code,
                "ms": round((time.perf_counter() - start) * 1000, 1),
            },
        )
        response.headers["X-Request-Id"] = rid
        response.headers["Cache-Control"] = "no-store"
        return response

    for r in (
        system.router,
        auth.router,
        me.router,
        gastos.router,
        gastos_extra.router,
        imports.router,
        inversiones.router,
        analytics.router,
        planes.router,
        revision.router,
        export.router,
    ):
        app.include_router(r, prefix="/api")
    return app


app = create_app()
