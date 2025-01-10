CREATE TABLE employees_history (
                                   emp_id INT,
                                   first_name VARCHAR(40),
                                   last_name VARCHAR(40),
                                   birth_day DATE,
                                   email VARCHAR(40),
                                   phone INT,
                                   status VARCHAR(40),
                                   store_id INT,
                                   sup_id INT,
                                   ValidFrom DATETIME,
                                   ValidTo DATETIME,
                                   IsCurrent BOOLEAN,
                                   PRIMARY KEY (emp_id, ValidFrom)
);



DELIMITER $$

CREATE TRIGGER before_employee_update
    BEFORE UPDATE ON employee
    FOR EACH ROW
BEGIN
    INSERT INTO employees_history (
        emp_id, first_name, last_name, birth_day, email, phone,
        status, store_id, sup_id, ValidFrom, ValidTo, IsCurrent
    )
    VALUES (
               OLD.emp_id, OLD.first_name, OLD.last_name, OLD.birth_day,
               OLD.email, OLD.phone, OLD.status, OLD.store_id, OLD.sup_id,
               OLD.ValidFrom, NOW(), FALSE
           );

    SET NEW.ValidFrom = NOW();
    SET NEW.IsCurrent = TRUE;
END$$

DELIMITER ;


DELIMITER $$

CREATE TRIGGER after_employee_insert
    AFTER INSERT ON employee
    FOR EACH ROW
BEGIN
    INSERT INTO employees_history (
        emp_id, first_name, last_name, birth_day, email, phone,
        status, store_id, sup_id, ValidFrom, ValidTo, IsCurrent
    )
    VALUES (
               NEW.emp_id, NEW.first_name, NEW.last_name, NEW.birth_day,
               NEW.email, NEW.phone, NEW.status, NEW.store_id, NEW.sup_id,
               NEW.ValidFrom, '9999-12-31 23:59:59', TRUE
           );
END$$

DELIMITER ;