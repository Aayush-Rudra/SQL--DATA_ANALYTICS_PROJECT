
/*
===============================================================================
Dimensions Exploration
===============================================================================
Purpose:
    - To explore the structure of dimension tables.
	
SQL Functions Used:
    - DISTINCT
    - ORDER BY
===============================================================================
*/


-- explore all countries our customers come from
SELECT DISTINCT country FROM
gold.dim_customers

--explore all categories "the major divisions"
SELECT DISTINCT category,subcategory, product_name FROM
gold.dim_products ORDER BY 1, 2, 3

