CREATE DATABASE QUANLYBANHANG;
USE QUANLYBANHANG;
CREATE TABLE Customers(
customer_id VARCHAR(4) PRIMARY KEY NOT NULL,
name VARCHAR(100) NOT NULL,
email VARCHAR(100) NOT NULL,
phone VARCHAR(25) NOT NULL,
address VARCHAR(255) NOT NULL
);
DROP TRIGGER IF EXISTS before_insert_Customers;
DELIMITER $$
CREATE TRIGGER before_insert_Customers
BEFORE INSERT ON Customers
FOR EACH ROW
BEGIN
    DECLARE max_id INT;
    DECLARE new_id VARCHAR(4);
    SELECT IFNULL(MAX(CAST(SUBSTRING(customer_id, 2, 3) AS UNSIGNED)), 0) INTO max_id FROM Customers;
    SET new_id = CONCAT('C', LPAD(max_id + 1, 3, '0'));
    SET NEW.customer_id = new_id;
END $$
DELIMITER ;

INSERT INTO Customers(name,email,phone,address) VALUES
('Nguyễn Trung Mạnh','manhnt@gmail.com','0984756332','Cầu Giấy, Hà Nội'),
('Hỗ Hải Nam','namhh@gmail.com','0984875926','Ba Vì, Hà Nội'),
('Tô Ngọc Vũ','vutn@gmail.com','0904725784','Mộc Châu, Sơn La'),
('Phạm Ngọc Anh','anhpn@gmail.com','0984635365','Vinh, Nghệ An'),
('Trương Minh Cường','cuongtm@gmail.com','0989735624','Hai Bà Trưng, Hà Nội');

CREATE TABLE Products(
product_id VARCHAR(4) PRIMARY KEY NOT NULL,
name VARCHAR(255) NOT NULL,
description TEXT,
price DOUBLE NOT NULL,
status BIT(1) NOT NULL
);

DELIMITER $$
CREATE TRIGGER before_insert_Products
BEFORE INSERT ON Products
FOR EACH ROW
BEGIN
    DECLARE max_id INT;
    DECLARE new_id VARCHAR(4);
    SELECT IFNULL(MAX(CAST(SUBSTRING(product_id, 2, 3) AS UNSIGNED)), 0) INTO max_id FROM Products;
    SET new_id = CONCAT('P', LPAD(max_id + 1, 3, '0'));
    SET NEW.product_id = new_id;
END $$
DELIMITER ;

INSERT INTO Products(name,description,price,status) VALUES
('Iphone13ProMax','Bản 512GB, xanh lá',22999999,1),
('Dell Vostro V3510','Core i5,RAM 8GB',14999999,1),
('Macbook Pro M2','8CPU 10GPU 8GB 256GB',28999999,1),
('Apple Watch Ultra','Titanium Alpine Loop Small',18999999,1),
('Airpods 2 2022','Spatial Audio',4090000,1);
SELECT * FROM Products;

CREATE TABLE Orders(
order_id VARCHAR(4) PRIMARY KEY NOT NULL,
customer_id VARCHAR(4) NOT NULL REFERENCES Customers(customer_id) ,
order_date DATE NOT NULL,
total_amount DOUBLE NOT NULL
);

DROP TRIGGER IF EXISTS before_insert_Orders;
DELIMITER $$
CREATE TRIGGER before_insert_Orders
BEFORE INSERT ON Orders
FOR EACH ROW
BEGIN
    DECLARE max_id INT;
    DECLARE new_id VARCHAR(4);
    SELECT IFNULL(MAX(CAST(SUBSTRING(order_id, 2, 3) AS UNSIGNED)), 0) INTO max_id FROM Orders;
    SET new_id = CONCAT('H', LPAD(max_id + 1, 3, '0'));
    SET NEW.order_id = new_id;
END $$
DELIMITER ;

INSERT INTO Orders(customer_id,order_date,total_amount) VALUES
('C001','2023-02-22',52999997),
('C001','2023-03-11',80999997),
('C002','2023-01-22',54359998),
('C002','2023-03-14',102999995),
('C003','2022-03-12',80999997),
('C004','2023-02-01',110449994),
('C004','2023-03-29',79999996),
('C005','2023-02-14',29999998),
('C005','2023-01-10',28999999),
('C005','2023-04-01',149999994);
SELECT* FROM Orders;

CREATE TABLE Orders_details(
order_id VARCHAR(4) NOT NULL REFERENCES Orders(order_id) ,
product_id VARCHAR(4) NOT NULL REFERENCES Products(product_id),
price DOUBLE NOT NULL,
quantity INT(11) NOT NULL,
PRIMARY KEY (order_id,product_id)
);
INSERT INTO Orders_details VALUES
('H001','P002','14999999',1),
('H001','P004','18999999',2),

('H002','P001','22999999',1),
('H002','P003','28999999',2),

('H003','P004','18999999',2),
('H003','P005','4090000',4),

('H004','P002','14999999',3),
('H004','P003','28999999',2),

('H005','P001','22999999',1),
('H005','P003','28999999',2),

('H006','P005','4090000',5),
('H006','P002','14999999',6),

('H007','P004','18999999',3),
('H007','P001','22999999',1),

('H008','P002','14999999',2),
('H009','P003','28999999',1),

('H010','P003','28999999',2),
('H010','P001','22999999',4);

-- ---------------------
-- Bài 3: Truy vấn dữ liệu [30 điểm]:
-- 1. Lấy ra tất cả thông tin gồm: tên, email, số điện thoại và địa chỉ trong bảng Customers .
-- [4 điểm]

SELECT name,email,phone,address FROM Customers ;

-- 2. Thống kê những khách hàng mua hàng trong tháng 3/2023 
-- (thông tin bao gồm tên, số điện thoại và địa chỉ khách hàng). [4 điểm]
SELECT DISTINCT Customers.name,Customers.phone,Customers.address  FROM Orders
LEFT JOIN Customers USING (customer_id)
WHERE Orders.order_date BETWEEN '2023-03-01' AND '2023-03-31';

-- 3. Thống kê doanh thu theo từng tháng của cửa hàng trong năm 2023 (thông tin bao gồm tháng và tổng doanh thu ). 
-- [4 điểm]
SELECT * FROM Orders;
SELECT MONTH(order_date) as Month, Sum(total_amount) AS Revenue FROM Orders
WHERE order_date BETWEEN '2023-01-01' AND '2023-12-31'
GROUP BY MONTH(order_date)
ORDER BY Month;

-- 4. Thống kê những người dùng không mua hàng trong tháng 2/2023 
-- (thông tin gồm tên khách hàng, địa chỉ , email và số điên thoại). [4 điểm]
SELECT name,email,phone,address FROM Customers
WHERE customer_id NOT IN (
SELECT Customers.customer_id FROM Orders 
LEFT JOIN Customers USING (customer_id)
WHERE Orders.order_date BETWEEN '2023-02-01' AND '2023-02-28'
);

-- 5. Thống kê số lượng từng sản phẩm được bán ra trong tháng 3/2023
-- (thông tin bao gồm mã sản phẩm, tên sản phẩm và số lượng bán ra). [4 điểm]
SELECT * FROM Orders;
SELECT * FROM Orders_details;
SELECT Products.product_id,Products.name , SUM(Orders_details.quantity) AS Total_sale FROM Orders_details
LEFT JOIN Orders USING (order_id)
LEFT JOIN Products USING (product_id)
WHERE Orders.order_date BETWEEN '2023-03-01' AND '2023-03-31'
GROUP BY Products.product_id
ORDER BY Products.product_id;

-- 6. Thống kê tổng chi tiêu của từng khách hàng trong năm 2023 sắp xếp giảm dần theo mức chi
-- tiêu (thông tin bao gồm mã khách hàng, tên khách hàng và mức chi tiêu). [5 điểm]
SELECT Customers.customer_id,Customers.name, SUM(Orders.total_amount) AS Total FROM Orders
LEFT JOIN Customers USING(customer_id)
WHERE Orders.order_date BETWEEN '2023-01-01' AND '2023-12-31'
GROUP BY Customers.customer_id;

-- 7. Thống kê những đơn hàng mà tổng số lượng sản phẩm mua từ 5 trở lên
-- (thông tin bao gồm tên người mua, tổng tiền , ngày tạo hoá đơn, tổng số lượng sản phẩm) . [5 điểm] 
CREATE VIEW order_Qty_g5 AS
SELECT 
    order_id,
    SUM(price * quantity) AS Total_Bill,
    SUM(quantity) AS Total_qty,
    Orders.order_date,
    customer_id
FROM Orders_details
JOIN Orders USING (order_id)
GROUP BY order_id;
SELECT * FROM order_Qty_g5 ;
-- -------------------
SELECT
	Customers.name,
    SUM(price * quantity) AS Total_Bill,
    Orders.order_date,
    SUM(quantity) AS Total_qty
FROM Orders_details
JOIN Orders USING (order_id)
LEFT JOIN Customers USING(customer_id)
GROUP BY order_id
HAVING Total_qty> 5;

-- Bài 4: Tạo View, Procedure [30 điểm]: 
-- 1. Tạo VIEW lấy các thông tin hoá đơn bao gồm :
--  Tên khách hàng, số điện thoại, địa chỉ, tổng tiền và ngày tạo hoá đơn . [3 điểm]

SELECT * FROM Orders ;
SELECT * FROM Orders_details ;
CREATE VIEW Bill_info AS
SELECT Customers.name, Customers.phone,Customers.address, 
		Orders.total_amount, Orders.order_date
FROM Orders 
LEFT JOIN Customers USING (customer_id);
SELECT * FROM Bill_info;

-- 2. Tạo VIEW hiển thị thông tin khách hàng gồm : tên khách hàng, địa chỉ, số điện thoại và tổng số đơn đã đặt. [3 điểm]
SELECT * FROM Orders;
CREATE VIEW Customer_totalBill AS
SELECT Customers.name,Customers.address,Customers.phone,COUNT(order_id) FROM order_Qty_g5
LEFT JOIN Customers USING (customer_id)
GROUP BY customer_id;
SELECT * FROM Customer_totalBill;
-- 3. Tạo VIEW hiển thị thông tin sản phẩm gồm: tên sản phẩm, mô tả, giá và tổng số lượng đã bán ra của mỗi sản phẩm.

SELECT * FROM Orders_details ;

CREATE VIEW Product_Sale AS
SELECT Products.name,Products.description,Products.price, SUM(quantity)
FROM Orders_details
LEFT JOIN Products USING (product_id)
GROUP BY product_id;

SELECT * FROM Product_Sale ;

-- 4. Đánh Index cho trường `phone` và `email` của bảng Customer. [3 điểm]

CREATE INDEX index_phone
ON Customers (phone);
CREATE INDEX index_email
ON Customers (email);

-- 5. Tạo PROCEDURE lấy tất cả thông tin của 1 khách hàng dựa trên mã số khách hàng.[3 điểm]
SELECT * FROM Customers ;

DELIMITER $$
CREATE PROCEDURE get_customer_byID( IN id VARCHAR(4))
BEGIN
	SELECT * FROM Customers 
    WHERE customer_id = id;
END $$
DELIMITER ;

CALL get_customer_byID('C001');

-- 6. Tạo PROCEDURE lấy thông tin của tất cả sản phẩm. [3 điểm]
SELECT * FROM Products ;

DELIMITER $$
CREATE PROCEDURE get_all_product()
BEGIN
	SELECT * FROM Products ;
END $$
DELIMITER ;

CALL get_all_product();

-- 7. Tạo PROCEDURE hiển thị danh sách hoá đơn dựa trên mã người dùng. [3 điểm]
SELECT * FROM Orders ;

DELIMITER $$
CREATE PROCEDURE get_order_byCuStomerID(IN id VARCHAR(4))
BEGIN
	SELECT * FROM Orders 
    WHERE customer_id = id;
END $$
DELIMITER ;

CALL get_order_byCuStomerID('C001');

-- 8. Tạo PROCEDURE tạo mới một đơn hàng với các tham số là 
-- mã khách hàng, tổng tiền và ngày tạo hoá đơn, và hiển thị ra mã hoá đơn vừa tạo. [3 điểm]
SELECT * FROM Orders ;

DROP PROCEDURE IF EXISTS Add_new_order_getID;
DELIMITER $$
CREATE PROCEDURE Add_new_order_getID(
IN customer_id_new varchar(4),
IN order_date_new date, 
IN total_amount_new double,
OUT ID varchar(4))
BEGIN
	INSERT INTO Orders(customer_id, order_date, total_amount) VALUES
    (customer_id_new,order_date_new,total_amount_new);
    SET ID = (SELECT order_id FROM Orders ORDER BY order_id DESC LIMIT 1);
END $$
DELIMITER ;

SELECT * FROM Orders;
SELECT * FROM Orders_details;
CALL Add_new_order_getID('C002', '2024-09-25', 14999999, @ID);
SELECT @ID;

-- 9. Tạo PROCEDURE thống kê số lượng bán ra của mỗi sản phẩm trong khoảng thời gian cụ thể
-- với 2 tham số là ngày bắt đầu và ngày kết thúc. [3 điểm]
DROP PROCEDURE IF EXISTS Sale_by_date;
DELIMITER $$
CREATE PROCEDURE Sale_by_date(
IN date1 date, 
IN date2 date
)
BEGIN
	SELECT Products.*, SUM(quantity) AS Total_sale
FROM Orders_details
LEFT JOIN Products USING (product_id)
LEFT JOIN Orders USING (order_id)
WHERE Orders.order_date BETWEEN date1 AND date2
GROUP BY product_id;
END $$
DELIMITER ;
CALL Sale_by_date ('2023-04-01','2023-04-30');

-- 10. Tạo PROCEDURE thống kê số lượng của mỗi sản phẩm được bán ra theo thứ tự giảm dần
-- của tháng đó với tham số vào là tháng và năm cần thống kê. [3 điểm]
DROP PROCEDURE IF EXISTS Sale_by_month;
DELIMITER $$
CREATE PROCEDURE Sale_by_month(
IN month_check INT, 
IN year_check INT
)
BEGIN
	SELECT Products.*, SUM(quantity) AS Month_sale
	FROM Orders_details
	LEFT JOIN Products USING (product_id)
	LEFT JOIN Orders USING (order_id)
	WHERE YEAR(order_date) = year_check
    AND MONTH(order_date) = month_check
	GROUP BY product_id
    ORDER BY SUM(quantity) DESC;
END $$
DELIMITER ;

CALL Sale_by_month (3,2023);












