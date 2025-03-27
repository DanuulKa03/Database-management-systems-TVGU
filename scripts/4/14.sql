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