/*
===============================================================================
Performance Analysis (Year-over-Year, Month-over-Month)
===============================================================================
Purpose:
    - To measure the performance of products, customers, or regions over time.
    - For benchmarking and identifying high-performing entities.
    - To track yearly trends and growth.

SQL Functions Used:
    - LAG(): Accesses data from previous rows.
    - AVG() OVER(): Computes average values within partitions.
    - CASE: Defines conditional logic for trend analysis.
===============================================================================
*/

--Q1 Analyze the yearly performance of products by comparing their sales 
--   to both the average sales performance of the product and the previous year's sales
SELECT * FROM gold.fact_sales

-- Table which gives out the Total Sales of a products in a year 
SELECT 
YEAR(f.order_date) AS Order_Year,
p.product_name,
SUM(f.sales_amount) AS Total_Sales
FROM gold.fact_sales f
LEFT JOIN gold.dim_products p
ON f.product_key = p.product_key
WHERE YEAR(f.order_date) IS NOT NULL
GROUP BY 
YEAR(f.order_date),
p.product_name
ORDER BY 1

-- Above table wil be used to answer the performance question by using window fuction and CTE
WITH yearly_product_sales AS 
(   SELECT 
    YEAR(f.order_date) AS Order_Year,
    p.product_name,
    SUM(f.sales_amount) AS Total_Sales_Year
    FROM gold.fact_sales f
    LEFT JOIN gold.dim_products p
    ON f.product_key = p.product_key
    WHERE YEAR(f.order_date) IS NOT NULL
    GROUP BY 
    YEAR(f.order_date),
    p.product_name
)

SELECT 
product_name,
Order_Year,
Total_Sales_Year,
SUM(Total_Sales_Year) OVER (PARTITION BY product_name ORDER BY Order_Year) AS Running_Overall_Sale_Product_Year,
AVG(Total_Sales_Year) OVER (PARTITION BY product_name) AS Avg_Sales_product_Year,
Total_Sales_Year - AVG(Total_Sales_Year) OVER (PARTITION BY product_name) AS Performance_Analysis,
CASE 
        WHEN Total_Sales_Year - AVG(Total_Sales_Year) OVER (PARTITION BY product_name) > 0 THEN 'Above Avg'
        WHEN Total_Sales_Year - AVG(Total_Sales_Year) OVER (PARTITION BY product_name) < 0 THEN 'Below Avg'
        ELSE 'Avg'
END AS avg_change,
-- Year Over Year Comparison Of A product Sales
LAG(Total_Sales_Year) OVER (PARTITION BY product_name ORDER BY order_year) AS Comparison_PY_Sales,
Total_Sales_Year - LAG(Total_Sales_Year) OVER (PARTITION BY product_name ORDER BY order_year) AS diff_with_PY_Sales,
CASE 
        WHEN Total_Sales_Year - LAG(Total_Sales_Year) OVER (PARTITION BY product_name ORDER BY order_year) > 0 THEN 'Increase'
        WHEN Total_Sales_Year - LAG(Total_Sales_Year) OVER (PARTITION BY product_name ORDER BY order_year) < 0 THEN 'Decrease'
        ELSE 'No Change'
END AS avg_change
FROM yearly_product_sales

--testing query
SELECT 
p.product_name,
SUM(f.sales_amount) 
FROM gold.fact_sales f
LEFT JOIN gold.dim_products p
ON f.product_key = p.product_key
WHERE p.product_name = 'All-Purpose Bike Stand'
GROUP BY p.product_name

