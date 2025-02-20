--N1
select second_name from student
--N2
select n_group, name, second_name, telephone from student
--N3
select * from student
--N4
select * from student where n_group = '11A'
--N5
select * from student where second_name = 'Иванов'
--N6
select * from student where n_group = '11A' or n_group = '12B'
--N7
select * from student where (n_group = '11A' or n_group = '12B') and telephone is NOT NULL
--N8
select distinct n_group from student
--N9
select distinct second_name_teacher from discipline
--N10
select distinct n_credit_book from student_discipline where estimation = 2
--N11
select n_credit_book, n_discipline, estimation from student_discipline where n_credit_book = 1
--N11 для продвинутых 
select sd.n_credit_book, s.second_name, sd.n_discipline, d.title_discipline, sd.estimation from student_discipline as sd 
left join discipline as d on sd.n_discipline = d.n_discipline
left join student as s on sd.n_credit_book = s.n_credit_book
where sd.n_credit_book = 1
--N12
select n_credit_book from student_discipline where n_discipline = 3 and (estimation = 4 or estimation = 5 )
--N12
select n_credit_book from student_discipline where n_discipline = 3 and (estimation = 4 or estimation = 5 )
--N13.1
select n_credit_book, n_discipline, estimation from student_discipline where n_credit_book = 1 or n_credit_book = 3 or n_credit_book = 4  
--N13.2
select n_credit_book, n_discipline, estimation from student_discipline where n_credit_book in (1, 3, 4)  
--N14.1
select n_credit_book, n_discipline, estimation from student_discipline where n_discipline = 2 and (n_credit_book = 1 or n_credit_book = 4 or n_credit_book = 5)  
--N14.2
select n_credit_book, n_discipline, estimation from student_discipline where n_discipline = 2 and n_credit_book in (1, 4, 5)  




