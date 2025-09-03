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
