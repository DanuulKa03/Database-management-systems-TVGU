-- 15. Вывести фамилии преподавателей, поставивших больше, чем одну двойку.
-- Написать 2 запроса.

SELECT DISTINCT second_name_teacher FROM discipline as D
WHERE EXISTS(
    SELECT 1 FROM student_discipline as SD
    WHERE D.n_discipline = SD.n_discipline AND SD.estimation = 2
);

SELECT DISTINCT D.second_name_teacher FROM discipline as D
JOIN student_discipline as SD ON D.n_discipline = SD.n_discipline AND SD.estimation = 2;
