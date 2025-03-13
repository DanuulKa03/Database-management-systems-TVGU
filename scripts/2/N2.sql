-- СУБД
-- Задание № 2 SQL (order by, natural join, group by, агрегатные функции, вложенные запросы)

--     1.  Вывести список студентов, в фамилии которых вторая буква  «а», а последняя «я».
		SELECT * FROM student WHERE second_name LIKE '_о%в'
		
--     2.  Вывести список студентов, в фамилии которых имеется сочетание «мир».
		SELECT * FROM student WHERE LOWER(second_name) LIKE '%мир%'
		
--     3.  Вывести список студентов первого курса.
		SELECT * FROM student WHERE n_group LIKE '1%'
		
--     4.  Вывести рейтинг студентов по каждому предмету (рейтинг рассчитывается: оценка * 10). Результат должен быть выведен в виде: №зачетки, название предмета, рейтинг.
		SELECT 
			n_credit_book AS "№зачетки", 
			d.title_discipline AS "название предмета", 
			(estimation * 10) AS "рейтинг"
		FROM student_discipline sd
		JOIN discipline d ON sd.n_discipline = d.n_discipline
		--то же самое но с использованием NATURAL JOIN	
		SELECT 
			n_credit_book AS "№зачетки", 
			d.title_discipline AS "название предмета", 
			(estimation * 10) AS "рейтинг"
		FROM student_discipline sd
		NATURAL JOIN discipline d
				
--     5.  Вывести рейтинг студентов по каждому предмету (рейтинг рассчитывается: оценка * 10). Результат должен быть выведен в виде: №зачетки, Фамилия, Имя, Отчество, название предмета, рейтинг.
		SELECT 
			sd.n_credit_book AS "№зачетки", 
			s.second_name AS "Фамилия", 
			s.name AS "Имя", 
			s.patronymic AS "Отчество", 
			d.title_discipline AS "название предмета", 
			(estimation * 10) AS "рейтинг"
		FROM student_discipline sd
		JOIN student s ON s.n_credit_book = sd.n_credit_book
		JOIN discipline d ON sd.n_discipline = d.n_discipline
		--то же самое но с использованием NATURAL JOIN
		SELECT 
			sd.n_credit_book AS "№зачетки", 
			s.second_name AS "Фамилия", 
			s.name AS "Имя", 
			s.patronymic AS "Отчество", 
			d.title_discipline AS "название предмета", 
			(estimation * 10) AS "рейтинг"
		FROM student_discipline sd
		NATURAL JOIN student s
		NATURAL JOIN discipline d 
		
--     6.  Получить список студентов 11 группы в алфавитном порядке.
		SELECT * FROM student 
		WHERE n_group LIKE '11%' 
		ORDER BY second_name ASC
		
--     7.  Упорядочить вывод 4 запроса по дисциплинам и по баллам.
		SELECT 
			n_credit_book AS "№зачетки", 
			d.title_discipline AS "название предмета", 
			(estimation * 10) AS "рейтинг"
		FROM student_discipline sd
		JOIN discipline d ON sd.n_discipline = d.n_discipline
		ORDER BY d.title_discipline, estimation DESC --можно BY 2, 3
		
--     8.  Вывести наивысший и наименьший баллы, полученные студентами по английскому языку.
		SELECT 
			MAX(estimation) AS "наивысший балл", 
			MIN(estimation) AS "наименьший балл"
		FROM student_discipline
		WHERE n_discipline = 3
		---------------------------------------
		SELECT 
			MAX(estimation) AS "наивысший балл", 
			MIN(estimation) AS "наименьший балл"
		FROM student_discipline
		WHERE n_discipline IN (SELECT n_discipline FROM discipline WHERE title_discipline = 'Английский язык')

--     9.  Вывести количество оценок 5, полученных студентами по английскому языку.
		SELECT COUNT(*) AS "количество оценок 5" 
		FROM student_discipline 
		WHERE n_discipline = 3 AND estimation = 5
		---------------------------------------
		SELECT COUNT(*) AS "количество оценок 5"
		FROM student_discipline
		WHERE n_discipline IN (SELECT n_discipline FROM discipline WHERE title_discipline = 'Английский язык') AND estimation = 5;

--     10.  Получить среднее значение оценок по английскому языку в каждой группе.
		SELECT 
			n_group AS "группа", 
			ROUND(AVG(sd.estimation), 2) AS "среднее значение"
		FROM student s
		NATURAL JOIN student_discipline sd
		WHERE n_discipline IN (SELECT n_discipline FROM discipline WHERE title_discipline = 'Английский язык')
		GROUP BY n_group
		ORDER BY n_group
		
--     11.  Вывести количество оценок, полученных каждым студентом (предложение Group by).
		SELECT 
			s.n_credit_book AS "№зачетки", 
			second_name AS "Фамилия", 
			name AS "Имя", 
			patronymic AS "Отчество", 
			COUNT(sd.estimation) AS "количество оценок"
		FROM student s
		JOIN student_discipline sd ON s.n_credit_book = sd.n_credit_book
		GROUP BY s.n_credit_book
		ORDER BY s.n_credit_book
		
--     12.  Вывести список студентов со средними оценками, полученными каждым за сессию (не использовать Avg).
		SELECT 
			s.n_credit_book AS "№зачетки", 
			second_name AS "Фамилия", 
			s.name AS "Имя", 
			patronymic AS "Отчество", 
			ROUND(SUM(sd.estimation::NUMERIC) / COUNT(sd.estimation::NUMERIC), 2) AS "средняя оценка"
		FROM student s
		JOIN student_discipline sd ON s.n_credit_book = sd.n_credit_book
		GROUP BY s.n_credit_book
		ORDER BY s.n_credit_book
		
--     13.   Вывести для каждого названия_предмета средний балл и количество оценок, полученных на экзамене. 
		SELECT 
			d.title_discipline AS "название предмета", 
			ROUND(AVG(sd.estimation), 2) AS "средний балл", 
			COUNT(sd.estimation) AS "количество оценок"
		FROM discipline d
		NATURAL JOIN student_discipline sd
		GROUP BY d.n_discipline
		ORDER BY d.n_discipline
		
--     14.  Вывести количество оценок «2», «3», «4», «5», полученных по каждому предмету тремя способами:
-- в виде таблицы (Название_предмета, Оценка, Количество) – один способ;
		SELECT
			d.title_discipline AS "название предмета", 
			sd.estimation AS "оценка", 
			COUNT(sd.estimation) AS "количество оценок"
		FROM discipline d
		NATURAL JOIN student_discipline sd
		GROUP BY d.title_discipline, estimation
		ORDER BY d.title_discipline, estimation DESC
		----------
		SELECT 
    		d.title_discipline AS "название предмета", 
    		e.estimation AS "оценка", 
    		COUNT(sd.estimation) AS "количество оценок"
		FROM discipline d
		CROSS JOIN (SELECT 2 AS estimation UNION ALL SELECT 3 UNION ALL SELECT 4 UNION ALL SELECT 5) e
		LEFT JOIN student_discipline sd ON d.n_discipline = sd.n_discipline AND sd.estimation = e.estimation
		GROUP BY d.title_discipline, e.estimation
		ORDER BY d.title_discipline, e.estimation DESC
-- в виде таблицы (Название_предмета, Количество «2», Количество «3», Количество «4», Количество «5») – двумя способами.
---------------1-способ-----------
		SELECT 
		    d.title_discipline AS "Название предмета",
		    COUNT(CASE WHEN sd.estimation = 2 THEN 1 END) AS "Количество «2»",
		    COUNT(CASE WHEN sd.estimation = 3 THEN 1 END) AS "Количество «3»",
		    COUNT(CASE WHEN sd.estimation = 4 THEN 1 END) AS "Количество «4»",
		    COUNT(CASE WHEN sd.estimation = 5 THEN 1 END) AS "Количество «5»"
		FROM discipline d
		LEFT JOIN student_discipline sd ON d.n_discipline = sd.n_discipline
		GROUP BY d.title_discipline
		ORDER BY d.title_discipline
---------------2-способ-----------
		SELECT 
		    d.title_discipline AS "Название предмета",
		    SUM(CASE WHEN sd.estimation = 2 THEN 1 ELSE 0 END) AS "Количество «2»",
		    SUM(CASE WHEN sd.estimation = 3 THEN 1 ELSE 0 END) AS "Количество «3»",
		    SUM(CASE WHEN sd.estimation = 4 THEN 1 ELSE 0 END) AS "Количество «4»",
		    SUM(CASE WHEN sd.estimation = 5 THEN 1 ELSE 0 END) AS "Количество «5»"
		FROM discipline d
		LEFT JOIN student_discipline sd ON d.n_discipline = sd.n_discipline
		GROUP BY d.title_discipline
		ORDER BY d.title_discipline
		
--     15.  Вывести количество студентов в каждой группе.
		SELECT 
			n_group AS "группа", 
			COUNT(n_credit_book) AS "студентов в группе"
		FROM student
		GROUP BY n_group
		ORDER BY n_group
		
--     16.  Вывести количество «2», «3», «4», «5», полученных каждым студентом на экзамене тремя способами (см. запрос 14).
---------------1-способ-----------
		SELECT 
    		s.n_credit_book AS "№ зачетки",
    		s.second_name AS "Фамилия",
    		s.name AS "Имя",
    		s.patronymic AS "Отчество",
    		e.estimation AS "Оценка",
    		COUNT(sd.estimation) AS "Количество оценок"
		FROM student s
		CROSS JOIN (SELECT 2 AS estimation UNION ALL SELECT 3 UNION ALL SELECT 4 UNION ALL SELECT 5) e
		LEFT JOIN student_discipline sd ON s.n_credit_book = sd.n_credit_book AND sd.estimation = e.estimation
		GROUP BY s.n_credit_book, s.second_name, s.name, s.patronymic, e.estimation
		ORDER BY s.n_credit_book, e.estimation DESC
---------------2-способ-----------
		SELECT 
		    s.n_credit_book AS "№ зачетки",
		    s.second_name AS "Фамилия",
		    s.name AS "Имя",
		    s.patronymic AS "Отчество",
		   	COUNT(CASE WHEN sd.estimation = 2 THEN 1 END) AS "Количество «2»",
			COUNT(CASE WHEN sd.estimation = 3 THEN 1 END) AS "Количество «3»",
			COUNT(CASE WHEN sd.estimation = 4 THEN 1 END) AS "Количество «4»",
			COUNT(CASE WHEN sd.estimation = 5 THEN 1 END) AS "Количество «5»"
		FROM student s
		LEFT JOIN student_discipline sd ON s.n_credit_book = sd.n_credit_book
		GROUP BY s.n_credit_book, s.second_name, s.name, s.patronymic
		ORDER BY s.n_credit_book
---------------3-способ-----------
	SELECT 
	    s.n_credit_book AS "№ зачетки",
	    s.second_name AS "Фамилия",
	    s.name AS "Имя",
	    s.patronymic AS "Отчество",
	    SUM(CASE WHEN sd.estimation = 2 THEN 1 ELSE 0 END) AS "Количество «2»",
		SUM(CASE WHEN sd.estimation = 3 THEN 1 ELSE 0 END) AS "Количество «3»",
		SUM(CASE WHEN sd.estimation = 4 THEN 1 ELSE 0 END) AS "Количество «4»",
		SUM(CASE WHEN sd.estimation = 5 THEN 1 ELSE 0 END) AS "Количество «5»"
	FROM student s
	LEFT JOIN student_discipline sd ON s.n_credit_book = sd.n_credit_book
	GROUP BY s.n_credit_book, s.second_name, s.name, s.patronymic
	ORDER BY s.n_credit_book;
	
--     17.  Вывести количество студентов в каждой группе, которые имеют телефон.
		SELECT 
			n_group AS "группа", 
			COUNT(telephone) AS "студентов c телефоном"
		FROM student
		--WHERE telephone IS NOT NULL
		GROUP BY n_group
		ORDER BY n_group
		
--     18.  Вывести количество студентов в каждой малочисленной группе (<5 студентов).
		SELECT 
			n_group AS "группа", 
			COUNT(n_credit_book) AS "студентов в группе"
		FROM student
		GROUP BY n_group
		HAVING COUNT(n_credit_book) < 3
		ORDER BY n_group
		
--     19.  Вывести средний показатель успеваемости групп по предмету. Результат представить в виде таблицы: (N_группы, Название_предмета, средний показатель успеваемости).
		SELECT
			n_group AS "N_группы",
			d.title_discipline AS "Название_предмета",
			ROUND(AVG(sd.estimation), 2) AS "средний показатель успеваемости"
		FROM student s 
		NATURAL JOIN student_discipline sd 
		NATURAL JOIN discipline d
		GROUP BY n_group, d.title_discipline
		ORDER BY n_group, d.title_discipline
--     20.  Вывести сведения обо всех студентах, получивших самый высокий балл на экзамене по английскому языку (то есть самый высокий из тех баллов, что получили студенты, сдававшие английский).
		SELECT 
			sd.n_credit_book AS "№зачетки", 
			s.second_name AS "Фамилия", 
			s.name AS "Имя", 
			s.patronymic AS "Отчество", 
			estimation AS "оценка"
		FROM student_discipline sd
		NATURAL JOIN student s
		NATURAL JOIN discipline d
		WHERE d.title_discipline LIKE 'Английский язык' 
		AND sd.estimation = (	
			SELECT 
				MAX(estimation) 
			FROM student_discipline 
			NATURAL JOIN discipline d
			WHERE d.title_discipline = 'Английский язык'
			)
		






-------