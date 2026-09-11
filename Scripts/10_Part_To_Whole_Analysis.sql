/*
===============================================================================
Part-to-Whole Analysis
===============================================================================
Purpose:
    - To compare performance or metrics across dimensions or time periods.
    - To evaluate differences between categories.
    - Useful for A/B testing or regional comparisons.

SQL Functions Used:
    - SUM(), AVG(): Aggregates values for comparison.
    - Window Functions: SUM() OVER() for total calculations.
===============================================================================
*/
-- Which categories contribute the most to overall sales?
    SELECT * FROM gold.dim_products
    SELECT * FROM gold.fact_sales
    --Product id wil used to fetch details from fact 
    --and category as it is the only common key  
 
 SELECT 
 p.category,
 p.product_key,
 p.product_name,
 SUM(f.sales_amount) AS Total_Sales_Product
 FROM gold.fact_sales f
 LEFT JOIN gold.dim_products p
 ON f.product_key = p.product_key
 GROUP BY
 p.category,
 p.product_key,
 p.product_name
 ORDER BY 1,3
 
 -- ANS
 WITH Category_Sales AS 
 (
     SELECT 
     p.category,
     SUM(f.sales_amount) AS Total_Sales_Categories,
     SUM(SUM(f.sales_amount)) OVER () AS Overall_Total_Sales
     FROM gold.fact_sales f
     LEFT JOIN gold.dim_products p
     ON f.product_key = p.product_key
     GROUP BY
     p.category
 )
 SELECT 
 category,
 Total_Sales_Categories,
 Overall_Total_Sales,
 CONCAT (ROUND( (CAST(Total_Sales_Categories AS FLOAT)/Overall_Total_Sales)*100,2), '%')AS Percentage 
 FROM Category_Sales
 ORDER BY 4 DESC
 
