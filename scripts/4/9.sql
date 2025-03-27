-- 9. Вывести список студентов из группы, в которой учится Иванов.
-- Написать 3 запроса, один из них – с пользованием предиката Exists).

SELECT second_name, name, patronymic FROM student
WHERE n_group IN (
    SELECT n_group FROM student
    WHERE second_name = 'Лебедев'
);

SELECT second_name, name, patronymic FROM student as ST
WHERE EXISTS(
    SELECT 1 FROM student as ST_1
    WHERE second_name = 'Лебедев' AND ST_1.n_group = ST.n_group
);

SELECT ST.second_name, ST.name, ST.patronymic
FROM student AS ST
JOIN student AS ST_1 ON ST.n_group = ST_1.n_group
WHERE ST_1.second_name = 'Лебедев';
