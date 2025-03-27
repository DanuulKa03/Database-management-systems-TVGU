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
