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