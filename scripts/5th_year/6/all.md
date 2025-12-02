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

## 3.2	Создать пользователей с паролями и назначить им роли по умолчанию (совпадающие с именами пользователей).
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
