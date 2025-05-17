-- Create Views --------------
USE suplements_data;

-- Revenue Adjusted for 2022
CREATE VIEW revenue_adjusted_22 AS 
	SELECT 
		  data AS date,
		  product_name,
		  category,
		  location,
		  platform,
		  ROUND((units_sold - units_returned) * price *(1 - discount),2) AS adj_revenue
	FROM suplements_data.data
    WHERE YEAR(data) = 2022;
    
-- Trending the Data - Understand the trend in the data ---------

-- Simple Weekly Trend Total 2022
SELECT 
	date,
	ROUND(SUM(adj_revenue),2) AS adj_revenue
FROM revenue_adjusted_22
GROUP BY date;

-- Montly Trends Total 2022
SELECT 
  DATE_FORMAT(date, '%Y-%m') AS years_months,
  ROUND(SUM(adj_revenue), 2) AS adj_revenue
FROM revenue_adjusted_22
GROUP BY 1;

-- Comparing Components ------------------

-- Categories Montly Adjusted Revenue
SELECT 
	  DATE_FORMAT(date, '%Y-%m') AS years_months,
      category,
      ROUND(SUM(adj_revenue),2) AS adj_revenue
FROM revenue_adjusted_22
GROUP BY 1,2;

-- Categories Montly Adjusted Revenue for the top 4 products in 2022
SELECT 
      date,
      product_category,
	  product_name,
      ROUND(SUM(adj_revenue),2) AS adj_revenue
FROM(
	SELECT 
		  category AS product_category,
		  product_name AS product_name,
		  DATE_FORMAT(date, '%Y-%m') AS date,
		  adj_revenue AS adj_revenue
	FROM revenue_adjusted_22
	WHERE category IN ('Vitamin','Mineral','Performance','Protein')
    ) AS tab
GROUP BY  date,product_name,product_category;

-- Calculate the gap montly difference between Vitamins and Performance 
SELECT 
       date,
       ROUND(Vitamins - performance,2) AS vitamins_minus_performance,
       ROUND(performance - Vitamins,2) AS performance_minus_vitamins,
       ROUND(Vitamins / performance,2) AS vitamins_times_performance,
       ROUND((Vitamins / performance - 1) * 100, 2) AS vitamins_pct_of_performance
FROM (
	SELECT 
		  DATE_FORMAT(date,'%Y-%m') AS date,
		  SUM(CASE 
				  WHEN category = 'Performance' THEN adj_revenue
				  END) AS performance,
		  SUM(CASE 
				  WHEN category = 'Vitamin' THEN adj_revenue
				  END) AS Vitamins 
	FROM revenue_adjusted_22
	GROUP BY 1
    ) AS tab;
    
-- Calculate the percent of total sales for each category
SELECT 
  category,
  DATE_FORMAT(date, '%Y-%m') AS month,
  SUM(adj_revenue) AS monthly_revenue,
  SUM(adj_revenue) * 100.0 / SUM(SUM(adj_revenue)) OVER (PARTITION BY DATE_FORMAT(date, '%Y-%m')) AS pct_total
FROM revenue_adjusted_22
GROUP BY category, DATE_FORMAT(date, '%Y-%m')
ORDER BY month, category;

-- Indexing to See Percent Change over Time Vitamins and Performance
SELECT
  date,
  category,
  ROUND((adj_revenue / FIRST_VALUE(adj_revenue) OVER (PARTITION BY category ORDER BY date) - 1) * 100,2) AS pct_from_index
FROM (
  SELECT 
    DATE_FORMAT(date, '%Y-%m') AS date,
    category,
    SUM(adj_revenue) AS adj_revenue
  FROM revenue_adjusted_22
  GROUP BY 1, 2
) AS tab
WHERE category IN ('Performance','Vitamin')
ORDER BY category, date;

-- Rolling Time Windows MA for Vitamins 
WITH monthly_revenue AS (
  SELECT 
    DATE_FORMAT(date, "%Y-%m") AS month,
    ROUND(SUM(adj_revenue),2) AS total_revenue
  FROM revenue_adjusted_22 
  WHERE category = 'Vitamin'
  GROUP BY DATE_FORMAT(date, "%Y-%m")
)
SELECT 
  month,
  total_revenue,
  ROUND(AVG(total_revenue) OVER (ORDER BY month ROWS BETWEEN 6 PRECEDING AND CURRENT ROW), 2) AS MA_7,
  ROUND(AVG(total_revenue) OVER (ORDER BY month ROWS BETWEEN 10 PRECEDING AND CURRENT ROW), 2) AS MA_11
FROM monthly_revenue;

-- Calculating Cumulative Values for Vitamins
SELECT 
  DATE_FORMAT(date, '%Y-%m-%d') AS date,
  ROUND(SUM(adj_revenue) OVER (
    PARTITION BY DATE_FORMAT(date, '%Y-%m') 
       ORDER BY date),2) AS revenue_mtd,
  ROUND(SUM(adj_revenue) OVER (
    PARTITION BY QUARTER(date), YEAR(date) 
       ORDER BY date),2) AS revenue_qtd
FROM revenue_adjusted_22
WHERE category = 'Vitamin'
ORDER BY date;

--  Period-over-Period Comparisons: YoY and MoM





