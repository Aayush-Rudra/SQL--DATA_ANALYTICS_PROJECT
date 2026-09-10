/*
===============================================================================
Cumulative Analysis
===============================================================================
Purpose:
    - To calculate running totals or moving averages for key metrics.
    - To track performance over time cumulatively.
    - Useful for growth analysis or identifying long-term trends.

SQL Functions Used:
    - Window Functions: SUM() OVER(), AVG() OVER()
===============================================================================
*/

--Calculate the total sales for each month 
--and the running total of sales over time

SELECT 
Order_Month,
Total_Sales,
SUM(Total_Sales) OVER(PARTITION BY YEAR(Order_Month) ORDER BY Order_Month) AS Running_Total_Sales_Year
--SUM(Total_Sales) OVER(PARTITION BY Order_Month ORDER BY Order_Month) AS Running_Total_Sales
--Default FRAME CLAUSE is RANGE BETWEEN UNBOUNDED PROCEDINGS AND CURRENT ROW
FROM
  (	
    SELECT 
	DATETRUNC(MONTH,order_date) AS Order_Month,
	SUM(sales_amount) AS Total_Sales
    FROM gold.fact_sales
	WHERE DATETRUNC(MONTH,order_date) IS NOT NULL
	GROUP BY DATETRUNC(MONTH,order_date)
	
  )t

SELECT 
    DATETRUNC(YEAR, order_date) AS Order_Years,
    SUM(sales_amount) AS Total_Sales
FROM gold.fact_sales
WHERE order_date >= '2012-01-01'
  AND order_date <  '2013-01-01'
GROUP BY DATETRUNC(YEAR, order_date);	

SELECT 
    order_date,
    sales_amount 
FROM gold.fact_sales
WHERE order_date >= '2012-01-01'
  AND order_date <  '2013-01-01'	

	


-- Moving Avg of Price
SELECT 
Order_Year,
Total_Sales,
SUM(Total_Sales) OVER(ORDER BY Order_Year) AS Running_Total_Sales,
AVG(avg_price) OVER (ORDER BY Order_Year) AS moving_average_price
FROM
  (	
    SELECT 
	DATETRUNC(YEAR,order_date) AS Order_Year,
	SUM(sales_amount) AS Total_Sales,
    AVG(price) AS avg_price	
    FROM gold.fact_sales
	WHERE DATETRUNC(YEAR,order_date) IS NOT NULL
	GROUP BY DATETRUNC(YEAR,order_date)
	
  )t

