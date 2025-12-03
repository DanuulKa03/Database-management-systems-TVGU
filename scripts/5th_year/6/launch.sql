-- 1. Создаем таблицу mand_tab на основе student, добавив столбец уровня доступа
CREATE TABLE mand_tab AS
SELECT n_credit_book,
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
SELECT n_credit_book,
       second_name,
       name,
       patronymic,
       n_group,
       telephone,
       -- Вычисляем уровень доступа: номер курса = первая цифра в номере группы
       -- Преобразуем первый символ группы в число, затем определяем уровень
       CASE
           WHEN SUBSTRING(n_group FROM '^(\d)')::INT <= 2 THEN 0 -- 1-2 курс -> уровень 0
           WHEN SUBSTRING(n_group FROM '^(\d)')::INT <= 4 THEN 1 -- 3-4 курс -> уровень 1
           ELSE 2 -- 5-6 курс -> уровень 2
           END
           as mand_level
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
CREATE TABLE user_levels
(
    user_name  VARCHAR(50) PRIMARY KEY,
    user_level INT NOT NULL CHECK (user_level BETWEEN 0 AND 2)
);

-- Заполняем таблицу user_levels
INSERT INTO user_levels (user_name, user_level)
VALUES ('stud_0', 0),
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

-- 3.7. Реализация удаления: триггер BEFORE DELETE для mand_tab

-- Функция-триггер контроля удаления
CREATE
    OR REPLACE FUNCTION mand_tab_before_delete()
    RETURNS trigger
    LANGUAGE plpgsql
AS
$$
DECLARE
    v_username text;
    v_user_level
               int;
BEGIN
    -- 3.7.1.1. Определяем имя текущего (активного) пользователя
    v_username
        := current_user;
    -- в PostgreSQL аналог USER()

    -- 3.7.1.2. Определяем уровень доступа пользователя по таблице user_levels
    SELECT user_level
    INTO v_user_level
    FROM user_levels
    WHERE user_name = v_username;

    IF
        NOT FOUND THEN
        RAISE EXCEPTION SQLSTATE '50005'
            USING MESSAGE = format(
                    'Для пользователя %s не задан уровень доступа в таблице user_levels',
                    v_username
                            );
    END IF;

    -- Если метка доступа пользователя не соответствует метке записи, запрещаем удаление
    IF
        v_user_level <> OLD.mand_level THEN
        RAISE EXCEPTION SQLSTATE '50005'
            USING MESSAGE = format(
                    'Удаление запрещено: уровень пользователя (%s) не совпадает с уровнем записи (%s)',
                    v_user_level, OLD.mand_level
                            );
    END IF;

    -- Разрешаем удаление
    RETURN OLD;
END;
$$;

-- Сам триггер
DROP TRIGGER IF EXISTS trg_mand_tab_before_delete ON mand_tab;

CREATE TRIGGER trg_mand_tab_before_delete
    BEFORE DELETE
    ON mand_tab
    FOR EACH ROW
EXECUTE FUNCTION mand_tab_before_delete();


-- 3.8. Реализация выборки: «процедура» select_mand_tab

-- Представление, в котором отбираются записи только с уровнем текущего пользователя
-- (используем его в п. 3.8.1.3)
CREATE OR REPLACE VIEW mand_tab_view AS
SELECT m.*
FROM mand_tab m
         JOIN user_levels u
              ON u.user_level = m.mand_level
                  AND u.user_name = current_user;
-- привязка к активному пользователю

-- Хранимая функция select_mand_tab
CREATE
    OR REPLACE FUNCTION select_mand_tab()
    RETURNS SETOF mand_tab
    LANGUAGE plpgsql
AS
$$
DECLARE
    v_username text;
    v_user_level
               int;
    v_cnt
               int;
BEGIN
    -- 3.8.1.1. Определяем имя текущего пользователя
    v_username
        := current_user;

    -- 3.8.1.2. Определяем его уровень доступа по user_levels
    SELECT user_level
    INTO v_user_level
    FROM user_levels
    WHERE user_name = v_username;

    IF
        NOT FOUND THEN
        RAISE EXCEPTION SQLSTATE '50005'
            USING MESSAGE = format(
                    'Для пользователя %s не задан уровень доступа в таблице user_levels',
                    v_username
                            );
    END IF;

    -- 3.8.1.3. Проверяем, есть ли записи с таким уровнем
    SELECT count(*)
    INTO v_cnt
    FROM mand_tab
    WHERE mand_level = v_user_level;

-- 3.8.1.4. Если записей нет, печатаем сообщение
    IF
        v_cnt = 0 THEN
        RAISE NOTICE 'Записи не найдены.';
        RETURN;
    END IF;

    -- Возвращаем записи, используя представление (п. 3.8.1.3)
    RETURN QUERY
        SELECT *
        FROM mand_tab_view;
END;
$$;

-- Разрешаем вызов функции пользователям-студентам
GRANT EXECUTE ON FUNCTION select_mand_tab
    () TO stud_0, stud_1, stud_2;
