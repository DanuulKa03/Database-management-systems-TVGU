-- 1. Вывести фамилии преподавателей, которые принимали экзамен (2 способа: использовать exists и естественное соединение).
SELECT second_name_teacher FROM discipline as DE
WHERE EXISTS(
    SELECT * FROM student_discipline as SD
    WHERE DE.n_discipline = SD.n_discipline
);

-- Второй способ
SELECT DISTINCT second_name_teacher FROM discipline as DE
    JOIN student_discipline as SD ON DE.n_discipline = SD.n_discipline;