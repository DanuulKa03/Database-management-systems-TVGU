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

-- Заполняем данными и вычисляем мандатный уровень
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

-- Создаём таблицу user_levels
CREATE TABLE user_levels (
    user_name VARCHAR(50) PRIMARY KEY,
    user_level INT NOT NULL CHECK (user_level BETWEEN 0 AND 2)
);

-- Заполняем таблицу user_levels
INSERT INTO user_levels (user_name, user_level) VALUES
    ('stud_0', 0),
    ('stud_1', 1),
    ('stud_2', 2);

-- Выдаем права на таблицу mand_tab
GRANT SELECT, INSERT, UPDATE, DELETE ON mand_tab TO stud_0;
GRANT SELECT, INSERT, UPDATE, DELETE ON mand_tab TO stud_1;
GRANT SELECT, INSERT, UPDATE, DELETE ON mand_tab TO stud_2;

-- Выдаем SELECT на user_levels
GRANT SELECT ON user_levels TO stud_0;
GRANT SELECT ON user_levels TO stud_1;
GRANT SELECT ON user_levels TO stud_2;
