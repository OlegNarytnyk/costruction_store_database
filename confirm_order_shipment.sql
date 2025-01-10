DELIMITER $$

CREATE PROCEDURE confirm_order_shipment(
    IN p_order_id INT
)
BEGIN
    DECLARE v_order_exists INT;

    SELECT COUNT(*)
    INTO v_order_exists
    FROM orders
    WHERE order_id = p_order_id AND order_status != 'Shipped';

    IF v_order_exists = 0 THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Order does not exist or is already shipped.';
    ELSE
        -- Use the existing procedure to update the order
        CALL add_or_update_order(
                p_order_id,
                NULL,
                NULL,
                'Shipped',
                NULL,
                CURDATE(),
                NULL,
                NULL                     
             );
    END IF;
END$$

DELIMITER ;