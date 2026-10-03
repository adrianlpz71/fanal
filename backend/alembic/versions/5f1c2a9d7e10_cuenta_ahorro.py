"""cuentas: tipo ahorro

Revision ID: 5f1c2a9d7e10
Revises: eb8883a81209
Create Date: 2026-10-02 18:00:00
"""

from collections.abc import Sequence

from alembic import op

revision: str = "5f1c2a9d7e10"
down_revision: str | None = "eb8883a81209"
branch_labels: str | Sequence[str] | None = None
depends_on: str | Sequence[str] | None = None

NEW = "kind IN ('gastos', 'refugio', 'ahorro', 'inversion', 'efectivo', 'otra')"
OLD = "kind IN ('gastos', 'refugio', 'inversion', 'efectivo', 'otra')"


def upgrade() -> None:
    op.drop_constraint(op.f("ck_accounts_kind_valid"), "accounts", type_="check")
    op.create_check_constraint(op.f("ck_accounts_kind_valid"), "accounts", NEW)


def downgrade() -> None:
    op.execute("UPDATE accounts SET kind = 'otra' WHERE kind = 'ahorro'")
    op.drop_constraint(op.f("ck_accounts_kind_valid"), "accounts", type_="check")
    op.create_check_constraint(op.f("ck_accounts_kind_valid"), "accounts", OLD)
