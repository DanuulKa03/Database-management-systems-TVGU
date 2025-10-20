--1.	Создайте представление для получения сведений о количестве студентов в каждой группе.
CREATE OR REPLACE VIEW v1
	AS SELECT n_group, COUNT(n_credit_book) AS "количество" FROM student
       GROUP BY n_group
       ORDER BY n_group;


SELECT * FROM v1;

--2.	Используя предыдущее представление, создайте представление, определяющее минимальное,
--максимальное и среднее число студентов в группе.
CREATE OR REPLACE VIEW v2
	AS SELECT MIN("количество") AS "минимум", MAX("количество") AS "максимум", AVG("количество") AS "среднее" FROM v1;

--3.	Создайте представление для получения максимального числа студентов
--в группе, используя предыдущее представление.
CREATE OR REPLACE VIEW v3
	AS SELECT "максимум" FROM v2;

--4.	Используя предыдущие представления, создайте представление,
--определяющее номер группы (номера групп) с максимальным количеством студентов
--(одно из представлений используется в подзапросе).
CREATE OR REPLACE VIEW v4
	AS SELECT n_group FROM v1
       WHERE "количество" = (SELECT "максимум" FROM v3);

--5.	Создайте представление для получения сведений по каждому студенту
--с локальным условием проверки на номер зачетки (номер зачетки меньше заданного).
--Попытайтесь осуществить вставку в данное представление с нарушением и без нарушения ограничений. Прокомментируйте результат.
CREATE OR REPLACE VIEW v5
	AS SELECT * FROM student
       WHERE n_credit_book < 50
       ORDER BY n_credit_book
                  WITH LOCAL CHECK OPTION;

INSERT INTO v5 (n_credit_book, second_name, name, patronymic, n_group, telephone)
VALUES  (999, 'Тестов', 'Тест', 'Тестович', '99Z', '89771112233');


-- [44000] ERROR: new row violates check option for view "v5"
--   Detail: Failing row contains (999, Тестов, Тест, Тестович, 99Z, 89771112233).


INSERT INTO v5 (n_credit_book, second_name, name, patronymic, n_group, telephone)
VALUES  (49, 'Тестов', 'Тест', 'Тестович', '99Z', '89771112233');


-- 6. Создайте представление для получения сведений по каждому студенту с каскадным условием проверки на номер зачетки (номер зачетки больше заданного). Попытайтесь осуществить вставку в данное представление с нарушениями и без нарушения верхнего и нижнего ограничений. Прокомментируйте результат.

CREATE OR REPLACE VIEW orders_products_customers
AS
SELECT * FROM v5
   WHERE n_credit_book > 40
        WITH CASCADED CHECK OPTION;

INSERT INTO orders_products_customers VALUES (45, 'Петя', 'Пётов', 'Петькович', '23C', '88005553535');

INSERT INTO orders_products_customers VALUES (33, 'Петя', 'Пётов', 'Петькович', '23C', '88005553535');

-- [44000] ERROR: new row violates check option for view "orders_products_customers"
--   Detail: Failing row contains (33, Петя, Пётов, Петькович, 23C, 88005553535).

INSERT INTO orders_products_customers VALUES (65, 'Петя', 'Пётов', 'Петькович', '23C', '88005553535');

-- [44000] ERROR: new row violates check option for view "v5"
--   Detail: Failing row contains (65, Петя, Пётов, Петькович, 23C, 88005553535).

-- 7. Попытайтесь изменить фамилию студента с заданным номером зачетки с помощью представления 6 для случаев нарушения ограничений и без нарушения ограничений. Прокомментируйте результат.


UPDATE orders_products_customers SET second_name='Федор' WHERE n_credit_book=45;
UPDATE orders_products_customers SET second_name='Лолка' WHERE n_credit_book=26; -- не выдает ошибку

-- 8. Попытайтесь удалить студента с заданным номером зачетки с помощью представления 6 для случаев нарушения ограничений и без нарушения ограничений. Прокомментируйте результат.

DELETE FROM orders_products_customers WHERE n_credit_book=45;
DELETE FROM orders_products_customers WHERE n_credit_book=26; -- не изменяется

-- 9. Создайте представления для получения списка студентов заданной группы: с условием проверки и без условия проверки. Попытайтесь с помощью этих представлений вставить сведения о новом студенте в другую группу с нарушением и без нарушения ограничений. Прокомментируйте результат.

CREATE OR REPLACE VIEW orders_products_customers_check
AS
SELECT * FROM student
WHERE n_group LIKE '1%';

INSERT INTO orders_products_customers_check VALUES (45, 'Петя', 'Пётов', 'Петькович', '23C', '88005553535');
INSERT INTO orders_products_customers_check VALUES (46, 'Петя', 'Пётов', 'Петькович', '13C', '88005553535');

CREATE OR REPLACE VIEW orders_products_customers_check_fin
AS
SELECT * FROM student
WHERE n_group LIKE '1%'
WITH LOCAL CHECK OPTION;

INSERT INTO orders_products_customers_check_fin VALUES (48, 'Петя', 'Пётов', 'Петькович', '23C', '88005553535');

-- [44000] ERROR: new row violates check option for view "orders_products_customers_check_fin"
--   Detail: Failing row contains (48, Петя, Пётов, Петькович, 23C, 88005553535).

INSERT INTO orders_products_customers_check_fin VALUES (55, 'Петя', 'Пётов', 'Петькович', '13C', '88005553535');

-- 10. Создайте представление для получения сведений обо всех студентах, имеющих только отличные оценки. Является ли данное представление вставляемым, удаляемым, обновляемым? Ответ обоснуйте.

CREATE OR REPLACE VIEW orders_products_customers_check_five
AS
SELECT s.n_credit_book, second_name, name, patronymic, n_group, telephone FROM student AS s
LEFT JOIN student_discipline AS sd
ON s.n_credit_book = sd.n_credit_book
GROUP BY s.n_credit_book
HAVING MIN(sd.estimation) = 5;

-- 11.	Создайте представление для получения сведений по каждому студенту:
-- номер зачетки, фамилия, имя, средний и общий баллы за сессию.
-- Является ли данное представление вставляемым, удаляемым, обновляемым? Ответ обоснуйте.
-- Данное представление не является вставляемым, удаляемым, обновляемым,
-- так как в запросе для формирования представления использовались:
-- агрегатные функции и конструкция group by
create view student_data as
select s.n_credit_book, s.second_name, s.name, avg(sd.estimation), sum(sd.estimation)  from student s
join student_discipline sd on s.n_credit_book = sd.n_credit_book
group by s.n_credit_book;

select * from student_data
drop view student_data;
-- 12.	Создайте представление для получения сведений о количестве экзаменов, которые сдавал каждый студент.
-- С помощью данного представления получите количество экзаменов, которые сдавал заданный студент.
-- Является ли данное представление вставляемым, удаляемым, обновляемым? Ответ обоснуйте.
create view count_discipline as
select n_credit_book, count(n_discipline) from student_discipline as sd
group by n_credit_book
order by n_credit_book;

select * from count_discipline;
drop view count_discipline;
-- 13.	Создайте представление для получения списка преподавателей, принимавших экзамены.
-- Является ли данное представление вставляемым, удаляемым, обновляемым? Ответ обоснуйте.
create view list_exam_teachers as
select distinct second_name_teacher from discipline
where n_discipline in (select distinct n_discipline FROM student_discipline);

select  * from list_exam_teachers;

drop view list_exam_teachers;
-- 14.	Создайте представления для кураторов курсов. Допустимыми значениями номера группы являются:
-- a)	для первого курса – 10, 11, 12, 13, 14, 15
create view first_course as
select * from student
where n_group like '1%'
        with local check option;

insert into first_course(
    second_name, name, patronymic, n_group, telephone)
values ('Иванов', 'Петр', 'Сергеевич', '11А', null);

insert into first_course(
    second_name, name, patronymic, n_group, telephone)
values ('Петров', 'Иван', 'Николаевич', '21Б', null);

UPDATE first_course SET second_name = 'Иванов' where n_credit_book = 55;
UPDATE first_course SET second_name = 'Иванов' where n_credit_book = 45;

drop view first_course;
-- b)	для второго курса – 20, 21, 22, 23, 24, 25

create view second_course as
select * from student
where n_group like '2%'
        with local check option;

insert into second_course(
    second_name, name, patronymic, n_group, telephone)
values ('Сидоров', 'Алексей', 'Михайлович', '22В', '+79161234567');

insert into second_course(
    second_name, name, patronymic, n_group, telephone)
values ('Кузнецова', 'Ольга', 'Владимировна', '12Г', null);

drop view second_course;
-- c)	для третьего курса – 30, 31, 32, 33, 34, 35

create view third_course as
select * from student
where n_group like '3%'
        with local check option;

insert into third_course(
    second_name, name, patronymic, n_group, telephone)
values ('Николаев', 'Дмитрий', 'Сергеевич', '33Д', null);

insert into third_course(
    second_name, name, patronymic, n_group, telephone)
values ('Орлова', 'Мария', 'Ивановна', '43Е', '+79267778899');

drop view third_course
-- d)	для четвертого курса –  40, 41, 42, 43, 44, 45

create view fourth_course as
select * from student
where n_group like '4%'
        with local check option;

insert into fourth_course(
    second_name, name, patronymic, n_group, telephone)
values ('Федорова', 'Анна', 'Павловна', '44Ж', null);

insert into fourth_course(
    second_name, name, patronymic, n_group, telephone)
values ('Громов', 'Сергей', 'Олегович', '54З', '+79368889900');

drop view fourth_course
-- e)	для пятого курса – 50, 51, 52, 53, 54, 55

create view fifth_course as
select * from student
where n_group like '5%'
        with local check option;

insert into fifth_course(
    second_name, name, patronymic, n_group, telephone)
values ('Владимиров', 'Михаил', 'Андреевич', '55И', null);

insert into fifth_course(
    second_name, name, patronymic, n_group, telephone)
values ('Белова', 'Екатерина', 'Дмитриевна', '65К', '+79469990011');

drop view fifth_course
-- f)	для шестого курса – 64, 65.

create view sixth_course as
select * from student
where n_group like '6%'
        with local check option;

insert into sixth_course(
    second_name, name, patronymic, n_group, telephone)
values ('Ковалев', 'Андрей', 'Викторович', '66Л', null);

insert into sixth_course(
    second_name, name, patronymic, n_group, telephone)
values ('Смирнов', 'Павел', 'Николаевич', '16М', '+79561001122');

drop view sixth_course