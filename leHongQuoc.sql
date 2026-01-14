-- phan 1
INSERT INTO customers (full_name, email, phone, city, join_date) VALUES
('Nguyễn Văn An', 'an@gmail.com', '0901111111', 'Hà Nội', '2024-01-05'),
('Trần Thị Bình', 'binh@gmail.com', '0902222222', 'TP.HCM', '2024-02-10'),
('Lê Văn Cường', 'cuong@gmail.com', NULL, 'Đà Nẵng', '2024-03-15'),
('Phạm Thị Dung', 'dung@gmail.com', '0903333333', 'Hà Nội', '2024-04-01'),
('Hoàng Văn Em', 'em@gmail.com', '0904444444', 'TP.HCM', '2024-04-20'),
('Vũ Thị Hoa', 'hoa@gmail.com', NULL, 'Cần Thơ', '2024-05-10'),
('Đặng Văn Long', 'long@gmail.com', '0905555555', 'Hà Nội', '2024-06-01'),
('Bùi Thị Mai', 'mai@gmail.com', '0906666666', 'TP.HCM', '2024-06-15'),
('Phan Văn Nam', 'nam@gmail.com', '0907777777', 'Huế', '2024-07-01'),
('Đỗ Thị Oanh', 'oanh@gmail.com', NULL, 'Hà Nội', '2024-07-10');


INSERT INTO products (product_name, category, price, stock_quantity) VALUES
('iPhone 15', 'Electronics', 25000000, 10),
('Samsung TV', 'Electronics', 18000000, 5),
('Laptop Dell', 'Electronics', 22000000, 8),
('Tai nghe Sony', 'Electronics', 3000000, 0),
('Chuột Logitech', 'Electronics', 800000, 20),

('Sách SQL Cơ Bản', 'Books', 150000, 50),
('Sách Python', 'Books', 200000, 40),
('Sách Data Science', 'Books', 350000, 30),
('Tiểu thuyết A', 'Books', 120000, 0),
('Tiểu thuyết B', 'Books', 180000, 25),

('Áo thun nam', 'Clothing', 250000, 60),
('Quần jeans', 'Clothing', 450000, 40),
('Áo khoác', 'Clothing', 650000, 15),
('Váy nữ', 'Clothing', 550000, 20),
('Giày sneaker', 'Clothing', 900000, 10);

INSERT INTO orders (customer_id, order_date, total_amount, status) VALUES
(1, '2024-07-01', 25000000, 'CONFIRMED'),
(2, '2024-07-02', 18000000, 'PENDING'),
(3, '2024-07-03', 150000, 'CONFIRMED'),
(4, '2024-07-04', 450000, 'CANCELLED'),
(5, '2024-07-05', 22000000, 'PENDING'),
(6, '2024-07-06', 650000, 'CONFIRMED'),
(7, '2024-07-07', 350000, 'SHIPPED'),
(8, '2024-07-08', 900000, 'PENDING');

UPDATE products
SET price = price * 1.10
WHERE category = 'Electronics';

UPDATE customers
SET phone = '0912345678'
WHERE email = 'hoa@gmail.com';

UPDATE orders
SET status = 'CONFIRMED'
WHERE status = 'PENDING';

DELETE FROM products
WHERE stock_quantity = 0;

DELETE FROM customers c
WHERE NOT EXISTS (
    SELECT 1
    FROM orders o
    WHERE o.customer_id = c.customer_id
);
-- phan 2
SELECT *
FROM customers
WHERE full_name ILIKE '%an%';

SELECT *
FROM products
WHERE price BETWEEN 500000 AND 1000000;

SELECT *
FROM customers
WHERE phone IS NULL;

SELECT *
FROM products
ORDER BY price DESC
LIMIT 5;

SELECT *
FROM orders
ORDER BY order_date
LIMIT 3 OFFSET 3;

SELECT city, COUNT(DISTINCT customer_id) AS total_customers
FROM customers
GROUP BY city;

SELECT *
FROM orders
WHERE order_date BETWEEN '2024-07-01' AND '2024-07-05';

SELECT p.*
FROM products p
WHERE NOT EXISTS (
    SELECT 1
    FROM orders o
    WHERE o.total_amount >= p.price
);

 