-- 1. Создать процедуру для получения экзаменационной ведомости по мат. анализу группы 11.

CREATE PROCEDURE insert_data()
LANGUAGE SQL
AS $$
    SELECT * FROM student_discipline AS sd
    INNER JOIN discipline AS ds ON ds.n_discipline = sd.n_discipline
    INNER JOIN student AS st ON st.n_credit_book = sd.n_credit_book
    WHERE ds.title_discipline LIKE 'Математика' AND st.n_group LIKE '11%';
$$;

CALL insert_data();

-- 2. Создать процедуру с параметрами для изменения оценки заданного студента по заданной дисциплине после пересдачи экзамена.

CREATE PROCEDURE insert_data_student(p_credit_book INT, p_discipline INT, p_estemation INT)
LANGUAGE SQL
AS $$
    INSERT INTO student_discipline(n_credit_book, n_discipline, estimation)
    VALUES (p_credit_book, p_discipline, p_estemation);
$$;

CALL insert_data_student(17, 15, 5);

-- 3. Создать процедуру для определения предметов с самой низкой успеваемостью.

CREATE PROCEDURE show_minimal_args_discipline()
LANGUAGE SQL
AS $$
    SELECT DS.title_discipline, AVG(ST.estimation) FROM student_discipline AS ST
    INNER JOIN discipline AS DS ON ST.n_discipline = DS.n_discipline
    GROUP BY DS.title_discipline;
$$;

CALL show_minimal_args_discipline();

-- 4. Создать процедуру с входным и выходным параметрами для определения числа задолжников в группе, в которой учится данный студент.

-- CREATE PROCEDURE print_count(p_credit_book INT)
-- LANGUAGE SQL
-- AS $$
--     SELECT DS.title_discipline, AVG(ST.estimation) FROM student_discipline AS ST
--     INNER JOIN discipline AS DS ON ST.n_discipline = DS.n_discipline
--     GROUP BY DS.title_discipline;
-- $$;

CREATE OR REPLACE FUNCTION print_count(p_group TEXT)
    RETURNS INT AS $$
DECLARE
    count_chil INT;
BEGIN
    SELECT COUNT(SD.n_credit_book) INTO count_chil
    FROM student_discipline AS SD
    INNER JOIN student AS ST ON ST.n_credit_book = SD.n_credit_book
    WHERE ST.n_group LIKE p_group AND SD.estimation = 2;

    RETURN count_chil;
END;
$$ LANGUAGE plpgsql;

-- вызов
SELECT print_count('11A');

-- 5. Для предыдущего задания создать функцию с параметром.

CREATE OR REPLACE FUNCTION get_count_debtors(p_group TEXT)
    RETURNS INT
    LANGUAGE plpgsql
AS $$
DECLARE
    cnt INT;
BEGIN
    SELECT COUNT(SD.n_credit_book) INTO cnt
    FROM student_discipline AS SD
    INNER JOIN student AS ST ON ST.n_credit_book = SD.n_credit_book
    WHERE ST.n_group LIKE p_group AND SD.estimation = 2;

    RETURN cnt;
END;
$$;

-- Вызов:
SELECT get_count_debtors('11A');