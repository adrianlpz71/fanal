"""Exportación de datos (fase 6)."""

from datetime import date
from typing import Literal

from fastapi import APIRouter, Query, Response

from app.api.deps import DB, CurrentUser
from app.services import export as svc

router = APIRouter(prefix="/export", tags=["export"])


@router.get(
    "",
    response_class=Response,
    responses={
        200: {
            "content": {
                "application/json": {},
                "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet": {},
            }
        }
    },
)
def export_all(db: DB, user: CurrentUser, format: Literal["json", "xlsx"] = Query(default="json")):
    """Todos tus datos (sin nada de seguridad). JSON para copias o Excel para mirarlos."""
    data = svc.collect(db, user)
    name = f"faro-{date.today().isoformat()}"
    if format == "xlsx":
        body = svc.to_xlsx(data)
        media = "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet"
        filename = f"{name}.xlsx"
    else:
        body, media, filename = svc.to_json(data), "application/json", f"{name}.json"
    return Response(
        body,
        media_type=media,
        headers={"Content-Disposition": f'attachment; filename="{filename}"'},
    )
