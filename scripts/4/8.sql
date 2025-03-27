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