/*This SQL script performs exploratory analysis on a retail sales database consisting of dimension tables 
(dim_customers, dim_products) and a fact table (gold_fact_sales)
*/

/*
===============================================================================
Database Exploration
===============================================================================
Purpose:
    - To explore the structure of the database, including the list of tables and their schemas.
    - To inspect the columns and metadata for specific tables.

Table Used:
    - INFORMATION_SCHEMA.TABLES
    - INFORMATION_SCHEMA.COLUMNS
===============================================================================
*/
--Explore all objects in the Database
SELECT * FROM INFORMATION_SCHEMA.TABLES --provides information about the database e.g table schema, table name, table type

---Explore all columns in the database
SELECT * FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_NAME = 'dim_customers'

---Exploring the countries where all the customers come from
SELECT DISTINCT country FROM gold.dim_customers

---Exploring all product categories 'The major divisions'
SELECT DISTINCT 
category,
subcategory,
product_name
FROM gold.dim_products
ORDER BY 1,2,3

  /*
===============================================================================
Date Range Exploration 
===============================================================================
Purpose:
    - To determine the temporal boundaries of key data points.
    - To understand the range of historical data.

SQL Functions Used:
    - MIN(), MAX(), DATEDIFF()
===============================================================================
*/
---Finding the data of the first and last order
---How many years of sales are available
SELECT
	MIN(order_date) AS first_order,
	MAX(order_date) AS last_order,
	DATEDIFF(year, MIN(order_date), MAX(order_date)) AS order_range_years
FROM gold_fact_sales

--Find the youngest and oldest customer
SELECT
	MIN(birthdate) AS youngest_birthdate,
	DATEDIFF(year, MIN(birthdate), GETDATE()) AS oldest_age,
	MAX(birthdate) oldest_birthdate,
	DATEDIFF(year, MAX(birthdate), GETDATE()) AS youngest_age
FROM gold.dim_customers

SELECT * FROM gold_fact_sales

/*
===============================================================================
Measures Exploration (Key Metrics)
===============================================================================
Purpose:
    - To calculate aggregated metrics (e.g., totals, averages) for quick insights.
    - To identify overall trends or spot anomalies.

SQL Functions Used:
    - COUNT(), SUM(), AVG()
===============================================================================
*/
---Find the total sales
SELECT 
	SUM(sales_amount) AS total_sales
FROM gold_fact_sales

---Find how many items are sold
SELECT 
	SUM(quantity) AS tota_quantity
FROM gold_fact_sales

---Find the average selling price
SELECT 
	AVG(price) AS avg_price
FROM gold_fact_sales
---Find the total number of orders
SELECT 
	COUNT(order_number) AS total_orders,
	COUNT(DISTINCT order_number) AS total_orders
FROM gold_fact_sales
---Find the total number of products
SELECT 
	COUNT(product_key) AS total_products
FROM gold.dim_products

SELECT 
	COUNT(DISTINCT product_key) AS total_products
FROM gold.dim_products

---Find the total number of customers
SELECT
	COUNT(customer_key) AS totsl_customers
FROM gold.dim_customers
---Find the total number of customers that has placed an order
SELECT 
	COUNT(DISTINCT customer_key) AS total_customers
FROM gold_fact_sales

---Generate a reprot that shows all key metrics of the business

SELECT 
	'total sales' AS measure_name,
	SUM(sales_amount) AS measure_value 
FROM gold_fact_sales
UNION ALL
SELECT 
	'average price',
	AVG(price)
FROM gold_fact_sales
UNION ALL
SELECT 
	'total quantity',
	SUM(quantity) 
FROM gold_fact_sales
UNION ALL
SELECT 
	'total nr. orders',
	COUNT(DISTINCT order_number) 
FROM gold_fact_sales
UNION ALL
SELECT 
	'total nr. products',
	COUNT(product_name) 
FROM gold.dim_products
UNION ALL
SELECT 
	'total nr. customers',
	COUNT(customer_key) 
FROM gold.dim_customers

/*
===============================================================================
Magnitude Analysis
===============================================================================
Purpose:
    - To quantify data and group results by specific dimensions.
    - For understanding data distribution across categories.

SQL Functions Used:
    - Aggregate Functions: SUM(), COUNT(), AVG()
    - GROUP BY, ORDER BY
===============================================================================
*/

---Find total customers by countries
SELECT 
	country,
	COUNT(customer_key) AS total_customers
FROM gold.dim_customers
GROUP BY country
ORDER BY total_customers DESC
---Find total customers by gender
SELECT
new_gender,
COUNT(customer_key) AS total_customers
FROM gold.dim_customers
GROUP BY new_gender
ORDER BY total_customers
---Find total products by category
SELECT
category,
COUNT(product_key) AS total_products
FROM gold.dim_products
GROUP BY category
ORDER BY total_products DESC

--What is the average costs in each category
SELECT
	category,
	AVG(cost) AS avg_costs
FROM gold.dim_products
GROUP BY category
ORDER BY avg_costs DESC

---what is the total revenue generated for each catergory
SELECT
	p.category,
	SUM(f.sales_amount) total_revenue
FROM gold_fact_sales f
LEFT JOIN gold.dim_products p
ON p.product_key = f.product_key
GROUP BY p.category
ORDER BY total_revenue DESC

  /*
===============================================================================
Ranking Analysis
===============================================================================
Purpose:
    - To rank items (e.g., products, customers) based on performance or other metrics.
    - To identify top performers or laggards.

SQL Functions Used:
    - Window Ranking Functions: RANK(), DENSE_RANK(), ROW_NUMBER(), TOP
    - Clauses: GROUP BY, ORDER BY
===============================================================================
*/

---find total reveue is generated by each customer
SELECT
	c.customer_key,
	c.first_name,
	c.last_name,
SUM(f.sales_amount) AS total_revenue
FROM gold_fact_sales f
LEFT JOIN gold.dim_customers c
ON c.customer_key = f.customer_key
GROUP BY 
	c.customer_key,
	c.first_name,
	c.last_name
ORDER BY total_revenue DESC

---what is the distribution of sold items across countries
SELECT
	c.country,
SUM(f.quantity) AS total_sold_items
FROM gold_fact_sales f
LEFT JOIN gold.dim_customers c
ON c.customer_key = f.customer_key
GROUP BY 
	c.country
ORDER BY total_sold_items DESC

---Products that generated the highes revenue
SELECT TOP 5
	p.product_name,
	SUM(f.sales_amount) total_revenue
FROM gold_fact_sales f
LEFT JOIN gold.dim_products p
ON p.product_key = f.product_key
GROUP BY p.product_name
ORDER BY total_revenue DESC

----What are the worst performin products in terms of sales?
SELECT TOP 5
	p.product_name,
	SUM(f.sales_amount) total_revenue
FROM gold_fact_sales f
LEFT JOIN gold.dim_products p
ON p.product_key = f.product_key
GROUP BY p.product_name
ORDER BY total_revenue

SELECT *
FROM (
	SELECT
	p.product_name,
	SUM(f.sales_amount) total_revenue,
	RANK() OVER(ORDER BY SUM(f.sales_amount) DESC) AS rank_products
FROM gold_fact_sales f
LEFT JOIN gold.dim_products p
ON p.product_key = f.product_key
GROUP BY p.product_name
)t

--find the top 10 customers who have generated the highest revenue
SELECT TOP 10
c.customer_key,
c.first_name,
c.last_name,
SUM(f.sales_amount) AS total_revenue
FROM gold_fact_sales f
LEFT JOIN gold.dim_customers c
ON c.customer_key = f.customer_key
GROUP BY
c.customer_key,
c.first_name,
c.last_name
ORDER BY total_revenue DESC

---find the 3 customers with fewest orders placed
SELECT TOP 3
c.customer_key,
c.first_name,
c.last_name,
COUNT(DISTINCT order_number) AS total_orders
FROM gold_fact_sales f
LEFT JOIN gold.dim_customers c
ON c.customer_key = f.customer_key
GROUP BY
c.customer_key,
c.first_name,
c.last_name
ORDER BY total_orders
