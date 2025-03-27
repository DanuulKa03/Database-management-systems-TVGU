--СУБД
--Задание 5 SQL (any, some, all, union)

--1. Вывести список групп, в которых учится студент(ы) по фамилии Иванов (2 запроса: с использованием Exists и Any).
SELECT DISTINCT s1.n_group as "Группа"
FROM student s1
WHERE EXISTS (
    SELECT s2.n_group 
    FROM student s2 
    WHERE s2.n_group = s1.n_group 
    AND s2.second_name LIKE 'Иванов'
)
ORDER BY s1.n_group;
------------------------------------
SELECT DISTINCT s1.n_group as "Группа"
FROM student s1
WHERE s1.n_group = ANY (
    SELECT s2.n_group 
    FROM student s2 
    WHERE s2.n_group = s1.n_group 
    AND s2.second_name LIKE 'Иванов'
)
ORDER BY s1.n_group;


--2. Вывести список студентов в виде таблицы (ФИО, №группы, средняя оценка), средняя оценка которых больше,
--чем хотя бы у одного студента по фамилии Иванов (2 варианта запроса).
SELECT 
    CONCAT(s.second_name, ' ', s.name, ' ', s.patronymic) AS "ФИО",
    s.n_group AS "№ группы",
    ROUND(AVG(sd.estimation), 2) AS "Средняя оценка"
FROM student s
JOIN student_discipline sd ON s.n_credit_book = sd.n_credit_book
GROUP BY s.n_credit_book, s.second_name, s.name, s.patronymic, s.n_group
HAVING ROUND(AVG(sd.estimation), 2) > ANY (
    SELECT ROUND(AVG(sd2.estimation), 2) 
    FROM student s2
    JOIN student_discipline sd2 ON s2.n_credit_book = sd2.n_credit_book
    WHERE s2.second_name = 'Иванов'
    GROUP BY s2.n_credit_book
)
ORDER BY "Средняя оценка" DESC;
----------------------------------------------------------------------------
SELECT 
    CONCAT(s.second_name, ' ', s.name, ' ', s.patronymic) AS "ФИО",
    s.n_group AS "№ группы",
    ROUND(AVG(sd.estimation), 2) AS "Средняя оценка"
FROM student s
JOIN student_discipline sd ON s.n_credit_book = sd.n_credit_book
GROUP BY s.n_credit_book, s.second_name, s.name, s.patronymic, s.n_group
HAVING EXISTS (
    SELECT 1
    FROM student s2
    JOIN student_discipline sd2 ON s2.n_credit_book = sd2.n_credit_book
    WHERE s2.second_name = 'Иванов'
    GROUP BY s2.n_credit_book
    HAVING ROUND(AVG(sd.estimation), 2) > ROUND(AVG(sd2.estimation), 2)
)
ORDER BY "Средняя оценка" DESC;

--3. Вывести список студентов в виде таблицы (ФИО, №группы, средняя оценка), средняя оценка которых больше, 
--чем у всех студентов по фамилии Иванов (2 варианта запроса).
SELECT 
    CONCAT(s.second_name, ' ', s.name, ' ', s.patronymic) AS "ФИО",
    s.n_group AS "№ группы",
    ROUND(AVG(sd.estimation), 2) AS "Средняя оценка"
FROM student s
JOIN student_discipline sd ON s.n_credit_book = sd.n_credit_book
GROUP BY s.n_credit_book, s.second_name, s.name, s.patronymic, s.n_group
HAVING ROUND(AVG(sd.estimation), 2) > ALL (
    SELECT ROUND(AVG(sd2.estimation), 2) 
    FROM student s2
    JOIN student_discipline sd2 ON s2.n_credit_book = sd2.n_credit_book
    WHERE s2.second_name = 'Иванов'
    GROUP BY s2.n_credit_book
)
ORDER BY "Средняя оценка" DESC;
-------------------------------------------------------------------------
WITH avg_ivanov AS (
	SELECT ROUND(AVG(sd2.estimation), 2) AS r_avg
    FROM student s2
    JOIN student_discipline sd2 ON s2.n_credit_book = sd2.n_credit_book
    WHERE s2.second_name = 'Иванов'
    GROUP BY s2.n_credit_book
)

SELECT 
    CONCAT(s.second_name, ' ', s.name, ' ', s.patronymic) AS "ФИО",
    s.n_group AS "№ группы",
    ROUND(AVG(sd.estimation), 2) AS "Средняя оценка"
FROM student s
JOIN student_discipline sd ON s.n_credit_book = sd.n_credit_book
GROUP BY s.n_credit_book, s.second_name, s.name, s.patronymic, s.n_group
HAVING ROUND(AVG(sd.estimation), 2) > (SELECT MAX(r_avg) FROM avg_ivanov)
ORDER BY "Средняя оценка" DESC;

--4. Вывести ФИО, №группы и оценку за экзамен по английскому языку тех студентов, 
--которые сдали этот экзамен лучше, чем все студенты по фамилии Иванов (2 варианта запроса).
SELECT 
    CONCAT(s.second_name, ' ', s.name, ' ', s.patronymic) AS "ФИО",
    s.n_group AS "№ группы",
    sd.estimation AS "оценка по английскому"
FROM student s
JOIN student_discipline sd ON s.n_credit_book = sd.n_credit_book
JOIN discipline d ON sd.n_discipline = d.n_discipline
WHERE d.title_discipline = 'Английский'
AND sd.estimation > ALL (
    SELECT sd2.estimation
    FROM student s2
    JOIN student_discipline sd2 ON s2.n_credit_book = sd2.n_credit_book
    JOIN discipline d2 ON sd2.n_discipline = d2.n_discipline
    WHERE s2.second_name = 'Иванов' AND d2.title_discipline = 'Английский'
)
ORDER BY sd.estimation DESC;
----------------------------------------------------------------------------
WITH avg_ivanov AS (
	SELECT sd2.estimation
    FROM student s2
    JOIN student_discipline sd2 ON s2.n_credit_book = sd2.n_credit_book
	JOIN discipline d2 ON sd2.n_discipline = d2.n_discipline
    WHERE s2.second_name = 'Иванов' AND d2.title_discipline = 'Английский'
)

SELECT 
    CONCAT(s.second_name, ' ', s.name, ' ', s.patronymic) AS "ФИО",
    s.n_group AS "№ группы",
    sd.estimation AS "оценка по английскому"
FROM student s
JOIN student_discipline sd ON s.n_credit_book = sd.n_credit_book
JOIN discipline d ON sd.n_discipline = d.n_discipline
WHERE d.title_discipline = 'Английский' AND sd.estimation > (SELECT MAX(avg_ivanov.estimation) FROM avg_ivanov)
ORDER BY "оценка по английскому" DESC;

--5. Вывести в алфавитном порядке в одном столбце фамилии, имена и отчества студентов и фамилии преподавателей, 
--а во втором столбце – статус (студент/преподаватель).
SELECT CONCAT(second_name, ' ', name, ' ', patronymic) AS "ФИО", 'студент' AS "Статус"
FROM student 
UNION ALL
SELECT second_name_teacher AS "ФИО", 'преподаватель' AS "Статус" 
FROM discipline
ORDER BY "ФИО";


--6. Вывести весь список 11 группы, если в ней учится студент Иванов (написать 3 варианта запроса).
SELECT * 
FROM student
WHERE n_group LIKE '11%' 
AND EXISTS (
    SELECT 1 
    FROM student 
    WHERE n_group LIKE '11%'
    AND second_name LIKE 'Иванов'
);
---------------------------------------------
SELECT * 
FROM student 
WHERE n_group LIKE '11%'  
AND n_group = ANY (
    SELECT n_group 
    FROM student 
    WHERE second_name = 'Иванов'
);
---------------------------------------------
SELECT * 
FROM student 
WHERE n_group IN (
    SELECT n_group 
    FROM student 
    WHERE second_name = 'Иванов'
);
---------------------------------------------
SELECT DISTINCT s1.* 
FROM student s1
JOIN student s2 ON s1.n_group = s2.n_group
WHERE s1.n_group LIKE '11%' 
AND s2.second_name = 'Иванов';


--7. Используя объединение Union, создать стипендиальную ведомость о сдаче сессии: 
--все оценки «хорошо» или «хорошо» и «отлично» - 1850 руб.; 
--все «отлично» - 2600 руб. Результат представить в виде таблицы: №зачетки, ФИО студента, размер стипендии (2 варианта запроса).
WITH session AS(
SELECT 4 AS "оценка", 1850 AS "стипендия"
UNION
SELECT 5, 2600
)

SELECT * FROM (
	SELECT s.n_credit_book AS "№ зачетки", 
	CONCAT(s.second_name, ' ', s.name, ' ', s.patronymic) AS "ФИО",
	(SELECT "стипендия" 
	FROM session 
	WHERE (
		SELECT MIN(sd.estimation) 
		FROM student_discipline sd 
		WHERE sd.n_credit_book = s.n_credit_book) = session."оценка"
	) AS "размер стипендии"
    FROM student s
) t
WHERE t."размер стипендии" IS NOT NULL;
----------------------------------------------------
SELECT * FROM (
    SELECT 
        s.n_credit_book AS "№ зачетки",
        CONCAT(s.second_name, ' ', s.name, ' ', s.patronymic) AS "ФИО",
        2600 AS "размер стипендии"
    FROM student s
    JOIN student_discipline sd ON s.n_credit_book = sd.n_credit_book
    GROUP BY s.n_credit_book, s.second_name, s.name, s.patronymic
    HAVING MIN(sd.estimation) = 5 AND MAX(sd.estimation) = 5

    UNION 

    SELECT 
        s.n_credit_book AS "№ зачетки",
        CONCAT(s.second_name, ' ', s.name, ' ', s.patronymic) AS "ФИО",
        1850 AS "размер стипендии"
    FROM student s
    JOIN student_discipline sd ON s.n_credit_book = sd.n_credit_book
    GROUP BY s.n_credit_book, s.second_name, s.name, s.patronymic
    HAVING 
        MIN(sd.estimation) >= 4 
        AND EXISTS (
            SELECT 1 FROM student_discipline sd2 
            WHERE sd2.n_credit_book = s.n_credit_book AND sd2.estimation = 4
        )
) t
ORDER BY t."№ зачетки";


--8. Вывести количество экзаменов для каждой группы. Результат представить в виде: №группы, количество экзаменов
SELECT 
    s.n_group AS "№ группы", 
    COUNT(sd.n_discipline) AS "количество экзаменов"
FROM student s
JOIN student_discipline sd ON s.n_credit_book = sd.n_credit_book
GROUP BY s.n_group
ORDER BY s.n_group;


--9. Вывести для каждого курса количество предметов, по которым студенты должны сдавать экзамены.
--Результат представить в виде: Курс, количество экзаменов (2 варианта запроса).
	
SELECT DISTINCT LEFT(s.n_group, 1)::INT AS "Курс",
       (SELECT COUNT(DISTINCT sd.n_discipline) 
        FROM student_discipline sd 
        JOIN student s2 ON s2.n_credit_book = sd.n_credit_book
        WHERE LEFT(s2.n_group, 1)::INT = LEFT(s.n_group, 1)::INT) AS "количество экзаменов"
FROM student s
ORDER BY "Курс";
-------------------------------------------------
SELECT LEFT(s.n_group, 1)::INT AS "Курс", 
       COUNT(DISTINCT sd.n_discipline) AS "Количество экзаменов"
FROM student s
JOIN student_discipline sd ON s.n_credit_book = sd.n_credit_book
WHERE LEFT(s.n_group, 1)::INT = 1
GROUP BY LEFT(s.n_group, 1)::INT

UNION

SELECT LEFT(s.n_group, 1)::INT AS "Курс", 
       COUNT(DISTINCT sd.n_discipline) AS "Количество экзаменов"
FROM student s
JOIN student_discipline sd ON s.n_credit_book = sd.n_credit_book
WHERE LEFT(s.n_group, 1)::INT = 2
GROUP BY LEFT(s.n_group, 1)::INT

UNION 

SELECT LEFT(s.n_group, 1)::INT AS "Курс", 
       COUNT(DISTINCT sd.n_discipline) AS "Количество экзаменов"
FROM student s
JOIN student_discipline sd ON s.n_credit_book = sd.n_credit_book
WHERE LEFT(s.n_group, 1)::INT = 3
GROUP BY LEFT(s.n_group, 1)::INT

UNION

SELECT LEFT(s.n_group, 1)::INT AS "Курс", 
       COUNT(DISTINCT sd.n_discipline) AS "Количество экзаменов"
FROM student s
JOIN student_discipline sd ON s.n_credit_book = sd.n_credit_book
WHERE LEFT(s.n_group, 1)::INT = 4
GROUP BY LEFT(s.n_group, 1)::INT

ORDER BY "Курс";

