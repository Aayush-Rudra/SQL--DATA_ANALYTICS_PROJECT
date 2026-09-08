/*
In this we explore how many tables are there, relations etc
In a way understanding the database
*/


--explore all the objects in the database
SELECT * FROM INFORMATION_SCHEMA.TABLES
-- Output will be list of all the database tables

-- Explore the all the columns in the database
SELECT * FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_NAME = 'dim_customers'