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
    conn = op.get_bind()

    # Выполняем initial.sql
    with open("alembic/initial.sql", "r", encoding="utf-8") as f:
        initial_sql = f.read()
    conn.execute(text(initial_sql))

    # Выполняем insert.sql
    with open("alembic/insert.sql", "r", encoding="utf-8") as f:
        insert_sql = f.read()
    conn.execute(text(insert_sql))


def downgrade() -> None:
    op.execute("""
    -- Удаление данных (в обратном порядке)
    
    DELETE FROM staff_orders;
    DELETE FROM telephone_number;
    DELETE FROM list_social_programs_promotions;
    DELETE FROM list_additional_equipment_cars;
    DELETE FROM list_car_models_engines;
    DELETE FROM list_fuel_types_engines;
    DELETE FROM car_order_colors;
    DELETE FROM social_programs_promotions;
    DELETE FROM additional_equipment_car;
    DELETE FROM sale_contracts;
    DELETE FROM sales;
    DELETE FROM car_orders;
    DELETE FROM car_instances;
    DELETE FROM staff;
    DELETE FROM clients;
    DELETE FROM human;
    DELETE FROM telephone_type;
    DELETE FROM order_types;
    DELETE FROM labor_rates;
    DELETE FROM positions;
    DELETE FROM engines;
    DELETE FROM fuel_types;
    DELETE FROM car_body_types;
    DELETE FROM drive_types;
    DELETE FROM classes_cars;
    DELETE FROM brands;
    
    -- Удаление таблиц
    DROP TABLE IF EXISTS staff_orders;
    DROP TABLE IF EXISTS telephone_number;
    DROP TABLE IF EXISTS list_social_programs_promotions;
    DROP TABLE IF EXISTS list_additional_equipment_cars;
    DROP TABLE IF EXISTS list_car_models_engines;
    DROP TABLE IF EXISTS list_fuel_types_engines;
    DROP TABLE IF EXISTS car_order_colors;
    DROP TABLE IF EXISTS social_programs_promotions;
    DROP TABLE IF EXISTS additional_equipment_car;
    DROP TABLE IF EXISTS sale_contracts;
    DROP TABLE IF EXISTS sales;
    DROP TABLE IF EXISTS car_orders;
    DROP TABLE IF EXISTS car_instances;
    DROP TABLE IF EXISTS staff;
    DROP TABLE IF EXISTS clients;
    DROP TABLE IF EXISTS human;
    DROP TABLE IF EXISTS telephone_type;
    DROP TABLE IF EXISTS order_types;
    DROP TABLE IF EXISTS labor_rates;
    DROP TABLE IF EXISTS positions;
    DROP TABLE IF EXISTS engines;
    DROP TABLE IF EXISTS fuel_types;
    DROP TABLE IF EXISTS car_body_types;
    DROP TABLE IF EXISTS drive_types;
    DROP TABLE IF EXISTS classes_cars;
    DROP TABLE IF EXISTS brands;
    
    -- Удаление типов
    DROP TYPE IF EXISTS car_instances_status;
    DROP TYPE IF EXISTS driver_categorys;
    DROP TYPE IF EXISTS type_discount;
    DROP TYPE IF EXISTS status_social_programs_promotions;
    DROP TYPE IF EXISTS order_status;
    DROP TYPE IF EXISTS sale_contract_status;
    """)
