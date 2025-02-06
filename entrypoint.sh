#!/bin/sh
set -e

echo "Ожидание запуска PostgreSQL..."
# Ждем, пока сервер Postgres станет доступен (проверка на localhost:5432)
while ! pg_isready -q -h localhost -p 5432; do
sleep 1
done

echo "Выполняем миграции Alembic..."
# Применяем все миграции (проверьте, что в файле alembic.ini корректно указан URL для подключения к базе)
alembic upgrade head

echo "Запускаем PostgreSQL..."
# Передаем управление оригинальному entrypoint-скрипту из образа Postgres
exec docker-entrypoint.sh "$@"
