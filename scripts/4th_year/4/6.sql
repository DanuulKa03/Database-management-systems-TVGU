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