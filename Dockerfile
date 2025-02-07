FROM postgres:16.1-alpine3.18

COPY . /app
WORKDIR /app

# Устанавливаем Python3, pip и необходимые пакеты
RUN apk update && \
    apk add --no-cache python3 py3-pip && \
    pip3 install alembic psycopg2-binary