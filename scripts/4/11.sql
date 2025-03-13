-- 11. Вывести информацию о преподавателях, которые поставили столько же или больше оценок 5,
-- чем преподаватель Бурков.

WITH search_count_est_for_kazakov as (
    SELECT COUNT(SD.estimation) AS count_estimation FROM student_discipline AS SD
    JOIN discipline AS DE ON DE.n_discipline = SD.n_discipline
    WHERE SD.estimation = 5 AND DE.second_name_teacher = 'Казаков'
)

SELECT DE.second_name_teacher, COUNT(SD.estimation) FROM student_discipline AS SD
JOIN discipline as DE on DE.n_discipline = SD.n_discipline
GROUP BY SD.estimation, DE.second_name_teacher
HAVING SD.estimation = 5 AND COUNT(SD.estimation) >= (SELECT count_estimation FROM search_count_est_for_kazakov)
                         AND DE.second_name_teacher != 'Казаков';