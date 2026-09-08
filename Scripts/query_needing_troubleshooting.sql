
--What is the distribution of sold items acroos countries
SELECT
    c.country,
    SUM(f.quantity) AS total_sold_items
FROM gold.fact_sales f
LEFT JOIN gold.dim_customers c
    ON c.customer_key = f.customer_key
GROUP BY c.country
ORDER BY total_sold_items DESC;

SELECT
dc.country, 
COALESCE(SUM(f.quantity), 0) AS total_sold_items
FROM gold.dim_customers dc
LEFT JOIN gold.fact_sales f 
ON dc.customer_key = f.customer_key
GROUP BY dc.country
ORDER BY total_sold_items DESC


--Every non-aggregated column in SELECT must explicitly appear in GROUP BY.
SELECT TOP 5 
dp.product_key, dp.product_name,SUM(f.sales_amount) AS Total_Revenue
FROM gold.dim_products dp
JOIN gold.fact_sales f
ON dp.product_key = f.product_key
GROUP BY dp.product_key  -- include dp.product_name then only error will not appears
ORDER BY Total_Revenue DESC
