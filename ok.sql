-- ==============================
-- HỆ THỐNG QUẢN LÝ BÁN HÀNG ĐIỆN TỬ
-- ==============================

-- ===== 1. BẢNG CATEGORIES =====
CREATE TABLE categories (
    category_id SERIAL PRIMARY KEY,
    category_name VARCHAR(100) NOT NULL UNIQUE,
    description VARCHAR(255)
);

INSERT INTO categories (category_name, description) VALUES
('Laptop', 'Các dòng máy tính xách tay'),
('Smartphone', 'Điện thoại thông minh'),
('Phụ kiện', 'Phụ kiện điện tử'),
('Thiết bị mạng', 'Router, modem, wifi');

-- ===== 2. BẢNG CUSTOMERS =====
CREATE TABLE customers (
    customer_id SERIAL PRIMARY KEY,
    customer_name VARCHAR(100) NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL,
    city VARCHAR(100),
    join_date DATE DEFAULT CURRENT_DATE
);

INSERT INTO customers (customer_name, email, city, join_date) VALUES
('Nguyễn Văn An', 'an@gmail.com', 'Hà Nội', '2024-01-10'),
('Trần Thị Bình', 'binh@gmail.com', 'TP Hồ Chí Minh', '2024-02-15'),
('Lê Quốc Cường', 'cuong@gmail.com', 'Đà Nẵng', '2024-03-05'),
('Phạm Minh Đức', 'duc@gmail.com', 'Hà Nội', '2024-03-20');

-- ===== 3. BẢNG PRODUCTS =====
CREATE TABLE products (
    product_id SERIAL PRIMARY KEY,
    product_name VARCHAR(150) NOT NULL,
    category VARCHAR(100),
    price DECIMAL(12,2) NOT NULL CHECK (price > 0),
    stock_quantity INT NOT NULL CHECK (stock_quantity >= 0)
);

INSERT INTO products (product_name, category, price, stock_quantity) VALUES
('Laptop Dell XPS 13', 'Laptop', 25000000, 10),
('MacBook Air M2', 'Laptop', 28000000, 8),
('iPhone 15', 'Smartphone', 23000000, 15),
('Samsung Galaxy S23', 'Smartphone', 20000000, 12),
('Chuột Logitech MX Master', 'Phụ kiện', 2500000, 30),
('Router TP-Link AX3000', 'Thiết bị mạng', 1800000, 20);

-- ===== 4. BẢNG ORDERS =====
CREATE TABLE orders (
    order_id SERIAL PRIMARY KEY,
    customer_id INT NOT NULL REFERENCES customers(customer_id),
    order_date DATE DEFAULT CURRENT_DATE,
    total_amount DECIMAL(14,2),
    status VARCHAR(50) CHECK (status IN ('Pending', 'Completed', 'Cancelled'))
);

INSERT INTO orders (customer_id, order_date, total_amount, status) VALUES
(1, '2024-04-01', 50500000, 'Completed'),
(2, '2024-04-03', 23000000, 'Completed'),
(3, '2024-04-05', 4300000, 'Pending'),
(1, '2024-04-10', 1800000, 'Cancelled');

-- ===== 5. BẢNG ORDER_ITEMS =====
CREATE TABLE order_items (
    item_id SERIAL PRIMARY KEY,
    order_id INT NOT NULL REFERENCES orders(order_id),
    product_id INT NOT NULL REFERENCES products(product_id),
    quantity INT NOT NULL CHECK (quantity > 0),
    unit_price DECIMAL(12,2) NOT NULL CHECK (unit_price > 0)
);

INSERT INTO order_items (order_id, product_id, quantity, unit_price) VALUES
(1, 1, 1, 25000000),
(1, 5, 1, 2500000),
(2, 3, 1, 23000000),
(3, 6, 2, 1800000),
(4, 6, 1, 1800000);

-- Phần 1
select product_name "Tên SP", price "Đơn giá" from products;
select count(customer_id), city
from customers
group by city;

select category, max(price) "giá cao nhất",min(price) "Thấp nhất",avg(price) "Trung bình"
from products
group by category;

select status, count(order_id) "SÔ đơn hàng"
from orders
group by status;


-- Phần 2
select c.customer_name, count(order_id)
from customers c
join orders o
on o.customer_id = c.customer_id
group by c.customer_name
having count(order_id) >=3;

select category, sum(stock_quantity)
from products
group by category
having sum(stock_quantity)> 100;

select count(customer_id), city
from customers
group by city
having count(customer_id) >=5;

select sum(ot.quantity), p.product_name
from order_items ot
join products p
on ot.product_id = p.product_id
group by  p.product_name
having sum(ot.quantity) >50;

-- phần 3
select c.customer_name
from customers c
where customer_id = (
select customer_id
from orders
where total_amount =(
select max(total_amount)
from orders
)
)



select product_name
from products
where product_name not in (
select p.product_name
from order_items ot
join products p
on ot.product_id = p.product_id
group by p.product_name
)

select *
from products
where price > (
SELECT ROUND(AVG(price)::numeric, 1)
FROM products
)

-- JOINS

select o.*, c.customer_name,c.email
from orders o
join customers c
on o.customer_id = c.customer_id

select o.*, c.customer_name,c.email
from orders o
left join customers c
on o.customer_id = c.customer_id

select oi.*,p.*
from order_items oi
left join products p
on oi.product_id = p.product_id

select category
from products

select *
from categories

-- Phan 5
SELECT email FROM customers
UNION
SELECT email FROM marketing_emails;

SELECT o.customer_id
FROM orders o
JOIN order_items oi ON o.order_id = oi.order_id
JOIN products p ON oi.product_id = p.product_id
WHERE p.category = 'Electronics'

INTERSECT

SELECT o.customer_id
FROM orders o
JOIN order_items oi ON o.order_id = oi.order_id
JOIN products p ON oi.product_id = p.product_id
WHERE p.category = 'Books';

SELECT o.customer_id
FROM orders o
JOIN order_items oi ON o.order_id = oi.order_id
JOIN products p ON oi.product_id = p.product_id
WHERE p.category IN ('Electronics', 'Books')
GROUP BY o.customer_id
HAVING COUNT(DISTINCT p.category) = 2;
SELECT o.customer_id
FROM orders o
JOIN order_items oi ON o.order_id = oi.order_id
JOIN products p ON oi.product_id = p.product_id
WHERE p.category IN ('Electronics', 'Books')
GROUP BY o.customer_id
HAVING COUNT(DISTINCT p.category) = 2;



