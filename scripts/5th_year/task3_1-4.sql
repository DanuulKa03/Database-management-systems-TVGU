--Задание 3. Триггеры.
--Создайте триггеры. Проверьте их выполнение.

--1.Создайте триггер Before Insert для таблицы Предмет, 
--который при вставке записи о предмете проверяет, 
--входит ли предмет в допустимое множество, и, если не входит, задает значение поля предмет равным null или ‘Новая дисциплина’.
CREATE OR REPLACE FUNCTION check_discipline_title()
RETURNS TRIGGER 
LANGUAGE plpgsql
AS $$
DECLARE
allowed_disciplines TEXT[] := ARRAY[
        'История', 
		'Биология', 
		'Математика', 
		'Литература',
        'Физика', 
		'География', 
		'Информатика', 
		'Английский', 
		'Химия'
];
BEGIN
 IF NEW.title_discipline NOT IN (SELECT unnest(allowed_disciplines)) THEN
        NEW.title_discipline := 'Новая дисциплина';
    END IF;
    RETURN NEW;
END;
$$;

CREATE TRIGGER trg_check_discipline_title
BEFORE INSERT ON discipline
FOR EACH ROW
EXECUTE FUNCTION check_discipline_title();

SELECT DISTINCT(title_discipline) 
FROM discipline;

INSERT INTO discipline (title_discipline, second_name_teacher)
VALUES ('Математика', 'Иванов');

INSERT INTO discipline (title_discipline, second_name_teacher)
VALUES ('Физкультура', 'Иванов');

DROP TRIGGER IF EXISTS trg_check_discipline_title ON discipline;
DROP FUNCTION check_discipline_title();




--2.Создайте триггер Before Insert для таблицы Студент, 
--который при добавлении нового студента преобразует его фамилию, имя и отчество в верхний регистр, 
--а при добавлении нового студента с номером группы null вставляет его в группу первого курса с номером 15.
CREATE OR REPLACE FUNCTION student_before_insert()
RETURNS TRIGGER
LANGUAGE plpgsql
AS $$
BEGIN
    NEW.second_name := UPPER(NEW.second_name);
    NEW.name := UPPER(NEW.name);
    NEW.patronymic := UPPER(NEW.patronymic);

    IF NEW.n_group IS NULL THEN
        NEW.n_group := '15Z';
    END IF;

    RETURN NEW;
END;
$$;

CREATE TRIGGER trg_student_before_insert
BEFORE INSERT ON student
FOR EACH ROW
EXECUTE FUNCTION student_before_insert();


INSERT INTO student (second_name, name, patronymic, n_group, telephone)
VALUES ('Тестов', 'Тест', 'Тестович', '11A', '89005553322');

SELECT * FROM student WHERE second_name = 'ТЕСТОВ';

INSERT INTO student (second_name, name, patronymic, telephone)
VALUES ('Иванов', 'Иван', 'Иванович', '89004443322');

SELECT * FROM student WHERE second_name = 'ИВАНОВ';


DROP TRIGGER IF EXISTS trg_student_before_insert ON student;
DROP FUNCTION student_before_insert();




--3.Создайте триггер каскадного удаления Before Delete для таблицы Студент. 
--Убедитесь, что удаление записей, на которые есть ссылки в таблице Студент предмет, происходит из двух таблиц. Удалите триггер.
CREATE OR REPLACE FUNCTION student_before_delete()
RETURNS TRIGGER
LANGUAGE plpgsql
AS $$
BEGIN
    DELETE FROM student_discipline
    WHERE n_credit_book = OLD.n_credit_book;

    RETURN OLD;
END;
$$;

CREATE TRIGGER trg_student_before_delete
BEFORE DELETE ON student
FOR EACH ROW
EXECUTE FUNCTION student_before_delete();

SELECT * FROM student WHERE n_credit_book = 1;
SELECT * FROM student_discipline WHERE n_credit_book = 1;

DELETE FROM student WHERE n_credit_book = 1;

DROP TRIGGER IF EXISTS trg_student_before_delete ON student;
DROP FUNCTION student_before_delete();




--4.Создайте триггер каскадного удаления After Delete для таблицы Студент. 
--Убедитесь, что каскадное удаление не осуществляется. Объясните, почему.
CREATE OR REPLACE FUNCTION student_after_delete()
RETURNS TRIGGER
LANGUAGE plpgsql
AS $$
BEGIN
    DELETE FROM student_discipline
    WHERE n_credit_book = OLD.n_credit_book;

    RETURN OLD;
END;
$$;

CREATE TRIGGER trg_student_after_delete
AFTER DELETE ON student
FOR EACH ROW
EXECUTE FUNCTION student_after_delete();

SELECT * FROM student WHERE n_credit_book = 2;
SELECT * FROM student_discipline WHERE n_credit_book = 2;

DELETE FROM student WHERE n_credit_book = 2;

DROP TRIGGER IF EXISTS trg_student_after_delete ON student;
DROP FUNCTION student_after_delete();