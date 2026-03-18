/*
Project: Meesho Sales Analysis
Level: Fresher (with ETL understanding)
Author: Avinash Vidyasagar Rao

Description:
End-to-end SQL project covering data validation, KPI analysis,
and business insights on e-commerce sales data.
*/

-- =============================
-- 1. DATABASE SETUP
-- =============================

CREATE DATABASE IF NOT EXISTS meesho_project;
USE meesho_project;

DROP TABLE IF EXISTS meesho_sales;

CREATE TABLE meesho_sales (
    order_id VARCHAR(50),
    order_date DATE,
    product_name VARCHAR(255),
    category VARCHAR(100),
    city VARCHAR(100),
    state VARCHAR(100),
    quantity INT,
    unit_price DECIMAL(10,2),
    discount DECIMAL(5,2),
    delivery_status VARCHAR(50),
    rating DECIMAL(3,1),
    total_sale DECIMAL(10,2)
);

-- =============================
-- 2. DATA VALIDATION
-- =============================

-- Total rows
SELECT COUNT(*) AS total_rows FROM meesho_sales;

-- Sample data
SELECT * FROM meesho_sales LIMIT 10;

-- Date range
SELECT MIN(order_date) AS start_date,
       MAX(order_date) AS end_date
FROM meesho_sales;

-- Check NULL values
SELECT * 
FROM meesho_sales
WHERE order_id IS NULL 
   OR product_name IS NULL;

-- Check invalid values
SELECT * 
FROM meesho_sales
WHERE quantity <= 0 OR unit_price <= 0;

-- Check duplicate orders
SELECT order_id, COUNT(*) AS order_count
FROM meesho_sales
GROUP BY order_id
HAVING COUNT(*) > 1;

SELECT order_id,
       COUNT(DISTINCT product_name) AS product_count
FROM meesho_sales
GROUP BY order_id
HAVING COUNT(*) > 1;

-- Remove exact duplicate rows
CREATE TABLE meesho_sales_clean AS
SELECT DISTINCT *
FROM meesho_sales;

-- Replace original table
DROP TABLE meesho_sales;
RENAME TABLE meesho_sales_clean TO meesho_sales;

-- =============================
-- 3. CORE KPIs
-- =============================

-- Total Revenue
SELECT ROUND(SUM(total_sale),2) AS total_revenue
FROM meesho_sales;

-- Total Orders
SELECT COUNT(DISTINCT order_id) AS total_orders
FROM meesho_sales;

-- Average Order Value
SELECT 
    ROUND(SUM(total_sale) / COUNT(DISTINCT order_id),2) AS avg_order_value
FROM meesho_sales;

-- Total Quantity Sold
SELECT SUM(quantity) AS total_quantity
FROM meesho_sales;

-- =============================
-- 4. BUSINESS ANALYSIS
-- =============================

-- Top 5 Products
SELECT product_name,
       ROUND(SUM(total_sale),2) AS revenue
FROM meesho_sales
GROUP BY product_name
ORDER BY revenue DESC
LIMIT 5;

-- Sales by Category
SELECT category,
       ROUND(SUM(total_sale),2) AS revenue
FROM meesho_sales
GROUP BY category
ORDER BY revenue DESC;

-- Sales by State
SELECT state,
       ROUND(SUM(total_sale),2) AS revenue
FROM meesho_sales
GROUP BY state
ORDER BY revenue DESC;

-- =============================
-- 5. DELIVERY ANALYSIS
-- =============================

SELECT delivery_status,
       COUNT(*) AS total_orders,
       ROUND(AVG(rating),2) AS avg_rating
FROM meesho_sales
GROUP BY delivery_status;

-- =============================
-- 6. DISCOUNT ANALYSIS
-- =============================

SELECT 
    CASE 
        WHEN discount = 0 THEN 'No Discount'
        ELSE 'Discount Applied'
    END AS discount_type,
    COUNT(*) AS orders,
    ROUND(SUM(total_sale),2) AS revenue,
    ROUND(AVG(total_sale),2) AS avg_order_value
FROM meesho_sales
GROUP BY discount_type;

-- =============================
-- 7. MONTHLY TREND
-- =============================

SELECT DATE_FORMAT(order_date, '%Y-%m') AS month,
       ROUND(SUM(total_sale),2) AS revenue
FROM meesho_sales
GROUP BY month
ORDER BY month;

-- =============================
-- 8. REVENUE CONTRIBUTION
-- =============================

SELECT state,
       ROUND(SUM(total_sale),2) AS revenue,
       ROUND(SUM(total_sale) * 100 /
            (SELECT SUM(total_sale) FROM meesho_sales),2) AS contribution_pct
FROM meesho_sales
GROUP BY state
ORDER BY revenue DESC
LIMIT 5;

-- =============================
-- KEY INSIGHTS
-- =============================

-- Top products and categories contribute majority of revenue
-- Discounts increase order volume but reduce average order value
-- Sales are concentrated in top states like Gujarat and Rajasthan
-- Delivery performance is strong with high customer ratings