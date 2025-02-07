-- Создание таблицы Студент
CREATE TABLE student (
    n_credit_book SERIAL PRIMARY KEY,
    second_name VARCHAR(50) NOT NULL,
    name VARCHAR(50) NOT NULL,
    patronymic VARCHAR(50) NOT NULL,
    n_group VARCHAR(10) NOT NULL,
    telephone VARCHAR(20) DEFAULT NULL,
    CHECK (n_group ~ '^\d{2}[A-Z]?$')  -- Теперь разрешает '11A', '12B'
);

-- Создание таблицы Предмет
CREATE TABLE discipline (
    n_discipline SERIAL PRIMARY KEY,
    title_discipline VARCHAR(100) NOT NULL,
    second_name_teacher VARCHAR(50) NOT NULL
);

-- Создание таблицы Студент_предмет (связь между студентами и предметами)
CREATE TABLE student_discipline (
    n_credit_book INT NOT NULL,
    n_discipline INT NOT NULL,
    estimation INT NOT NULL CHECK (estimation BETWEEN 2 AND 5),
    PRIMARY KEY (n_credit_book, n_discipline),
    FOREIGN KEY (n_credit_book) REFERENCES student(n_credit_book) ON DELETE CASCADE,
    FOREIGN KEY (n_discipline) REFERENCES discipline(n_discipline) ON DELETE CASCADE
);

-- Добавление тестовых данных

-- Студенты
INSERT INTO student (second_name, name, patronumic, n_group, telephone) VALUES
    ('Иванов', 'Алексей', 'Сергеевич', '11A', '89005553322'),
    ('Петров', 'Иван', 'Алексеевич', '11A', '89001234567'),
    ('Сидоров', 'Николай', 'Игоревич', '12B', NULL),
    ('Федоров', 'Антон', 'Викторович', '12B', '89009876543');

-- Предметы
INSERT INTO discipline (title_discipline, second_name_teacher) VALUES
    ('Математика', 'Смирнов'),
    ('Физика', 'Петров'),
    ('Английский язык', 'Сидорова');

-- Записи о сдаче экзаменов
INSERT INTO student_discipline (n_credit_book, n_discipline, estimation) VALUES
    (1, 1, 5),  -- Иванов по математике
    (1, 2, 4),  -- Иванов по физике
    (2, 1, 3),  -- Петров по математике
    (2, 3, 2),  -- Петров по английскому (не сдал)
    (3, 2, 5),  -- Сидоров по физике
    (4, 3, 4);  -- Федоров по английскому
