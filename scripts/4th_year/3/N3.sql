
-- 1.	Напишите запрос, который выводит декартово произведение двух таблиц Студент и Студент_Предмет.
select s.*, sd.* from student as s, student_discipline as sd;

-- 2.	Напишите запрос, выводящий фамилии студентов вместе с названиями предметов и оценками, которые были ими получены.
select s.second_name, d.title_discipline, sd.estimation
from student as s 
join student_discipline as sd on s.n_credit_book = sd.n_credit_book
join discipline as d on sd.n_discipline = d.n_discipline;

-- 3.	Напишите запрос, выводящий фамилии студентов вместе с названиями предметов, которые они сдавали в сессию,
-- и фамилиями преподавателей, которые принимали у них экзамены по соответствующим предметам.
select s.second_name, d.title_discipline, sd.estimation, d.second_name_teacher
from student as s 
join student_discipline as sd on s.n_credit_book = sd.n_credit_book
join discipline as d on sd.n_discipline = d.n_discipline;

-- 4.	Вывести фамилии преподавателей, названия предметов и группы, у которых принимали экзамены эти преподаватели.
select d.second_name_teacher, d.title_discipline, s.n_group 
from discipline as d 
join student_discipline as sd on sd.n_discipline = d.n_discipline
join student as s on s.n_credit_book = sd.n_credit_book
group by d.second_name_teacher, d.title_discipline, s.n_group
order by d.second_name_teacher;

-- 5.	Вывести список студентов из той же группы, что и Иванов.
-- select name, second_name, n_group from student
select second_name, n_group from student where n_group in (select distinct n_group from student where second_name = 'Иванов')

-- 6.	Вывести список преподавателей, которые преподают тот же предмет, что и преподаватель Бурков.
-- select second_name_teacher, n_discipline,title_discipline from discipline
select second_name_teacher, title_discipline from discipline 
where title_discipline in (select distinct title_discipline from discipline where second_name_teacher = 'Смирнов')

-- 7.	Вывести количество студентов, сдавших экзамены по всем предметам,
-- то есть не имеющих задолженностей (использовать группировку).
with good_student as (
	select n_credit_book from student_discipline
	group by n_credit_book 
	having n_credit_book not in
		(select n_credit_book from student_discipline where estimation = 2)
)
select count(n_credit_book) from good_student

-- 8.	Вывести количество оценок 2, 3, 4, 5 полученных в каждой группе (использовать группировку).
SELECT 
	s.n_group, 
	e.estimation, 
	COUNT(sd.estimation)
FROM student as s
CROSS JOIN (SELECT 2 AS estimation UNION ALL SELECT 3 UNION ALL SELECT 4 UNION ALL SELECT 5) e
LEFT JOIN student_discipline as sd ON s.n_credit_book = sd.n_credit_book AND sd.estimation = e.estimation
GROUP BY s.n_group, e.estimation
ORDER BY s.n_group, e.estimation

-- 9.	Вывести средний балл оценок, полученных в каждой группе (использовать группировку).
select s.n_group, avg(sd.estimation) from student_discipline as sd
join student as s on sd.n_credit_book = s.n_credit_book
group by s.n_group order by s.n_group

-- 10.	Вывести количество оценок 2, 3, 4, 5 по каждому предмету вместе с преподавателем, который принимал экзамен (использовать группировку).
SELECT 
	d.title_discipline, 
	e.estimation, 
	COUNT(sd.estimation),
	d.second_name_teacher
FROM discipline d
CROSS JOIN (SELECT 2 AS estimation UNION ALL SELECT 3 UNION ALL SELECT 4 UNION ALL SELECT 5) e
LEFT JOIN student_discipline sd ON d.n_discipline = sd.n_discipline AND sd.estimation = e.estimation
GROUP BY d.title_discipline, e.estimation, d.second_name_teacher
ORDER BY d.title_discipline, e.estimation 

-- 11.	Вывести фамилии студентов, названия предметов, оценки, и фамилии преподавателей,
-- которые принимали экзамен у данного студента по данному предмету (в виде таблицы (ФИО студента, Название предмета, Оценка, Фамилия преподавателя).
select concat(s.second_name, ' ', s.name, ' ', s.patronymic) as "ФИО студента",
		d.title_discipline as "Название предмета",
		sd.estimation as "Оценка",
		d.second_name_teacher as "Фамилия преподавателя"	
from student_discipline as sd
join student as s on sd.n_credit_book = s.n_credit_book
join discipline as d on sd.n_discipline = d.n_discipline

-- 12.	Вывести список «слабых» групп, средний балл по оценкам в которых ниже 4.
select s.n_group, avg(sd.estimation) from student_discipline as sd
join student as s on sd.n_credit_book = s.n_credit_book
group by s.n_group
having avg(sd.estimation) < 4.0
order by s.n_group

-- 13.	Вывести список студентов, средний балл которых не ниже 4.
select concat(s.second_name, ' ', s.name, ' ', s.patronymic) as "ФИО студента",
	avg(sd.estimation) from student_discipline as sd
join student as s on sd.n_credit_book = s.n_credit_book
group by s.n_credit_book
having avg(sd.estimation) >= 4.0
order by s.n_credit_book

-- 14.	Узнать успеваемость студентки Беловой по всем предметам (написать 2 запроса: использующий естественное соединение и использующий подзапрос).
select sd.n_credit_book, sd.estimation from student_discipline as sd
natural join student as s 
where s.second_name = 'Иванов'

select n_credit_book, estimation from student_discipline 
where n_credit_book in (select n_credit_book from student where second_name = 'Иванов')

-- 15.	Вывести список групп, у которых принимал экзамен Бурков 
--(написать 2 запроса: использующий естественное соединение и использующий подзапрос).
select distinct s.n_group
from student as s
natural join student_discipline as sd
natural join discipline as d
where d.second_name_teacher = 'Сидорова'
order by s.n_group

select distinct n_group from student 
where n_credit_book in (
	select n_credit_book from student_discipline
	where n_discipline in (
		select n_discipline from discipline where second_name_teacher = 'Сидорова'
	)
)
order by n_group

-- 16.	Вывести список названий предметов, которые сдавала студентка Белова (
--написать 2 запроса: использующий естественное соединение и использующий подзапрос).
select distinct d.title_discipline 
from student_discipline as sd
natural join student as s 
natural join discipline as d 
where s.second_name = 'Иванов'
order by d.title_discipline

select distinct title_discipline from discipline 
where n_discipline in (
	select n_discipline from student_discipline
	where n_credit_book in (
		select n_credit_book from student where second_name = 'Иванов'
	)
)
order by title_discipline

-- 17.	Вывести список студентов, успеваемость которых выше, чем у студентки Беловой, 
--т.е. их средний балл выше, чем средний балл студентки Беловой (подзапрос в предложении Having).
select concat(s.second_name, ' ', s.name, ' ', s.patronymic) as "ФИО студента",
	avg(sd.estimation) from student_discipline as sd
join student as s on sd.n_credit_book = s.n_credit_book
group by s.n_credit_book
having avg(sd.estimation) > (select avg(sd.estimation) from student_discipline as sd
									join student as s on sd.n_credit_book = s.n_credit_book
									where second_name = 'Иванов')
order by s.n_credit_book

-- 18.	Узнать по каким предметам самая низкая успеваемость,
-- т.е. средний балл по этим предметам меньше или равен среднему баллу по каждому из остальных предметов
--(подзапрос в предложении Having, написать 2 запроса).
with avg_est as (
	select avg(sd.estimation) as aest
	from student_discipline as sd
	join discipline as d on sd.n_discipline = d.n_discipline
	group by d.n_discipline)
select d.title_discipline, avg(sd.estimation) from student_discipline as sd
join discipline as d on sd.n_discipline = d.n_discipline
group by d.n_discipline
having avg(sd.estimation) <= (select min(aest) from avg_est)

select d.title_discipline, avg(sd.estimation) as avg_estimation
from student_discipline as sd
join discipline d on sd.n_discipline = d.n_discipline
group by d.title_discipline
having avg(sd.estimation) <= (
    select avg(sd2.estimation)
    from student_discipline sd2
    group by sd2.n_discipline
    order by avg(sd2.estimation)
    limit 1
);


-- 19.	Узнать номера «сильных» групп (с успеваемостью выше средней из средних по группам) (подзапрос в предложении Having).
select s.n_group, avg(sd.estimation) from student_discipline as sd
join student as s on sd.n_credit_book = s.n_credit_book
group by s.n_group
having avg(sd.estimation) >= (select avg(e) from (
	select s.n_group, avg(sd.estimation) as e from student_discipline as sd
	join student as s on sd.n_credit_book = s.n_credit_book
	group by s.n_group
))
