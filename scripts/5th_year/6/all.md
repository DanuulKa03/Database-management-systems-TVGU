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

