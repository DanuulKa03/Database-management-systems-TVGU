-- 1. Создать процедуру для получения экзаменационной ведомости по мат. анализу группы 11.

CREATE OR REPLACE PROCEDURE get_student_math_data(
    IN p_title text, -- название дисциплины ('Математика')
    IN p_group_pattern text, -- шаблон группы ('11%')
    INOUT p_cur refcursor -- курсор с результатом
)
    LANGUAGE plpgsql
AS
$$
BEGIN
    OPEN p_cur FOR
        SELECT st.n_credit_book,
               st.second_name,
               st.name,
               st.patronymic,
               ds.title_discipline,
               sd.estimation
        FROM student_discipline sd
                 JOIN discipline ds ON ds.n_discipline = sd.n_discipline
                 JOIN student st ON st.n_credit_book = sd.n_credit_book
        WHERE ds.title_discipline = p_title
          AND st.n_group LIKE p_group_pattern
        ORDER BY st.second_name, st.name, st.patronymic;
END;
$$;

BEGIN;
CALL get_student_math_data('Математика', '11%', 'cur_sd');
FETCH ALL FROM cur_sd;
CLOSE cur_sd;
COMMIT;

-- 2. Создать процедуру с параметрами для изменения оценки заданного студента по заданной дисциплине после пересдачи экзамена.

CREATE OR REPLACE PROCEDURE update_student_estimation(
    IN p_credit_book INT, -- номер зачетной книжки
    IN p_discipline INT, -- номер дисциплины
    IN p_estimation INT -- новая оценка (2–5)
)
    LANGUAGE SQL
AS
$$
UPDATE student_discipline
SET estimation = p_estimation
WHERE n_credit_book = p_credit_book
  AND n_discipline = p_discipline;
$$;

CALL update_student_estimation(2, 1, 4);

-- 3. Создать процедуру для определения предметов с самой низкой успеваемостью.

CREATE OR REPLACE PROCEDURE show_minimal_args_discipline(
    INOUT p_cur refcursor
)
    LANGUAGE plpgsql
AS
$$
BEGIN
    OPEN p_cur FOR
        SELECT ds.title_discipline AS title,
               AVG(sd.estimation)  AS avg_estimation
        FROM student_discipline sd
                 JOIN discipline ds ON sd.n_discipline = ds.n_discipline
        GROUP BY ds.title_discipline
        ORDER BY avg_estimation
        LIMIT 1;
END;
$$;

BEGIN;
CALL show_minimal_args_discipline('cur_sd');
FETCH ALL FROM cur_sd;
CLOSE cur_sd;
COMMIT;

-- 4. Создать процедуру с входным и выходным параметрами для определения числа задолжников в группе,
-- в которой учится данный студент.

CREATE OR REPLACE PROCEDURE print_count_1(
    IN p_credit_book INT,
    OUT count_chil INT
)
    LANGUAGE plpgsql
AS
$$
DECLARE
    v_group TEXT;
BEGI
    -- определяем группу студента
    SELECT s.n_group
    INTO v_group
    FROM student s
    WHERE s.n_credit_book = p_credit_book;

-- считаем должников (оценка = 2) в этой группе
    SELECT COUNT(*)
    INTO count_chil
    FROM student_discipline sd
             JOIN student s ON s.n_credit_book = sd.n_credit_book
    WHERE s.n_group = v_group
      AND sd.estimation = 2;
END;
$$;

SELECT print_count(1);

-- 5. Для предыдущего задания создать функцию с параметром.

CREATE OR REPLACE FUNCTION get_count_debtors(p_credit_book INT)
    RETURNS INT
    LANGUAGE plpgsql
AS
$$
DECLARE
    v_group TEXT;
    v_count INT;
BEGIN
    -- определяем группу студента
    SELECT s.n_group
    INTO v_group
    FROM student s
    WHERE s.n_credit_book = p_credit_book;

-- считаем должников в этой группе
    SELECT COUNT(*)
    INTO v_count
    FROM student_discipline sd
             JOIN student s ON s.n_credit_book = sd.n_credit_book
    WHERE s.n_group = v_group
      AND sd.estimation = 2;

    RETURN v_count;
END;
$$;

SELECT get_count_debtors(1);

-- 6. Процедура: число студентов в группе с оценкой по дисциплине выше средней

CREATE OR REPLACE PROCEDURE count_good_student(
    IN p_group text,
    IN p_discipline int,
    OUT p_count int
)
    LANGUAGE plpgsql
AS
$$
DECLARE
    v_avg numeric;
BEGIN
    -- 1) считаем среднюю оценку по дисциплине в заданной группе
    SELECT AVG(sd.estimation)::numeric
    INTO v_avg
    FROM student_discipline sd
             JOIN student s ON sd.n_credit_book = s.n_credit_book
    WHERE sd.n_discipline = p_discipline
      AND s.n_group = p_group;

-- если оценок нет вообще, возвращаем 0
    IF v_avg IS NULL THEN
        p_count := 0;
        RETURN;
    END IF;

    -- 2) считаем, сколько студентов имеют оценку выше среднего
    SELECT COUNT(*)
    INTO p_count
    FROM student_discipline sd
             JOIN student s ON sd.n_credit_book = s.n_credit_book
    WHERE sd.n_discipline = p_discipline
      AND s.n_group = p_group
      AND sd.estimation > v_avg;
END;
$$;

CALL count_good_student('11A', 1, NULL);

--7.	Для предыдущего задания создать функцию с параметрами.

CREATE OR REPLACE FUNCTION public.count_good_student_f(_group text, _discip int)
    RETURNS integer
    LANGUAGE plpgsql
AS
$$
DECLARE
    _avg   float;
    _count integer;
BEGIN
    SELECT avg(estimation)
    FROM student_discipline sd
             JOIN student s ON sd.n_credit_book = s.n_credit_book
    WHERE sd.n_discipline = _discip
      AND s.n_group = _group
    INTO _avg;

    SELECT count(sd.n_credit_book)
    FROM student_discipline sd
             JOIN student s ON sd.n_credit_book = s.n_credit_book
    WHERE sd.n_discipline = _discip
      AND s.n_group = _group
      AND estimation > _avg
    INTO _count;

    RETURN _count;
END;
$$;

select *
from public.count_good_student_f('14A'::text, 3);

--8.	Создать процедуру, которая выводит оценки студентов по заданной дисциплине в текстовом или цифровом формате в зависимости от значения входного параметра С.
--      Использовать условный оператор.

--drop function public.student_estimation_discip(int, boolean)

CREATE OR REPLACE PROCEDURE public.student_estimation_discip(_discip int, _C boolean, inout _res refcursor)
    LANGUAGE plpgsql
AS
$$
declare
BEGIN
    if _c then
        open _res for select sd.n_credit_book, sd.estimation
                      from student_discipline sd
                      where sd.n_discipline = _discip;
    else
        open _res for select sd.n_credit_book,
                             case sd.estimation
                                 when 2 then 'Неудовлиторительно'
                                 when 3 then 'Удовлетворительно'
                                 when 4 then 'Хорошо'
                                 when 5 then 'Отлично'
                                 end
                      from student_discipline sd
                      where sd.n_discipline = _discip;
    end if;
END;
$$



BEGIN;
CALL public.student_estimation_discip(3, true, 'my_cursor');
FETCH ALL FROM my_cursor;
COMMIT;

BEGIN;
CALL public.student_estimation_discip(3, false, 'my_cursor');
FETCH ALL FROM my_cursor;
COMMIT;


--9.	Создать процедуру, которая изменяет регистр фамилий студентов на верхний. Использовать курсоры.

CREATE OR REPLACE PROCEDURE public.second_name_stud_to_upper()
    LANGUAGE plpgsql
AS
$$
declare
    student_cur CURSOR FOR
        SELECT n_credit_book
        FROM student;
    rec int;
BEGIN
    OPEN student_cur;

    LOOP
        FETCH student_cur INTO rec;
        EXIT WHEN NOT FOUND;

        UPDATE student
        SET second_name = UPPER(second_name)
        WHERE n_credit_book = rec;

    END LOOP;
END;
$$
    call public.second_name_stud_to_upper();
select *
from student UPDATE student
SET second_name = LOWER(second_name)


----------------------------------------------------------------------------------------

--10.	Создать процедуру, которая формирует таблицы-списки студентов-задолжников в виде
--		(фио студента; номер зачетки; номер группы; количество задолженностей;
--		строку-конкатенацию, содержащую перечень несданных дисциплин).
--		Использовать курсоры.
CREATE OR REPLACE PROCEDURE debt_list()
    LANGUAGE plpgsql
AS
$$
DECLARE
    rec_stud RECORD;
    cur_stud CURSOR FOR
        SELECT DISTINCT s.n_credit_book,
                        s.second_name,
                        s.name,
                        s.patronymic,
                        s.n_group
        FROM student s
                 JOIN student_discipline sd ON s.n_credit_book = sd.n_credit_book
        WHERE sd.estimation = 2;
    debt_cnt INT;
    debt_dis TEXT;
BEGIN
    DROP TABLE IF EXISTS debtors;
    CREATE TABLE debtors
    (
        fio             TEXT,
        n_credit_book   INT,
        n_group         VARCHAR(10),
        debt_count      INT,
        debt_discipline TEXT
    );

    OPEN cur_stud;
    LOOP
        FETCH cur_stud INTO rec_stud;
        EXIT WHEN NOT FOUND;

        SELECT COUNT(*)
        INTO debt_cnt
        FROM student_discipline sd
        WHERE sd.n_credit_book = rec_stud.n_credit_book
          AND sd.estimation = 2;

        SELECT string_agg(d.title_discipline, ', ' ORDER BY d.title_discipline)
        INTO debt_dis
        FROM student_discipline sd
                 JOIN discipline d ON sd.n_discipline = d.n_discipline
        WHERE sd.n_credit_book = rec_stud.n_credit_book
          AND sd.estimation = 2;

        INSERT INTO debtors(fio, n_credit_book, n_group, debt_count, debt_discipline)
        VALUES (CONCAT(rec_stud.second_name, ' ', rec_stud.name, ' ', rec_stud.patronymic),
                rec_stud.n_credit_book,
                rec_stud.n_group,
                debt_cnt,
                debt_dis);
    END LOOP;
    CLOSE cur_stud;
END;
$$;

CALL debt_list();

SELECT *
FROM debtors;
----------------------------------------------------------------------------------------------

--11.	Создать процедуру, которая переводит студентов на следующий курс по итогам сессии.
--		Если курс последний, запись удаляется. Использовать условный оператор и курсор.
CREATE OR REPLACE PROCEDURE transfer_student()
    LANGUAGE plpgsql
AS
$$
DECLARE
    rec_stud    RECORD;
    cur_stud CURSOR FOR
        SELECT n_credit_book, n_group
        FROM student;
    debt_cnt    INT;
    n_group_new VARCHAR(10);
BEGIN
    OPEN cur_stud;
    LOOP
        FETCH cur_stud INTO rec_stud;
        EXIT WHEN NOT FOUND;

        SELECT COUNT(*)
        INTO debt_cnt
        FROM student_discipline sd
        WHERE sd.n_credit_book = rec_stud.n_credit_book
          AND sd.estimation = 2;

        IF debt_cnt > 0 THEN
            CONTINUE;
        END IF;

        IF CAST(SUBSTRING(rec_stud.n_group FROM 1 FOR 1) AS INT) = 4 THEN
            DELETE
            FROM student_discipline
            WHERE n_credit_book = rec_stud.n_credit_book;
            DELETE
            FROM student
            WHERE n_credit_book = rec_stud.n_credit_book;
        ELSE
            n_group_new := (CAST(SUBSTRING(rec_stud.n_group FROM 1 FOR 1) AS INTEGER) + 1)::TEXT ||
                           SUBSTRING(rec_stud.n_group FROM 2);
            UPDATE student
            SET n_group = n_group_new
            WHERE n_credit_book = rec_stud.n_credit_book;
        END IF;
    END LOOP;
    CLOSE cur_stud;
END;
$$;

CALL transfer_student();

SELECT *
FROM student
ORDER BY n_credit_book ASC;
SELECT *
FROM student_discipline
ORDER BY n_credit_book ASC, n_discipline ASC;
-------------------------------------------------------------------------------------------------------

--12.	Написать процедуру, которая создает новую таблицу Результаты сессии:
--		(Номер_зачетки, Фамилия_студента, Номер_группы, количество экзаменов, количество оценок 5, 4, 3
--		и задолженностей (не сданных и не сдававшихся экзаменов)); и таблицу Стипендиальная ведомость:
--		(Номер_зачетки, Фамилия_студента, Номер_группы, стипендия). Стипендия начисляется из условия:
--		как минимум одна 5, остальные – 4 (не меньше одной) – 2000 руб., все 5 – 2500 руб. Использовать курсор.
CREATE OR REPLACE PROCEDURE results_and_stipendii()
    LANGUAGE plpgsql
AS
$$
DECLARE
    rec_stud RECORD;
    cur_stud CURSOR FOR
        SELECT s.n_credit_book,
               s.second_name,
               s.n_group
        FROM student s;
    cnt_exam INT;
    cnt_5    INT;
    cnt_4    INT;
    cnt_3    INT;
    debt_cnt INT;
    stip     INT;
BEGIN
    DROP TABLE IF EXISTS session_results;
    CREATE TABLE session_results
    (
        n_credit_book INT,
        second_name   VARCHAR(50),
        n_group       VARCHAR(10),
        cnt_exam      INT,
        cnt_5         INT,
        cnt_4         INT,
        cnt_3         INT,
        debt_cnt      INT
    );
    DROP TABLE IF EXISTS stipendii;
    CREATE TABLE stipendii
    (
        n_credit_book INT,
        second_name   VARCHAR(50),
        n_group       VARCHAR(10),
        stip          INT
    );

    OPEN cur_stud;
    LOOP
        FETCH cur_stud INTO rec_stud;
        EXIT WHEN NOT FOUND;

        SELECT COUNT(*),
               SUM(CASE WHEN estimation = 5 THEN 1 ELSE 0 END),
               SUM(CASE WHEN estimation = 4 THEN 1 ELSE 0 END),
               SUM(CASE WHEN estimation = 3 THEN 1 ELSE 0 END),
               SUM(CASE WHEN estimation = 2 THEN 1 ELSE 0 END)
        INTO
            cnt_exam,
            cnt_5,
            cnt_4,
            cnt_3,
            debt_cnt
        FROM student_discipline sd
        WHERE sd.n_credit_book = rec_stud.n_credit_book;

        INSERT INTO session_results(n_credit_book, second_name, n_group, cnt_exam, cnt_5, cnt_4, cnt_3, debt_cnt)
        VALUES (rec_stud.n_credit_book,
                rec_stud.second_name,
                rec_stud.n_group,
                cnt_exam,
                cnt_5,
                cnt_4,
                cnt_3,
                debt_cnt);

        IF cnt_exam = cnt_5 THEN
            stip := 2500;
        ELSIF cnt_5 >= 1 AND cnt_4 = cnt_exam - cnt_5 THEN
            stip := 2000;
        ELSE
            CONTINUE;
        END IF;

        INSERT INTO stipendii(n_credit_book, second_name, n_group, stip)
        VALUES (rec_stud.n_credit_book,
                rec_stud.second_name,
                rec_stud.n_group,
                stip);

    END LOOP;
    CLOSE cur_stud;
END;
$$;

CALL results_and_stipendii();

SELECT *
FROM session_results;
SELECT *
FROM stipendii;
-------------------------------------------------------------------------------------------------------------------
--13.	Создать процедуру, которая генерирует пароли студентов для теста и помещает их в создаваемую таблицу Пароли.
--		Пароль должен содержать заглавные и прописные английские буквы, цифры и знаки препинания и иметь длину не менее 8 символов.
--		Использовать курсоры.
CREATE OR REPLACE PROCEDURE passwords_gen(IN len INT DEFAULT 8)
    LANGUAGE plpgsql
AS
$$
DECLARE
    rec_stud RECORD;
    cur_stud CURSOR FOR
        SELECT s.n_credit_book
        FROM student s;
    pswd     TEXT;
    alphabet TEXT := 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789!@#$%^&*()-_=+[]{};:,.<>?/';
BEGIN
    DROP TABLE IF EXISTS test_passwords;
    CREATE TABLE test_passwords
    (
        n_credit_book INT,
        pswd          TEXT
    );

    OPEN cur_stud;
    LOOP
        FETCH cur_stud INTO rec_stud;
        EXIT WHEN NOT FOUND;

        SELECT string_agg(substr(alphabet, (random() * length(alphabet) + 1)::int, 1), '')
        INTO pswd
        FROM generate_series(1, len);

        INSERT INTO test_passwords(n_credit_book, pswd)
        VALUES (rec_stud.n_credit_book, pswd);

    END LOOP;
    CLOSE cur_stud;
END;
$$;

CALL passwords_gen();
CALL passwords_gen(20);

SELECT *
FROM test_passwords;