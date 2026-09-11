/*
===============================================================================
Data Segmentation Analysis
===============================================================================
Purpose:
    - To group data into meaningful categories for targeted insights.
    - For customer segmentation, product categorization, or regional analysis.

SQL Functions Used:
    - CASE: Defines custom segmentation logic.
    - GROUP BY: Groups data into segments.
===============================================================================
*/

-- Q1 Segment products into cost ranges and 
--    count how many products fall into each segment*/
SELECT * FROM gold.dim_products

SELECT 
MIN(cost),-- 0
MAX(cost),-- 2171
AVG(cost) -- 431
FROM gold.dim_products;-- 431


WITH product_segments AS (
    SELECT
        product_key,
        product_name,
        cost,
        CASE 
            WHEN cost < 100 THEN 'Below 100'
            WHEN cost BETWEEN 100 AND 500 THEN '100-500'
            WHEN cost BETWEEN 500 AND 1000 THEN '500-1000'
            ELSE 'Above 1000'
        END AS cost_range
    FROM gold.dim_products
)

SELECT 
cost_range,
COUNT(product_key) AS Total_Products
FROM product_segments
GROUP BY cost_range
ORDER BY Total_Products;

-- Q2 Group customers into three segments based on their spending behavior:
	    -- VIP: Customers with at least 12 months of history and spending more than €5,000.
	    -- Regular: Customers with at least 12 months of history but spending €5,000 or less.
	    -- New: Customers with a lifespan less than 12 months.
-- And find the total number of customers by each group
WITH customer_spending AS
( 
    SElECT 
    c.customer_key,
    c.first_name,
    c.last_name,
    DATEDIFF(Year, birthdate, GETDATE()) AS Age,
    DATEDIFF(month, MIN(order_date), MAX(order_date)) AS lifespan,
    SUM(f.sales_amount) AS Total_Spending_Amount_Customer
    FROM gold.fact_sales f
    JOIN gold.dim_customers c
    ON f.customer_key = c.customer_key
    GROUP BY
    c.customer_key,
    c.first_name,
    c.last_name,
    --In a SELECT with GROUP BY, every selected column must either 
    --be in the GROUP BY or be wrapped in an aggregate function 
    --like SUM(), MIN(), MAX(), AVG(), or COUNT().
    c.birthdate
    
),
segmented_customers AS 
(
    SELECT 
    customer_key,
    first_name,
    last_name,
    lifespan,
    CASE 
        WHEN lifespan >= 12 AND Total_Spending_Amount_Customer > 5000 THEN 'VIP'
        WHEN lifespan >= 12 AND Total_Spending_Amount_Customer <= 5000 THEN 'Regular'
        ELSE 'New'
        END AS customer_segment
    FROM customer_spending
)

SELECT 
customer_segment,
COUNT(customer_key) AS total_customers
FROM segmented_customers
GROUP BY customer_segment
ORDER BY total_customers DESC

/*
SELECT
customer_segment,
lifespan,
customer_key,
first_name,
last_name
FROM segmented_customers
GROUP BY 
customer_segment,
customer_key,
first_name,
last_name,
lifespan
ORDER BY customer_segment DESC
*/

-- ============================================================
-- QUICK RULE
-- ============================================================

-- CTE          → Use within ONE query
-- Temp Table   → Reuse within the SAME session
-- View         → Reuse across MANY queries
-- Repeat CTE   → Fine when you only have a few independent queries