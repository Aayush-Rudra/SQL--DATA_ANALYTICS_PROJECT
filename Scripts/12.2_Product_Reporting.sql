/*
===============================================================================
Product Report
===============================================================================
Purpose:
    - This report consolidates key product metrics and behaviors.

Highlights:
    1. Gathers essential fields such as product name, category, subcategory, and cost.
    2. Segments products by revenue to identify High-Performers, Mid-Range, or Low-Performers.
    3. Aggregates product-level metrics:
       - total orders
       - total sales
       - total quantity sold
       - total customers (unique)
       - lifespan (in months)
    4. Calculates valuable KPIs:
       - recency (months since last sale)
       - average order revenue (AOR)
       - average monthly revenue
===============================================================================
*/
SELECT * FROM gold.fact_sales
where product_key = 47;
SELECT * FROM gold.dim_products;


IF OBJECT_ID('gold.report_products', 'V') IS NOT NULL
    DROP VIEW gold.report_products;
GO

CREATE VIEW gold.report_products AS
WITH base_query AS (
/*---------------------------------------------------------------------------
1) Base Query: Retrieves core columns from fact_sales and dim_products
---------------------------------------------------------------------------*/
    SELECT 
    p.product_key,
    p.product_name,
    p.category,
    p.subcategory,
    p.cost,
    f.customer_key,
    f.order_number,
    f.sales_amount,
    f.quantity,
    f.price,
    f.order_date
    FROM gold.dim_products p
    LEFT JOIN gold.fact_sales f
    ON p.product_key = f.product_key
    WHERE order_date IS NOT NULL  -- only consider valid sales dates
),
product_aggregations AS (
/*---------------------------------------------------------------------------
2) Product Aggregations: Summarizes key metrics at the product level
---------------------------------------------------------------------------*/
    SELECT 
    product_key,
    product_name,
    category,
    subcategory,
    cost,
    MAX(order_date) AS last_sales_date,
    COUNT(DISTINCT order_number) AS total_orders, -- total orders
    SUM(sales_amount) AS total_sales, -- total sales
    SUM(quantity) AS total_quantity_sold, -- total quantity sold
    COUNT(DISTINCT customer_key) AS total_customers, --total customers (unique)
    DATEDIFF(MONTH, MIN(order_date), MAX(order_date)) AS lifespan, --lifespan (in months)
    /*
    Average Selling Price (ASP):
    If a product has a consistent unit price across all sales and no discounts or price adjustments,
    the ASP will be equal to the product's unit selling price. In this case, calculating
    SUM(sales_amount) / SUM(quantity) is redundant, as it will return the same value as price.

    If the product was sold at different prices, ASP should be calculated as:
    Total Sales / Total Quantity Sold
    which gives the quantity-weighted average selling price.

    SELECT * FROM gold.fact_sales
    where product_key = 47;

    Above query shows that selling_price_One_Unit is not equal for the product_key = 47 in its 
    entire history of sales price flactuates

    */
    ROUND(AVG(CAST(sales_amount AS FLOAT) / NULLIF(quantity, 0)),1) AS avg_selling_price
    FROM base_query
    GROUP BY 
    product_key,
    product_name,
    category,
    subcategory,
    cost

)
/*---------------------------------------------------------------------------
  3) Final Query: Combines all product results into one output
---------------------------------------------------------------------------*/
SELECT 
	product_key,
	product_name,
	category,
	subcategory,
	cost,
	last_sales_date,
    lifespan,
    total_orders,
    FORMAT(total_sales, 'N0', 'en-IN') AS total_sales,
	total_quantity_sold,
	total_customers,
	avg_selling_price,
    /*
    So OVER () is what allows 
    you to compare each product against the 
    overall average while still keeping each product row.
    */
    FORMAT( AVG(total_sales) OVER(), 'N0', 'en-IN') AS Overall_avg_sales,
    CASE
    -- More than 10% ABOVE the overall average → High Performer
    -- 1.10 means 100% + 10% = 110% of the average
    WHEN total_sales > AVG(total_sales) OVER() * 1.10 THEN 'High Performer'

    -- Between 90% and 110% of the overall average → Mid Performer
    -- 0.90 means 100% - 10% = 90% of the average
    WHEN total_sales >= AVG(total_sales) OVER() * 0.90 THEN 'Mid Performer'

    -- Less than 90% of the overall average → Low Performer
    ELSE 'Low Performer'
    END AS product_segment ,
    CASE
    WHEN total_sales > AVG(total_sales) OVER() * 1.10
        THEN 'More than 10% above overall average sales'
    WHEN total_sales >= AVG(total_sales) OVER() * 0.90
        THEN 'Within ±10% of overall average sales'
    ELSE 'More than 10% below overall average sales'
    END AS product_segment_description,
    DATEDIFF(MONTH, last_sales_date, GETDATE()) AS recency_in_months, -- recency (months since last sale)
    -- Average Order Revenue (AOR) 
    -- avg_order_revenue = average revenue generated per order for that specific product.
    CASE 
		WHEN total_orders = 0 THEN 0
		ELSE total_sales / total_orders
	END AS avg_order_revenue,
	-- Average Monthly Revenue
    -- avg_monthly_revenue = average revenue generated per month during that specific product's lifespan.
	CASE
		WHEN lifespan = 0 THEN total_sales
		ELSE total_sales / lifespan
	END AS avg_monthly_revenue
FROM product_aggregations
GO

SELECT * FROM gold.report_products
ORDER BY product_segment