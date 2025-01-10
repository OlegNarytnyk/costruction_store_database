-- Аналіз виконаних замовлень
SELECT o.order_id, o.order_date, p.product_name, oi.quantity, oi.discount,
       (oi.quantity * oi.list_price * (1 - oi.discount)) AS total_price
FROM orders o
         JOIN order_items oi ON o.order_id = oi.order_id
         JOIN product p ON oi.product_id = p.product_id
WHERE o.order_status = 'Shipped'
ORDER BY o.order_id;

-- Запити для виявлення найпопулярніших товарів
SELECT st.store_id, p.product_name, SUM(oi.quantity) AS total_quantity
FROM store st
         JOIN orders o ON st.store_id = o.store_id
         JOIN order_items oi ON o.order_id = oi.order_id
         JOIN product p ON oi.product_id = p.product_id
GROUP BY st.store_id, p.product_name
ORDER BY total_quantity DESC;

-- Аналіз клієнтів з великими замовленнями
SELECT c.first_name, c.last_name, o.order_id, SUM(oi.quantity * oi.list_price * (1 - oi.discount)) AS total_order_value
FROM customers c
         JOIN orders o ON c.customer_id = o.customer_id
         JOIN order_items oi ON o.order_id = oi.order_id
GROUP BY c.customer_id, o.order_id
HAVING total_order_value > 100;

-- Аналіз залишків товару в магазині
SELECT p.product_name, SUM(a.quantity) AS total_quantity, c.category_name
FROM product p
         JOIN availability a ON p.product_id = a.product_id
         JOIN category c ON p.category_id = c.category_id
GROUP BY p.product_id, c.category_name
ORDER BY total_quantity ASC;

-- Аналіз продажів у розрізі місяців
SELECT MONTH(o.order_date) AS month, SUM(oi.quantity * oi.list_price * (1 - oi.discount)) AS total_sales
FROM orders o
         JOIN order_items oi ON o.order_id = oi.order_id
WHERE o.order_status = 'Shipped'
GROUP BY MONTH(o.order_date)
ORDER BY month;

-- Аналіз активності співробітників
SELECT e.first_name, e.last_name, e.email, e.phone, st.store_id, st.address, st.city, COUNT(o.order_id) AS total_orders
FROM employee e
         JOIN store st ON e.store_id = st.store_id
         LEFT JOIN orders o ON e.emp_id = o.emp_id
GROUP BY e.emp_id, st.store_id
ORDER BY total_orders ASC
LIMIT 5;
