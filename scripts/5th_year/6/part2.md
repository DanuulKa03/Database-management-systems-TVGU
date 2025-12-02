## 3.5.	Реализация вставки.
### 3.5.1.	Написать триггер вставки before insert для таблицы mand_tab, который осуществляет контроль за вставкой записей в эту таблицу. В триггере выполнить следующие операции:
        1.  С помощью функции USER() определить имя текущего (активного) пользователя.  
        
        2.  Определить его уровень доступа по таблице user_levels.  
        
        3.  Если уровень секретности пользователя не позволяет ему осуществлять данную операцию (значение метки вставляемой записи не соответствует метке пользователя – см. п. 1.2), вызвать сообщение об ошибке (например, с помощью signal sqlstate '50005' set message_text = 'Сообщение об ошибке').  -
**Выполняем из под рута**
```sql
CREATE OR REPLACE FUNCTION check_insert_mand_tab()
RETURNS TRIGGER AS $$
DECLARE
    curr_user TEXT;
    curr_level INT;
BEGIN
    curr_user := CURRENT_USER;

    SELECT user_level INTO curr_level
    FROM user_levels
    WHERE user_name = curr_user;

    IF NEW.mand_level <> curr_level THEN
        RAISE EXCEPTION 'Ошибка вставки: пользователь % (уровень %) не может вставить запись уровня %',
            curr_user, curr_level, NEW.mand_level
            USING ERRCODE = '50005';
    END IF;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_insert_mand_tab
BEFORE INSERT ON mand_tab
FOR EACH ROW
EXECUTE FUNCTION check_insert_mand_tab();
```

### 3.5.2.	После создания триггера выполнить вставку от имени каждого пользователя.
### 3.5.3.	Распечатать системные сообщения и результаты вставки в таблицу.

**выполняем из под stud_0**  
успешная вставка
```sql
tvgudb=> INSERT INTO mand_tab (n_credit_book, second_name, name, patronymic, n_group, telephone, mand_level)
tvgudb-> VALUES (2001, 'Тестов', 'Студент0', 'А.', '11A', '80000000001', 0);
INSERT 0 1
tvgudb=>
```
неудачная вставка
```sql
tvgudb=> INSERT INTO mand_tab (n_credit_book, second_name, name, patronymic, n_group, telephone, mand_level)
tvgudb-> VALUES (2002, 'Тестов', 'Студент0', 'студентович', '33B', '80000000002', 1);
ERROR:  Ошибка вставки: пользователь stud_0 (уровень 0) не может вставить запись уровня 1
CONTEXT:  PL/pgSQL function check_insert_mand_tab() line 13 at RAISE
```

**выполняем из под stud_1**  
успешная вставка
```sql
tvgudb=> INSERT INTO mand_tab (n_credit_book, second_name, name, patronymic, n_group, telephone, mand_level)
tvgudb-> VALUES (2003, 'Тестов', 'Студент1', 'И.', '32A', '80090000001', 1);
INSERT 0 1
```
неудачная вставка
```sql
tvgudb=> INSERT INTO mand_tab (n_credit_book, second_name, name, patronymic, n_group, telephone, mand_level)
tvgudb-> VALUES (2004, 'Тестов', 'Студент1', 'И.', '62A', '80090000001', 2);
ERROR:  Ошибка вставки: пользователь stud_1 (уровень 1) не может вставить запись уровня 2
CONTEXT:  PL/pgSQL function check_insert_mand_tab() line 13 at RAISE
```

**выполняем из под stud_2**  
успешная вставка
```sql
tvgudb=> INSERT INTO mand_tab (n_credit_book, second_name, name, patronymic, n_group, telephone, mand_level)
tvgudb-> VALUES (2005, 'Тестов', 'Студент2', 'Ф.', '56A', '80090000001', 2);
INSERT 0 1
```
неудачная вставка
```sql
tvgudb=> INSERT INTO mand_tab (n_credit_book, second_name, name, patronymic, n_group, telephone, mand_level)
tvgudb-> VALUES (2006, 'Тестов', 'Студент1', 'Ф.', '15A', '80090000001', 0);
ERROR:  Ошибка вставки: пользователь stud_2 (уровень 2) не может вставить запись уровня 0
CONTEXT:  PL/pgSQL function check_insert_mand_tab() line 13 at RAISE
```
## 3.6.	Реализация обновления.
### 3.6.1.	Написать триггер обновления before update для таблицы mand_tab, который осуществляет контроль за обновлением записей в этой таблице. В триггере выполнить следующие операции.
        1.  С помощью функции USER() определить имя текущего (активного) пользователя.
        
        2.  Определить его уровень доступа по таблице user_levels.
        
        3.  Если уровень секретности пользователя не позволяет ему осуществлять данную операцию (значение метки обновляемой записи не соответствует метке пользователя), вызвать сообщение об ошибке (например, с помощью signal sqlstate '50005' set message_text = 'Сообщение об ошибке').
**Выполняем из под рута**
```sql
CREATE OR REPLACE FUNCTION check_update_mand_tab()
RETURNS TRIGGER AS $$
DECLARE
    curr_user TEXT;
    curr_level INT;
BEGIN
    curr_user := CURRENT_USER;

    SELECT user_level INTO curr_level
    FROM user_levels
    WHERE user_name = curr_user;

    IF OLD.mand_level < curr_level THEN
        RAISE EXCEPTION 'Ошибка обновления: пользователь % (уровень %) не может изменять запись уровня %',
            curr_user, curr_level, OLD.mand_level
            USING ERRCODE = '50005';
    END IF;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_update_mand_tab
BEFORE UPDATE ON mand_tab
FOR EACH ROW
EXECUTE FUNCTION check_update_mand_tab();
```
### 3.6.2.	После создания триггера выполнить обновление от имени каждого пользователя.
### 3.6.3.	Распечатать системные сообщения и результат обновления таблицы.
**выполняем из под stud_0**  
обновляем запись уровня 0
```sql
tvgudb=> UPDATE mand_tab
tvgudb-> SET second_name = 'Иванов_туц'
tvgudb-> WHERE n_credit_book = 1;
UPDATE 1
```
обновляем запись уровня 2
```sql
tvgudb=> UPDATE mand_tab
tvgudb-> SET second_name = 'stud_2_new'
tvgudb-> WHERE n_credit_book = 2005;
UPDATE 1
```
**выполняем из под stud_1**  
обновляем запись уровня 0
```sql
tvgudb=>  UPDATE mand_tab
tvgudb->  SET second_name = 'Иванов_juj'
tvgudb->  WHERE n_credit_book = 1;
ERROR:  Ошибка обновления: пользователь stud_1 (уровень 1) не может изменять запись уровня 0
CONTEXT:  PL/pgSQL function check_update_mand_tab() line 13 at RAISE
```
обновляем запись уровня 2
```sql
tvgudb=>  UPDATE mand_tab
tvgudb->  SET second_name = 'stud_2_FEF'
tvgudb->  WHERE n_credit_book = 2005;
UPDATE 1
```
**выполняем из под stud_2**  
обновляем запись уровня 0
```sql
tvgudb=> UPDATE mand_tab
tvgudb-> SET second_name = 'Иванов_куе'
tvgudb-> WHERE n_credit_book = 1;
ERROR:  Ошибка обновления: пользователь stud_2 (уровень 2) не может изменять запись уровня 0
CONTEXT:  PL/pgSQL function check_update_mand_tab() line 13 at RAISE
```
обновляем запись уровня 1
```sql
tvgudb=> UPDATE mand_tab
tvgudb-> SET second_name = 'Петров_куе'
tvgudb-> WHERE n_credit_book = 5;
ERROR:  Ошибка обновления: пользователь stud_2 (уровень 2) не может изменять запись уровня 1
CONTEXT:  PL/pgSQL function check_update_mand_tab() line 13 at RAISE
```
обновляем запись уровня 2
```sql
tvgudb=>  UPDATE mand_tab
tvgudb->  SET second_name = 'stud_2_http'
tvgudb->  WHERE n_credit_book = 2005;
UPDATE 1
```