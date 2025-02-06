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
Вы попадете в консоль контейнера, по умолчанию вы окажитесь в корне. 