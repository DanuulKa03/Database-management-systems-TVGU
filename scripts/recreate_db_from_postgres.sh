#!/bin/sh

rm -rf docker/postgres-data/*
docker compose down
docker compose up -d
docker compose exec postgres alembic upgrade head