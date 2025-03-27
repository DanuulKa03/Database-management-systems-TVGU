"""Merge multiple heads

Revision ID: ff3f0a4a1f45
Revises: f6717d13e73b, 5d4ea56c71d7
Create Date: 2025-03-13 20:38:52.944261

"""
from typing import Sequence, Union

from alembic import op
import sqlalchemy as sa


# revision identifiers, used by Alembic.
revision: str = 'ff3f0a4a1f45'
down_revision: Union[str, None] = ('f6717d13e73b', '5d4ea56c71d7')
branch_labels: Union[str, Sequence[str], None] = None
depends_on: Union[str, Sequence[str], None] = None


def upgrade() -> None:
    pass


def downgrade() -> None:
    pass
