# Старт

Запуск двух контейнеров:
```shell
docker compose up -d
```

Остановка контейнера:
```shell
docker compose down
```

Как подключиться к контейнеру ?
```shell
docker compose exec postgres sh
```
Вы попадете в консоль контейнера, по умолчанию вы окажитесь в папке app. 

Для инициализации базы данных нужно ввести команду
```shell
docker compose exec postgres alembic upgrade head
```

Подключение к базе данных
```shell
  docker compose exec postgres psql -h localhost -U tvgupguser -d tvgudb
```