DELIMITER $$

CREATE PROCEDURE purchase_product(
    IN p_first_name VARCHAR(40),
    IN p_last_name VARCHAR(40),
    IN p_birth_day DATE,
    IN p_phone VARCHAR(10),
    IN p_email VARCHAR(40),
    IN p_address VARCHAR(80),
    IN p_city VARCHAR(40),
    IN p_country VARCHAR(40),
    IN p_post_code VARCHAR(10),
    IN p_store_id INT,
    IN p_emp_id INT,
    IN p_product_ids TEXT,
    IN p_quantities TEXT,
    IN p_discounts TEXT
)
BEGIN
    DECLARE p_customer_id INT;
    DECLARE p_order_id INT;
    DECLARE v_product_id INT;
    DECLARE v_quantity INT;
    DECLARE v_discount DECIMAL(3, 2);
    DECLARE v_list_price DECIMAL(10, 2);
    DECLARE v_pos INT;
    DECLARE v_next_pos INT;
    DECLARE v_product_ids_remaining TEXT;
    DECLARE v_quantities_remaining TEXT;
    DECLARE v_discounts_remaining TEXT;
    DECLARE v_required_date DATE;

    DECLARE CONTINUE HANDLER FOR SQLEXCEPTION
        BEGIN
            ROLLBACK;
            SELECT 'Error occurred during the operation';
        END;

    START TRANSACTION;


    SELECT customer_id INTO p_customer_id
    FROM customers
    WHERE email = p_email;

    IF p_customer_id IS NULL THEN
        CALL add_or_update_customer(NULL, p_first_name, p_last_name, p_birth_day, p_phone, p_email, p_address, p_city, p_country, p_post_code);
        SELECT LAST_INSERT_ID() INTO p_customer_id;
    END IF;

    SET v_required_date = DATE_ADD(CURRENT_DATE(), INTERVAL 4 DAY);

    CALL add_or_update_order(NULL, p_customer_id, CURRENT_DATE(), 'Pending', v_required_date, NULL, p_store_id, p_emp_id);
    SELECT LAST_INSERT_ID() INTO p_order_id;

    SET v_product_ids_remaining = p_product_ids;
    SET v_quantities_remaining = p_quantities;
    SET v_discounts_remaining = p_discounts;

    WHILE LENGTH(v_product_ids_remaining) > 0 DO
            SET v_pos = LOCATE(',', v_product_ids_remaining);
            IF v_pos = 0 THEN
                SET v_product_id = CAST(v_product_ids_remaining AS UNSIGNED);
                SET v_product_ids_remaining = '';
            ELSE
                SET v_product_id = CAST(SUBSTRING(v_product_ids_remaining, 1, v_pos - 1) AS UNSIGNED);
                SET v_product_ids_remaining = SUBSTRING(v_product_ids_remaining, v_pos + 1);
            END IF;

            SET v_next_pos = LOCATE(',', v_quantities_remaining);
            IF v_next_pos = 0 THEN
                SET v_quantity = CAST(v_quantities_remaining AS UNSIGNED);
                SET v_quantities_remaining = '';
            ELSE
                SET v_quantity = CAST(SUBSTRING(v_quantities_remaining, 1, v_next_pos - 1) AS UNSIGNED);
                SET v_quantities_remaining = SUBSTRING(v_quantities_remaining, v_next_pos + 1);
            END IF;

            SET v_next_pos = LOCATE(',', v_discounts_remaining);
            IF v_next_pos = 0 THEN
                SET v_discount = CAST(v_discounts_remaining AS DECIMAL(3, 2));
                SET v_discounts_remaining = '';
            ELSE
                SET v_discount = CAST(SUBSTRING(v_discounts_remaining, 1, v_next_pos - 1) AS DECIMAL(3, 2));
                SET v_discounts_remaining = SUBSTRING(v_discounts_remaining, v_next_pos + 1);
            END IF;

            SELECT list_price INTO v_list_price
            FROM product
            WHERE product_id = v_product_id;


            CALL add_or_update_order_item(p_order_id, v_product_id, v_product_id, v_quantity, v_list_price, v_discount);

            CALL add_or_update_availability(p_store_id, v_product_id, -v_quantity);
        END WHILE;

    COMMIT;

    SELECT 'Purchase completed successfully', p_order_id AS order_id;
END$$

DELIMITER ;