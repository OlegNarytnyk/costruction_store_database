CREATE TABLE customers (
                           customer_id INT PRIMARY KEY,
                           first_name VARCHAR(40),
                           last_name VARCHAR(40),
                           birth_day DATE,
                           phone VARCHAR(10),
                           email VARCHAR(40),
                           address VARCHAR(80),
                           city VARCHAR(40),
                           country VARCHAR(40),
                           post_code VARCHAR(10)
);

CREATE TABLE employee (
                          emp_id INT PRIMARY KEY,
                          first_name VARCHAR(40),
                          last_name VARCHAR(40),
                          birth_day DATE,
                          email VARCHAR(40),
                          phone VARCHAR(10),
                          status VARCHAR(40),
                          store_id INT,
                          sup_id INT
);


CREATE TABLE store (
                       store_id INT PRIMARY KEY,
                       email VARCHAR(40),
                       phone VARCHAR(10),
                       address VARCHAR(80),
                       city VARCHAR(40),
                       post_code VARCHAR(10),
                       manager_id INT,
                       FOREIGN KEY (manager_id) REFERENCES employee(emp_id) ON DELETE SET NULL
);

ALTER TABLE employee
    ADD FOREIGN KEY(store_id)
        REFERENCES store(store_id)
        ON DELETE SET NULL;

ALTER TABLE employee
    ADD FOREIGN KEY (sup_id)
        REFERENCES employee(emp_id)
        ON DELETE SET NULL ;

CREATE TABLE orders(
                       order_id INT PRIMARY KEY,
                       customer_id INT,
                       order_date DATE,
                       order_status VARCHAR(10),
                       required_date DATE,
                       shipped_date DATE,
                       store_id INT,
                       emp_id INT,
                       FOREIGN KEY (customer_id) REFERENCES customers(customer_id) ON DELETE SET NULL,
                       FOREIGN KEY (store_id) REFERENCES store(store_id) ON DELETE SET NULL,
                       FOREIGN KEY (emp_id) REFERENCES employee(emp_id) ON DELETE SET NULL
);


CREATE TABLE order_items(
                            order_id INT,
                            item_id INT,
                            product_id INT,
                            quantity INT,
                            list_price DECIMAL(10, 2),
                            discount DECIMAL(3, 2),
                            PRIMARY KEY (order_id, item_id),
                            FOREIGN KEY (order_id) REFERENCES orders(order_id) ON DELETE CASCADE
);


CREATE TABLE product(
                        product_id INT PRIMARY KEY,
                        product_name VARCHAR(40),
                        category_id INT,
                        brand_id INT,
                        list_price DECIMAL(10, 2)
);

ALTER TABLE order_items
    ADD FOREIGN KEY (product_id)
        REFERENCES product(product_id)
        ON DELETE SET NULL;

CREATE TABLE category(
                         category_id INT PRIMARY KEY,
                         category_name VARCHAR(40)
);


CREATE TABLE brand(
                      brand_id INT PRIMARY KEY,
                      brand_name VARCHAR(40)
);

ALTER TABLE product
    ADD FOREIGN KEY (category_id)
        REFERENCES category(category_id)
        ON DELETE SET NULL;

ALTER TABLE product
    ADD FOREIGN KEY (brand_id)
        REFERENCES brand(brand_id)
        ON DELETE SET NULL;

CREATE TABLE availability(
                             store_id INT,
                             product_id INT,
                             quantity INT,
                             PRIMARY KEY (store_id, product_id),
                             FOREIGN KEY (store_id) REFERENCES store(store_id),
                             FOREIGN KEY (product_id) REFERENCES product(product_id)
);

CREATE TABLE supplier(
                         store_id INT,
                         supplier_id INT,
                         supplier_name VARCHAR(40),
                         product_id INT,
                         PRIMARY KEY (store_id, supplier_id, product_id),
                         FOREIGN KEY (store_id) REFERENCES store(store_id) ON DELETE CASCADE,
                         FOREIGN KEY (product_id) REFERENCES product(product_id) ON DELETE CASCADE
);