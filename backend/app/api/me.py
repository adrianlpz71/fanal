from datetime import UTC, datetime

from fastapi import APIRouter

from app.api.deps import CurrentUser
from app.models import User
from app.schemas.auth import ProfileIn, UserOut

router = APIRouter(prefix="/me", tags=["me"])


def _out(u: User) -> UserOut:
    return UserOut(
        id=u.id,
        email=u.email,
        display_name=u.display_name,
        birth_date=u.birth_date,
        locale=u.locale,
        currency=u.currency,
        timezone=u.timezone,
        tax_region=u.tax_region,
        onboarding_completed=u.onboarding_completed_at is not None,
    )


@router.get("", response_model=UserOut)
def me(user: CurrentUser) -> UserOut:
    return _out(user)


@router.patch("", response_model=UserOut)
def update_profile(body: ProfileIn, user: CurrentUser) -> UserOut:
    """Perfil básico del onboarding. Cada módulo añadirá sus preguntas en su fase."""
    if body.display_name is not None:
        user.display_name = body.display_name.strip()
    if body.birth_date is not None:
        user.birth_date = body.birth_date
    if body.tax_region is not None:
        user.tax_region = body.tax_region
    if body.complete_onboarding and user.onboarding_completed_at is None:
        user.onboarding_completed_at = datetime.now(UTC)
    return _out(user)
