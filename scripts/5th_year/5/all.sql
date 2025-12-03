-- =====================================================================
-- ОПЗБД — Ролевая модель доступа для БД "Сессия"
-- Единый скрипт для пунктов 1–16
-- =====================================================================

-- ---------------------------------------------------------------------
-- 1. Копия таблицы "Предмет" (discipline) и расширение атрибутов
-- ---------------------------------------------------------------------

DROP TABLE IF EXISTS discipline_plus;
CREATE TABLE IF NOT EXISTS discipline_plus AS SELECT * FROM discipline;

SELECT * FROM discipline_plus
ORDER BY n_discipline;

ALTER TABLE discipline_plus
    ADD is_cur_session bool DEFAULT false;

-- DROP TYPE type_rep; -- при необходимости
CREATE TYPE type_rep AS ENUM('exam', 'test');

ALTER TABLE discipline_plus
    ADD reporting type_rep;

ALTER TABLE discipline_plus
    ADD course integer;

UPDATE discipline_plus dp
SET is_cur_session = true
WHERE dp.n_discipline IN (1, 4, 6, 7, 9, 11, 13, 15);

UPDATE discipline_plus dp
SET reporting = 'test'
WHERE dp.n_discipline IN (1, 6, 9, 11, 15);

UPDATE discipline_plus dp
SET reporting = 'exam'
WHERE dp.n_discipline IN (4, 7, 13);

UPDATE discipline_plus dp
SET course = (
    SELECT LEFT(s.n_group, 1)::INTEGER
FROM student_discipline sd
    JOIN student s ON sd.n_credit_book = s.n_credit_book
WHERE dp.n_discipline = sd.n_discipline
    LIMIT 1
    )
WHERE dp.is_cur_session;

-- ---------------------------------------------------------------------
-- 2. Создание ролей
-- ---------------------------------------------------------------------

CREATE ROLE administrator;
CREATE ROLE dean;
CREATE ROLE deputy_dean;
CREATE ROLE methodologist;
CREATE ROLE teacher;
CREATE ROLE curator_1_course;
CREATE ROLE curator_2_course;
CREATE ROLE curator_3_course;
CREATE ROLE curator_4_course;
CREATE ROLE curator_5_course;
CREATE ROLE curator_6_course;

-- ---------------------------------------------------------------------
-- 3. Привилегии ролей и процедура current_session()
-- ---------------------------------------------------------------------

-- Администратор — все операции для всех таблиц + права на схему
GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA public TO administrator;
GRANT CREATE ON SCHEMA public TO administrator;

-- Технический пользователь-администратор
CREATE USER firstadmin;
ALTER USER firstadmin WITH PASSWORD '12345678';
GRANT administrator TO firstadmin;

-- Процедура, выводящая предметы текущей сессии
CREATE OR REPLACE PROCEDURE current_session()
LANGUAGE plpgsql
AS $$
DECLARE
rec RECORD;
BEGIN
FOR rec IN
SELECT *
FROM discipline_plus dp
WHERE dp.is_cur_session
    LOOP
        RAISE NOTICE 'Предмет: % | Преподаватель: % | Отчётность: %',
            rec.title_discipline, rec.second_name_teacher, rec.reporting;
END LOOP;

    IF NOT FOUND THEN
        RAISE NOTICE 'Нет предметов в текущей сессии.';
END IF;
END;
$$;

CALL current_session();

-- Декан — SELECT из всех таблиц + выполнение процедуры
GRANT SELECT ON ALL TABLES IN SCHEMA public TO dean;
GRANT USAGE  ON SCHEMA public TO dean;

-- Замдекана — SELECT из student и student_discipline; ALL на discipline
GRANT SELECT ON student, student_discipline TO deputy_dean;
GRANT USAGE  ON SCHEMA public TO deputy_dean;

-- Методист — ALL на student и student_discipline; SELECT по discipline только для текущей сессии (через политику)
GRANT ALL PRIVILEGES ON student, student_discipline TO methodologist;

CREATE POLICY select_current_session_only
ON discipline FOR SELECT TO methodologist
                                                                                   USING (n_discipline IN (
                                                                                   SELECT n_discipline
                                                                                   FROM discipline_plus
                                                                                   WHERE is_cur_session
                                                                                   ));

GRANT USAGE ON SCHEMA public TO methodologist;

-- Преподаватель — SELECT из discipline
GRANT SELECT ON discipline TO teacher;
GRANT USAGE  ON SCHEMA public TO teacher;

-- Кураторы курса — RLS-политики и доступ
CREATE OR REPLACE FUNCTION get_student_ids_by_course(p_course INT)
RETURNS SETOF INT
LANGUAGE sql
AS $$
SELECT n_credit_book
FROM student s
WHERE LEFT(s.n_group, 1)::INTEGER = p_course;
$$;

-- Куратор 1 курса
CREATE POLICY select_course_info_student_1 ON student
FOR SELECT TO curator_1_course
               USING (n_credit_book IN (SELECT * FROM get_student_ids_by_course(1)));

CREATE POLICY select_course_info_student_discipline_1 ON student_discipline
FOR SELECT TO curator_1_course
               USING (n_credit_book IN (SELECT * FROM get_student_ids_by_course(1)));

CREATE POLICY select_course_info_discipline_1 ON student_discipline
FOR SELECT TO curator_1_course
               USING (n_discipline IN (
               SELECT n_discipline
               FROM discipline_plus
               WHERE course = 1
               ));

GRANT USAGE ON SCHEMA public TO curator_1_course;

-- Куратор 2 курса
CREATE POLICY select_course_info_student_2 ON student
FOR SELECT TO curator_2_course
                                     USING (n_credit_book IN (SELECT * FROM get_student_ids_by_course(2)));

CREATE POLICY select_course_info_student_discipline_2 ON student_discipline
FOR SELECT TO curator_2_course
               USING (n_credit_book IN (SELECT * FROM get_student_ids_by_course(2)));

CREATE POLICY select_course_info_discipline_2 ON student_discipline
FOR SELECT TO curator_2_course
               USING (n_discipline IN (
               SELECT n_discipline
               FROM discipline_plus
               WHERE course = 2
               ));

GRANT USAGE ON SCHEMA public TO curator_2_course;

-- Куратор 3 курса
CREATE POLICY select_course_info_student_3 ON student
FOR SELECT TO curator_3_course
                                     USING (n_credit_book IN (SELECT * FROM get_student_ids_by_course(3)));

CREATE POLICY select_course_info_student_discipline_3 ON student_discipline
FOR SELECT TO curator_3_course
               USING (n_credit_book IN (SELECT * FROM get_student_ids_by_course(3)));

CREATE POLICY select_course_info_discipline_3 ON student_discipline
FOR SELECT TO curator_3_course
               USING (n_discipline IN (
               SELECT n_discipline
               FROM discipline_plus
               WHERE course = 3
               ));

GRANT USAGE ON SCHEMA public TO curator_3_course;

-- Куратор 4 курса
CREATE POLICY select_course_info_student_4 ON student
FOR SELECT TO curator_4_course
                                     USING (n_credit_book IN (SELECT * FROM get_student_ids_by_course(4)));

CREATE POLICY select_course_info_student_discipline_4 ON student_discipline
FOR SELECT TO curator_4_course
               USING (n_credit_book IN (SELECT * FROM get_student_ids_by_course(4)));

CREATE POLICY select_course_info_discipline_4 ON student_discipline
FOR SELECT TO curator_4_course
               USING (n_discipline IN (
               SELECT n_discipline
               FROM discipline_plus
               WHERE course = 4
               ));

GRANT USAGE ON SCHEMA public TO curator_4_course;

-- Куратор 5 курса
CREATE POLICY select_course_info_student_5 ON student
FOR SELECT TO curator_5_course
                                     USING (n_credit_book IN (SELECT * FROM get_student_ids_by_course(5)));

CREATE POLICY select_course_info_student_discipline_5 ON student_discipline
FOR SELECT TO curator_5_course
               USING (n_credit_book IN (SELECT * FROM get_student_ids_by_course(5)));

CREATE POLICY select_course_info_discipline_5 ON student_discipline
FOR SELECT TO curator_5_course
               USING (n_discipline IN (
               SELECT n_discipline
               FROM discipline_plus
               WHERE course = 5
               ));

GRANT USAGE ON SCHEMA public TO curator_5_course;

-- Куратор 6 курса
CREATE POLICY select_course_info_student_6 ON student
FOR SELECT TO curator_6_course
                                     USING (n_credit_book IN (SELECT * FROM get_student_ids_by_course(6)));

CREATE POLICY select_course_info_student_discipline_6 ON student_discipline
FOR SELECT TO curator_6_course
               USING (n_credit_book IN (SELECT * FROM get_student_ids_by_course(6)));

CREATE POLICY select_course_info_discipline_6 ON student_discipline
FOR SELECT TO curator_6_course
               USING (n_discipline IN (
               SELECT n_discipline
               FROM discipline_plus
               WHERE course = 6
               ));

GRANT USAGE ON SCHEMA public TO curator_6_course;

-- ---------------------------------------------------------------------
-- 6. Иерархия ролей: выдача ролей нижнего уровня верхним
-- ---------------------------------------------------------------------

GRANT dean, deputy_dean, methodologist, teacher,
    curator_1_course, curator_2_course, curator_3_course,
    curator_4_course, curator_5_course, curator_6_course
    TO administrator;

GRANT curator_1_course, curator_2_course, curator_3_course,
    curator_4_course, curator_5_course, curator_6_course
    TO dean;

GRANT teacher TO methodologist;

-- ---------------------------------------------------------------------
-- 7. Просмотр привилегий, предоставленных ролям (селекты-отчёты)
-- ---------------------------------------------------------------------

-- Табличные и процедурные гранты + политики RLS
-- (выполни для отчётности — не меняет состояние)
SELECT grantee AS role,
       table_name AS object_name,
       STRING_AGG(privilege_type, ', ') AS privileges,
       'TABLE GRANT' AS type
FROM information_schema.role_table_grants
WHERE grantee IN (
    'administrator', 'dean', 'deputy_dean', 'methodologist', 'teacher',
    'curator_1_course', 'curator_2_course', 'curator_3_course',
    'curator_4_course', 'curator_5_course', 'curator_6_course'
    )
GROUP BY grantee, table_name

UNION ALL

SELECT grantee AS role,
       routine_name AS object_name,
       STRING_AGG(privilege_type, ', ') AS privileges,
       'PROCEDURE GRANT' AS type
FROM information_schema.role_routine_grants
WHERE grantee IN (
    'administrator', 'dean', 'deputy_dean', 'methodologist', 'teacher',
    'curator_1_course', 'curator_2_course', 'curator_3_course',
    'curator_4_course', 'curator_5_course', 'curator_6_course'
    )
GROUP BY grantee, routine_name

UNION ALL

SELECT unnest(roles) AS role,
       tablename AS object_name,
       cmd AS privileges,
       'RLS' AS type
FROM pg_policies
WHERE roles && ARRAY[
    'curator_1_course', 'curator_2_course', 'curator_3_course',
    'curator_4_course', 'curator_5_course', 'curator_6_course'
    ]::name[]
ORDER BY role, object_name;

-- ---------------------------------------------------------------------
-- 8. Создание пользователей
-- ---------------------------------------------------------------------

CREATE USER dean_user           WITH PASSWORD '1234';
CREATE USER deputy_dean_user    WITH PASSWORD '1234';
CREATE USER methodologist_user  WITH PASSWORD '1234';
CREATE USER teacher_user        WITH PASSWORD '1234';
CREATE USER curator1_user       WITH PASSWORD '1234';
CREATE USER curator2_user       WITH PASSWORD '1234';
CREATE USER curator3_user       WITH PASSWORD '1234';
CREATE USER curator4_user       WITH PASSWORD '1234';
CREATE USER curator5_user       WITH PASSWORD '1234';
CREATE USER curator6_user       WITH PASSWORD '1234';

-- ---------------------------------------------------------------------
-- 9. Выдача ролей пользователям
-- ---------------------------------------------------------------------

GRANT dean             TO dean_user;
GRANT deputy_dean      TO deputy_dean_user;
GRANT methodologist    TO methodologist_user;
GRANT teacher          TO teacher_user;
GRANT curator_1_course TO curator1_user;
GRANT curator_2_course TO curator2_user;
GRANT curator_3_course TO curator3_user;
GRANT curator_4_course TO curator4_user;
GRANT curator_5_course TO curator5_user;
GRANT curator_6_course TO curator6_user;

-- ---------------------------------------------------------------------
-- 10. Просмотр ролей, выданных пользователям (селект-отчёт)
-- ---------------------------------------------------------------------

SELECT u.rolname AS user_name,
       r.rolname AS role_name
FROM pg_roles u
         JOIN pg_auth_members m ON m.member = u.oid
         JOIN pg_roles r ON r.oid = m.roleid
WHERE u.rolname IN (
                    'firstadmin', 'dean_user', 'deputy_dean_user', 'methodologist_user', 'teacher_user',
                    'curator1_user', 'curator2_user', 'curator3_user',
                    'curator4_user', 'curator5_user', 'curator6_user'
    )
ORDER BY u.rolname;

-- ---------------------------------------------------------------------
-- 11. Прямой грант пользователю на привилегию, которую даёт роль
-- ---------------------------------------------------------------------

GRANT EXECUTE ON PROCEDURE current_session() TO dean_user;
REVOKE dean FROM dean_user;

-- Попытка вызова выдаст ошибку без SELECT на discipline_plus,
-- поэтому дополнительно даём прямой SELECT.
GRANT SELECT ON discipline_plus TO dean_user;

-- Для проверки:
-- \c tvgudb dean_user
-- CALL current_session();

-- =====================================================================

-- [Подготовка тестовых пользователей]
DO $$
BEGIN
  IF NOT EXISTS (SELECT 1 FROM pg_roles WHERE rolname = 'u_dean') THEN
CREATE ROLE u_dean LOGIN PASSWORD 'u_dean_pw';
END IF;
  IF NOT EXISTS (SELECT 1 FROM pg_roles WHERE rolname = 'u_deputy') THEN
CREATE ROLE u_deputy LOGIN PASSWORD 'u_deputy_pw';
END IF;
  IF NOT EXISTS (SELECT 1 FROM pg_roles WHERE rolname = 'u_methodologist') THEN
CREATE ROLE u_methodologist LOGIN PASSWORD 'u_methodologist_pw';
END IF;
  IF NOT EXISTS (SELECT 1 FROM pg_roles WHERE rolname = 'u_teacher') THEN
CREATE ROLE u_teacher LOGIN PASSWORD 'u_teacher_pw';
END IF;
  IF NOT EXISTS (SELECT 1 FROM pg_roles WHERE rolname = 'u_curator1') THEN
CREATE ROLE u_curator1 LOGIN PASSWORD 'u_curator1_pw';
END IF;
  IF NOT EXISTS (SELECT 1 FROM pg_roles WHERE rolname = 'u_teacher_direct') THEN
CREATE ROLE u_teacher_direct LOGIN PASSWORD 'u_teacher_direct_pw';
END IF;
END$$;

GRANT dean              TO u_dean;
GRANT deputy_dean       TO u_deputy;
GRANT methodologist     TO u_methodologist;
GRANT teacher           TO u_teacher;
GRANT curator_1_course  TO u_curator1;
GRANT teacher           TO u_teacher_direct;

-- Витрина: роли тест-пользователей
-- Показать, какие роли выданы выбранным логинам
SELECT member.rolname AS user_name,
       role.rolname   AS role_name
FROM pg_auth_members m
         JOIN pg_roles role   ON role.oid   = m.roleid
         JOIN pg_roles member ON member.oid = m.member
WHERE member.rolname IN (
                         'u_dean','u_deputy','u_methodologist','u_teacher','u_curator1','u_teacher_direct'
    )
ORDER BY user_name, role_name;

-- 12.A Декан
SET ROLE dean;
SELECT current_user AS acting_as_dean,
       has_table_privilege(current_user,'public.student','SELECT') AS can_select_student,
       has_table_privilege(current_user,'public.student_discipline','SELECT') AS can_select_student_disc,
       has_table_privilege(current_user,'public.discipline','SELECT') AS can_select_discipline;
CALL current_session();
RESET ROLE;

-- 12.B Замдекана
SET ROLE deputy_dean;
SELECT current_user AS acting_as_deputy,
       has_table_privilege(current_user,'public.student','SELECT') AS can_select_student,
       has_table_privilege(current_user,'public.student_discipline','SELECT') AS can_select_student_disc,
       has_table_privilege(current_user,'public.discipline','SELECT') AS can_select_disc,
       has_table_privilege(current_user,'public.discipline','INSERT') AS can_insert_disc,
       has_table_privilege(current_user,'public.discipline','UPDATE') AS can_update_disc,
       has_table_privilege(current_user,'public.discipline','DELETE') AS can_delete_disc;
CALL current_session();
RESET ROLE;

-- 12.C Методист
SET ROLE methodologist;
SELECT current_user AS acting_as_methodologist,
       has_table_privilege(current_user,'public.student','SELECT') AS can_select_student,
       has_table_privilege(current_user,'public.student','INSERT') AS can_insert_student,
       has_table_privilege(current_user,'public.student','UPDATE') AS can_update_student,
       has_table_privilege(current_user,'public.student','DELETE') AS can_delete_student,
       has_table_privilege(current_user,'public.student_discipline','SELECT') AS can_select_student_disc,
       has_table_privilege(current_user,'public.discipline','SELECT') AS can_select_discipline;
SELECT n_discipline, title_discipline, second_name_teacher
FROM discipline
ORDER BY n_discipline
    LIMIT 10;
CALL current_session();
RESET ROLE;

-- 12.D Преподаватель
SET ROLE teacher;
SELECT current_user AS acting_as_teacher,
       has_table_privilege(current_user,'public.discipline','SELECT') AS can_select_discipline;
CALL current_session();
RESET ROLE;

-- 12.E Куратор 1 курса
SET ROLE curator_1_course;
SELECT 'student_rows_visible' AS check_name, COUNT(*) AS rows_visible FROM student;
SELECT 'student_discipline_rows_visible' AS check_name, COUNT(*) AS rows_visible FROM student_discipline;
SELECT current_user AS acting_as_curator1,
       has_table_privilege(current_user,'public.student','SELECT') AS can_select_student,
       has_table_privilege(current_user,'public.student_discipline','SELECT') AS can_select_student_disc;
CALL current_session();
RESET ROLE;

-- 12.F Прямая привилегия vs. роль (u_teacher_direct)
GRANT SELECT ON public.discipline TO u_teacher_direct;
SELECT 'before_revokes' AS phase,
       pg_has_role('u_teacher_direct','teacher','USAGE') AS is_member_of_teacher,
       has_table_privilege('u_teacher_direct','public.discipline','SELECT') AS user_can_select_discipline;
REVOKE SELECT ON public.discipline FROM u_teacher_direct;
SELECT 'after_revoke_direct' AS phase,
       pg_has_role('u_teacher_direct','teacher','USAGE') AS is_member_of_teacher,
       has_table_privilege('u_teacher_direct','public.discipline','SELECT') AS user_can_select_discipline;
GRANT SELECT ON public.discipline TO u_teacher_direct;
REVOKE SELECT ON public.discipline FROM teacher;
SELECT 'after_revoke_from_role' AS phase,
       pg_has_role('u_teacher_direct','teacher','USAGE') AS is_member_of_teacher,
       has_table_privilege('u_teacher_direct','public.discipline','SELECT') AS user_can_select_discipline;
GRANT SELECT ON public.discipline TO teacher;
REVOKE SELECT ON public.discipline FROM u_teacher_direct;

-- 12.G Выдать нижнюю роль и сменить активную роль
GRANT curator_1_course TO u_teacher;
SELECT grantee AS user_name, role_name
FROM information_schema.applicable_roles
WHERE grantee = 'u_teacher'
ORDER BY role_name;

SET ROLE curator_1_course;
SELECT current_user AS acting_as_after_role_switch,
       (SELECT COUNT(*) FROM student) AS rows_student_visible_under_curator_role;
RESET ROLE;

-- ---------------------------------------------------------------------
-- 13–16. Очистка
-- ---------------------------------------------------------------------

-- A) Безопасная очистка тест-пользователей (u_*)
REVOKE dean              FROM u_dean;
REVOKE deputy_dean       FROM u_deputy;
REVOKE methodologist     FROM u_methodologist;
REVOKE teacher           FROM u_teacher;
REVOKE curator_1_course  FROM u_curator1;
REVOKE teacher           FROM u_teacher_direct;
REVOKE curator_1_course  FROM u_teacher;
REVOKE ALL PRIVILEGES ON public.discipline FROM u_teacher_direct;

DO $$
BEGIN
  IF EXISTS (SELECT 1 FROM pg_roles WHERE rolname = 'u_dean') THEN
DROP ROLE u_dean;
END IF;
  IF EXISTS (SELECT 1 FROM pg_roles WHERE rolname = 'u_deputy') THEN
DROP ROLE u_deputy;
END IF;
  IF EXISTS (SELECT 1 FROM pg_roles WHERE rolname = 'u_methodologist') THEN
DROP ROLE u_methodologist;
END IF;
  IF EXISTS (SELECT 1 FROM pg_roles WHERE rolname = 'u_teacher') THEN
DROP ROLE u_teacher;
END IF;
  IF EXISTS (SELECT 1 FROM pg_roles WHERE rolname = 'u_curator1') THEN
DROP ROLE u_curator1;
END IF;
  IF EXISTS (SELECT 1 FROM pg_roles WHERE rolname = 'u_teacher_direct') THEN
DROP ROLE u_teacher_direct;
END IF;
END$$;

-- B) (Опционально) Полная зачистка ролей задания.
-- Разкомментируй, если нужно удалить роли и их привилегии полностью.
-- REVOKE ALL PRIVILEGES ON ALL TABLES IN SCHEMA public FROM administrator;
-- REVOKE CREATE ON SCHEMA public FROM administrator;
-- REVOKE SELECT ON ALL TABLES IN SCHEMA public FROM dean;
-- REVOKE USAGE  ON SCHEMA public FROM dean;
-- REVOKE SELECT ON student, student_discipline FROM deputy_dean;
-- REVOKE USAGE  ON SCHEMA public FROM deputy_dean;
-- REVOKE ALL PRIVILEGES ON discipline FROM deputy_dean;
-- REVOKE ALL PRIVILEGES ON student, student_discipline FROM methodologist;
-- REVOKE USAGE ON SCHEMA public FROM methodologist;
-- REVOKE SELECT ON discipline FROM teacher;
-- REVOKE USAGE  ON SCHEMA public FROM teacher;
-- REVOKE USAGE ON SCHEMA public FROM curator_1_course;
-- REVOKE USAGE ON SCHEMA public FROM curator_2_course;
-- REVOKE USAGE ON SCHEMA public FROM curator_3_course;
-- REVOKE USAGE ON SCHEMA public FROM curator_4_course;
-- REVOKE USAGE ON SCHEMA public FROM curator_5_course;
-- REVOKE USAGE ON SCHEMA public FROM curator_6_course;
-- DO $$
-- BEGIN
--   FOREACH r IN ARRAY ARRAY[
--     'administrator','dean','deputy_dean','methodologist','teacher',
--     'curator_1_course','curator_2_course','curator_3_course',
--     'curator_4_course','curator_5_course','curator_6_course'
--   ]
--   LOOP
--     IF EXISTS (SELECT 1 FROM pg_roles WHERE rolname = r) THEN
--       EXECUTE format('DROP ROLE %I', r);
--     END IF;
--   END LOOP;
-- END$$;

-- =====================================================================
-- Конец единого скрипта
-- =====================================================================
