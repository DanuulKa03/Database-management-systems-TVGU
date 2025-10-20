-- 8. Создайте таблицу Стипендия. Создайте триггер Before Insert для таблицы Стипендия, который
-- при начислении студенту социальной стипендии проверяет, должен ли студент получать
-- академическую стипендию по итогам результатов сессии, и если должен, то назначает
-- стипендию, равную сумме академической и социальной стипендии.

-- Таблица "Стипендия" (включает вид и сумму)
CREATE TABLE IF NOT EXISTS scholarship (
    id           SERIAL PRIMARY KEY,
    credit_book  INT NOT NULL REFERENCES student(n_credit_book) ON DELETE CASCADE,
    stipend_kind TEXT NOT NULL CHECK (stipend_kind IN ('social','academic','combined')),
    amount       NUMERIC(12,2) NOT NULL,
    assigned_at  TIMESTAMP NOT NULL DEFAULT NOW(),
    n_group      VARCHAR(10) NOT NULL
    );

-- Функция: если вставляется 'social' и студент тянет на академическую
-- (нет оценок < 4), то превращаем в 'combined' и добавляем размер академической
CREATE OR REPLACE FUNCTION trg_scholarship_before_insert_social_plus_academic()
    RETURNS TRIGGER AS $$
DECLARE
    v_eligible    BOOLEAN;
    v_acad_amount NUMERIC(12,2) := 2000.00; -- фиксированная академическая (можно изменить)
BEGIN
    IF NEW.stipend_kind = 'social' THEN
SELECT NOT EXISTS (
    SELECT 1
    FROM student_discipline sd
    WHERE sd.n_credit_book = NEW.credit_book
      AND sd.estimation < 4
)
INTO v_eligible;

IF v_eligible THEN
            NEW.stipend_kind := 'combined';
            NEW.amount := NEW.amount + v_acad_amount;
END IF;
END IF;

RETURN NEW;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS bfi_scholarship_social_plus ON scholarship;
CREATE TRIGGER bfi_scholarship_social_plus
    BEFORE INSERT ON scholarship
    FOR EACH ROW
    EXECUTE FUNCTION trg_scholarship_before_insert_social_plus_academic();

-- Студент 1 (Иванов) имеет только оценки >= 4, значит получит комбинированную стипендию
INSERT INTO scholarship (credit_book, stipend_kind, amount, n_group)
VALUES (3, 'social', 1500.00, '12B');

-- Проверяем результат
SELECT * FROM scholarship;

-- Ожидаем: stipend_kind = 'combined', amount = 3500.00

-- 9. Создайте триггер Before Insert для таблицы Стипендия, который проверяет, правильно ли
-- указана группа студента, и при необходимости изменяет номер группы. Проверка
-- осуществляется по таблице Студент.

-- Функция: подтянуть корректную группу из student по зачетке
CREATE OR REPLACE FUNCTION trg_scholarship_fix_group()
    RETURNS TRIGGER AS $$
DECLARE
v_group VARCHAR(10);
BEGIN
SELECT s.n_group INTO v_group
FROM student s
WHERE s.n_credit_book = NEW.credit_book;

IF v_group IS NULL THEN
        RAISE EXCEPTION 'Студент с зачетной книжкой % не найден', NEW.credit_book;
END IF;

    IF NEW.n_group IS DISTINCT FROM v_group THEN
        NEW.n_group := v_group; -- исправляем
END IF;

RETURN NEW;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS bfi_scholarship_fix_group ON scholarship;
CREATE TRIGGER bfi_scholarship_fix_group
    BEFORE INSERT ON scholarship
    FOR EACH ROW
    EXECUTE FUNCTION trg_scholarship_fix_group();

-- Пытаемся вставить с неправильной группой: у студента 2 группа "11A"
INSERT INTO scholarship (credit_book, stipend_kind, amount, n_group)
VALUES (2, 'academic', 2000.00, '99Z');

-- Проверяем, что в таблице стипендий группа исправилась
SELECT * FROM scholarship WHERE credit_book = 2;

-- 10. Создайте триггеры, осуществляющие аудит операций обновления, удаления и вставки для
-- таблицы Студент. Данные об операциях записываются в таблицу Аудит с набором атрибутов:
-- (пользователь (выполнивший операцию), дата (выполнения операции), операция (название),
-- таблица (название), атрибут (название), старое значение атрибута, новое значение атрибута).

-- Для удобства сравнения по всем столбцам используем hstore
-- hstore — это специальный тип данных PostgreSQL, позволяющий хранить пары ключ–значение в одном поле (как мини-словарь внутри строки).
CREATE EXTENSION IF NOT EXISTS hstore;

CREATE TABLE IF NOT EXISTS audit (
    id           BIGSERIAL PRIMARY KEY,
    username     TEXT        NOT NULL,
    action_time  TIMESTAMP   NOT NULL,
    operation    TEXT        NOT NULL,  -- INSERT / UPDATE / DELETE
    table_name   TEXT        NOT NULL,  -- 'student'
    attribute    TEXT        NOT NULL,  -- имя столбца
    old_value    TEXT        NULL,
    new_value    TEXT        NULL
);

-- Одна функция, три триггера (на INSERT/UPDATE/DELETE)
CREATE OR REPLACE FUNCTION fn_student_audit()
    RETURNS TRIGGER AS $$
DECLARE
k  TEXT;
    ov TEXT;
    nv TEXT;
BEGIN
    IF TG_OP = 'INSERT' THEN
        FOR k, nv IN SELECT * FROM each(hstore(NEW)) LOOP
    INSERT INTO audit(username, action_time, operation, table_name, attribute, old_value, new_value)
                     VALUES (CURRENT_USER, NOW(), 'INSERT', TG_TABLE_NAME, k, NULL, nv);
END LOOP;
RETURN NEW;

ELSIF TG_OP = 'DELETE' THEN
        FOR k, ov IN SELECT * FROM each(hstore(OLD)) LOOP
    INSERT INTO audit(username, action_time, operation, table_name, attribute, old_value, new_value)
                     VALUES (CURRENT_USER, NOW(), 'DELETE', TG_TABLE_NAME, k, ov, NULL);
END LOOP;
RETURN OLD;

ELSE -- UPDATE
        FOR k IN
SELECT DISTINCT key
FROM (
    SELECT key FROM each(hstore(OLD))
    UNION
    SELECT key FROM each(hstore(NEW))
    ) t
    LOOP
    ov := (hstore(OLD))->k;
nv := (hstore(NEW))->k;
                IF ov IS DISTINCT FROM nv THEN
                    INSERT INTO audit(username, action_time, operation, table_name, attribute, old_value, new_value)
                    VALUES (CURRENT_USER, NOW(), 'UPDATE', TG_TABLE_NAME, k, ov, nv);
END IF;
END LOOP;
RETURN NEW;
END IF;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS ai_student_audit ON student;
DROP TRIGGER IF EXISTS au_student_audit ON student;
DROP TRIGGER IF EXISTS ad_student_audit ON student;

CREATE TRIGGER ai_student_audit
    AFTER INSERT ON student
    FOR EACH ROW
    EXECUTE FUNCTION fn_student_audit();

CREATE TRIGGER au_student_audit
    AFTER UPDATE ON student
    FOR EACH ROW
    EXECUTE FUNCTION fn_student_audit();

CREATE TRIGGER ad_student_audit
    AFTER DELETE ON student
    FOR EACH ROW
    EXECUTE FUNCTION fn_student_audit();


-- Вставка нового студента
INSERT INTO student (second_name, name, patronymic, n_group, telephone)
VALUES ('Новиков', 'Павел', 'Владимирович', '13C', '89007775555');

-- Изменение телефона
UPDATE student SET telephone = '+79001112233' WHERE second_name = 'Иванов';

-- Удаление студента
DELETE FROM student WHERE second_name = 'Иванов';

-- Проверяем аудит
SELECT operation, attribute, old_value, new_value FROM audit ORDER BY id;

-- 11. Создать триггер, который при вставке номера телефона студента в таблицу Студент проверяет
-- значение первого символа и если он не равен 8 или +, то выдает сообщение об ошибке, и
-- вставка не происходит.

CREATE OR REPLACE FUNCTION trg_student_phone_check_on_insert()
    RETURNS TRIGGER AS $$
DECLARE
first_char TEXT;
BEGIN
    IF NEW.telephone IS NULL THEN
        RETURN NEW; -- допускаем NULL
END IF;

    first_char := SUBSTRING(BTRIM(NEW.telephone) FROM 1 FOR 1);

    IF first_char NOT IN ('8', '+') THEN
        RAISE EXCEPTION 'Неверный формат телефона "%". Первый символ должен быть 8 или +', NEW.telephone;
END IF;

RETURN NEW;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS bfi_student_phone_check ON student;
CREATE TRIGGER bfi_student_phone_check
    BEFORE INSERT ON student
    FOR EACH ROW
    EXECUTE FUNCTION trg_student_phone_check_on_insert();

-- Успешная вставка (телефон начинается с 8)
INSERT INTO student (second_name, name, patronymic, n_group, telephone)
VALUES ('Смирнов', 'Олег', 'Викторович', '14A', '89003334455');

-- Ошибка (телефон начинается с 7)
INSERT INTO student (second_name, name, patronymic, n_group, telephone)
VALUES ('Тестов', 'Артём', 'Ильич', '14A', '79005556677');
-- Ожидаем сообщение:
-- ERROR:  Неверный формат телефона "79005556677". Первый символ должен быть 8 или +