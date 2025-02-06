FROM postgres:16.1-alpine3.18

COPY . /app
WORKDIR /app

# Устанавливаем Python3, pip и необходимые пакеты
RUN apk update && \
    apk add --no-cache python3 py3-pip && \
    pip3 install alembic psycopg2-binary

# Копируем конфигурационные файлы Alembic в образ.
# Предполагается, что у вас в репозитории есть файл alembic.ini и папка alembic с миграциями.
COPY alembic.ini /app/alembic.ini
COPY alembic /app/alembic