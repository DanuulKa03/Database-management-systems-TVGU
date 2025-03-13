"""add_poor_student

Revision ID: f6717d13e73b
Revises: 04ec75b3dc74
Create Date: 2025-02-24 13:07:10.909165

"""
from typing import Sequence, Union

from alembic import op
import sqlalchemy as sa


# revision identifiers, used by Alembic.
revision: str = 'f6717d13e73b'
down_revision: Union[str, None] = '04ec75b3dc74'
branch_labels: Union[str, Sequence[str], None] = None
depends_on: Union[str, Sequence[str], None] = None


def upgrade() -> None:
    op.execute("""
        INSERT INTO discipline (title_discipline, second_name_teacher)
        VALUES ('Информатика', 'Казаков'),
               ('Математика', 'Казаков'),
               ('Английский', 'Казаков'),
               ('Информатика', 'Коновалов'),
               ('Математика', 'Коновалов'),
               ('Английский', 'Коновалов')
        ON CONFLICT (n_discipline) DO NOTHING;
    """)

    op.execute("""
        INSERT INTO student_discipline (n_credit_book, n_discipline, estimation)
        VALUES
               (11, 10, 5),
               (11, 11, 5),
               (11, 12, 5), 
               (10, 13, 5),
               (10, 14, 5),
               (10, 15, 5), 
               (12, 1, 2),
               (12, 2, 2),
               (12, 3, 2),
               (12, 10, 2)
               
           ON CONFLICT (n_credit_book, n_discipline) DO NOTHING;
    """)

def downgrade() -> None:
    pass
