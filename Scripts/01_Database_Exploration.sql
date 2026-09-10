
/*
===============================================================================
Dimensions Exploration
===============================================================================
Purpose:
    - To explore the structure of dimension tables.
    - In a way understanding the database
	
SQL Functions Used:
    - DISTINCT
    - ORDER BY
===============================================================================
*/


--explore all the objects in the database
SELECT * FROM INFORMATION_SCHEMA.TABLES
-- Output will be list of all the database tables

-- Explore the all the columns in the database
SELECT * FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_NAME = 'dim_customers'