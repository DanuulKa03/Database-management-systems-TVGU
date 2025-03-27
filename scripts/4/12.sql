-- 12. Вывести фамилии студентов и все их оценки по каждому предмету.
-- Написать 2 типа запроса: использовать естественное соединение и вложенные запросы в предложении Select.

SELECT SD.second_name, DS.title_discipline, SDD.estimation FROM student AS SD
JOIN student_discipline AS SDD on SD.n_credit_book = SDD.n_credit_book
JOIN discipline AS DS on DS.n_discipline = SDD.n_discipline;

SELECT stu_name.second_name, exams_name.title_discipline, SD.estimation FROM student_discipline AS SD
JOIN (
    SELECT n_discipline as ND, title_discipline
    FROM discipline
) AS exams_name ON exams_name.ND = SD.n_discipline
JOIN (
    SELECT student.n_credit_book as NCB, second_name
    FROM student
) AS stu_name ON stu_name.NCB = SD.n_credit_book;