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
