-- Create Views --------------
USE suplements_data;
SELECT *
FROM suplements_data.data;
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

-- Location Monthly Adjusted Revenue
SELECT 
	  DATE_FORMAT(date,'%Y-%m') AS date,
      location,
      ROUND(SUM(adj_revenue),2) AS adj_revenue
FROM revenue_adjusted_22
GROUP BY 1,2;

-- Platform Montly Adjust Revenue
SELECT 
      DATE_FORMAT(date,'%Y-%m') AS date,
      platform,
      ROUND(SUM(adj_revenue)) AS adj_revenue
FROM revenue_adjusted_22
GROUP BY 1,2;

-- Platform and Location Montly Adjust Revenue
SELECT 
      DATE_FORMAT(date,'%Y-%m') AS date,
      location,
      platform,
      ROUND(SUM(adj_revenue),2) AS adj_revenue
FROM revenue_adjusted_22
GROUP BY 1,2,3;

-- Categories Montly Adjusted Revenue for the top 4 products 
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

-- Compare products categories in Canada across diffrent platforms 
SELECT 
      DATE_FORMAT(date,'%Y-%m') AS date,
      category,
      platform,
      ROUND(SUM(adj_revenue),2)AS adj_revenue
FROM revenue_adjusted_22
WHERE location = 'Canada'
GROUP BY 1,2,3;

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
    
-- Calculate the gap montly difference between Vitamins and Proteins
SELECT 
	 date,
     ROUND(vitamin_revenue - protein_revenue,2) AS vitamin_minus_protein,
     ROUND(vitamin_revenue / protein_revenue,2) AS vitamin_times_protein,
     ROUND((vitamin_revenue / protein_revenue - 1)* 100,2) AS vitamin_pct_protein
FROM(
	SELECT 
		  DATE_FORMAT(date,"%Y-%m") AS date,
		  SUM(CASE 
				 WHEN category = "Vitamin" THEN adj_revenue
				 END) AS vitamin_revenue,
		  SUM(CASE 
				  WHEN category = "Protein" THEN adj_revenue
				  END) AS protein_revenue
	FROM revenue_adjusted_22
	GROUP BY 1
    ) AS tab;

-- Calculate the gap montly difference between Vitamins and Minerals
SELECT 
     date,
     ROUND(vitamin_revenue - minerals_revenue,2) AS vitamins_minus_minerals,
     ROUND(vitamin_revenue / minerals_revenue,2) AS vitamins_times_mineeals,
     ROUND((vitamin_revenue / minerals_revenue-1)*100,2) AS vitamin_pct_minerals
FROM(
	SELECT 
		  DATE_FORMAT(date,"%Y-%m")AS date,
		  SUM(CASE
				  WHEN category = "Vitamin" THEN adj_revenue
				  END) AS vitamin_revenue,
		  SUM(CASE
				  WHEN category = "Mineral" THEN adj_revenue
				  END) AS minerals_revenue
	FROM revenue_adjusted_22
	GROUP BY 1
) AS tab;

-- Calculate the gap montly difference between Vitamins Vitamin C and Biotin
SELECT 
	  date,
      ROUND(vitamin_c_revenue - biotin_revenue,2) AS vitamin_c_minus_biotin,
      ROUND(vitamin_c_revenue / biotin_revenue,2) AS vitamin_c_times_biotin,
      ROUND((vitamin_c_revenue / biotin_revenue - 1) * 100,2) AS vitamin_c_pct_biotin
FROM(
	SELECT 
		  DATE_FORMAT(date,"%Y-%m") AS date,
		  SUM(CASE 
				  WHEN product_name = "Vitamin C" THEN adj_revenue
					   END) AS vitamin_c_revenue,
		   SUM(CASE 
				   WHEN product_name = "Biotin" THEN adj_revenue
					   END) AS biotin_revenue
	FROM revenue_adjusted_22
	GROUP BY 1
) AS tab;

-- Calculate the gap montly difference between  Canada and UK
SELECT 
      date,
      ROUND(canada_revenue - uk_revenue,2) AS canada_minus_uk_revenue,
      ROUND(canada_revenue / uk_revenue,2) AS canada_times_uk_revenue,
      ROUND((canada_revenue / uk_revenue -1) * 100,2) AS canada_pct_uk_revenue
FROM (
	SELECT 
		  DATE_FORMAT(date,"%Y-%m") AS date,
		  SUM(CASE
				  WHEN location = "Canada" THEN adj_revenue
						END) AS canada_revenue,
		  SUM(CASE
				  WHEN location = "UK" THEN adj_revenue
						END) AS uk_revenue
	FROM revenue_adjusted_22
	GROUP BY 1
) AS tab;

-- Calculate the gap montly difference between Locations Canada and uk across and platforms
SELECT
      date,
      ROUND(canada_iherb_revenue - uk_iherb_revenue,2) AS canada_minus_uk_iherb_revenue,
      ROUND(canada_iherb_revenue / uk_iherb_revenue,2) AS canada_times_uk_iherb_revenue,
      ROUND((canada_iherb_revenue / uk_iherb_revenue -1)* 100,2) AS canada_pct_uk_iherb_revenue
FROM(
	SELECT 
		  DATE_FORMAT(date,"%Y-%m") AS date,
		  SUM(CASE 
				  WHEN location = "Canada" AND platform = "iHerb" THEN adj_revenue
					   END) AS canada_iherb_revenue,
		  SUM(
			  CASE 
				  WHEN location = "UK" AND platform = "iHerb" THEN adj_revenue
						END ) AS uk_iherb_revenue
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

-- Calculate the percent of total sales for each location
SELECT 
     DATE_FORMAT(date,"%Y-%m") AS date,
     location,
     ROUND(SUM(adj_revenue),2) AS monthly_revenue,
     ROUND(SUM(adj_revenue) * 100 / SUM(SUM(adj_revenue)) OVER(PARTITION BY DATE_FORMAT(date,"%Y-%m")),2) AS pct_total
FROM revenue_adjusted_22
GROUP BY 1,2;

-- Calculate the percent of total sales for each platform
SELECT 
      DATE_FORMAT(date,"%Y-%m") AS date,
      platform,
      ROUND(SUM(adj_revenue),2) AS monthly_revenue,
      ROUND(SUM(adj_revenue) * 100 / SUM(SUM(adj_revenue)) OVER(PARTITION BY DATE_FORMAT(date,"%Y-%m")),2) AS pct_total
FROM revenue_adjusted_22
GROUP BY 1,2;

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

-- Indexing to See Percent Change over Time Vitamins and Protein
SELECT
      date,
      category,
      ROUND((monthly_revenue / FIRST_VALUE(monthly_revenue) OVER(PARTITION BY category ORDER BY date)-1)* 100,2) AS pct_from_index
FROM (
	SELECT 
		  DATE_FORMAT(date,"%Y-%m") AS date,
		  category,
		  SUM(adj_revenue) AS monthly_revenue
	FROM revenue_adjusted_22
    WHERE category IN ("Vitamin","Protein")
	GROUP BY 1,2
) AS tab;

-- Indexing to See Percent Change over Time Vitamins and Minerals
SELECT
     date,
     category,
     ROUND((monthly_revenue / FIRST_VALUE(monthly_revenue) OVER(PARTITION BY category ORDER BY date)-1)*100,2) AS pct_from_index
FROM(
	SELECT 
		  DATE_FORMAT(date,"%Y-%m") AS date,
		  category,
		  SUM(adj_revenue) AS monthly_revenue
	FROM revenue_adjusted_22
    WHERE category IN ("Vitamin","Mineral")
	GROUP BY 1,2
) AS tab;

-- Indexing to See Percent Change over Time Locations Canada and UK
SELECT
      date,
      location,
      ROUND((monthly_revenue / FIRST_VALUE(monthly_revenue) OVER(PARTITION BY location ORDER BY date)-1)* 100,2) AS pct_from_index
FROM(
	SELECT 
		 DATE_FORMAT(date,"%Y-%m") AS date,
		 location,
		 SUM(adj_revenue) AS monthly_revenue
	FROM revenue_adjusted_22
    WHERE location IN ("Canada","UK")
	GROUP BY 1,2
) AS tab;

-- Indexing to See Percent Change over Time Platforms Amazon and iHerb
SELECT
       date,
       platform,
       ROUND((monthly_revenue / FIRST_VALUE(monthly_revenue) OVER(PARTITION BY platform ORDER BY date)-1)* 100) AS pct_from_index
FROM(
	SELECT 
		  DATE_FORMAT(date,"%Y-%m") AS date,
		  platform,
		  SUM(adj_revenue) AS monthly_revenue
	FROM revenue_adjusted_22
    WHERE platform IN ("Amazon","iHerb")
	GROUP BY 1,2
) AS tab;

-- Indexing to See Percent Change over Time Platforms Amazon and iHerb across Canada
SELECT 
      date,
      location,
      platform,
      ROUND((monthly_revenue / FIRST_VALUE(monthly_revenue) OVER(PARTITION BY platform ORDER BY date)-1)*100,2) AS pct_from_index
FROM (
	SELECT 
		  DATE_FORMAT(date,"%Y-%m") AS date,
		  platform,
		  location,
		  SUM(adj_revenue) AS monthly_revenue
	FROM revenue_adjusted_22
	WHERE location = "Canada" AND platform IN ("Amazon","iHerb")
	GROUP BY 1,2,3
) AS tab;

-- Rolling Time Windows MA for Vitamins 
WITH monthly_revenue_vitamins AS (
  SELECT 
    DATE_FORMAT(date, "%Y-%m") AS month,
    ROUND(SUM(adj_revenue),2) AS total_revenue_vitamins
  FROM revenue_adjusted_22 
  WHERE category = 'Vitamin'
  GROUP BY DATE_FORMAT(date, "%Y-%m")
)
SELECT 
  month,
  total_revenue,
  ROUND(AVG(total_revenue) OVER (ORDER BY month ROWS BETWEEN 6 PRECEDING AND CURRENT ROW), 2) AS MA_7,
  ROUND(AVG(total_revenue) OVER (ORDER BY month ROWS BETWEEN 10 PRECEDING AND CURRENT ROW), 2) AS MA_11
FROM monthly_revenue_vitamins;

-- Rolling Time Windows MA for Minerals
WITH montly_revenue_minerals AS(
      SELECT 
	        DATE_FORMAT(date,"%Y-%m") AS month,
            ROUND(SUM(adj_revenue)) AS total_revenue_mineral
      FROM revenue_adjusted_22
      WHERE category = "Mineral"
      GROUP BY 1
)
SELECT 
        month,
        total_revenue_mineral,
        ROUND(AVG(total_revenue_mineral) OVER(ORDER BY month ROWS BETWEEN 11 PRECEDING AND CURRENT ROW),2) AS MA_11,
        ROUND(AVG(total_revenue_mineral) OVER(ORDER BY month ROWS BETWEEN 7 PRECEDING AND CURRENT ROW),2) AS MA_7
FROM montly_revenue_minerals;

-- Rolling Time Windows MA for Protein
WITH weekly_revenue_protein AS (
    SELECT 
          DATE_FORMAT(date,"%m-%d") AS weeks,
          ROUND(SUM(adj_revenue)) AS total_revenue_protein
    FROM revenue_adjusted_22
    WHERE category = "Protein"
    GROUP BY 1
)
SELECT 
      weeks,
      total_revenue_protein,
      ROUND(AVG(total_revenue_protein) OVER(ORDER BY weeks ROWS BETWEEN 11 PRECEDING AND CURRENT ROW),2) AS MA_11,
      ROUND(AVG(total_revenue_protein) OVER(ORDER BY weeks ROWS BETWEEN 7 PRECEDING AND CURRENT ROW),2) AS MA_7
FROM weekly_revenue_protein;

-- Rolling Time Windows MA for Performance
WITH weekly_revenue_performance AS (
	 SELECT 
           DATE_FORMAT(date,"%m-%d") AS weeks,
           SUM(adj_revenue) AS total_revenue_performance
     FROM revenue_adjusted_22
     WHERE category = "Performance"
     GROUP BY 1
)
SELECT 
      weeks,
      total_revenue_performance,
      ROUND(AVG(total_revenue_performance) OVER(ORDER BY weeks ROWS BETWEEN 11 PRECEDING AND CURRENT ROW),2) AS MA_11,
      ROUND(AVG(total_revenue_performance) OVER(ORDER BY weeks ROWS BETWEEN 7 PRECEDING AND CURRENT ROW),2) AS MA_7
FROM weekly_revenue_performance;

-- Rolling Time Windows MA for Minerals in Canada
WITH weekly_revenue_canada AS(
     SELECT 
           DATE_FORMAT(date,"%m-%d") AS weeks,
           ROUND(SUM(adj_revenue),2) AS total_revenue_canada
	FROM revenue_adjusted_22
    WHERE location = "Canada"
    GROUP BY 1
)
SELECT
      weeks,
      total_revenue_canada,
      ROUND(AVG(total_revenue_canada) OVER(ORDER BY weeks ROWS BETWEEN 11 PRECEDING AND CURRENT ROW),2) AS MA_11,
      ROUND(AVG(total_revenue_canada) OVER(ORDER BY weeks ROWS BETWEEN 7 PRECEDING AND CURRENT ROW),2) AS MA_7
FROM weekly_revenue_canada;

-- Rolling Time Windows MA for Proteins in UK across Amazon
WITH weekly_revenue_proteins_uk_amazon AS (
	 SELECT 
           DATE_FORMAT(date,"%m-%d") AS weeks,
           ROUND(SUM(adj_revenue),2) AS total_revenue_proteins_uk_amazon
	 FROM revenue_adjusted_22
     WHERE 
          category = "Protein" AND 
          platform = "Amazon" AND 
          location = "UK"
     GROUP BY 1
)
SELECT 
      weeks,
      total_revenue_proteins_uk_amazon,
      ROUND(AVG(total_revenue_proteins_uk_amazon) OVER(ORDER BY weeks ROWS BETWEEN 11 PRECEDING AND CURRENT ROW),2) AS MA_11,
      ROUND(AVG(total_revenue_proteins_uk_amazon) OVER(ORDER BY weeks ROWS BETWEEN 7 PRECEDING AND CURRENT ROW),2) AS MA_7
FROM weekly_revenue_proteins_uk_amazon;

-- Rolling Time Windows MA for Performance in iHerb across US
WITH weekly_revemue_performance_iherb_us AS (
     SELECT 
           DATE_FORMAT(date,"%m-%d") AS weeks,
           ROUND(SUM(adj_revenue),2) AS total_revenue_performance_iherb_us
	 FROM revenue_adjusted_22
     WHERE 
		  category = "Performance" AND
          platform = "iHerb" AND
          location = "UK"
	 GROUP BY 1
)
SELECT 
      weeks,
      total_revenue_performance_iherb_us,
      ROUND(AVG(total_revenue_performance_iherb_us) OVER(ORDER BY weeks ROWS BETWEEN 11 PRECEDING AND CURRENT ROW),2) AS MA_11,
      ROUND(AVG(total_revenue_performance_iherb_us) OVER(ORDER BY weeks ROWS BETWEEN 7 PRECEDING AND CURRENT ROW),2) AS MA_7
FROM weekly_revemue_performance_iherb_us;

-- Calculating Cumulative Values for Vitamins
WITH weekly_revenue_vitamins AS (
  SELECT 
    date,
    ROUND(SUM(adj_revenue),2) AS weekly_total_vitamin
  FROM revenue_adjusted_22
  WHERE category = 'Vitamin'
  GROUP BY 1
)
SELECT 
  date,
  weekly_total,
  ROUND(SUM(weekly_total) OVER (PARTITION BY YEAR(date), MONTH(date)ORDER BY date),2) AS revenue_mtd,
  ROUND(SUM(weekly_total) OVER (PARTITION BY YEAR(date), QUARTER(date)ORDER BY date), 2) AS revenue_qtd
FROM weekly_revenue_vitamins
ORDER BY date;

-- Calculating Cumulative Values for Minerals
WITH weekly_revenue_minerals AS (
     SELECT 
           date,
           ROUND(SUM(adj_revenue),2) AS weekly_total_revenue_minerals
	 FROM revenue_adjusted_22
     WHERE category = "Mineral"
     GROUP BY 1
)
SELECT 
      date,
      weekly_total_revenue_minerals,
      ROUND(SUM(weekly_total_revenue_minerals) OVER(PARTITION BY YEAR(date), MONTH(date) ORDER BY date),2) AS revenue_minerals_mtd,
      ROUND(SUM(weekly_total_revenue_minerals) OVER(PARTITION BY YEAR(date), QUARTER(date) ORDER BY date),2) AS revenue_minerals_qtd
FROM weekly_revenue_minerals;

-- Calculating Cumulative Values for Performance
WITH weekly_total_revenue_performance AS (
	 SELECT 
		   date,
           ROUND(SUM(adj_revenue),2) AS total_revenue_performance
	 FROM revenue_adjusted_22
     WHERE category = "Performance"
     GROUP BY 1
)
SELECT 
      date,
      total_revenue_performance,
      ROUND(SUM(total_revenue_performance) OVER(PARTITION BY YEAR(date), MONTH(date) ORDER BY date),2) AS revenue_performance_mtd,
      ROUND(SUM(total_revenue_performance) OVER(PARTITION BY YEAR(date), MONTH(date) ORDER BY date),2) AS revenue_performance_qtd
FROM weekly_total_revenue_performance;

-- Calculating Cumulative Values for Proteins
WITH weekly_total_revenue_proteins AS (
     SELECT 
           date,
           ROUND(SUM(adj_revenue),2) AS total_revenue_proteins
	  FROM revenue_adjusted_22
      WHERE category = "Protein"
      GROUP BY 1
)
SELECT 
      date,
      total_revenue_proteins,
      ROUND(SUM(total_revenue_proteins) OVER(PARTITION BY YEAR(date),MONTH(date) ORDER BY date),2) AS revenue_performance_mtd,
      ROUND(SUM(total_revenue_proteins) OVER(PARTITION BY YEAR(date), QUARTER(date) ORDER BY date),2) AS revenue_performance_qtd
FROM weekly_total_revenue_proteins;

-- Calculating Cumulative Values for Minerals in UK and across platforms
WITH weekly_revenue_minerals_uk AS (
     SELECT 
           date,
           ROUND(SUM(CASE
				   WHEN platform = "Walmart" 
                        AND adj_revenue IS NOT NULL THEN adj_revenue 
                        ELSE 0
                        END),2) AS revenue_walmart_uk,
		   ROUND(SUM(CASE 
					WHEN platform = "iHerb" 
                         AND adj_revenue IS NOT NULL THEN adj_revenue
						 ELSE 0
                         END),2) AS revenue_iherb_uk,
		   ROUND(SUM(CASE
                    WHEN platform = "Amazon" 
                         AND adj_revenue IS NOT NULL THEN adj_revenue
                         ELSE 0
                         END),2) AS revenue_amazon_uk,
           ROUND(SUM(adj_revenue),2) AS total_revenue_minerals_uk
	  FROM revenue_adjusted_22
      WHERE location = "UK"
      GROUP BY 1
)
SELECT 
      date,
      total_revenue_minerals_uk,
      ROUND(SUM(revenue_walmart_uk) OVER(PARTITION BY YEAR(date), MONTH(date) ORDER BY date),2) AS walmart_revenue_mtd,
      ROUND(SUM(revenue_walmart_uk) OVER(PARTITION BY YEAR(date), QUARTER(date) ORDER BY date),2) AS walmart_revenue_qtd,
      ROUND(SUM(revenue_amazon_uk) OVER(PARTITION BY YEAR(date), MONTH(date) ORDER BY date),2) AS amazon_revenue_mtd,
      ROUND(SUM(revenue_amazon_uk) OVER (PARTITION BY YEAR(date), QUARTER(date) ORDER BY date),2) AS amazon_revenue_qtd,
      ROUND(SUM(revenue_iherb_uk) OVER(PARTITION BY YEAR(date), MONTH(date) ORDER BY date),2) AS iherb_revenue_mtd,
      ROUND(SUM(revenue_iherb_uk) OVER(PARTITION BY YEAR(date), QUARTER(date) ORDER BY date),2) AS iherb_revenue_qtd
FROM weekly_revenue_minerals_uk;

-- Calculating Cumulative Values for Performance in Canada and across platforms

CREATE VIEW canada_performace AS(
		SELECT 
              date,
              adj_revenue,
              platform
        FROM revenue_adjusted_22
        WHERE location = "Canada" AND category = "Performance"
);

WITH week_rev_location_platforms AS (

	SELECT 
         date,
         "iherb" AS platform,
         ROUND(SUM(adj_revenue),2) AS weekly_revenue
	FROM canada_performace
    WHERE platform = "iherb"
    GROUP BY date
    
    UNION ALL
    
    SELECT 
          date,
          "Amazon" AS platform,
          ROUND(SUM(adj_revenue),2) AS weekly_revenue
	FROM canada_performace
    WHERE platform = "Amazon"
    GROUP BY 1
    
    UNION ALL 
    
    SELECT 
         date,
         "Walmart" AS platform,
         ROUND(SUM(adj_revenue),2) AS weekly_revenue
	FROM canada_performace
    WHERE  platform = "Walmart"
    GROUP BY 1
    
)
SELECT 
      date,
      platform,
      ROUND(SUM(weekly_revenue) OVER(PARTITION BY platform,YEAR(date), MONTH(date) ORDER BY date),2) AS revenue_mtd,
      ROUND(SUM(weekly_revenue) OVER(PARTITION BY platform,YEAR(date), QUARTER(date) ORDER BY date),2) AS revenue_qtd
FROM week_rev_location_platforms;

--  Period-over-Period Comparisons: MoM
WITH monthly_revenue AS (
  SELECT
    category,
    DATE_FORMAT(date, '%Y-%m') AS month,
    SUM(adj_revenue) AS adj_revenue
  FROM revenue_adjusted_22
  GROUP BY category, month
)
SELECT
  category,
  month,
  adj_revenue,
  ROUND(((adj_revenue / LAG(adj_revenue) OVER (PARTITION BY category ORDER BY month) - 1) * 100), 2) AS pct_growth_from_previous
FROM monthly_revenue
ORDER BY category, month;

--  Period-over-Period Comparisons: MoM for Vitamins
WITH revenue_vitamins_mom AS (
     SELECT 
           DATE_FORMAT(date,"%Y-%m") AS months,
           ROUND(SUM(adj_revenue),2) AS revenue,
           "Vitamins" AS category
	  FROM revenue_adjusted_22
      WHERE category = "Vitamin"
      GROUP BY 1
)
SELECT 
     months,
     revenue,
     category,
     ROUND(((revenue / LAG(revenue) OVER(PARTITION BY category  ORDER BY months)-1) * 100),2) AS pct_growth_from_previous
FROM revenue_vitamins_mom;
     
--  Period-over-Period Comparisons: MoM for Performance
WITH revenue_performance_mom AS (
     SELECT 
           DATE_FORMAT(date,"%Y-%m") AS months,
           ROUND(SUM(adj_revenue),2) AS revenue,
           "Performance" AS category
	FROM revenue_adjusted_22
    WHERE category = "Performance"
    GROUP BY 1
)
SELECT 
      months,
      category,
      revenue,
      ROUND((revenue / LAG(revenue) OVER(PARTITION BY category ORDER BY months)-1 )* 100 ,2) AS pct_growth_from_previous
FROM revenue_performance_mom;

--  Period-over-Period Comparisons: MoM for Minerals
WITH revenue_minerals_mom AS (
     SELECT 
           DATE_FORMAT(date,"%Y-%m") AS months,
           "Minerals" AS category,
           ROUND(SUM(adj_revenue),2) AS revenue
	 FROM revenue_adjusted_22
     WHERE category = "Mineral"
     GROUP BY 1
)
SELECT 
       months,
       category,
       revenue,
       ROUND(
       ((revenue / LAG(revenue) OVER(PARTITION BY category ORDER BY months))-1 ) * 100,2) AS pct_growth_from_previous
FROM revenue_minerals_mom;

--  Period-over-Period Comparisons: MoM for Vitamins in UK across Amazon and iHerb
WITH revenue_vitamin_uk_amazon_iherb AS (
     SELECT
          DATE_FORMAT(date,"%Y-%m") AS months,
          platform,
          "Vitamins" AS category,
          ROUND(SUM(adj_revenue),2) AS revenue
	 FROM revenue_adjusted_22
     WHERE 
          location = "UK" AND
          platform IN ("Amazon","iHerb") AND 
          category = "Vitamin"
	GROUP BY 1,2
)
SELECT 
      months,
      category,
      platform,
      revenue,
      ROUND(
      ((revenue / LAG(revenue) OVER(PARTITION BY platform ORDER BY months))-1)* 100,2) AS pct_growth_from_previous
FROM revenue_vitamin_uk_amazon_iherb;

--  Period-over-Period Comparisons: MoM for Minerals in Canada and Uk across Amazon
WITH revenue_minerals_cad_uk_amazon AS (
      SELECT 
            DATE_FORMAT(date,"%Y-%m") AS months,
            location,
            "Amazon" AS platform,
            "Minerals" AS minerals,
            ROUND(SUM(adj_revenue),2) AS revenue
	   FROM revenue_adjusted_22
       WHERE 
            location IN ("Canada", "UK") AND
            platform = "Amazon"
	   GROUP BY months,location
)
SELECT 
      months,
      location,
      platform,
      minerals,
      revenue,
      ROUND(
      ((revenue / LAG(revenue) OVER(PARTITION BY location ORDER BY months))-1) * 100,2) AS pct_growth_from_previous
FROM revenue_minerals_cad_uk_amazon;

--  Period-over-Period Comparisons: MoM for Performance in Canada and US acoross Amazon and iHerb
WITH performance_cad_us_amazon_iherb AS (
    SELECT 
          DATE_FORMAT(date,"%Y-%m") AS months,
          location,
          platform,
          "Performance" AS category,
          ROUND(SUM(adj_revenue),2) AS revenue
	FROM revenue_adjusted_22
    WHERE 
         location IN("Canada","USA") AND
         platform IN ("Amazon", "iHerb") AND
         category = "Performance"
	GROUP BY 1,2,3
)
SELECT 
      months,
      location,
      platform,
      category,
      revenue,
      ROUND(
      (revenue / LAG(revenue) OVER(PARTITION BY location,platform ORDER BY months)-1) * 100,2) AS pct_growth_from_previous
FROM performance_cad_us_amazon_iherb;
