-- 17. Вывести фамилии преподавателей, которые принимали экзамен
-- в 45 группе, но не принимали экзамен в 35 группе.

with teacher_group as(
    select d.second_name_teacher as teacher, s.n_group as "group"
    from student_discipline as sd
    join discipline as d on d.n_discipline = sd.n_discipline
    join student as s on s.n_credit_book = sd.n_credit_book
    group by s.n_group, d.second_name_teacher
    order by teacher, "group"
)

-- select teacher from teacher_group where "group" = '24A'
select teacher from teacher_group
where "group" = '41A' and teacher not in (select teacher from teacher_group
                                          where "group" = '24A')