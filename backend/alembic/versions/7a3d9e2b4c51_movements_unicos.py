"""movements: restricciones únicas con nombre propio

Las dos UniqueConstraint de movements generaban el mismo nombre por la convención
(uq_movements_user_id) y solo llegó a crearse la de bank_ref: la de external_ref no existía.

Revision ID: 7a3d9e2b4c51
Revises: c6e72d8db597
Create Date: 2026-10-02 19:00:00
"""

from collections.abc import Sequence

from alembic import op

revision: str = "7a3d9e2b4c51"
down_revision: str | None = "c6e72d8db597"
branch_labels: str | Sequence[str] | None = None
depends_on: str | Sequence[str] | None = None


def upgrade() -> None:
    op.execute(
        "ALTER TABLE movements RENAME CONSTRAINT uq_movements_user_id TO uq_movements_bank_ref"
    )
    op.create_unique_constraint(
        "uq_movements_external_ref", "movements", ["user_id", "external_ref"]
    )


def downgrade() -> None:
    op.drop_constraint("uq_movements_external_ref", "movements", type_="unique")
    op.execute(
        "ALTER TABLE movements RENAME CONSTRAINT uq_movements_bank_ref TO uq_movements_user_id"
    )
