----------------------------------------------------------------------------------------

--10.	Создать процедуру, которая формирует таблицы-списки студентов-задолжников в виде 
--		(фио студента; номер зачетки; номер группы; количество задолженностей; 
--		строку-конкатенацию, содержащую перечень несданных дисциплин). 
--		Использовать курсоры.
CREATE OR REPLACE PROCEDURE debt_list()
LANGUAGE plpgsql  
AS $$
DECLARE
rec_stud RECORD;
cur_stud CURSOR FOR
	SELECT DISTINCT 
					s.n_credit_book,
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
	CREATE TABLE debtors(
	fio TEXT,
	n_credit_book INT,
	n_group VARCHAR(10),
	debt_count INT,
	debt_discipline TEXT
	);
	
	OPEN cur_stud;
	LOOP
		FETCH cur_stud INTO rec_stud;
		EXIT WHEN NOT FOUND;

		SELECT COUNT(*)
		INTO debt_cnt
		FROM student_discipline sd
		WHERE sd.n_credit_book = rec_stud.n_credit_book AND sd.estimation = 2;
	
		SELECT string_agg(d.title_discipline, ', ' ORDER BY d.title_discipline)
		INTO debt_dis
		FROM student_discipline sd
		JOIN discipline d ON sd.n_discipline = d.n_discipline
		WHERE sd.n_credit_book = rec_stud.n_credit_book AND sd.estimation = 2;
	
		INSERT INTO debtors(fio, n_credit_book, n_group, debt_count, debt_discipline)
		VALUES (
			CONCAT(rec_stud.second_name,' ', rec_stud.name,' ',rec_stud.patronymic),
			rec_stud.n_credit_book,
			rec_stud.n_group,
			debt_cnt,
			debt_dis
		);
	END LOOP;
	CLOSE cur_stud;
END;
$$;

CALL debt_list();

SELECT * FROM debtors;
----------------------------------------------------------------------------------------------

--11.	Создать процедуру, которая переводит студентов на следующий курс по итогам сессии. 
--		Если курс последний, запись удаляется. Использовать условный оператор и курсор.
CREATE OR REPLACE PROCEDURE transfer_student()
LANGUAGE plpgsql  
AS $$
DECLARE
	rec_stud RECORD;
    cur_stud CURSOR FOR
        SELECT n_credit_book, n_group
        FROM student;
		debt_cnt INT;
		n_group_new VARCHAR(10);
BEGIN
	OPEN cur_stud;
	LOOP
		FETCH cur_stud INTO rec_stud;
		EXIT WHEN NOT FOUND;
		
		SELECT COUNT(*)
		INTO debt_cnt
		FROM student_discipline sd
		WHERE sd.n_credit_book = rec_stud.n_credit_book AND sd.estimation = 2;

		IF debt_cnt > 0 THEN
			CONTINUE;
		END IF;

		IF CAST(SUBSTRING(rec_stud.n_group FROM 1 FOR 1) AS INT) = 4 THEN
			DELETE FROM student_discipline
            WHERE n_credit_book = rec_stud.n_credit_book;
			DELETE FROM student
            WHERE n_credit_book = rec_stud.n_credit_book;
		ELSE
			n_group_new := (CAST(SUBSTRING(rec_stud.n_group FROM 1 FOR 1) AS INTEGER) + 1)::TEXT || SUBSTRING(rec_stud.n_group FROM 2);
			UPDATE student
			SET n_group = n_group_new
			WHERE n_credit_book = rec_stud.n_credit_book;
		END IF;
	END LOOP;
	CLOSE cur_stud;
END;
$$;

CALL transfer_student();

SELECT * FROM student
ORDER BY n_credit_book ASC;
SELECT * FROM student_discipline
ORDER BY n_credit_book ASC, n_discipline ASC; 
-------------------------------------------------------------------------------------------------------

--12.	Написать процедуру, которая создает новую таблицу Результаты сессии: 
--		(Номер_зачетки, Фамилия_студента, Номер_группы, количество экзаменов, количество оценок 5, 4, 3
--		и задолженностей (не сданных и не сдававшихся экзаменов)); и таблицу Стипендиальная ведомость: 
--		(Номер_зачетки, Фамилия_студента, Номер_группы, стипендия). Стипендия начисляется из условия: 
--		как минимум одна 5, остальные – 4 (не меньше одной) – 2000 руб., все 5 – 2500 руб. Использовать курсор.
CREATE OR REPLACE PROCEDURE results_and_stipendii()
LANGUAGE plpgsql  
AS $$
DECLARE
	rec_stud RECORD;
    cur_stud CURSOR FOR
		SELECT
			s.n_credit_book,
			s.second_name,
			s.n_group
	FROM student s;

	cnt_exam INT;
	cnt_5 INT;
	cnt_4 INT;
	cnt_3 INT;
	debt_cnt INT;
	
	stip INT;
BEGIN
	DROP TABLE IF EXISTS session_results;
	CREATE TABLE session_results (
		n_credit_book INT,
		second_name VARCHAR(50),
		n_group VARCHAR(10),
		cnt_exam INT,
		cnt_5 INT,
		cnt_4 INT,
		cnt_3 INT,
		debt_cnt INT
	);
	DROP TABLE IF EXISTS stipendii;
	CREATE TABLE stipendii (
		n_credit_book INT,
		second_name VARCHAR(50),
		n_group VARCHAR(10),
		stip INT
	);

	OPEN cur_stud;
	LOOP
		FETCH cur_stud INTO rec_stud;
		EXIT WHEN NOT FOUND;

		SELECT 
			COUNT(*),
			SUM(CASE WHEN estimation = 5  THEN 1 ELSE 0 END),
			SUM(CASE WHEN estimation = 4  THEN 1 ELSE 0 END),
			SUM(CASE WHEN estimation = 3  THEN 1 ELSE 0 END),
			SUM(CASE WHEN estimation = 2  THEN 1 ELSE 0 END)
		INTO 
			cnt_exam, 
			cnt_5, 
			cnt_4, 
			cnt_3, 
			debt_cnt
		FROM student_discipline sd
		WHERE sd.n_credit_book = rec_stud.n_credit_book;

		INSERT INTO session_results(n_credit_book, second_name, n_group, cnt_exam, cnt_5, cnt_4, cnt_3, debt_cnt)
		VALUES(
			rec_stud.n_credit_book,
			rec_stud.second_name,
			rec_stud.n_group,
			cnt_exam, 
			cnt_5, 
			cnt_4, 
			cnt_3, 
			debt_cnt
		);
		
		IF cnt_exam = cnt_5 THEN
            stip := 2500;
        ELSIF cnt_5 >= 1 AND cnt_4 = cnt_exam - cnt_5 THEN
            stip := 2000;
        ELSE
            CONTINUE;
        END IF;

		INSERT INTO stipendii(n_credit_book, second_name, n_group, stip)
		VALUES (
		    rec_stud.n_credit_book, 
			rec_stud.second_name, 
			rec_stud.n_group, 
			stip
		);
		
	END LOOP;
	CLOSE cur_stud;
END;
$$;

CALL results_and_stipendii();

SELECT * FROM session_results;
SELECT * FROM stipendii;
-------------------------------------------------------------------------------------------------------------------
--13.	Создать процедуру, которая генерирует пароли студентов для теста и помещает их в создаваемую таблицу Пароли.
--		Пароль должен содержать заглавные и прописные английские буквы, цифры и знаки препинания и иметь длину не менее 8 символов.
--		Использовать курсоры.
CREATE OR REPLACE PROCEDURE passwords_gen(IN len INT DEFAULT 8)
LANGUAGE plpgsql  
AS $$
DECLARE
	rec_stud RECORD;
    cur_stud CURSOR FOR
		SELECT
			s.n_credit_book
		FROM student s;
	pswd TEXT;
	alphabet TEXT:='ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789!@#$%^&*()-_=+[]{};:,.<>?/';
BEGIN
	DROP TABLE IF EXISTS test_passwords;
	CREATE TABLE test_passwords (
		n_credit_book INT,
		pswd TEXT
	);

	OPEN cur_stud;
	LOOP
		FETCH cur_stud INTO rec_stud;
		EXIT WHEN NOT FOUND;
		
		SELECT string_agg(substr(alphabet, (random() * length(alphabet) + 1)::int, 1),'')
	    INTO pswd
	    FROM generate_series(1, len);

		INSERT INTO test_passwords(n_credit_book, pswd)
		VALUES(rec_stud.n_credit_book, pswd);
		
	END LOOP;
	CLOSE cur_stud;
END;
$$;

CALL passwords_gen();
CALL passwords_gen(20);

SELECT * FROM test_passwords;