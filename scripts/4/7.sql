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
