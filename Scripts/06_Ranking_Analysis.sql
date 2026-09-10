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


--Which 5 Products generate the highest revenue
SELECT TOP 5 
dp.product_name,SUM(f.sales_amount) AS Total_Revenue
FROM gold.dim_products dp
JOIN gold.fact_sales f
ON dp.product_key = f.product_key
GROUP BY dp.product_name
ORDER BY Total_Revenue DESC

	-- by using window fuction
	SELECT *
	FROM
		  ( SELECT
			dp.product_name,
			SUM(f.sales_amount) AS Total_Revenue,
			ROW_NUMBER() OVER (ORDER BY SUM(f.sales_amount) DESC) AS rank_products
			FROM gold.dim_products dp
			JOIN gold.fact_sales f
			ON dp.product_key = f.product_key
			GROUP BY dp.product_name
		  )t
	WHERE rank_products <=5


--What are the 5 worst performing products in terms of sales?
SELECT TOP 5 
dp.product_name,SUM(f.sales_amount) AS Total_Revenue
FROM gold.dim_products dp
JOIN gold.fact_sales f
ON dp.product_key = f.product_key
GROUP BY dp.product_name
ORDER BY Total_Revenue

--- Find the top 10 customers who have generated the highest revenue 
SELECT *
FROM
      ( SELECT
		dc.customer_key,
		dc.first_name,
		dc.last_name,
		SUM(f.sales_amount) AS Total_Revenue,
		RANK() OVER (ORDER BY SUM(f.sales_amount) DESC) AS rank_products,
		ROW_NUMBER() OVER (ORDER BY SUM(f.sales_amount) DESC) AS rank_products2
		FROM gold.dim_customers dc
		JOIN gold.fact_sales f
		ON dc.customer_key = f.customer_key
		GROUP BY dc.customer_key, dc.first_name, dc.last_name
	  )t
WHERE rank_products <=10

--- Find 3 customers with the fewest orders placed with lowest revenue
SELECT *
FROM
      ( SELECT
		dc.customer_key,
		dc.first_name,
		dc.last_name,
		COUNT(DISTINCT order_number) AS Total_orders,
		SUM(f.sales_amount) AS Total_Revenue,
        SUM(f.quantity) AS Total_quantity,
        ROW_NUMBER() OVER (
            ORDER BY
                  COUNT(DISTINCT order_number) ASC
                
        ) AS customer_rank
		FROM gold.dim_customers dc
		JOIN gold.fact_sales f
		ON dc.customer_key = f.customer_key
		GROUP BY dc.customer_key, dc.first_name, dc.last_name
	  )t
WHERE customer_rank <=10 

