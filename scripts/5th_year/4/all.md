1. Просмотреть таблицу пользователей и их паролей.

```sh
tvgudb=# SELECT *  FROM pg_authid WHERE rolcanlogin = true;
 oid |  rolname   | rolsuper | rolinherit | rolcreaterole | rolcreatedb | rolcanlogin | rolreplication | rolbypassrls | rolconnlimit |                                                              rolpassword                                                              | rolvaliduntil
-----+------------+----------+------------+---------------+-------------+-------------+----------------+--------------+--------------+---------------------------------------------------------------------------------------------------------------------------------------+---------------
  10 | tvgupguser | t        | t          | t             | t           | t           | t              | t            |           -1 | SCRAM-SHA-256$4096:2Ghqr9DaCD0YX+oqu8gQiw==$lbVFMLiMKpevolOgDglN8OJplKyw16FGLo5RUU7s4+c=:GT/OIY9n+zjL4lT6Q+JwtMoJNBT5wQuJeGB7B4CLOEg= |
(1 row)
```

2. Создать пользователя Stud без пароля.

```sh
tvgudb=# CREATE USER Stud;
CREATE ROLE
tvgudb=# \du
                              List of roles
 Role name  |                         Attributes
------------+------------------------------------------------------------
 stud       |
 tvgupguser | Superuser, Create role, Create DB, Replication, Bypass RLS

tvgudb=#
```

3. Осуществить авторизацию пользователя Stud и убедиться, что он не имеет никаких привилегий.

```bash
➜  Database-management-systems-TVGU git:(5th_year_2) ✗ docker compose exec postgres psql -U stud -d tvgudb
psql (16.1)
Type "help" for help.

tvgudb=> \du
                              List of roles
 Role name  |                         Attributes
------------+------------------------------------------------------------
 stud       |
 tvgupguser | Superuser, Create role, Create DB, Replication, Bypass RLS

tvgudb=> SELECT *  FROM pg_authid WHERE rolcanlogin = true;
ERROR:  permission denied for table pg_authid
tvgudb=>
```

4. Задать пароль пользователя Stud, совпадающий с именем. Авторизоваться от его имени.

Создание пароля
```bash
tvgudb=> \password stud
Enter new password for user "stud":
Enter it again:
tvgudb=>
```
Вход под этим пользователем
```bash
➜  Database-management-systems-TVGU git:(5th_year_2) ✗ docker compose exec postgres psql -U stud -d tvgudb
psql (16.1)
Type "help" for help.

tvgudb=> ls
tvgudb->
```
5. Переименовать пользователя Stud в FirstStud с помощью оператора переименования.
```bash
tvgudb=# ALTER USER stud RENAME TO FirstStud;
ALTER ROLE
tvgudb=# \du
                              List of roles
 Role name  |                         Attributes
------------+------------------------------------------------------------
 firststud  |
 tvgupguser | Superuser, Create role, Create DB, Replication, Bypass RLS

tvgudb=#
```
6. Переименовать пользователя FirstStud в SecondStud, используя прямой доступ к таблице User

> НЕ НАШЕЛ, видимо в postgres только такой способ

7. Удалить пользователя SecondStud.
```bash
tvgudb=# \du
                              List of roles
 Role name  |                         Attributes
------------+------------------------------------------------------------
 firststud  |
 tvgupguser | Superuser, Create role, Create DB, Replication, Bypass RLS

tvgudb=# DROP USER firststud;
DROP ROLE
tvgudb=# \du
                              List of roles
 Role name  |                         Attributes
------------+------------------------------------------------------------
 tvgupguser | Superuser, Create role, Create DB, Replication, Bypass RLS

tvgudb=#
```
8.	Создать пользователей Stud1 и Stud2 с паролями, совпадающими с их именами.

    создаём пользователей
    ```bash
    tvgudb=# CREATE USER stud1 WITH PASSWORD 'stud1';
    CREATE ROLE
    tvgudb=# CREATE USER stud2 WITH PASSWORD 'stud2';
    CREATE ROLE
    ```
    проверяем, что пользователи созданы
    ```bash
    tvgudb=# \du
                                List of roles
    Role name  |                         Attributes
    ------------+------------------------------------------------------------
    stud1      |
    stud2      |
    tvgupguser | Superuser, Create role, Create DB, Replication, Bypass RLS

    tvgudb=#
    ```
9.	Наделить пользователя Stud1 привилегиями просмотра, вставки, обновления и удаления по работе с таблицей StudentPredmet. Авторизоваться от имени пользователя Stud1 и выполнить действия, на которые предоставлены привилегии.

    выдаём права stud1
    ```bash
    tvgudb=# GRANT SELECT, INSERT, UPDATE, DELETE ON student_discipline TO stud1;
    GRANT
    tvgudb=#
    ```
    авторизовываемся и выполняем действия

    SELECT
    ```bash
    tvgudb=> SELECT * FROM student_discipline;
    n_credit_book | n_discipline | estimation
    ---------------+--------------+------------
                1 |            1 |          5
                1 |            2 |          5
                1 |            3 |          3
                3 |            1 |          5
                3 |            2 |          5
    ```
    INSERT
    ```bash
    tvgudb=> INSERT INTO student_discipline (n_credit_book, n_discipline, estimation) VALUES (1, 5, 3);
    INSERT 0 1
    tvgudb=>
    ```
    UPDATE
    ```bash
    tvgudb=> UPDATE student_discipline SET estimation = 5 WHERE n_credit_book = 1 AND n_discipline = 5;
    UPDATE 1
    tvgudb=>
    ```
    DELETE
    ```bash
    tvgudb=> DELETE FROM student_discipline WHERE n_credit_book = 1 AND n_discipline = 5;
    DELETE 1
    tvgudb=>
    ```
10.	Отозвать у пользователя Stud1 две последние привилегии. Авторизоваться от имени пользователя Stud1, выполнить действия, на которые предоставлены привилегии, и проверить, что действия по отозванным привилегиям не выполняются.

    переключаемся обратно на суперпользователя и отзываем права stud1
    ```bash
    tvgudb=> \c tvgudb tvgupguser
    You are now connected to database "tvgudb" as user "tvgupguser".
    tvgudb=# REVOKE UPDATE, DELETE ON student_discipline FROM stud1;
    REVOKE
    tvgudb=#
    ```
    проверяем

    SELECT
    ```bash
    tvgudb=# \c tvgudb  stud1
    You are now connected to database "tvgudb" as user "stud1".
    tvgudb=> SELECT * FROM student_discipline;
    n_credit_book | n_discipline | estimation
    ---------------+--------------+------------
                1 |            1 |          5
                1 |            2 |          5
                1 |            3 |          3
                3 |            1 |          5
    ```
    INSERT
    ```bash
    tvgudb=> INSERT INTO student_discipline (n_credit_book, n_discipline, estimation) VALUES (1, 5, 3);
    INSERT 0 1
    tvgudb=>
    ```
    UPDATE
    ```bash
    tvgudb=> UPDATE student_discipline SET estimation = 5 WHERE n_credit_book = 1 AND n_discipline = 5;
    ERROR:  permission denied for table student_discipline
    tvgudb=>
    ```
    DELETE
    ```bash
    tvgudb=> DELETE FROM student_discipline WHERE n_credit_book = 1 AND n_discipline = 5;
    ERROR:  permission denied for table student_discipline
    tvgudb=>
    ```
11.	Наделить пользователя Stud2 привилегиями просмотра таблицы Student с возможностью передачи этой привилегии другому пользователю.

    выдаём права stud2
    ```bash
    tvgudb=# GRANT SELECT ON student TO stud2 WITH GRANT OPTION;
    GRANT
    tvgudb=#
    ```
12.	Осуществить авторизацию пользователя Stud2 и наделить от его имени пользователя Stud1 привилегией просмотра таблицы Student. Авторизоваться от имени пользователя Stud1 и выполнить действия, на которые предоставлены привилегии.

    авторизовываемся как stud2 выдаём права stud1
    ```bash
    tvgudb=# \c tvgudb stud2
    You are now connected to database "tvgudb" as user "stud2".
    tvgudb=> GRANT SELECT ON student TO stud1;
    GRANT
    tvgudb=>
    ```
    авторизовываемся как stud1 и проверяем
    ```bash
    tvgudb=> \c tvgudb stud1
    You are now connected to database "tvgudb" as user "stud1".
    tvgudb=> SELECT * FROM student;
    n_credit_book | second_name |   name    |  patronymic   | n_group |  telephone
    ---------------+-------------+-----------+---------------+---------+-------------
                1 | Иванов      | Алексей   | Сергеевич     | 11A     | 89005553322
                3 | Сидоров     | Николай   | Игоревич      | 12B     |
                4 | Федоров     | Антон     | Викторович    | 12B     | 89009876543
                6 | Смирнов     | Владимир  | Николаевич    | 13C     |
                7 | Васильев    | Артем     | Дмитриевич    | 14A     | 89003456789
                8 | Морозов     | Сергей    | Александрович | 14A     | 89005678901
                9 | Новиков     | Михаил    | Романович     | 15D     | 89007775544
    ```
13.	Предоставить пользователю Stud1 привилегии просмотра столбца с названиями предметов в таблице Predmet, создание представления и создание хранимой процедуры. Авторизоваться от имени пользователя Stud1 и выполнить действия, на которые предоставлены привилегии. Прокомментировать, как действуют привилегии на создание представлений и создание хранимой процедуры (какие операторы могут быть записаны в представлении и процедуре; может ли пользователь, создавший представление и процедуру их выполнить).

    выдаём права stud1
    ```bash
    tvgudb=# GRANT SELECT (title_discipline) ON discipline TO stud1;
    GRANT
    tvgudb=# GRANT CREATE ON SCHEMA public  TO stud1;
    GRANT
    tvgudb=#
    ```
    проверяем

    SELECT
    ```bash
    tvgudb=# \c tvgudb stud1
    You are now connected to database "tvgudb" as user "stud1".
    tvgudb=> SELECT * FROM discipline;
    ERROR:  permission denied for table discipline
    tvgudb=>
    ```
    ```bash
    tvgudb=> SELECT title_discipline FROM discipline;
    title_discipline
    ------------------
    Математика
    Физика
    Химия
    Биология
    Литература
    История
    География
    Информатика
    Математика
    Математика
    Английский
    Информатика
    Математика
    Английский
    Английский
    Математика
    Новая дисциплина
    (17 rows)

    tvgudb=>
    ```

    VIEW
    создаем VIEW
    ```bash
    tvgudb=> CREATE VIEW v_titles AS
    tvgudb-> SELECT title_discipline FROM discipline;
    CREATE VIEW
    tvgudb=>
    ```
    вызываем SELECT на этот VIEW
    ```bash
    tvgudb=> SELECT * FROM v_titles;
    title_discipline
    ------------------
    Математика
    Физика
    Химия
    Биология
    Литература
    История
    География
    Информатика
    Математика
    Математика
    Английский
    Информатика
    Математика
    Английский
    Английский
    Математика
    Новая дисциплина
    (17 rows)

    tvgudb=>
    ```
    PROCEDURE
    создаем PROCEDURE
    ```bash
    tvgudb=> CREATE OR REPLACE PROCEDURE count_titles()
    tvgudb-> LANGUAGE plpgsql
    tvgudb-> AS $$
    tvgudb$> DECLARE
    tvgudb$>     cnt INT;
    tvgudb$> BEGIN
    tvgudb$>     SELECT COUNT(title_discipline) INTO cnt
    tvgudb$>     FROM discipline;
    tvgudb$>
    tvgudb$>     RAISE NOTICE 'Количество дисциплин: %', cnt;
    tvgudb$> END;
    tvgudb$> $$;
    CREATE PROCEDURE
    tvgudb=>
    ```
    вызываем
    ```bash
    tvgudb=> CALL count_titles();
    NOTICE:  Количество дисциплин: 17
    CALL
    tvgudb=>
    ```
    создаём PROCEDURE
    ```bash
    tvgudb=> CREATE OR REPLACE PROCEDURE count_teachers()
    tvgudb-> LANGUAGE plpgsql
    tvgudb-> AS $$
    tvgudb$> DECLARE
    tvgudb$>     cnt INT;
    tvgudb$> BEGIN
    tvgudb$>     SELECT COUNT(second_name_teacher) INTO cnt
    tvgudb$>     FROM discipline;
    tvgudb$>     RAISE NOTICE 'Количество преподавателей: %', cnt;
    tvgudb$> END;
    tvgudb$> $$;
    CREATE PROCEDURE
    tvgudb=>
    ```
    вызываем
    ```bash
    tvgudb=> CALL count_teachers();
    ERROR:  permission denied for table discipline
    CONTEXT:  SQL statement "SELECT COUNT(second_name_teacher)              FROM discipline"
    PL/pgSQL function count_teachers() line 5 at SQL statement
    tvgudb=>
    ```
14.	Создать пользователя Superuser и предоставить ему все привилегии.
    создадим пользователя superuser и выдадим ему все права
    ```bash
    tvgudb=> \c tvgudb tvgupguser
    You are now connected to database "tvgudb" as user "tvgupguser".
    tvgudb=# CREATE USER superuser WITH PASSWORD 'superuser' SUPERUSER;
    CREATE ROLE
    tvgudb=#
    ```
    проверим
    ```bash
    tvgudb=# \du
                                List of roles
    Role name  |                         Attributes
    ------------+------------------------------------------------------------
    stud1      |
    stud2      |
    superuser  | Superuser
    tvgupguser | Superuser, Create role, Create DB, Replication, Bypass RLS

    tvgudb=#
    ```
15.	От имени пользователя Superuser наделить пользователя Stud1 привилегией работы с файлами.
    ```
    tvgudb=# \c tvgudb superuser
    You are now connected to database "tvgudb" as user "superuser".
    tvgudb=# GRANT pg_read_server_files TO stud1;
    GRANT ROLE
    tvgudb=# GRANT pg_write_server_files TO stud1;
    GRANT ROLE
    ```

16.	Авторизоваться от имени пользователя Stud1 и выполнить действия, на которые предоставлены привилегии: записать данные из таблицы Student в файл Student.txt. Какая дополнительная привилегия требуется для выполнения операции.
    Дополнительно потребовалось разрешить запись файлов в операционной системе
    ```
    /app # chmod 755 files/
    ```
    Проверка
    ```
    tvgudb=> copy student to '/app/files/student.csv' with csv;
    COPY 35
    ```

17.	От имени пользователя Superuser создать таблицу Student1 - копию таблицы Student и предоставить пользователю Stud1 привилегию записи в таблицу Student1.
    ```
    tvgudb=> \c tvgudb superuser
    You are now connected to database "tvgudb" as user "superuser".
    tvgudb=# CREATE TABLE student1 AS
    tvgudb-# SELECT * FROM student
    tvgudb-# WHERE false;
    SELECT 0
    tvgudb=# GRANT INSERT, SELECT ON TABLE student1 TO stud1;
    GRANT
    ```
18.	Авторизоваться от имени пользователя Stud1 и выполнить действия, на которые предоставлены привилегии: загрузить в таблицу Student1 данные из файла Student.txt.
    ```
    tvgudb=> copy student1 from '/app/files/student.csv' with csv;
    COPY 35
    tvgudb=> select * from student1;
     n_credit_book | second_name |   name    |  patronymic   | n_group |  telephone
    ---------------+-------------+-----------+---------------+---------+-------------
                38 | ПЕТРОВ      | Иван      | Алексеевич    | 11A     | 89001234567
                 3 | СИДОРОВ     | Николай   | Игоревич      | 12B     |
                 4 | ФЕДОРОВ     | Антон     | Викторович    | 12B     | 89009876543
                 6 | СМИРНОВ     | Владимир  | Николаевич    | 13C     |
                 7 | ВАСИЛЬЕВ    | Артем     | Дмитриевич    | 14A     | 89003456789
                 8 | МОРОЗОВ     | Сергей    | Александрович | 14A     | 89005678901
                 9 | НОВИКОВ     | Михаил    | Романович     | 15D     | 89007775544
                10 | ПОПОВ       | Александр | Иванович      | 15D     |
    ...
    ```


19.	Показать привилегии всех пользователей.

    ```
    tvgudb=# SELECT
    tvgudb-#     rolname as username,
    tvgudb-#     rolsuper as is_superuser,
    tvgudb-#     rolcreatedb as can_create_db,
    tvgudb-#     rolcreaterole as can_create_roles,
    tvgudb-#     rolreplication as can_replicate,
    tvgudb-#     rolbypassrls as bypass_rls,
    tvgudb-#     CASE
    tvgudb-#         WHEN pg_has_role(oid, 'pg_read_server_files', 'USAGE') THEN 'YES'
    tvgudb-#         ELSE 'NO'
    tvgudb-#     END as can_read_server_files,
    tvgudb-#     CASE
    tvgudb-#         WHEN pg_has_role(oid, 'pg_write_server_files', 'USAGE') THEN 'YES'
    tvgudb-#         ELSE 'NO'
    tvgudb-#     END as can_write_server_files
    tvgudb-# FROM pg_roles
    tvgudb-# WHERE rolname NOT LIKE 'pg_%'
    tvgudb-# ORDER BY rolname;
      username  | is_superuser | can_create_db | can_create_roles | can_replicate | bypass_rls | can_read_server_files | can_write_server_files
    ------------+--------------+---------------+------------------+---------------+------------+-----------------------+------------------------
     stud1      | f            | f             | f                | f             | f          | YES                   | YES
     stud2      | f            | f             | f                | f             | f          | NO                    | NO
     superuser  | t            | f             | f                | f             | f          | YES                   | YES
     tvgupguser | t            | t             | t                | t             | t          | YES                   | YES
    (4 rows)
    ```
20.	Отозвать все привилегии у пользователей Stud1 и Stud2 и Superuser. Проверить, что привилегии не действуют.

    ```
    tvgudb=# revoke  all on all tables in schema public from stud1, stud2, superuser cascade;
    REVOKE
    tvgudb=# REVOKE ALL ON All PROCEDURES IN SCHEMA public FROM stud1, stud2, superuser;
    REVOKE
    tvgudb=# REVOKE ALL ON All functions IN SCHEMA public FROM stud1, stud2, superuser;
    REVOKE
    tvgudb=# revoke all ON schema public FROM stud1, stud2, superuser;
    REVOKE
    tvgudb=# REASSIGN OWNED BY Stud1, Stud2, superuser TO tvgupguser;
    REASSIGN OWNED
    tvgudb=# ALTER USER superuser  NOSUPERUSER;
    ALTER ROLE
    tvgudb=# REVOKE pg_read_server_files FROM Stud1;
    REVOKE ROLE
    tvgudb=# REVOKE pg_write_server_files FROM Stud1;
    REVOKE ROLE

    ```

    Проверяем
    ```
    tvgudb=# SELECT
        rolname as username,
        rolsuper as is_superuser,
        rolcreatedb as can_create_db,
        rolcreaterole as can_create_roles,
        rolreplication as can_replicate,
        rolbypassrls as bypass_rls,
        -- Файловые привилегии (PostgreSQL 14+)
        CASE
            WHEN pg_has_role(oid, 'pg_read_server_files', 'USAGE') THEN 'YES'
            ELSE 'NO'
        END as can_read_server_files,
        CASE
            WHEN pg_has_role(oid, 'pg_write_server_files', 'USAGE') THEN 'YES'
            ELSE 'NO'
        END as can_write_server_files
    FROM pg_roles
    WHERE rolname NOT LIKE 'pg_%'
    ORDER BY rolname;
      username  | is_superuser | can_create_db | can_create_roles | can_replicate | bypass_rls | can_read_server_files | can_write_server_files
    ------------+--------------+---------------+------------------+---------------+------------+-----------------------+------------------------
     stud1      | f            | f             | f                | f             | f          | NO                    | NO
     stud2      | f            | f             | f                | f             | f          | NO                    | NO
     superuser  | f            | f             | f                | f             | f          | NO                    | NO
     tvgupguser | t            | t             | t                | t             | t          | YES                   | YES
    (4 rows)

    tvgudb=# \c tvgudb stud1
    You are now connected to database "tvgudb" as user "stud1".
    tvgudb=> copy student1 from '/app/files/student.csv' with csv;
    ERROR:  permission denied to COPY from a file
    DETAIL:  Only roles with privileges of the "pg_read_server_files" role may COPY from a file.
    HINT:  Anyone can COPY to stdout or from stdin. psql's \copy command also works for anyone.

    tvgudb=> \c tvgudb superuser
    You are now connected to database "tvgudb" as user "superuser".
    tvgudb=> select * from student;
    ERROR:  permission denied for table student
    tvgudb=> drop table student;
    ERROR:  must be owner of table student

    tvgudb=> \c tvgudb stud2
    You are now connected to database "tvgudb" as user "stud2".
    tvgudb=> select * from discipline;
    ERROR:  permission denied for table discipline

    ```

21.	Удалить пользователей Stud1, Stud2 и Superuser.

    ```
    tvgudb=# drop user stud1, stud2, superuser;
    DROP ROLE

    tvgudb=# \du
                                  List of roles
     Role name  |                         Attributes
    ------------+------------------------------------------------------------
     tvgupguser | Superuser, Create role, Create DB, Replication, Bypass RLS
    ```
