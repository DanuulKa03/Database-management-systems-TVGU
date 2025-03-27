-- 16. Вывести фамилии преподавателей, поставивших больше
-- всего "двоек" (в сравнении с другими преподавателями).

with f_est_count as(
    select d.second_name_teacher as teacher, count(estimation) as f_count from student_discipline as sd
    join discipline as d on sd.n_discipline = d.n_discipline
    where sd.estimation = 2
    group by d.second_name_teacher
)
select teacher from f_est_count where f_count > (select avg(f_count) from f_est_count);