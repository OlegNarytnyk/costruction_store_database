DELIMITER $$

CREATE PROCEDURE add_or_update_customer(
    IN p_customer_id INT,
    IN p_first_name VARCHAR(40),
    IN p_last_name VARCHAR(40),
    IN p_birth_day DATE,
    IN p_phone VARCHAR(10),
    IN p_email VARCHAR(40),
    IN p_address VARCHAR(80),
    IN p_city VARCHAR(40),
    IN p_country VARCHAR(40),
    IN p_post_code VARCHAR(10)
)
BEGIN
    DECLARE CONTINUE HANDLER FOR SQLEXCEPTION
        BEGIN
            ROLLBACK;
            SELECT 'Error occurred during the operation';
        END;

    START TRANSACTION;

    IF p_customer_id IS NULL THEN
        INSERT INTO customers (first_name, last_name, birth_day, phone, email, address, city, country, post_code)
        VALUES (p_first_name, p_last_name, p_birth_day, p_phone, p_email, p_address, p_city, p_country, p_post_code);
    ELSE
        UPDATE customers
        SET first_name = p_first_name,
            last_name = p_last_name,
            birth_day = p_birth_day,
            phone = p_phone,
            email = p_email,
            address = p_address,
            city = p_city,
            country = p_country,
            post_code = p_post_code
        WHERE customer_id = p_customer_id;
    END IF;

    COMMIT;
END$$

DELIMITER ;



DELIMITER $$

CREATE PROCEDURE add_or_update_employee(
    IN p_emp_id INT,
    IN p_first_name VARCHAR(40),
    IN p_last_name VARCHAR(40),
    IN p_birth_day DATE,
    IN p_email VARCHAR(40),
    IN p_phone VARCHAR(10),
    IN p_status VARCHAR(40),
    IN p_store_id INT,
    IN p_sup_id INT
)
BEGIN
    DECLARE CONTINUE HANDLER FOR SQLEXCEPTION
        BEGIN
            ROLLBACK;
            SELECT 'Error occurred during the operation';
        END;

    START TRANSACTION;

    IF p_emp_id IS NULL THEN
        INSERT INTO employee (first_name, last_name, birth_day, email, phone, status, store_id, sup_id)
        VALUES (p_first_name, p_last_name, p_birth_day, p_email, p_phone, p_status, p_store_id, p_sup_id);
    ELSE
        UPDATE employee
        SET first_name = p_first_name,
            last_name = p_last_name,
            birth_day = p_birth_day,
            email = p_email,
            phone = p_phone,
            status = p_status,
            store_id = p_store_id,
            sup_id = p_sup_id
        WHERE emp_id = p_emp_id;
    END IF;

    COMMIT;
END$$

DELIMITER ;

DELIMITER $$

CREATE PROCEDURE add_or_update_store(
    IN p_store_id INT,
    IN p_email VARCHAR(40),
    IN p_phone VARCHAR(10),
    IN p_address VARCHAR(80),
    IN p_city VARCHAR(40),
    IN p_post_code VARCHAR(10),
    IN p_manager_id INT
)
BEGIN
    DECLARE CONTINUE HANDLER FOR SQLEXCEPTION
        BEGIN
            ROLLBACK;
            SELECT 'Error occurred during the operation';
        END;

    START TRANSACTION;

    IF p_store_id IS NULL THEN
        INSERT INTO store (email, phone, address, city, post_code, manager_id)
        VALUES (p_email, p_phone, p_address, p_city, p_post_code, p_manager_id);
    ELSE
        UPDATE store
        SET email = p_email,
            phone = p_phone,
            address = p_address,
            city = p_city,
            post_code = p_post_code,
            manager_id = p_manager_id
        WHERE store_id = p_store_id;
    END IF;

    COMMIT;
END$$

DELIMITER ;

DELIMITER $$

CREATE PROCEDURE add_or_update_order(
    IN p_order_id INT,
    IN p_customer_id INT,
    IN p_order_date DATE,
    IN p_order_status VARCHAR(10),
    IN p_required_date DATE,
    IN p_shipped_date DATE,
    IN p_store_id INT,
    IN p_emp_id INT
)
BEGIN
    DECLARE v_order_exists INT;

    SELECT COUNT(*)
    INTO v_order_exists
    FROM orders
    WHERE order_id = p_order_id;

    IF v_order_exists = 0 THEN
        INSERT INTO orders (
            order_id, customer_id, order_date, order_status,
            required_date, shipped_date, store_id, emp_id
        ) VALUES (
                     p_order_id, p_customer_id, IFNULL(p_order_date, CURDATE()),
                     IFNULL(p_order_status, 'processing'),
                     IFNULL(p_required_date, DATE_ADD(CURDATE(), INTERVAL 4 DAY)),
                     p_shipped_date, p_store_id, p_emp_id
                 );
    ELSE
        UPDATE orders
        SET
            customer_id = IFNULL(p_customer_id, customer_id),
            order_date = IFNULL(p_order_date, order_date),
            order_status = IFNULL(p_order_status, order_status),
            required_date = IFNULL(p_required_date, required_date),
            shipped_date = IFNULL(p_shipped_date, shipped_date),
            store_id = IFNULL(p_store_id, store_id),
            emp_id = IFNULL(p_emp_id, emp_id)
        WHERE order_id = p_order_id;
    END IF;
END$$

DELIMITER ;

DELIMITER $$

CREATE PROCEDURE add_or_update_order_item(
    IN p_order_id INT,
    IN p_item_id INT,
    IN p_product_id INT,
    IN p_quantity INT,
    IN p_list_price DECIMAL(10, 2),
    IN p_discount DECIMAL(3, 2)
)
BEGIN
    DECLARE item_exists INT;

    DECLARE CONTINUE HANDLER FOR SQLEXCEPTION
        BEGIN
            ROLLBACK;
            SELECT 'Error occurred during the operation' AS ErrorMessage;
        END;

    START TRANSACTION;

    SELECT COUNT(*)
    INTO item_exists
    FROM order_items
    WHERE order_id = p_order_id AND item_id = p_item_id;

    IF item_exists > 0 THEN
        UPDATE order_items
        SET product_id = p_product_id,
            quantity = p_quantity,
            list_price = p_list_price,
            discount = p_discount
        WHERE order_id = p_order_id AND item_id = p_item_id;
    ELSE
        INSERT INTO order_items (order_id, item_id, product_id, quantity, list_price, discount)
        VALUES (p_order_id, p_item_id, p_product_id, p_quantity, p_list_price, p_discount);
    END IF;

    COMMIT;
END$$

DELIMITER ;

DELIMITER $$

CREATE PROCEDURE add_or_update_product(
    IN p_product_id INT,
    IN p_product_name VARCHAR(40),
    IN p_category_id INT,
    IN p_brand_id INT,
    IN p_list_price DECIMAL(10, 2)
)
BEGIN
    DECLARE CONTINUE HANDLER FOR SQLEXCEPTION
        BEGIN
            ROLLBACK;
            SELECT 'Error occurred during the operation';
        END;

    START TRANSACTION;


    IF p_product_id IS NULL THEN
        INSERT INTO product (product_name, category_id, brand_id, list_price)
        VALUES (p_product_name, p_category_id, p_brand_id, p_list_price);
    ELSE
        UPDATE product
        SET product_name = p_product_name,
            category_id = p_category_id,
            brand_id = p_brand_id,
            list_price = p_list_price
        WHERE product_id = p_product_id;
    END IF;

    COMMIT;
END$$

DELIMITER ;

DELIMITER $$

CREATE PROCEDURE add_or_update_category(
    IN p_category_id INT,
    IN p_category_name VARCHAR(40)
)
BEGIN
    DECLARE CONTINUE HANDLER FOR SQLEXCEPTION
        BEGIN
            ROLLBACK;
            SELECT 'Error occurred during the operation';
        END;

    START TRANSACTION;


    IF p_category_id IS NULL THEN
        INSERT INTO category (category_name)
        VALUES (p_category_name);
    ELSE
        UPDATE category
        SET category_name = p_category_name
        WHERE category_id = p_category_id;
    END IF;

    COMMIT;
END$$

DELIMITER ;

DELIMITER $$

CREATE PROCEDURE add_or_update_brand(
    IN p_brand_id INT,
    IN p_brand_name VARCHAR(40)
)
BEGIN
    DECLARE CONTINUE HANDLER FOR SQLEXCEPTION
        BEGIN
            ROLLBACK;
            SELECT 'Error occurred during the operation';
        END;

    START TRANSACTION;

    IF p_brand_id IS NULL THEN
        INSERT INTO brand (brand_name)
        VALUES (p_brand_name);
    ELSE
        UPDATE brand
        SET brand_name = p_brand_name
        WHERE brand_id = p_brand_id;
    END IF;

    COMMIT;
END$$

DELIMITER ;

DELIMITER $$

CREATE PROCEDURE add_or_update_availability(
    IN p_store_id INT,
    IN p_product_id INT,
    IN p_quantity INT
)
BEGIN
    DECLARE CONTINUE HANDLER FOR SQLEXCEPTION
        BEGIN
            ROLLBACK;
            SELECT 'Error occurred during the operation';
        END;

    START TRANSACTION;

    IF p_store_id IS NOT NULL AND p_product_id IS NOT NULL THEN
        UPDATE availability
        SET quantity = p_quantity
        WHERE store_id = p_store_id AND product_id = p_product_id;
    ELSE
        INSERT INTO availability (store_id, product_id, quantity)
        VALUES (p_store_id, p_product_id, p_quantity);
    END IF;

    COMMIT;
END$$

DELIMITER ;


DELIMITER $$

CREATE PROCEDURE add_or_update_supplier(
    IN p_store_id INT,
    IN p_supplier_id INT,
    IN p_supplier_name VARCHAR(40),
    IN p_product_id INT
)
BEGIN
    DECLARE CONTINUE HANDLER FOR SQLEXCEPTION
        BEGIN
            ROLLBACK;
            SELECT 'Error occurred during the operation';
        END;

    START TRANSACTION;

    IF p_supplier_id IS NOT NULL AND p_store_id IS NOT NULL AND p_product_id IS NOT NULL THEN
        UPDATE supplier
        SET supplier_name = p_supplier_name
        WHERE store_id = p_store_id AND supplier_id = p_supplier_id AND product_id = p_product_id;
    ELSE
        INSERT INTO supplier (store_id, supplier_id, supplier_name, product_id)
        VALUES (p_store_id, p_supplier_id, p_supplier_name, p_product_id);
    END IF;

    COMMIT;
END$$

DELIMITER ;