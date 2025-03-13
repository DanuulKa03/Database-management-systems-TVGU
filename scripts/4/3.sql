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
