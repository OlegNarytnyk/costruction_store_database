-- Перегляд для всіх замовлень з деталями товарів, кількістю та знижками
CREATE VIEW view_orders_details AS
SELECT o.order_id, o.order_date, p.product_name, oi.quantity, oi.discount,
       (oi.quantity * oi.list_price * (1 - oi.discount)) AS total_price
FROM orders o
         JOIN order_items oi ON o.order_id = oi.order_id
         JOIN product p ON oi.product_id = p.product_id
WHERE o.order_status = 'Shipped'
ORDER BY o.order_id;

-- Перегляд для клієнтів з замовленнями на суму більше ніж 100
CREATE VIEW view_high_value_orders AS
SELECT c.first_name, c.last_name, o.order_id, o.order_date,
       SUM(oi.quantity * oi.list_price * (1 - oi.discount)) AS total_order_value
FROM customers c
         JOIN orders o ON c.customer_id = o.customer_id
         JOIN order_items oi ON o.order_id = oi.order_id
GROUP BY c.customer_id, o.order_id
HAVING total_order_value > 100;

-- Перегляд для найпопулярніших товарів, замовлених у кожному магазині
CREATE VIEW view_top_selling_products AS
SELECT st.store_id, p.product_name, SUM(oi.quantity) AS total_quantity
FROM store st
         JOIN orders o ON st.store_id = o.store_id
         JOIN order_items oi ON o.order_id = oi.order_id
         JOIN product p ON oi.product_id = p.product_id
GROUP BY st.store_id, p.product_name
ORDER BY total_quantity DESC;

-- Перегляд для співробітників, які мають найменше замовлень
CREATE VIEW view_least_active_employees AS
SELECT e.first_name, e.last_name, e.email, e.phone, st.store_id, st.address,
       COUNT(o.order_id) AS total_orders
FROM employee e
         JOIN store st ON e.store_id = st.store_id
         LEFT JOIN orders o ON e.emp_id = o.emp_id
GROUP BY e.emp_id, st.store_id
ORDER BY total_orders ASC
LIMIT 5;

-- Перегляд для всіх товарів, доступних у всіх магазинах
CREATE VIEW view_products_available_in_all_stores AS
SELECT p.product_name, c.category_name, SUM(a.quantity) AS total_available_quantity, s.supplier_name
FROM product p
         JOIN category c ON p.category_id = c.category_id
         JOIN availability a ON p.product_id = a.product_id
         JOIN supplier s ON a.store_id = s.store_id AND p.product_id = s.product_id
GROUP BY p.product_id, c.category_name, s.supplier_name;