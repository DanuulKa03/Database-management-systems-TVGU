-- 10. Вывести фамилии преподавателей, которые принимали более чем 1 экзамен,
-- то есть принимали экзамен более чем в одной группе и/или более чем по одному предмету.
-- Написать 2 запроса.

WITH TEMP as (
    SELECT DE.n_discipline as N_DE, count(DE.second_name_teacher) as SNT FROM student_discipline AS SD
    JOIN discipline as DE on DE.n_discipline = SD.n_discipline
    GROUP BY DE.n_discipline
)

SELECT discipline.second_name_teacher from discipline
JOIN TEMP AS SD_2 ON discipline.n_discipline = SD_2.N_DE
WHERE SD_2.SNT > 1;

SELECT DE.second_name_teacher as SNT FROM student_discipline AS SD
JOIN discipline as DE on DE.n_discipline = SD.n_discipline
GROUP BY DE.second_name_teacher
HAVING count(DE.second_name_teacher) > 1