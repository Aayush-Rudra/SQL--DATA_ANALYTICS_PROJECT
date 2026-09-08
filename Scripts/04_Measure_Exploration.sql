--Find the total sales
SELECT SUM(sales_amount) AS Total_Sales FROM gold.fact_sales
--Find how many items are sold
SELECT SUM(quantity) AS Total_quantity FROM gold.fact_sales
--Find the average selling price 
SELECT AVG(price) AS Avg_price FROM gold.fact_sales
--Find the total numbers of orders
SELECT COUNT(DISTINCT order_number) AS total_orders FROM gold.fact_sales;
--Find the total numbers of products
SELECT COUNT(product_key) AS total_product FROM gold.dim_products;
--Find the total number of customers
SELECT COUNT(customer_key) AS total_customers FROM gold.dim_customers;
--Find the total number of customers that has placed an order
SELECT COUNT(DISTINCT customer_key) FROM gold.fact_sales;

-- Generate a Report that shows all key metrics of the business
SELECT 'Total Sales' AS measure_name, SUM(sales_amount) AS measure_value FROM gold.fact_sales
UNION ALL
SELECT 'Total Quantity', SUM(quantity) FROM gold.fact_sales
UNION ALL
SELECT 'Average Price', AVG(price) FROM gold.fact_sales
UNION ALL
SELECT 'Total Orders', COUNT(DISTINCT order_number) FROM gold.fact_sales
UNION ALL
SELECT 'Total Products', COUNT(DISTINCT product_name) FROM gold.dim_products
UNION ALL
SELECT 'Total Customers', COUNT(customer_key) FROM gold.dim_customers;