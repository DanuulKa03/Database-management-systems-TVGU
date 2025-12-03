# 1. **Мандатная модель разграничения доступа** подразумевает предоставление пользователям доступа к записям соответствующего уровня секретности в некоторой таблице БД.

***1.1 Пользователь может получить доступ на чтение (select) к записям своего уровня секретности и ниже.***
***1.2 Пользователь может получить доступ на запись (update) записей своего уровня секретности и выше.***
***1.3 Пользователь может получить доступ на создание (insert) к записям своего уровня секретности.***
***1.4 Пользователь может получить доступ на удаление (delete) записей своего уровня секретности***

---
# 2. Словесное описание мандатной модели

## 2.1 Выбор таблицы для реализации модели
Например, в качестве mand_tab выбирается таблица Студент с
добавленным спец. столбцом mand_level (метка доступа).

## 2.2 Пользователи и их права на работу с таблицей *student*

Ниже представлена таблица, описывающая типы пользователей:

| Роль пользователя | Описание роли                        | Уровень секретности |
| ----------------- | ------------------------------------ | ------------------- |
| Студент 0 уровня  | Работа с данными студентов 1–2 курса | 0                   |
| Студент 1 уровня  | Работа с данными студентов 3–4 курса | 1                   |
| Студент 2 уровня  | Работа с данными студентов 5–6 курса | 2                   |


---

## 2.3 Уровни секретности пользователей
Уровни секретности соответствуют диапазонам курсов:
- **Уровень 0**:
    — _Чтение_: только студенты 1‑го и 2‑го курсов.
    — _Запись_ (обновление): студенты всех курсов (1–6).
- **Уровень 1**:
    — _Чтение_: студенты 1–4 курсов.
    — _Запись_ (обновление): только студенты 3–6 курсов.
- **Уровень 2**:
    — _Чтение_: студенты всех курсов (1–6).
    — _Запись_ (обновление): только студенты 5‑го и 6‑го курсов.
- **Вставка и удаление** записей разрешены **только** в рамках курсов, соответствующих уровню доступа пользователя.

Мандатная модель требует, чтобы пользователь имел уровень **не ниже**, чем уровень запрашиваемой записи.

---

## 2.4 Таблица *user_levels* и назначение уровней секретности

Для управления пользователями и назначением уровней создаётся служебная таблица:

### Таблица 2 — user_levels
| Поле   | Уровень доступа |
| ------ | --------------- |
| stud_0 | 0               |
| stud_1 | 1               |
| stud_2 | 2               |

Каждый пользователь получает уровень секретности. На его основе система определяет, может ли он получить доступ к определённым строкам в таблице *student*.

---
# 3.	Реализация мандатной модели.
## 3.1	Добавить в таблицу mand_tab столбец level с правами (метками) доступа.
Создание таблицы и добавление столбца
Выполнение из под root
```sql
-- 1. Создаем таблицу mand_tab на основе student, добавив столбец уровня доступа
CREATE TABLE mand_tab AS
SELECT
    n_credit_book,
    second_name,
    name,
    patronymic,
    n_group,
    telephone
FROM student
WHERE FALSE;

-- Добавляем столбец уровня доступа (mand_level)
ALTER TABLE mand_tab
ADD COLUMN mand_level INT NOT NULL;

-- Добавляем CHECK constraint для mand_level
ALTER TABLE mand_tab
ADD CONSTRAINT chk_mand_level CHECK (mand_level BETWEEN 0 AND 2);

-- Также сохраняем проверку для номера группы
ALTER TABLE mand_tab
ADD CONSTRAINT chk_n_group CHECK (n_group ~ '^\d{2}[A-Z]?$');
```
Заполняем данными и вычисляем мандатный уровень
Выполнение из под root
```sql
INSERT INTO mand_tab (n_credit_book, second_name, name, patronymic, n_group, telephone, mand_level)
SELECT
    n_credit_book,
    second_name,
    name,
    patronymic,
    n_group,
    telephone,
    -- Вычисляем уровень доступа: номер курса = первая цифра в номере группы
    -- Преобразуем первый символ группы в число, затем определяем уровень
    CASE
        WHEN SUBSTRING(n_group FROM '^(\d)')::INT <= 2 THEN 0  -- 1-2 курс -> уровень 0
        WHEN SUBSTRING(n_group FROM '^(\d)')::INT <= 4 THEN 1  -- 3-4 курс -> уровень 1
        ELSE 2  -- 5-6 курс -> уровень 2
    END as mand_level
FROM student;

SELECT * FROM mand_tab;
```
| n_credit_book | second_name |   name   | patronymic | n_group | telephone   | mand_level |
|---------------|-------------|----------|------------|---------|-------------|------------|
| 38            |	ПЕТРОВ    |	    Иван | Алексеевич |	11A     | 89001234567 |	0          |
| 3             |	СИДОРОВ |	Николай   |	Игоревич |	12B |	|	0|
|  4            |	ФЕДОРОВ |	Антон     |	Викторович |	12B |	89009876543|	0
| 6             |	СМИРНОВ |	Владимир |	Николаевич |	13C | |		0|
|  7            |	ВАСИЛЬЕВ |	Артем |	Дмитриевич |	14A |	89003456789|	0
| 8             |	МОРОЗОВ |	Сергей |	Александрович |	14A |	89005678901|	0
| 9             |	НОВИКОВ |	Михаил |	Романович |	15D |	89007775544|	0
| 10            |	ПОПОВ |	Александр |	Иванович |	15D | |		0|
|  11           |	СОКОЛОВ |	Кирилл |	Михайлович |	16E |	89003334455|	0
| 12            |	ЛЕБЕДЕВ |	Максим |	Геннадьевич |	16E |	89002221133|	0
| 14            |	БОРИСОВ |	Максим |	Игоревич |	23C |	89771112233|	0
| 15            |	МИРОНОВА |	Екатерина |	Сергеевна |	23C | |		0|
|  16           |	ГАВРИЛОВ |	Артём |	Васильевич |	23C |	89882223344|	0
| 17            |	ДЕНИСОВА |	Юлия |	Викторовна |	24A |	|	0|
|  18           |	ЖУКОВ |	Павел |	Алексеевич |	24A |	89993334455|	0
| 19            |	ЗАХАРОВА |	Алина |	Дмитриевна |	24A |	89115556677|	0
| 20            |	ИГНАТЬЕВ |	Сергей |	Романович |	32B |	|	1|
|  21           |	МИРОНОВ |	Марина |	Евгеньевна |	32B |	89227778899|	1
| 22            |	ЛАЗАРЕВ |	Олег |	Станиславович |	32B |	|	1|
|  23           |	МАКАРОВА |	Татьяна |	Артёмовна |	33C |	89338889900|	1
| 24            |	НИКИТИН |	Иван |	Олегович |	33C |	|	1|
|  26           |	ПАВЛОВ |	Дмитрий |	Станиславович |	41A |	89551234567|	1
| 27            |	РЯБЦЕВА |	Виктория |	Максимовна |	41A | |		1|
|  28           |	СИДОРОВ |	Александр |	Владимирович |	41A |	89662345678|	1
| 29            |	ТИМОФЕЕВА |	Наталья |	Игоревна |	42B |	89773456789|	1
| 30            |	УВАРОВ |	Егор |	Дмитриевич |	42B |	|	1|
|  5            |	НАЗАРОВ |	Кирилл |	Дмитриевич |	13C |	89004989312|	0
| 31            |	ИВАНОВ |	Максим |	Игоревич |	14A |	89771114233|	0
| 32            |	ИВАНОВ |	Игорь |	Сергеевич |	15D |	|	0|
|  33           |	ИВАНОВ |	Дмитрий |	Сергеевич |	61A |	|	2|
|  34           |	СМИРНОВА |	Анна |	Викторовна |	61A |	|	2|
|  35           |	КУЗНЕЦОВ |	Артём |	Павлович |	61B |	|	2|
|  36           |	НОВИКОВА |	Екатерина |	Игоревна |	61B |	|	2|
|  1            |	ИВАНОВ |	Алексей |	Сергеевич |	52Z |	89005553322|	2
| 37            |	? |	? |	? |	13A |	|	0|
##  3.2	Создать пользователей с паролями и назначить им роли по умолчанию (совпадающие с именами пользователей).
Выполняем из под root
```sql
-- Студент 0 уровня
CREATE ROLE stud_0 WITH
    LOGIN
    PASSWORD 'password0'
    NOSUPERUSER
    NOCREATEDB
    NOCREATEROLE;

-- Студент 1 уровня
CREATE ROLE stud_1 WITH
    LOGIN
    PASSWORD 'password1'
    NOSUPERUSER
    NOCREATEDB
    NOCREATEROLE;

-- Студент 2 уровня
CREATE ROLE stud_2 WITH
    LOGIN
    PASSWORD 'password2'
    NOSUPERUSER
    NOCREATEDB
    NOCREATEROLE;
```

## 3.3	Создать таблицу user_levels с двумя столбцами user_name и user_level, в которой будут храниться уровни секретности пользователей.

```sql
CREATE TABLE user_levels (
    user_name VARCHAR(50) PRIMARY KEY,
    user_level INT NOT NULL CHECK (user_level BETWEEN 0 AND 2)
);
```

## 3.4	Заполнить таблицу user_levels: определить для созданных пользователей уровни секретности.

```sql
INSERT INTO user_levels (user_name, user_level) VALUES
    ('stud_0', 0),
    ('stud_1', 1),
    ('stud_2', 2);

-- Проверяем заполнение
SELECT * FROM user_levels ORDER BY user_level;
```
| user_name | user_level    |
| --------- | ------------- |
| stud_0    | 0             |
| stud_1    | 1             |
| stud_2    | 2             |

```sql
--Выдаём права на таблицу mand_tab
GRANT SELECT, INSERT, UPDATE, DELETE ON mand_tab TO stud_0;
GRANT SELECT, INSERT, UPDATE, DELETE ON mand_tab TO stud_1;
GRANT SELECT, INSERT, UPDATE, DELETE ON mand_tab TO stud_2;

-- Выдаем SELECT на user_levels
GRANT SELECT ON user_levels TO stud_0;
GRANT SELECT ON user_levels TO stud_1;
GRANT SELECT ON user_levels TO stud_2;
```

## 3.5.	Реализация вставки.
### 3.5.1.	Написать триггер вставки before insert для таблицы mand_tab, который осуществляет контроль за вставкой записей в эту таблицу. В триггере выполнить следующие операции:
        1.  С помощью функции USER() определить имя текущего (активного) пользователя.

        2.  Определить его уровень доступа по таблице user_levels.

        3.  Если уровень секретности пользователя не позволяет ему осуществлять данную операцию (значение метки вставляемой записи не соответствует метке пользователя – см. п. 1.2), вызвать сообщение об ошибке (например, с помощью signal sqlstate '50005' set message_text = 'Сообщение об ошибке').  -
**Выполняем из под рута**
```sql
CREATE OR REPLACE FUNCTION check_insert_mand_tab()
RETURNS TRIGGER AS $$
DECLARE
    curr_user TEXT;
    curr_level INT;
BEGIN
    curr_user := CURRENT_USER;

    SELECT user_level INTO curr_level
    FROM user_levels
    WHERE user_name = curr_user;

    IF NEW.mand_level <> curr_level THEN
        RAISE EXCEPTION 'Ошибка вставки: пользователь % (уровень %) не может вставить запись уровня %',
            curr_user, curr_level, NEW.mand_level
            USING ERRCODE = '50005';
    END IF;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_insert_mand_tab
BEFORE INSERT ON mand_tab
FOR EACH ROW
EXECUTE FUNCTION check_insert_mand_tab();
```

### 3.5.2.	После создания триггера выполнить вставку от имени каждого пользователя.
### 3.5.3.	Распечатать системные сообщения и результаты вставки в таблицу.

**выполняем из под stud_0**
успешная вставка
```sql
tvgudb=> INSERT INTO mand_tab (n_credit_book, second_name, name, patronymic, n_group, telephone, mand_level)
tvgudb-> VALUES (2001, 'Тестов', 'Студент0', 'А.', '11A', '80000000001', 0);
INSERT 0 1
tvgudb=>
```
неудачная вставка
```sql
tvgudb=> INSERT INTO mand_tab (n_credit_book, second_name, name, patronymic, n_group, telephone, mand_level)
tvgudb-> VALUES (2002, 'Тестов', 'Студент0', 'студентович', '33B', '80000000002', 1);
ERROR:  Ошибка вставки: пользователь stud_0 (уровень 0) не может вставить запись уровня 1
CONTEXT:  PL/pgSQL function check_insert_mand_tab() line 13 at RAISE
```

**выполняем из под stud_1**
успешная вставка
```sql
tvgudb=> INSERT INTO mand_tab (n_credit_book, second_name, name, patronymic, n_group, telephone, mand_level)
tvgudb-> VALUES (2003, 'Тестов', 'Студент1', 'И.', '32A', '80090000001', 1);
INSERT 0 1
```
неудачная вставка
```sql
tvgudb=> INSERT INTO mand_tab (n_credit_book, second_name, name, patronymic, n_group, telephone, mand_level)
tvgudb-> VALUES (2004, 'Тестов', 'Студент1', 'И.', '62A', '80090000001', 2);
ERROR:  Ошибка вставки: пользователь stud_1 (уровень 1) не может вставить запись уровня 2
CONTEXT:  PL/pgSQL function check_insert_mand_tab() line 13 at RAISE
```

**выполняем из под stud_2**
успешная вставка
```sql
tvgudb=> INSERT INTO mand_tab (n_credit_book, second_name, name, patronymic, n_group, telephone, mand_level)
tvgudb-> VALUES (2005, 'Тестов', 'Студент2', 'Ф.', '56A', '80090000001', 2);
INSERT 0 1
```
неудачная вставка
```sql
tvgudb=> INSERT INTO mand_tab (n_credit_book, second_name, name, patronymic, n_group, telephone, mand_level)
tvgudb-> VALUES (2006, 'Тестов', 'Студент1', 'Ф.', '15A', '80090000001', 0);
ERROR:  Ошибка вставки: пользователь stud_2 (уровень 2) не может вставить запись уровня 0
CONTEXT:  PL/pgSQL function check_insert_mand_tab() line 13 at RAISE
```
## 3.6.	Реализация обновления.
### 3.6.1.	Написать триггер обновления before update для таблицы mand_tab, который осуществляет контроль за обновлением записей в этой таблице. В триггере выполнить следующие операции.
        1.  С помощью функции USER() определить имя текущего (активного) пользователя.

        2.  Определить его уровень доступа по таблице user_levels.

        3.  Если уровень секретности пользователя не позволяет ему осуществлять данную операцию (значение метки обновляемой записи не соответствует метке пользователя), вызвать сообщение об ошибке (например, с помощью signal sqlstate '50005' set message_text = 'Сообщение об ошибке').
**Выполняем из под рута**
```sql
CREATE OR REPLACE FUNCTION check_update_mand_tab()
RETURNS TRIGGER AS $$
DECLARE
    curr_user TEXT;
    curr_level INT;
BEGIN
    curr_user := CURRENT_USER;

    SELECT user_level INTO curr_level
    FROM user_levels
    WHERE user_name = curr_user;

    IF OLD.mand_level < curr_level THEN
        RAISE EXCEPTION 'Ошибка обновления: пользователь % (уровень %) не может изменять запись уровня %',
            curr_user, curr_level, OLD.mand_level
            USING ERRCODE = '50005';
    END IF;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_update_mand_tab
BEFORE UPDATE ON mand_tab
FOR EACH ROW
EXECUTE FUNCTION check_update_mand_tab();
```
### 3.6.2.	После создания триггера выполнить обновление от имени каждого пользователя.
### 3.6.3.	Распечатать системные сообщения и результат обновления таблицы.
**выполняем из под stud_0**
обновляем запись уровня 0
```sql
tvgudb=> UPDATE mand_tab
tvgudb-> SET second_name = 'Иванов_туц'
tvgudb-> WHERE n_credit_book = 1;
UPDATE 1
```
обновляем запись уровня 2
```sql
tvgudb=> UPDATE mand_tab
tvgudb-> SET second_name = 'stud_2_new'
tvgudb-> WHERE n_credit_book = 2005;
UPDATE 1
```
**выполняем из под stud_1**
обновляем запись уровня 0
```sql
tvgudb=>  UPDATE mand_tab
tvgudb->  SET second_name = 'Иванов_juj'
tvgudb->  WHERE n_credit_book = 1;
ERROR:  Ошибка обновления: пользователь stud_1 (уровень 1) не может изменять запись уровня 0
CONTEXT:  PL/pgSQL function check_update_mand_tab() line 13 at RAISE
```
обновляем запись уровня 2
```sql
tvgudb=>  UPDATE mand_tab
tvgudb->  SET second_name = 'stud_2_FEF'
tvgudb->  WHERE n_credit_book = 2005;
UPDATE 1
```
**выполняем из под stud_2**
обновляем запись уровня 0
```sql
tvgudb=> UPDATE mand_tab
tvgudb-> SET second_name = 'Иванов_куе'
tvgudb-> WHERE n_credit_book = 1;
ERROR:  Ошибка обновления: пользователь stud_2 (уровень 2) не может изменять запись уровня 0
CONTEXT:  PL/pgSQL function check_update_mand_tab() line 13 at RAISE
```
обновляем запись уровня 1
```sql
tvgudb=> UPDATE mand_tab
tvgudb-> SET second_name = 'Петров_куе'
tvgudb-> WHERE n_credit_book = 5;
ERROR:  Ошибка обновления: пользователь stud_2 (уровень 2) не может изменять запись уровня 1
CONTEXT:  PL/pgSQL function check_update_mand_tab() line 13 at RAISE
```
обновляем запись уровня 2
```sql
tvgudb=>  UPDATE mand_tab
tvgudb->  SET second_name = 'stud_2_http'
tvgudb->  WHERE n_credit_book = 2005;
UPDATE 1
```

Удаление (3.7.2–3.7.3) — от имени администратора или владельца схемы:

| n\_credit\_book | second\_name | name | patronymic | n\_group | telephone | mand\_level |
| :--- | :--- | :--- | :--- | :--- | :--- | :--- |
| 2 | Петров | Иван | Алексеевич | 11A | 89001234567 | 0 |
| 3 | Сидоров | Николай | Игоревич | 12B | null | 0 |
| 4 | Федоров | Антон | Викторович | 12B | 89009876543 | 0 |
| 6 | Смирнов | Владимир | Николаевич | 13C | null | 0 |
| 7 | Васильев | Артем | Дмитриевич | 14A | 89003456789 | 0 |
| 8 | Морозов | Сергей | Александрович | 14A | 89005678901 | 0 |
| 9 | Новиков | Михаил | Романович | 15D | 89007775544 | 0 |
| 10 | Попов | Александр | Иванович | 15D | null | 0 |
| 11 | Соколов | Кирилл | Михайлович | 16E | 89003334455 | 0 |
| 12 | Лебедев | Максим | Геннадьевич | 16E | 89002221133 | 0 |
| 14 | Борисов | Максим | Игоревич | 23C | 89771112233 | 0 |
| 15 | Миронова | Екатерина | Сергеевна | 23C | null | 0 |
| 16 | Гаврилов | Артём | Васильевич | 23C | 89882223344 | 0 |
| 17 | Денисова | Юлия | Викторовна | 24A | null | 0 |
| 18 | Жуков | Павел | Алексеевич | 24A | 89993334455 | 0 |
| 19 | Захарова | Алина | Дмитриевна | 24A | 89115556677 | 0 |
| 20 | Игнатьев | Сергей | Романович | 32B | null | 1 |
| 21 | Миронов | Марина | Евгеньевна | 32B | 89227778899 | 1 |
| 22 | Лазарев | Олег | Станиславович | 32B | null | 1 |
| 23 | Макарова | Татьяна | Артёмовна | 33C | 89338889900 | 1 |
| 24 | Никитин | Иван | Олегович | 33C | null | 1 |
| 25 | Мироновская | Светлана | Вячеславовна | 33C | 89440001122 | 1 |
| 26 | Павлов | Дмитрий | Станиславович | 41A | 89551234567 | 1 |
| 27 | Рябцева | Виктория | Максимовна | 41A | null | 1 |
| 28 | Сидоров | Александр | Владимирович | 41A | 89662345678 | 1 |
| 29 | Тимофеева | Наталья | Игоревна | 42B | 89773456789 | 1 |
| 30 | Уваров | Егор | Дмитриевич | 42B | null | 1 |
| 5 | Назаров | Кирилл | Дмитриевич | 13C | 89004989312 | 0 |
| 33 | Новиков | Павел | Владимирович | 13C | 89007775555 | 0 |
| 34 | Смирнов | Олег | Викторович | 14A | 89003334455 | 0 |

```sql
-- пример: пробуем удалить одну и ту же запись под разными ролями
SET ROLE stud_0;
DELETE FROM mand_tab WHERE n_credit_book = '12345';  -- либо любой существующий
RESET ROLE;
```

```shell
[2025-12-03 12:21:18] tvgudb.public> SET ROLE stud_0
[2025-12-03 12:21:18] completed in 8 ms
[2025-12-03 12:21:18] tvgudb.public> DELETE FROM mand_tab WHERE n_credit_book = '10'
[2025-12-03 12:21:18] completed in 9 ms
[2025-12-03 12:21:18] tvgudb.public> RESET ROLE
[2025-12-03 12:21:18] completed in 2 ms
```

Вывод таблицы после удаления :

| n\_credit\_book | second\_name | name | patronymic | n\_group | telephone | mand\_level |
| :--- | :--- | :--- | :--- | :--- | :--- | :--- |
| 2 | Петров | Иван | Алексеевич | 11A | 89001234567 | 0 |
| 3 | Сидоров | Николай | Игоревич | 12B | null | 0 |
| 4 | Федоров | Антон | Викторович | 12B | 89009876543 | 0 |
| 6 | Смирнов | Владимир | Николаевич | 13C | null | 0 |
| 7 | Васильев | Артем | Дмитриевич | 14A | 89003456789 | 0 |
| 8 | Морозов | Сергей | Александрович | 14A | 89005678901 | 0 |
| 9 | Новиков | Михаил | Романович | 15D | 89007775544 | 0 |
| 11 | Соколов | Кирилл | Михайлович | 16E | 89003334455 | 0 |
| 12 | Лебедев | Максим | Геннадьевич | 16E | 89002221133 | 0 |
| 14 | Борисов | Максим | Игоревич | 23C | 89771112233 | 0 |
| 15 | Миронова | Екатерина | Сергеевна | 23C | null | 0 |
| 16 | Гаврилов | Артём | Васильевич | 23C | 89882223344 | 0 |
| 17 | Денисова | Юлия | Викторовна | 24A | null | 0 |
| 18 | Жуков | Павел | Алексеевич | 24A | 89993334455 | 0 |
| 19 | Захарова | Алина | Дмитриевна | 24A | 89115556677 | 0 |
| 20 | Игнатьев | Сергей | Романович | 32B | null | 1 |
| 21 | Миронов | Марина | Евгеньевна | 32B | 89227778899 | 1 |
| 22 | Лазарев | Олег | Станиславович | 32B | null | 1 |
| 23 | Макарова | Татьяна | Артёмовна | 33C | 89338889900 | 1 |
| 24 | Никитин | Иван | Олегович | 33C | null | 1 |
| 25 | Мироновская | Светлана | Вячеславовна | 33C | 89440001122 | 1 |
| 26 | Павлов | Дмитрий | Станиславович | 41A | 89551234567 | 1 |
| 27 | Рябцева | Виктория | Максимовна | 41A | null | 1 |
| 28 | Сидоров | Александр | Владимирович | 41A | 89662345678 | 1 |
| 29 | Тимофеева | Наталья | Игоревна | 42B | 89773456789 | 1 |
| 30 | Уваров | Егор | Дмитриевич | 42B | null | 1 |
| 5 | Назаров | Кирилл | Дмитриевич | 13C | 89004989312 | 0 |
| 33 | Новиков | Павел | Владимирович | 13C | 89007775555 | 0 |
| 34 | Смирнов | Олег | Викторович | 14A | 89003334455 | 0 | 
      
```sql
SET ROLE stud_1;
DELETE FROM mand_tab WHERE n_credit_book = '5';
RESET ROLE;
```

```shell
[2025-12-03 12:28:49] tvgudb.public> SET ROLE stud_1
[2025-12-03 12:28:49] completed in 7 ms
[2025-12-03 12:28:49] tvgudb.public> DELETE FROM mand_tab WHERE n_credit_book = '5'
[2025-12-03 12:28:49] [50005] ERROR: Удаление запрещено: уровень пользователя (1) не совпадает с уровнем записи (0)
[2025-12-03 12:28:49] Where: PL/pgSQL function mand_tab_before_delete() line 30 at RAISE
```
      
```sql
SET ROLE stud_2;
DELETE FROM mand_tab WHERE n_credit_book = '34';
RESET ROLE;
```

```shell
[2025-12-03 12:29:51] tvgudb.public> SET ROLE stud_2
[2025-12-03 12:29:51] completed in 5 ms
[2025-12-03 12:29:51] tvgudb.public> DELETE FROM mand_tab WHERE n_credit_book = '34'
[2025-12-03 12:29:51] [50005] ERROR: Удаление запрещено: уровень пользователя (2) не совпадает с уровнем записи (0)
[2025-12-03 12:29:51] Where: PL/pgSQL function mand_tab_before_delete() line 30 at RAISE
```

Выборка (3.8.2–3.8.3):
```sql
SET ROLE stud_0;
SELECT * FROM select_mand_tab();
RESET ROLE;
```

```shell
[2025-12-03 12:30:53] tvgudb.public> SET ROLE stud_0
[2025-12-03 12:30:53] completed in 9 ms
[2025-12-03 12:30:53] tvgudb.public> SELECT * FROM select_mand_tab()
[2025-12-03 12:30:53] [42501] ERROR: permission denied for view mand_tab_view
[2025-12-03 12:30:53] Where: SQL statement "SELECT *
[2025-12-03 12:30:53] FROM mand_tab_view"
[2025-12-03 12:30:53] PL/pgSQL function select_mand_tab() line 42 at RETURN QUERY
```
      
```sql
SET ROLE stud_1;
SELECT * FROM select_mand_tab();
RESET ROLE;
```

```shell
[2025-12-03 12:32:03] tvgudb.public> SET ROLE stud_1
[2025-12-03 12:32:03] completed in 3 ms
[2025-12-03 12:32:03] tvgudb.public> SELECT * FROM select_mand_tab()
[2025-12-03 12:32:03] [42501] ERROR: permission denied for view mand_tab_view
[2025-12-03 12:32:03] Where: SQL statement "SELECT *
[2025-12-03 12:32:03] FROM mand_tab_view"
[2025-12-03 12:32:03] PL/pgSQL function select_mand_tab() line 42 at RETURN QUERY
```

```sql
SET ROLE stud_2;
SELECT * FROM select_mand_tab();
RESET ROLE;
```

```shell
[2025-12-03 12:32:14] tvgudb.public> SET ROLE stud_2
[2025-12-03 12:32:14] completed in 2 ms
[2025-12-03 12:32:14] tvgudb.public> SELECT * FROM select_mand_tab()
Записи не найдены.
[2025-12-03 12:32:14] 0 rows retrieved in 468 ms (execution: 11 ms, fetching: 457 ms)
[2025-12-03 12:32:14] tvgudb.public> RESET ROLE
[2025-12-03 12:32:14] completed in 2 ms
```
