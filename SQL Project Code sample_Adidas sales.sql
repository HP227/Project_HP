/*SQL_SELECT*/
-- Show sale data table & order by data
SELECT * FROM dbo.Adidas_sale_2020
ORDER BY [Invoice_Date]
-- List the product for women
SELECT retailer, product
FROM dbo.Adidas_sale_2020
WHERE retailer = 'Foot Locker'
AND product like 'Women%'

/*AGGREGATE FUNCTION*/
--Total Adidas Sales in 2020
SELECT SUM(revenue) as total_sale FROM dbo.Adidas_sale_2020
--Total Adidas Profit in 2020
SELECT SUM([operating profit]) AS total_profit FROM dbo.Adidas_sale_2020
--CONCAT 
SELECT CONCAT(RIGHT(region,4),' ', City) AS new_column
FROM dbo.Adidas_sale_2020
-- Calculate avg revenue of month
With total_month as (SELECT DISTINCT MONTH([Invoice_Date]) as [month],
	SUM(Revenue) AS total_month
FROM dbo.Adidas_Sale_2021
Group BY MONTH(Invoice_Date)
)
SELECT ROUND(AVG(total_month),2) AS avg_per_month FROM total_month AS avg_per_month
--Which is the lowest/highest sales in the database?
SELECT MIN(Revenue) AS lowest_sales,
	MAX(Revenue) AS highest_sales
FROM dbo.Adidas_sale_2020
-- pct's sales by product
SELECT DISTINCT product,
	SUM(Revenue)  AS total_by_product,
	CAST(SUM(revenue)*100/(SELECT SUM(revenue) FROM dbo.Adidas_sale_2020) AS DECIMAL (10,2)) AS pct
FROM dbo.Adidas_sale_2020
GROUP BY product
ORDER BY pct 
--Total revenue by month 
SELECT DISTINCT MONTH([Invoice_Date]) AS [Month],
	SUM(revenue) OVER (PARTITION BY MONTH([Invoice_Date])) AS Month_Revenue 
FROM dbo.Adidas_sale_2020
ORDER BY [Month]
	
--Classify retailer by total revenue
WITH revenue_retailer AS (
SELECT DISTINCT Retailer,
	SUM(revenue) AS Total_Revenue_Retailer
FROM dbo.Adidas_sale_2020
GROUP BY Retailer
)
SELECT Retailer, Total_Revenue_Retailer,
	CASE WHEN Total_Revenue_Retailer < '1000000000' THEN 'small_retailer'
		WHEN Total_Revenue_Retailer BETWEEN '1000000000' AND '5000000000' THEN 'medium_retailer'
	ELSE 'large_retailer'
	END AS classify_retailer
FROM revenue_retailer

-- Evaluate the units sold of Footwear’s product, each month in 2021 increases or decreases compared to the same period last year. (That means how many % growth in January 2021 compared to January 2020)
WITH Month_table AS (
SELECT DISTINCT YEAR(Invoice_Date) AS [Year] , MONTH(Invoice_Date) AS [Month],
		SUM(Units_Sold) OVER (PARTITION BY YEAR(Invoice_Date), MONTH(Invoice_Date)) AS Total_units
FROM (SELECT * FROM dbo.Adidas_sale_2020
	  WHERE Product LIKE '%Footwear'
	  UNION 
	  SELECT * FROM dbo.Adidas_Sale_2021
	  WHERE Product LIKE '%Footwear') AS unioned_table
	)
, Last_units_table AS (
SELECT * ,
	LAG(Total_units, 12) OVER (ORDER BY [Year], [Month]) AS Last_total_units
FROM Month_table 
)
SELECT * ,
	 FORMAT ( CAST ( ( Total_units - Last_total_units ) AS FLOAT ) / Last_total_units , 'p') "%_growth"
FROM  Last_units_table
WHERE [Year] = 2021



