CREATE DATABASE retail;
USE retail;
-- import the tables using wizard into workbench
DESC customer_profiles;
DESC product_inventory;
DESC sales_transaction;
-- Fixing the primary key of each column having typos error
ALTER TABLE customer_profiles
CHANGE ï»¿CustomerID CustomerID INT;
ALTER TABLE product_inventory
RENAME COLUMN ï»¿ProductID TO ProductId;
ALTER TABLE sales_transaction
RENAME COLUMN ï»¿TransactionID TO TransactionID;

-- Always spend time to understand the dataset.
SELECT * FROM customer_profiles;
SELECT * FROM product_inventory;
SELECT * FROM sales_transaction;
SELECT COUNT(*) FROM sales_transaction;

-- Identify and eliminate duplicate records from the sales_transaction 
-- table to ensure clean and accurate data analysis.

SELECT 
	TransactionID,
	COUNT(*) AS Trxn_count
FROM sales_transaction
GROUP BY 1
HAVING Trxn_count > 1;

SELECT * 
FROM sales_transaction 
WHERE TransactionID = 5000;

CREATE TABLE sales_trxn_unique AS 
SELECT 
	DISTINCT *
FROM sales_transaction;

SELECT * 
FROM sales_trxn_unique 
WHERE TransactionID = 5000;

DROP TABLE sales_transaction;
ALTER TABLE sales_trxn_unique 
RENAME TO sales_transaction;

SELECT * FROM customer_profiles;
SELECT * FROM product_inventory;
SELECT * FROM sales_transaction;

-- Ensure consistency between sales prices in the sales_transaction data 
-- and the product_inventory

SELECT
	s.ProductID,
    s.TransactionID,
    s.price AS TrxnPrice,
    p.price AS InventoryPrice
FROM sales_transaction AS s 
JOIN product_inventory AS p
ON s.ProductId = p.ProductId
WHERE p.price != s.price;
    
SELECT * FROM sales_transaction WHERE productID = 51;
UPDATE sales_transaction
SET Price = 93.12
WHERE ProductID = 51;

UPDATE sales_transaction AS s
SET Price = (
	SELECT 
		p.price 
	FROM product_inventory AS p 
    WHERE s.productID = p.productID
)
WHERE s.ProductID IN (
	SELECT ProductID FROM product_inventory AS p
    WHERE s.Price <> p.Price
);

-- Verifying the above subquery
-- SELECT 
-- 	p.price 
-- FROM product_inventory AS p 
-- JOIN sales_transaction AS s
-- WHERE s.productID = p.PRoductID;

-- Finding the missing Values
USE retail;
DESC customer_profiles;
SELECT DISTINCT Location FROM customer_profiles;
SELECT Count(Location) FROM Customer_profiles WHERE Location = "";
-- UPDATE the empty cells with Unknown. 
UPDATE customer_profiles
SET Location = "Unknown"
WHERE Location = "";

DESC sales_transaction;
-- Convert the TransactionDate column from text to DATE format for time-based analysis.
CREATE TABLE sales_trxn_backup AS 
SELECT *, CAST(TransactionDate AS DATE) AS new_trxn_date
FROM sales_transaction;

SELECT * FROM sales_trxn_backup;
SELECT * FROM sales_transaction;
DROP TABLE sales_transaction;
ALTER TABLE sales_trxn_backup
RENAME TO sales_transaction;
ALTER TABLE sales_transaction
DROP COLUMN TransactionDate;
ALTER TABLE sales_transaction
RENAME COLUMN new_trxn_date TO TransactionDate;

-- Analyze which products are generating the most sales and units sold.
SELECT * FROM sales_transaction;
SELECT 
	ProductID,
    ROUND(SUM(QuantityPurchased * Price),0) AS TotalSales,
    SUM(QuantityPurchased) AS TotalUnitSold
FROM sales_transaction
GROUP BY ProductID
ORDER BY TotalSales DESC;

-- Identify customers based on how frequently they make purchases.
SELECT 
	CustomerID,
    COUNT(*) AS Transaction_count
FROM sales_transaction
GROUP BY CustomerID
ORDER BY Transaction_count DESC;

-- Evaluate which product categories generate the most revenue & TotalUnitSold.
SELECT * FROM product_inventory;
SELECT * FROM sales_transaction;

SELECT 
	p.Category,
    ROUND(SUM(s.QuantityPurchased * s.Price),0) AS TotalRevenue,
    SUM(s.QuantityPurchased) AS TotalUnitSold
FROM product_inventory p
JOIN sales_transaction s
ON p.ProductID = s.ProductID
GROUP BY p.Category
ORDER BY TotalRevenue DESC;

-- Identify the top 10 products based on total revenue generated.
SELECT * FROM sales_transaction;
SELECT
	ProductID,
    ROUND(SUM(QuantityPurchased * Price),0) AS TotalRevenue
FROM sales_transaction
GROUP BY ProductID
ORDER BY TotalRevenue DESC
LIMIT 10;

-- Find the bottom 10 products with the lowest units sold (but > 0).
SELECT * FROM sales_transaction;
SELECT
	ProductId,
    SUM(QuantityPurchased) AS TotalUnitSold
FROM sales_transaction
GROUP BY ProductId
HAVING TotalUnitSold > 0
ORDER BY TotalUnitSold ASC
LIMIT 10;

USE retail;
DESC customer_profiles;
DESC sales_transaction;
SELECT * FROM sales_transaction;

-- Understand how daily sales and transaction volume fluctuate over time.
SELECT
	CAST(TransactionDate AS DATE) AS DATETRANS,
    COUNT(*) AS Transaction_count,
    SUM(QuantityPurchased) AS TotalUnitSold,
    ROUND(SUM(QuantityPurchased * Price),0) AS TotalSales
FROM sales_transaction
GROUP BY 1
ORDER BY 1 DESC;


SELECT
	TransactionDate,
    COUNT(*) AS Transaction_count,
    SUM(QuantityPurchased) AS TotalUnitSold,
    ROUND(SUM(QuantityPurchased * Price),0) AS TotalSales
FROM sales_transaction
GROUP BY 1
ORDER BY 1 DESC;

-- Analyze how total monthly sales are growing or declining over time.
SELECT * FROM sales_transaction;
WITH Monthly_sales AS (
	SELECT 
		EXTRACT(MONTH FROM TransactionDate) As month,
		ROUND(SUM(QuantityPurchased * Price),0) AS total_sales
     FROM sales_transaction
     GROUP BY EXTRACT(MONTH FROM TransactionDate)
)
SELECT month,
total_sales,
LAG(total_sales) OVER (Order BY Month) AS previous_month_sales,
ROUND(((total_sales - LAG(total_sales) OVER (Order BY Month))/
LAG(total_sales) OVER (Order BY Month)) * 100,2) AS mom_growth_percentage
FROM Monthly_sales
ORDER BY Month;


-- Identify customers who purchase frequently and spend significantly.
SELECT * FROM sales_transaction;

SELECT 
	CustomerID,
    COUNT(*) AS NumberOfTransactions,
    SUM(QuantityPurchased * Price) AS TotalSpent
FROM sales_transaction
GROUP BY CustomerID
HAVING TotalSpent > 1000 AND NumberOfTransactions > 10
ORDER BY TotalSpent DESC;

-- Detect low-frequency, low-spend customers for re-engagement strategies.
SELECT 
	CustomerID,
    COUNT(*) AS NumberOfTransactions,
    SUM(QuantityPurchased * Price) AS TotalSpent
FROM sales_transaction
GROUP BY CustomerID
HAVING NumberOfTransactions <=2
ORDER BY NumberOfTransactions, TotalSpent DESC;

-- Track which customers repeatedly purchase the same product.
SELECT * FROM sales_transaction;
SELECT 
	CustomerID,
    ProductID,
    COUNT(*) AS TimesPurchased
FROM sales_transaction
GROUP BY CustomerID,ProductID
HAVING TimesPurchased > 1
ORDER BY TimesPurchased DESC;

USE retail;
SELECT * FROM product_inventory;
SELECT * FROM sales_transaction;

-- Measure customer loyalty based on time between first and last purchases.
WITH transactionDate AS(
	SELECT
		CustomerID,
        TransactionDate
	FROM sales_transaction
)
SELECT
	CustomerID,
    MIN(TransactionDate) AS FirstPurchase,
    MAX(TransactionDate) AS LastPurchase,
    DATEDIFF(MAX(TransactionDate),MIN(TransactionDate)) AS DaysBetweenPurchases
FROM transactionDate
GROUP BY CustomerID
HAVING DaysBetweenPurchases > 0
ORDER BY DaysBetweenPurchases DESC;

-- Group customers into segments based on the total quantity of products they purchased.
DESC `customer_profiles`;
CREATE TABLE customer_segment AS 
SELECT	
	CustomerID,
    CASE
		WHEN TotalQty > 30 THEN 'High'
        WHEN TotalQty BETWEEN 11 AND 30 THEN 'Mid'
        WHEN TotalQty BETWEEN 1 AND 10 THEN 'Low'
    END AS CustomerSegment
FROM (
	SELECT
		c.CustomerID,
        SUM(s.QuantityPurchased) AS TotalQty
	FROM customer_profiles c 
    JOIN sales_transaction s 
    ON c.CustomerID = s.CustomerID
    GROUP BY c.CustomerID
) AS customer_total;

SELECT * FROM `customer_segment`;

SELECT 
	CustomerSegment,
    COUNT(*)
FROM customer_segment
GROUP BY 1;

-- ALTER TABLE + FOREIGN KEY
CREATE TABLE Customers(
	customer_id INT PRIMARY KEY,
    name VARCHAR(100)
);
CREATE TABLE Orders(
	order_id INT PRIMARY KEY,
    customer_id INT,
    order_date DATETIME DEFAULT CURRENT_TIMESTAMP
);
DESC Customers;
DESC Orders;

INSERT INTO customers (customer_id, name) VALUES
(1, 'Abhishek Behal'),
(2, 'Rohit Sharma'),
(3, 'Priya Singh'),
(4, 'Anjali Mehta'),
(5, 'Vikram Rao'),
(6, 'Neha Verma'),
(7, 'Amit Patel'),
(8, 'Kavita Desai'),
(9, 'Raj Malhotra'),
(10, 'Sneha Kapoor');

INSERT INTO orders (Order_ID, Customer_ID) VALUES
(101, 1),
(102, 2),
(103, 3),
(104, 4),
(105, 5),
(106, 1),
(107, 2),
(108, 3),
(109, 6),
(110, 7);

SELECT * FROM Customers;
SELECT * FROM Orders;

-- ALTER command to create customer_id AS F.K in Orders Table
ALTER TABLE Orders
ADD CONSTRAINT fk_customer
FOREIGN KEY (customer_id)
REFERENCES Customers(customer_id)
ON DELETE CASCADE;

DESC Orders;
SELECT * FROM Customers;
SELECT * FROM Orders;
-- DELETE something from parent table [P.K] to see the effect on child Table
DELETE FROM Customers WHERE customer_id = 7;

ALTER TABLE Orders
ADD CONSTRAINT fk_customer_update_cascade
FOREIGN KEY (customer_id)
REFERENCES Customers(customer_id)
ON UPDATE CASCADE;

ALTER TABLE Orders 
DROP Constraint fk_customer_update_cascade;

UPDATE Customers 
SET customer_id = 11
WHERE customer_id = 6;

SELECT * FROM Customers;
SELECT * FROM Orders;


ALTER TABLE Orders
ADD CONSTRAINT fk_customer
FOREIGN KEY (customer_id)
REFERENCES Customers(customer_id)
ON DELETE SET NULL;

DELETE FROM Customers WHERE customer_id = 11;
SELECT * FROM Customers;
SELECT * FROM Orders;

ALTER TABLE Orders 
DROP Constraint fk_customer;

DESC Orders;
ALTER TABLE Orders
MODIFY Customer_id INT DEFAULT 0;

ALTER TABLE Orders
ADD CONSTRAINT fk_customer_no_action
FOREIGN KEY (customer_id)
REFERENCES Customers(customer_id)
ON DELETE NO ACTION;

DELETE FROM Customers WHERE customer_id = 1;
-- Error Code: 1451. Cannot delete or update a parent row: a foreign key constraint fails 
-- (`retail`.`orders`, CONSTRAINT `fk_customer_no_action` FOREIGN KEY (`Customer_id`) 
-- REFERENCES `customers` (`customer_id`))
