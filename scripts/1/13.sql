SELECT * FROM student_discipline WHERE n_credit_book = 1 OR n_credit_book = 2 OR n_credit_book = 3;

SELECT * FROM student_discipline WHERE n_credit_book IN (1, 2, 3);