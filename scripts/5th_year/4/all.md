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
