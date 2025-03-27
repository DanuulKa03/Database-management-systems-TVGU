-- 1. Вывести фамилии преподавателей, которые принимали экзамен (2 способа: использовать exists и естественное соединение).
SELECT second_name_teacher FROM discipline as DE
WHERE EXISTS(
    SELECT * FROM student_discipline as SD
    WHERE DE.n_discipline = SD.n_discipline
);

-- Второй способ
SELECT DISTINCT second_name_teacher FROM discipline as DE
    JOIN student_discipline as SD ON DE.n_discipline = SD.n_discipline;



-- 2. Вывести список студентов, сдавших хотя бы один экзамен на 5
-- (2 способа: использовать exists и естественное соединение).
SELECT second_name FROM student as ST
WHERE EXISTS(
    SELECT * FROM student_discipline as SD
    WHERE ST.n_credit_book = SD.n_credit_book AND SD.estimation = 5
);

-- Второй способ
SELECT DISTINCT ST.second_name FROM student as ST
    JOIN student_discipline as SD ON ST.n_credit_book = SD.n_credit_book AND SD.estimation = 5;




-- 3. Вывести список студентов, сдавших больше, чем 1 экзамен,
-- то есть получивших оценки выше «2» по двум или более предметам
-- (2 способа: использовать вложенный запрос и группировку).
SELECT n_credit_book, second_name, name FROM student AS ST WHERE
    EXISTS ( SELECT 1 FROM student_discipline AS SD WHERE ST.n_credit_book = SD.n_credit_book AND estimation > 2
    GROUP BY SD.n_credit_book HAVING COUNT(SD.n_discipline) > 1
);

-- Другой способ
SELECT ST.n_credit_book, ST.second_name, ST.name
FROM student AS ST
         JOIN (
            SELECT n_credit_book
            FROM student_discipline
            WHERE estimation > 2
            GROUP BY n_credit_book
            HAVING COUNT(n_discipline) > 1
        ) AS PassedExams
        ON ST.n_credit_book = PassedExams.n_credit_book;



-- 4. Вывести список студентов, не сдавших ни одного экзамена,
-- то есть получивших двойки по всем предметам, которые надо было сдавать (написать 2 запроса).
SELECT ST.second_name, ST.name
FROM student AS ST
WHERE NOT EXISTS (
    SELECT 1
    FROM student_discipline AS SD
    WHERE SD.n_credit_book = ST.n_credit_book
      AND SD.estimation <> 2 THEN 1 END
);


SELECT ST.second_name, ST.name
FROM student AS ST
JOIN student_discipline AS SD ON ST.n_credit_book = SD.n_credit_book
GROUP BY ST.n_credit_book, ST.second_name, ST.name
HAVING COUNT(CASE WHEN SD.estimation <> 2 THEN 1 END) = 0;




-- 5. Для каждого студента вывести предметы, по которым этот студент хорошо
-- сдал экзамены, т.е. оценка по которым лучше его среднего балла.
-- Результат вывести в виде таблицы (№зачетки, название предмета, оценка).

SELECT SD.n_credit_book, DS.title_discipline, SD.estimation
FROM student_discipline AS SD
    JOIN discipline AS DS ON SD.n_discipline = DS.n_discipline
    JOIN (SELECT n_credit_book, AVG(SD2.estimation) as ttm
          FROM student_discipline AS SD2
          GROUP BY SD2.n_credit_book) as temp ON temp.n_credit_book = SD.n_credit_book
    WHERE SD.estimation >= temp.ttm AND temp.ttm <> 2;

-- SELECT SD.n_credit_book, DS.title_discipline, SD.estimation
-- FROM student_discipline AS SD
--          JOIN discipline AS DS ON SD.n_discipline = DS.n_discipline
-- WHERE SD.estimation <= (
--     SELECT AVG(SD2.estimation)
--     FROM student_discipline AS SD2
--     WHERE SD2.n_credit_book = SD.n_credit_book
-- ) AND SD.estimation <> 2;
--
-- SELECT student.second_name, temp.ttm FROM student JOIN
-- (SELECT n_credit_book, AVG(SD2.estimation) as ttm
-- FROM student_discipline AS SD2
-- GROUP BY SD2.n_credit_book) as temp ON temp.n_credit_book = student.n_credit_book;



-- 6. Вывести фамилии студентов, которые сдавали экзамены. Результат представить в виде таблицы
-- (ФИО, название предмета, оценка, фамилия экзаменатора).
-- Написать 2 варианта запроса: использовать соединение и вложенные запросы в предложении Select.

SELECT CONCAT(second_name, ' ', name, ' ', patronymic) as ФИО, DE.title_discipline, SE.estimation, DE.second_name_teacher FROM student as ST
    JOIN student_discipline as SE ON ST.n_credit_book = SE.n_credit_book
    JOIN discipline as DE ON SE.n_discipline = DE.n_discipline
    WHERE ST.n_credit_book = SE.n_credit_book;

SELECT CONCAT(second_name, ' ', name, ' ', patronymic), DE.title_discipline, SE.estimation, DE.second_name_teacher FROM student as ST
    JOIN (SELECT n_credit_book, n_discipline, estimation FROM student_discipline) AS SE ON SE.n_credit_book = ST.n_credit_book
    JOIN (SELECT n_discipline, title_discipline, second_name_teacher FROM discipline) AS DE ON SE.n_discipline = DE.n_discipline
    WHERE ST.n_credit_book = SE.n_credit_book;



-- 7. Вывести фамилии студентов, которые сдали все экзамены без двоек. Результат представить в виде таблицы
-- (ФИО, название предмета, оценка, фамилия экзаменатора).
-- Написать 2 варианта запроса, один из них – с использованием предиката Exists.

SELECT CONCAT(second_name, ' ', name, ' ', patronymic) as ФИО, DE.title_discipline, SE.estimation, DE.second_name_teacher FROM student as ST
    JOIN student_discipline as SE ON ST.n_credit_book = SE.n_credit_book
    JOIN discipline as DE ON SE.n_discipline = DE.n_discipline
    WHERE SE.n_credit_book NOT IN (
        SELECT n_credit_book
        FROM student_discipline
        WHERE estimation = 2
        GROUP BY n_credit_book, estimation
    );

SELECT CONCAT(second_name, ' ', name, ' ', patronymic) as ФИО, DE.title_discipline, SE.estimation, DE.second_name_teacher FROM student as ST
    JOIN student_discipline as SE ON ST.n_credit_book = SE.n_credit_book
    JOIN discipline as DE ON SE.n_discipline = DE.n_discipline
    WHERE NOT EXISTS(SELECT 1 FROM student_discipline as TEMP
                     WHERE estimation = 2 AND SE.n_credit_book = TEMP.n_credit_book
                     GROUP BY n_credit_book, estimation
    );



-- 8. Вывести информацию о студентах, у которых принимал экзамен Макаров.
-- Результат представить в виде таблицы (№зачетки, название предмета, оценка).
-- Написать 2 запроса, один из них – с использованием предиката Exists).

SELECT student.n_credit_book, discipline.title_discipline, student_discipline.estimation
FROM student_discipline
JOIN student ON student_discipline.n_credit_book = student.n_credit_book
JOIN discipline ON student_discipline.n_discipline = discipline.n_discipline
WHERE discipline.second_name_teacher = 'Смирнов';

SELECT student.n_credit_book, discipline.title_discipline, SD.estimation
FROM student_discipline AS SD
JOIN student ON SD.n_credit_book = student.n_credit_book
JOIN discipline ON SD.n_discipline = discipline.n_discipline
WHERE EXISTS(
    SELECT 1 FROM discipline
    WHERE discipline.second_name_teacher = 'Смирнов' AND discipline.n_discipline = SD.n_discipline
);



-- 9. Вывести список студентов из группы, в которой учится Иванов.
-- Написать 3 запроса, один из них – с пользованием предиката Exists).

SELECT second_name, name, patronymic FROM student
WHERE n_group IN (
    SELECT n_group FROM student
    WHERE second_name = 'Лебедев'
);

SELECT second_name, name, patronymic FROM student as ST
WHERE EXISTS(
    SELECT 1 FROM student as ST_1
    WHERE second_name = 'Лебедев' AND ST_1.n_group = ST.n_group
);

SELECT ST.second_name, ST.name, ST.patronymic
FROM student AS ST
JOIN student AS ST_1 ON ST.n_group = ST_1.n_group
WHERE ST_1.second_name = 'Лебедев';




-- 10. Вывести фамилии преподавателей, которые принимали более чем 1 экзамен,
-- то есть принимали экзамен более чем в одной группе и/или более чем по одному предмету.
-- Написать 2 запроса.

WITH TEMP as (
    SELECT DE.n_discipline as N_DE, count(DE.second_name_teacher) as SNT FROM student_discipline AS SD
    JOIN discipline as DE on DE.n_discipline = SD.n_discipline
    GROUP BY DE.n_discipline
)

SELECT discipline.second_name_teacher from discipline
JOIN TEMP AS SD_2 ON discipline.n_discipline = SD_2.N_DE
WHERE SD_2.SNT > 1;

SELECT DE.second_name_teacher as SNT FROM student_discipline AS SD
JOIN discipline as DE on DE.n_discipline = SD.n_discipline
GROUP BY DE.second_name_teacher
HAVING count(DE.second_name_teacher) > 1;


-- 11. Вывести информацию о преподавателях, которые поставили столько же или больше оценок 5,
-- чем преподаватель Бурков.

WITH search_count_est_for_kazakov as (
    SELECT COUNT(SD.estimation) AS count_estimation FROM student_discipline AS SD
    JOIN discipline AS DE ON DE.n_discipline = SD.n_discipline
    WHERE SD.estimation = 5 AND DE.second_name_teacher = 'Казаков'
)

SELECT DE.second_name_teacher, COUNT(SD.estimation) FROM student_discipline AS SD
JOIN discipline as DE on DE.n_discipline = SD.n_discipline
GROUP BY SD.estimation, DE.second_name_teacher
HAVING SD.estimation = 5 AND COUNT(SD.estimation) >= (SELECT count_estimation FROM search_count_est_for_kazakov)
                         AND DE.second_name_teacher != 'Казаков';



-- 12. Вывести фамилии студентов и все их оценки по каждому предмету.
-- Написать 2 типа запроса: использовать естественное соединение и вложенные запросы в предложении Select.

SELECT SD.second_name, DS.title_discipline, SDD.estimation FROM student AS SD
JOIN student_discipline AS SDD on SD.n_credit_book = SDD.n_credit_book
JOIN discipline AS DS on DS.n_discipline = SDD.n_discipline;

SELECT stu_name.second_name, exams_name.title_discipline, SD.estimation FROM student_discipline AS SD
JOIN (
    SELECT n_discipline as ND, title_discipline
    FROM discipline
) AS exams_name ON exams_name.ND = SD.n_discipline
JOIN (
    SELECT student.n_credit_book as NCB, second_name
    FROM student
) AS stu_name ON stu_name.NCB = SD.n_credit_book;



-- 13. Вывести фамилии преподавателей, которые принимали экзамены у студентов 11 группы.
-- Написать 2 запроса, один – с использованием предиката Exists.

SELECT DISTINCT discipline.second_name_teacher, s.n_group FROM discipline
JOIN student_discipline AS sd on discipline.n_discipline = sd.n_discipline
JOIN student AS s on s.n_credit_book = sd.n_credit_book
-- GROUP BY discipline.second_name_teacher, s.n_group
WHERE s.n_group LIKE '11%';

SELECT DISTINCT discipline.second_name_teacher FROM discipline
WHERE EXISTS(
    SELECT 1 FROM student_discipline
    JOIN public.student AS s on s.n_credit_book = student_discipline.n_credit_book
    WHERE discipline.n_discipline = student_discipline.n_discipline AND s.n_group LIKE '11%'
);



-- 14. Узнать, у студентов каких групп не принимал экзамен преподаватель Макаров.
-- Написать 2 запроса, один – с использованием предиката Exists.

SELECT DISTINCT s.n_group FROM student AS s
WHERE s.n_group NOT IN (
    SELECT student.n_group FROM student
    JOIN student_discipline AS d on student.n_credit_book = d.n_credit_book
    JOIN discipline AS d2 on d2.n_discipline = d.n_discipline
    WHERE second_name_teacher LIKE 'Казаков'
);

SELECT DISTINCT S.n_group
FROM student AS S
WHERE NOT EXISTS (
    SELECT 1
    FROM student_discipline AS SD
    JOIN discipline AS D ON SD.n_discipline = D.n_discipline
    WHERE SD.n_credit_book = S.n_credit_book
      AND D.second_name_teacher = 'Казаков'
);



-- 15. Вывести фамилии преподавателей, поставивших больше, чем одну двойку.
-- Написать 2 запроса.

SELECT DISTINCT second_name_teacher FROM discipline as D
WHERE EXISTS(
    SELECT 1 FROM student_discipline as SD
    WHERE D.n_discipline = SD.n_discipline AND SD.estimation = 2
);

SELECT DISTINCT D.second_name_teacher FROM discipline as D
JOIN student_discipline as SD ON D.n_discipline = SD.n_discipline AND SD.estimation = 2;



-- 16. Вывести фамилии преподавателей, поставивших больше
-- всего "двоек" (в сравнении с другими преподавателями).

with f_est_count as(
    select d.second_name_teacher as teacher, count(estimation) as f_count from student_discipline as sd
    join discipline as d on sd.n_discipline = d.n_discipline
    where sd.estimation = 2
    group by d.second_name_teacher
)
select teacher from f_est_count where f_count > (select avg(f_count) from f_est_count);



-- 17. Вывести фамилии преподавателей, которые принимали экзамен
-- в 45 группе, но не принимали экзамен в 35 группе.

with teacher_group as(
    select d.second_name_teacher as teacher, s.n_group as "group"
    from student_discipline as sd
    join discipline as d on d.n_discipline = sd.n_discipline
    join student as s on s.n_credit_book = sd.n_credit_book
    group by s.n_group, d.second_name_teacher
    order by teacher, "group"
)

-- select teacher from teacher_group where "group" = '24A'
select teacher from teacher_group
where "group" = '41A' and teacher not in (select teacher from teacher_group
                                          where "group" = '24A')