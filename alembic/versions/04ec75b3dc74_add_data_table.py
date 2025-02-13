"""add_data_table

Revision ID: 04ec75b3dc74
Revises: a12e22fe1f4c
Create Date: 2025-02-13 16:03:11.938270

"""
from typing import Sequence, Union

from alembic import op
import sqlalchemy as sa

# revision identifiers, used by Alembic.
revision: str = '04ec75b3dc74'
down_revision: Union[str, None] = 'a12e22fe1f4c'
branch_labels: Union[str, Sequence[str], None] = None
depends_on: Union[str, Sequence[str], None] = None


def upgrade() -> None:
    op.execute("""
        INSERT INTO student (second_name, name, patronymic, n_group, telephone)
        VALUES ('Федоров', 'Антон', 'Викторович', '12B', '89009876543'),
               ('Кузнецов', 'Дмитрий', 'Петрович', '13C', '89006789012'),
               ('Смирнов', 'Владимир', 'Николаевич', '13C', NULL),
               ('Васильев', 'Артем', 'Дмитриевич', '14A', '89003456789'),
               ('Морозов', 'Сергей', 'Александрович', '14A', '89005678901'),
               ('Новиков', 'Михаил', 'Романович', '15D', '89007775544'),
               ('Попов', 'Александр', 'Иванович', '15D', NULL),
               ('Соколов', 'Кирилл', 'Михайлович', '16E', '89003334455'),
               ('Лебедев', 'Максим', 'Геннадьевич', '16E', '89002221133');
    """)

    op.execute("""
        INSERT INTO discipline (title_discipline, second_name_teacher)
        VALUES ('Химия', 'Смирнов'),
               ('Биология', 'Иванов'),
               ('Литература', 'Петров'),
               ('История', 'Сидорова'),
               ('География', 'Кузнецов'),
               ('Информатика', 'Смирнов');
    """)


def downgrade() -> None:
    pass
