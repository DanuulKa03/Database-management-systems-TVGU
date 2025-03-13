-- 1. Напишите запрос, который выводит фамилии всех студентов.
SELECT second_name FROM student;

-- 2. Напишите запрос, который выводит таблицу со столбцами в следующем порядке: №группы, имя, фамилия, телефон.
SELECT n_group, name, second_name, telephone FROM student;

-- 3. Напишите запрос, который выводит всю информацию из таблицы Студент.
SELECT * FROM student;

-- 4. Напишите запрос, который выводит все строки из таблицы «Студент», для которых номер группы = 11.
SELECT * FROM student WHERE n_group LIKE '11%';

-- 5. Напишите запрос, который выводит записи о студентах с фамилией «Иванов».
SELECT * FROM student WHERE second_name LIKE 'Иванов';

-- 6. Напишите запрос, который выводит записи о студентах 11 и 12 группы.
SELECT * FROM student WHERE n_group LIKE '11%' OR n_group LIKE '12%';

-- 7. Напишите запрос, который выводит записи о студентах 11 и 12 группы, которые имеют телефон.
SELECT * FROM student WHERE (n_group LIKE '11%' OR n_group LIKE '12%') AND telephone IS NOT NULL;

-- 8. Напишите запрос, который выводит значения номеров групп из таблицы «Студент», без каких бы то ни было повторений.
SELECT n_group FROM student GROUP BY n_group;

-- 9. Напишите запрос, который выводит фамилии преподавателей (фамилии должны появляться без повтора, например, если преподаватели ведут два и более предметов).
SELECT second_name_teacher FROM discipline GROUP BY second_name_teacher;

-- 10. Выведите № зачеток неуспевающих студентов (у которых есть хотя бы одна двойка).
SELECT DISTINCT n_credit_book FROM student_discipline WHERE estimation = 2;

-- 11. Напишите запрос, который выводит информацию о сдаче экзаменов студентом с № зачетки = 11111
SELECT * FROM student_discipline WHERE n_credit_book = 1;

-- 12. Напишите запрос, который выводит № зачеток студентов, которые сдали английский на хорошо и отлично.
SELECT DISTINCT n_credit_book FROM student_discipline WHERE n_discipline = 3 AND estimation > 3;

-- 13. Напишите запрос, который выводит информацию о сдаче экзаменов студентами с номерами зачеток 11111, 11114 и 11115.  (Напишите 2 варианта запроса).
SELECT * FROM student_discipline WHERE n_credit_book = 1 OR n_credit_book = 2 OR n_credit_book = 3;
SELECT * FROM student_discipline WHERE n_credit_book IN (1, 2, 3);

-- 14. Напишите запрос, который выводит информацию об оценке по физике, полученной студентами с номерами зачеток 11111, 11114 и 11115. (Напишите 2 варианта запроса).
SELECT * FROM student_discipline WHERE n_discipline = 2 AND (n_credit_book = 1 OR n_credit_book = 2 OR n_credit_book = 3);
SELECT * FROM student_discipline WHERE n_discipline = 2 AND n_credit_book IN (1, 2, 3);