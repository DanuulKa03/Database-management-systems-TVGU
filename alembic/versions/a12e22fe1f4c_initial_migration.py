"""Initial migration

Revision ID: a12e22fe1f4c
Revises: 
Create Date: 2025-02-06 20:35:52.040616

"""
from typing import Sequence, Union

from alembic import op
import sqlalchemy as sa
from sqlalchemy.sql import text


# revision identifiers, used by Alembic.
revision: str = 'a12e22fe1f4c'
down_revision: Union[str, None] = None
branch_labels: Union[str, Sequence[str], None] = None
depends_on: Union[str, Sequence[str], None] = None


def upgrade() -> None:
    with open("alembic/initial.sql", "r", encoding="utf-8") as sql_file:
        sql_statements = sql_file.read()

    # Выполняем весь SQL-скрипт целиком
    conn = op.get_bind()
    conn.execute(text(sql_statements))

    with open("alembic/insert.sql", "r", encoding="utf-8") as sql_file:
        sql_statements = sql_file.read()

    # Выполняем весь SQL-скрипт целиком
    conn = op.get_bind()
    conn.execute(text(sql_statements))

def downgrade() -> None:
    pass
