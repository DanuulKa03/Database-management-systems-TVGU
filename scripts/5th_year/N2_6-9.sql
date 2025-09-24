--6.	Создать процедуру с входными и выходным параметрами для определения числа студентов в заданной группе, 
--      которые имеют оценку по заданной дисциплине выше средней в группе.

-- DROP PROCEDURE public.count_good_student(text, text, int);

CREATE OR REPLACE PROCEDURE public.count_good_student(IN _group text, IN  _discip int, out _count int)
	LANGUAGE plpgsql
AS $$
declare
	_avg float;
	BEGIN
	select avg(estimation) from student_discipline sd
	join student s on sd.n_credit_book = s.n_credit_book	
	where sd.n_discipline = _discip and s.n_group = _group
	into _avg;

	select count(sd.n_credit_book) from student_discipline sd
	join student s on sd.n_credit_book = s.n_credit_book	
	where sd.n_discipline = _discip and s.n_group = _group and estimation > _avg
	 into _count;	
	END;
$$

 
call public.count_good_student('14A'::text, 3, null );	
	
--7.	Для предыдущего задания создать функцию с параметрами.

CREATE OR REPLACE FUNCTION public.count_good_student_f(_group text, _discip int)
RETURNS integer
LANGUAGE plpgsql
AS $$
DECLARE
    _avg float;
    _count integer;
BEGIN
    SELECT avg(estimation) 
    FROM student_discipline sd
    JOIN student s ON sd.n_credit_book = s.n_credit_book	
    WHERE sd.n_discipline = _discip AND s.n_group = _group
    INTO _avg;

    SELECT count(sd.n_credit_book) 
    FROM student_discipline sd
    JOIN student s ON sd.n_credit_book = s.n_credit_book	
    WHERE sd.n_discipline = _discip 
      AND s.n_group = _group 
      AND estimation > _avg
    INTO _count;
    
    RETURN _count;
END;
$$;

select * from public.count_good_student_f('14A'::text, 3);

--8.	Создать процедуру, которая выводит оценки студентов по заданной дисциплине в текстовом или цифровом формате в зависимости от значения входного параметра С.
--      Использовать условный оператор.

--drop function public.student_estimation_discip(int, boolean)

CREATE OR REPLACE PROCEDURE public.student_estimation_discip(_discip int, _C boolean, inout _res refcursor)
	LANGUAGE plpgsql
AS $$
declare
	BEGIN
		if _c then
			open _res for select sd.n_credit_book, sd.estimation from student_discipline sd
			where sd.n_discipline = _discip;
		else
			open _res for select sd.n_credit_book, 
							case sd.estimation
								when 2 then 'Неудовлиторительно'
								when 3 then 'Удовлетворительно'
								when 4 then 'Хорошо'
								when 5 then 'Отлично'
							end
						 from student_discipline sd
			where sd.n_discipline = _discip;
		end if;
	END;
$$



BEGIN;
CALL public.student_estimation_discip(3, true, 'my_cursor');
FETCH ALL FROM my_cursor;
COMMIT;

BEGIN;
CALL public.student_estimation_discip(3, false, 'my_cursor');
FETCH ALL FROM my_cursor;
COMMIT;


--9.	Создать процедуру, которая изменяет регистр фамилий студентов на верхний. Использовать курсоры.

CREATE OR REPLACE PROCEDURE public.second_name_stud_to_upper()
	LANGUAGE plpgsql
AS $$
declare
	student_cur CURSOR FOR 
		    SELECT n_credit_book FROM student;
	rec int;
	BEGIN
		    OPEN student_cur;
		
		    LOOP
		        FETCH student_cur INTO rec;
		        EXIT WHEN NOT FOUND;

	            UPDATE student 
	            SET second_name = UPPER(second_name)
	            WHERE n_credit_book = rec;
		         
		    END LOOP;
	END;
$$

call public.second_name_stud_to_upper();
select * from student 

UPDATE student 
SET second_name = LOWER(second_name)


