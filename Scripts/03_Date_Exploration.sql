
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

-- find the date of first and last order
SELECT 
MIN(order_date) AS FIRST_ORDER,
MAX(order_date) AS LAST_ORDER
FROM gold.fact_sales

--How many years of sales are available
SELECT 
MIN(order_date) AS FIRST_ORDER,
MAX(order_date) AS LAST_ORDER,
DATEDIFF(year, MIN(order_date), MAX(order_date)) AS Order_range_years,
DATEDIFF(month, MIN(order_date), MAX(order_date)) AS Order_range_months
FROM gold.fact_sales

--find the youngest and oldest customer 
SELECT 
MIN(birthdate) AS Oldest_customer,
DATEDIFF(year, MIN(birthdate), GETDATE()) AS Oldest_age,
MAX(birthdate) AS youngest_customer,
DATEDIFF(year, MAX(birthdate), GETDATE()) AS Youngest_age
FROM gold.dim_customers

