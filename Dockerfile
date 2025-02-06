FROM postgres:16.1-alpine3.18

WORKDIR /app

# Устанавливаем Python3, pip и необходимые пакеты
RUN apk update && \
    apk add --no-cache python3 py3-pip && \
    pip3 install alembic psycopg2-binary

# Копируем конфигурационные файлы Alembic в образ.
# Предполагается, что у вас в репозитории есть файл alembic.ini и папка alembic с миграциями.
COPY alembic.ini /app/alembic.ini
COPY alembic /app/alembic

# Копируем скрипт entrypoint, который сначала выполнит миграции, а затем запустит PostgreSQL
COPY entrypoint.sh /app/entrypoint.sh
RUN chmod +x /app/entrypoint.sh

# Переопределяем ENTRYPOINT: сначала выполняется наш скрипт, а потом стандартный entrypoint Postgres.
ENTRYPOINT ["/app/entrypoint.sh"]

# По умолчанию запускается сервер PostgreSQL
CMD ["postgres"]
