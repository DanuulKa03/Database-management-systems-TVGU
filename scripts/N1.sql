-- 11.	Создайте представление для получения сведений по каждому студенту:
-- номер зачетки, фамилия, имя, средний и общий баллы за сессию.
-- Является ли данное представление вставляемым, удаляемым, обновляемым? Ответ обоснуйте.
-- Данное представление не является вставляемым, удаляемым, обновляемым, 
-- так как в запросе для формирования представления использовались:
-- агрегатные функции и конструкция group by 
create view student_data as 
select s.n_credit_book, s.second_name, s.name, avg(sd.estimation), sum(sd.estimation)  from student s
join student_discipline sd on s.n_credit_book = sd.n_credit_book
group by s.n_credit_book

select * from student_data
drop view student_data
-- 12.	Создайте представление для получения сведений о количестве экзаменов, которые сдавал каждый студент.
-- С помощью данного представления получите количество экзаменов, которые сдавал заданный студент.
-- Является ли данное представление вставляемым, удаляемым, обновляемым? Ответ обоснуйте.
create view count_discipline as 
select n_credit_book, count(n_discipline) from student_discipline as sd
group by n_credit_book
order by n_credit_book

select * from count_discipline
drop view count_discipline
-- 13.	Создайте представление для получения списка преподавателей, принимавших экзамены.
-- Является ли данное представление вставляемым, удаляемым, обновляемым? Ответ обоснуйте.
create view list_exam_teachers as
select distinct second_name_teacher from discipline 
where n_discipline in (select distinct n_discipline FROM student_discipline)

select  * from list_exam_teachers

drop view list_exam_teachers
-- 14.	Создайте представления для кураторов курсов. Допустимыми значениями номера группы являются: 
-- a)	для первого курса – 10, 11, 12, 13, 14, 15
create view first_course as
select * from student 
where n_group like '1%'
with cascaded check option;

insert into public.first_course(
    second_name, name, patronymic, n_group, telephone)
    values ('Иванов', 'Петр', 'Сергеевич', '11А', null);

insert into public.first_course(
    second_name, name, patronymic, n_group, telephone)
    values ('Петров', 'Иван', 'Николаевич', '21Б', null);

drop view first_course
-- b)	для второго курса – 20, 21, 22, 23, 24, 25

create view second_course as
select * from student 
where n_group like '2%'
with cascaded check option;

insert into public.second_course(
    second_name, name, patronymic, n_group, telephone)
    values ('Сидоров', 'Алексей', 'Михайлович', '22В', '+79161234567');

insert into public.second_course(
    second_name, name, patronymic, n_group, telephone)
    values ('Кузнецова', 'Ольга', 'Владимировна', '12Г', null);

drop view second_course
-- c)	для третьего курса – 30, 31, 32, 33, 34, 35

create view third_course as
select * from student 
where n_group like '3%'
with cascaded check option;

insert into public.third_course(
    second_name, name, patronymic, n_group, telephone)
    values ('Николаев', 'Дмитрий', 'Сергеевич', '33Д', null);

insert into public.third_course(
    second_name, name, patronymic, n_group, telephone)
    values ('Орлова', 'Мария', 'Ивановна', '43Е', '+79267778899');

drop view third_course
-- d)	для четвертого курса –  40, 41, 42, 43, 44, 45

create view fourth_course as
select * from student 
where n_group like '4%'
with cascaded check option;

insert into public.fourth_course(
    second_name, name, patronymic, n_group, telephone)
    values ('Федорова', 'Анна', 'Павловна', '44Ж', null);

insert into public.fourth_course(
    second_name, name, patronymic, n_group, telephone)
    values ('Громов', 'Сергей', 'Олегович', '54З', '+79368889900');

drop view fourth_course
-- e)	для пятого курса – 50, 51, 52, 53, 54, 55

create view fifth_course as
select * from student 
where n_group like '5%'
with cascaded check option;

insert into public.fifth_course(
    second_name, name, patronymic, n_group, telephone)
    values ('Владимиров', 'Михаил', 'Андреевич', '55И', null);

insert into public.fifth_course(
    second_name, name, patronymic, n_group, telephone)
    values ('Белова', 'Екатерина', 'Дмитриевна', '65К', '+79469990011');

drop view fifth_course
-- f)	для шестого курса – 64, 65.

create view sixth_course as
select * from student 
where n_group like '6%'
with cascaded check option;

insert into public.sixth_course(
    second_name, name, patronymic, n_group, telephone)
    values ('Ковалев', 'Андрей', 'Викторович', '66Л', null);

insert into public.sixth_course(
    second_name, name, patronymic, n_group, telephone)
    values ('Смирнов', 'Павел', 'Николаевич', '16М', '+79561001122');

drop view sixth_course