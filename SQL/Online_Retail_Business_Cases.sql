--CASE 1-- “Overall sales have declined. I need you to investigate what happened, 
        -- identify where the decline is concentrated, determine the likely drivers, 
        --and recommend what the business should investigate or do next.” 



-- ====================================================================
-- STEP 1: MACRO PERFORMANCE & MOM ANALYSIS
-- Observation: November to December 2011 shows a massive drop.
-- ====================================================================
SELECT date_trunc('month', invoice_date::date)::date AS MONTH,
       sum(revenue) AS total_revenue,
       count(DISTINCT invoice) AS orders,
       round(sum(revenue) / count(DISTINCT invoice)::NUMERIC, 2) AS aov,
       round(
           ((sum(revenue) - LAG(sum(revenue)) OVER (ORDER BY date_trunc('month', invoice_date::date)::date)) 
           / LAG(sum(revenue)) OVER (ORDER BY date_trunc('month', invoice_date::date)::date)) * 100, 
           2
       ) AS revenue_decline_pct
FROM online_retail_data
GROUP BY 1
ORDER BY 1;

-- ====================================================================
-- STEP 2: HYPOTHESIS 1 - SEASONALITY CHECK
-- Observation: Dec 2011 revenue is vastly inferior to Dec 2010. 
-- ====================================================================
SELECT
    EXTRACT(YEAR FROM invoice_date) AS year,
    SUM(revenue) AS revenue
FROM online_retail_data
WHERE EXTRACT(MONTH FROM invoice_date) = 12
GROUP BY 1
ORDER BY 1;

-- ====================================================================
-- STEP 3: HYPOTHESIS 2 - CUSTOMER METRIC DEGRADATION
-- Observation: Found a severe drop in both orders and active unique buyers.
-- ====================================================================
SELECT date_trunc('month', invoice_date::date)::date AS MONTH,
       count(DISTINCT invoice) AS orders,
       count(DISTINCT customer_id) AS active_customers
FROM online_retail_data 
GROUP BY 1
ORDER BY 1;

-- ====================================================================
-- STEP 4: HYPOTHESIS 3 - COHORT BEHAVIOR (NEW VS. RETURNING)
-- Observation: The drop is Mostly concentrated in RETURNING customers.
-- ====================================================================
WITH first_orders AS (
    SELECT customer_id, min(invoice_date) AS first_order_date
    FROM online_retail_data
    GROUP BY customer_id
)
SELECT date_trunc('month', o.invoice_date)::date AS MONTH,
       CASE 
       	  WHEN date_trunc('month', o.invoice_date) = date_trunc('month', f.first_order_date) THEN 'New' 
          ELSE 'Returning'
       END AS customer_type,
       count(DISTINCT o.customer_id) AS customers,      
       sum(o.revenue) AS revenue
FROM online_retail_data o
JOIN first_orders f ON o.customer_id = f.customer_id 
GROUP BY 1, 2
ORDER BY 1, 2;

-- ====================================================================
-- STEP 5: THE DATA INTEGRITY AUDIT (The Critical Missing Link)
-- Rationale: A 50%+ drop in loyal, returning customers overnight is 
-- highly anomalous for a functional business. Before triggering a fire 
-- alarm regarding product or marketing failures, we must validate the 
-- fundamental health and completeness of the data pipeline for December.
-- ====================================================================
SELECT 
    min(invoice_date) AS dec_start_date,
    max(invoice_date) AS dec_end_date,
    count(DISTINCT invoice_date::date) AS active_reporting_days
FROM online_retail_data 
WHERE invoice_date >= '2011-12-01';



-- ====================================================================
--"Conclusion & Recommendation for the Business:Our investigation reveals 
--that the headline 'sales decline' in December is not a business performance failure,
-- but a data truncation artifact. The dataset only contains roughly 9 days of data 
--for December 2011 compared to a full 30 days in November.
--Next Steps for the Business: Instead of altering marketing or product strategy,
-- the immediate recommendation is to audit the ETL/data pipeline to resolve the data ingestion cutoff.
-- To perform a true performance evaluation, we must request the remaining 22 days of December data
-- from the engineering team."
-- ====================================================================



--CASE 2  -- “One of our markets is underperforming compared with the others. 
          --Identify which country is underperforming, determine what is driving its weak performance, 
          --and recommend what the business should do.”



-- ====================================================================
-- STEP 1: IDENTIFYING THE UNDERPERFORMANCE COUNTRY
-- Observation : -- EIRE is an underperforming market. Investigate what caused its revenue to decline by ~25% in 2011 
-- compared with the same period in 2010.
-- ====================================================================


SELECT
    country,
    ROUND(SUM(CASE
        WHEN invoice_date >= '2010-01-01'
         AND invoice_date < '2010-12-01'
        THEN revenue ELSE 0
    END), 2) AS revenue_jan_nov_2010,
    ROUND(SUM(CASE
        WHEN invoice_date >= '2011-01-01'
         AND invoice_date < '2011-12-01'
        THEN revenue ELSE 0
    END), 2) AS revenue_jan_nov_2011,
    ROUND(
        SUM(CASE
            WHEN invoice_date >= '2011-01-01'
             AND invoice_date < '2011-12-01'
            THEN revenue ELSE 0
        END)
        -
        SUM(CASE
            WHEN invoice_date >= '2010-01-01'
             AND invoice_date < '2010-12-01'
            THEN revenue ELSE 0
        END),
        2
    ) AS revenue_change
FROM online_retail_data
WHERE is_cancellation = 0
  AND is_zero_price = 0
  AND invoice_date >= '2010-01-01'
  AND invoice_date < '2011-12-01'
GROUP BY country
ORDER BY revenue_change;

-- ====================================================================
-- STEP 2: INVESTIGATING ORDERS AND AOV PERFORMACE OF EIRE IN THIS YEARS
-- ====================================================================


SELECT
    country,
    ROUND(SUM(CASE
        WHEN invoice_date >= '2010-01-01'
         AND invoice_date < '2010-12-01'
        THEN revenue ELSE 0
    END), 2) AS revenue_jan_nov_2010,
    ROUND(SUM(CASE
        WHEN invoice_date >= '2011-01-01'
         AND invoice_date < '2011-12-01'
        THEN revenue ELSE 0
    END), 2) AS revenue_jan_nov_2011,
    COUNT(DISTINCT CASE
        WHEN invoice_date >= '2010-01-01'
         AND invoice_date < '2010-12-01'
        THEN invoice
    END) AS orders_jan_nov_2010,
    COUNT(DISTINCT CASE
        WHEN invoice_date >= '2011-01-01'
         AND invoice_date < '2011-12-01'
        THEN invoice
    END) AS orders_jan_nov_2011
FROM online_retail_data
WHERE is_cancellation = 0
  AND is_zero_price = 0
  AND invoice_date >= '2010-01-01'
  AND invoice_date < '2011-12-01'
  AND country = 'EIRE'
GROUP BY country;


--EIRE's revenue declined 25.25% YoY, while order volume declined 17.92%.




SELECT
    country,
    ROUND(SUM(CASE
        WHEN invoice_date >= '2010-01-01'
         AND invoice_date < '2010-12-01'
        THEN revenue ELSE 0
    END), 2) AS revenue_jan_nov_2010,
    ROUND(SUM(CASE
        WHEN invoice_date >= '2011-01-01'
         AND invoice_date < '2011-12-01'
        THEN revenue ELSE 0
    END), 2) AS revenue_jan_nov_2011,
    ROUND(
        SUM(CASE
            WHEN invoice_date >= '2010-01-01'
             AND invoice_date < '2010-12-01'
            THEN revenue ELSE 0
        END)
        /
        COUNT(DISTINCT CASE
            WHEN invoice_date >= '2010-01-01'
             AND invoice_date < '2010-12-01'
            THEN invoice
        END)::NUMERIC,
        2
    ) AS aov_jan_nov_2010,
    ROUND(
        SUM(CASE
            WHEN invoice_date >= '2011-01-01'
             AND invoice_date < '2011-12-01'
            THEN revenue ELSE 0
        END)
        /
        COUNT(DISTINCT CASE
            WHEN invoice_date >= '2011-01-01'
             AND invoice_date < '2011-12-01'
            THEN invoice
        END)::NUMERIC,
        2
    ) AS aov_jan_nov_2011
FROM online_retail_data
WHERE is_cancellation = 0
  AND is_zero_price = 0
  AND invoice_date >= '2010-01-01'
  AND invoice_date < '2011-12-01'
  AND country = 'EIRE'
GROUP BY country;


--EIRE's revenue decline appears to be driven more by a reduction in order volume (318 → 261, −17.9%)
-- than by a major change in AOV (−8.9%).


-- ====================================================================
-- STEP 3: INVESTIGATING EIRE'S ACTIVE CUSTOMERS
-- ====================================================================



SELECT country,
      COUNT(DISTINCT CASE
        WHEN invoice_date >= '2010-01-01'
         AND invoice_date < '2010-12-01'
        THEN customer_id
    END) AS active_customers_jan_nov_2010,
      COUNT(DISTINCT CASE
        WHEN invoice_date >= '2011-01-01'
         AND invoice_date < '2011-12-01'
        THEN customer_id
    END) AS active_customers_jan_nov_2011
FROM online_retail_data
WHERE country = 'EIRE'
  AND is_cancellation = 0
  AND is_zero_price = 0
GROUP BY country;
     

--EIRE's active customer base declined from **5 customers in Jan–Nov 2010 to 3 customers in Jan–Nov 2011, a 40% decrease.
--This indicates that the decline in EIRE's revenue and orders may be partly driven by a reduction in the number of
-- active customers.

-- ====================================================================
-- STEP 4: DETERMINE WHEATER THIS DECLINE CAME FROM FEWER NEW OR FEWER RETURNING CUSTOMERS OR BOTH.
-- ====================================================================


WITH first_order AS (
    SELECT
        customer_id,
        MIN(invoice_date) AS first_order_date
    FROM online_retail_data
    WHERE is_cancellation = 0
      AND is_zero_price = 0
      AND customer_id IS NOT NULL
    GROUP BY customer_id
)
SELECT
    '2010' AS year,
    COUNT(DISTINCT CASE
        WHEN f.first_order_date >= '2010-01-01'
         AND f.first_order_date < '2010-12-01'
        THEN o.customer_id
    END) AS new_customers,
    COUNT(DISTINCT CASE
        WHEN f.first_order_date < '2010-01-01'
        THEN o.customer_id
    END) AS returning_customers
FROM online_retail_data o
JOIN first_order f
    ON o.customer_id = f.customer_id
WHERE o.country = 'EIRE'
  AND o.is_cancellation = 0
  AND o.is_zero_price = 0
  AND o.invoice_date >= '2010-01-01'
  AND o.invoice_date < '2010-12-01'
UNION ALL
SELECT
    '2011' AS year,
    COUNT(DISTINCT CASE
        WHEN f.first_order_date >= '2011-01-01'
         AND f.first_order_date < '2011-12-01'
        THEN o.customer_id
    END) AS new_customers,
    COUNT(DISTINCT CASE
        WHEN f.first_order_date < '2011-01-01'
        THEN o.customer_id
    END) AS returning_customers
FROM online_retail_data o
JOIN first_order f
    ON o.customer_id = f.customer_id
WHERE o.country = 'EIRE'
  AND o.is_cancellation = 0
  AND o.is_zero_price = 0
  AND o.invoice_date >= '2011-01-01'
  AND o.invoice_date < '2011-12-01';



--CONCLUSION: EIRE's 25.25% revenue decline was primarily associated with lower order volume and a 40% decline 
--in active customers. The key customer-level issue was new customer acquisition, 
--which fell from 3 customers in Jan–Nov 2010 to 0 in Jan–Nov 2011. 
--Returning customers increased from 2 to 3, so customer retention does not appear to be the main driver of the decline.




-- ========================================================================================================
-- STEP 5: Which products contributed most to EIRE's revenue decline between Jan–Nov 2010 and Jan–Nov 2011?
-- ========================================================================================================



SELECT
    stock_code,
    ROUND(SUM(CASE
        WHEN invoice_date >= '2010-01-01'
         AND invoice_date < '2010-12-01'
        THEN revenue ELSE 0
    END), 2) AS revenue_jan_nov_2010,
    ROUND(SUM(CASE
        WHEN invoice_date >= '2011-01-01'
         AND invoice_date < '2011-12-01'
        THEN revenue ELSE 0
    END), 2) AS revenue_jan_nov_2011,
    ROUND(
        SUM(CASE
            WHEN invoice_date >= '2011-01-01'
             AND invoice_date < '2011-12-01'
            THEN revenue ELSE 0
        END)
        -
        SUM(CASE
            WHEN invoice_date >= '2010-01-01'
             AND invoice_date < '2010-12-01'
            THEN revenue ELSE 0
        END),
        2
    ) AS revenue_change
FROM online_retail_data
WHERE is_cancellation = 0
  AND is_zero_price = 0
  AND invoice_date >= '2010-01-01'
  AND invoice_date < '2011-12-01'
  AND country = 'EIRE'
GROUP BY stock_code 
ORDER BY revenue_change;



-- ========================================================================================================
-- STEP 6: Are the biggest product revenue declines caused by fewer units sold, lower prices, or both?
-- ========================================================================================================


SELECT
    stock_code,
    SUM(CASE
        WHEN invoice_date >= '2010-01-01'
         AND invoice_date < '2010-12-01'
        THEN quantity ELSE 0
    END) AS units_sold_2010,
    SUM(CASE
        WHEN invoice_date >= '2011-01-01'
         AND invoice_date < '2011-12-01'
        THEN quantity ELSE 0
    END) AS units_sold_2011,
    ROUND(SUM(CASE
        WHEN invoice_date >= '2010-01-01'
         AND invoice_date < '2010-12-01'
        THEN revenue ELSE 0
    END), 2) AS revenue_2010,
    ROUND(SUM(CASE
        WHEN invoice_date >= '2011-01-01'
         AND invoice_date < '2011-12-01'
        THEN revenue ELSE 0
    END), 2) AS revenue_2011
FROM online_retail_data
WHERE is_cancellation = 0
  AND is_zero_price = 0
  AND country = 'EIRE'
  AND invoice_date >= '2010-01-01'
  AND invoice_date < '2011-12-01'
GROUP BY stock_code
ORDER BY 3 - 4;


--Many products show lower units sold in 2011, which supports a volume-driven decline.
--Some products disappeared completely in 2011 (2010 units > 0, 2011 units = 0).
--Some products actually increased strongly, e.g. 22838 went from 4 → 333 units.
--Some products had almost unchanged units but lower revenue, which could indicate a price effect.


-- ========================================================================================================
-- STEP 7: INVESTIGATE WEATHER THEIR AVG SELLING PRICE CHANGES BETWEEN 2010 and 2011?
-- ========================================================================================================


SELECT
    stock_code,
    SUM(CASE
        WHEN invoice_date >= '2010-01-01'
         AND invoice_date < '2010-12-01'
        THEN quantity ELSE 0
    END) AS units_2010,
    SUM(CASE
        WHEN invoice_date >= '2011-01-01'
         AND invoice_date < '2011-12-01'
        THEN quantity ELSE 0
    END) AS units_2011,
    ROUND(
        SUM(CASE
            WHEN invoice_date >= '2010-01-01'
             AND invoice_date < '2010-12-01'
            THEN revenue ELSE 0
        END)
        /
        NULLIF(SUM(CASE
            WHEN invoice_date >= '2010-01-01'
             AND invoice_date < '2010-12-01'
            THEN quantity ELSE 0
        END), 0),
        2
    ) AS asp_2010,
    ROUND(
        SUM(CASE
            WHEN invoice_date >= '2011-01-01'
             AND invoice_date < '2011-12-01'
            THEN revenue ELSE 0
        END)
        /
        NULLIF(SUM(CASE
            WHEN invoice_date >= '2011-01-01'
             AND invoice_date < '2011-12-01'
            THEN quantity ELSE 0
        END), 0),
        2
    ) AS asp_2011
FROM online_retail_data
WHERE is_cancellation = 0
  AND is_zero_price = 0
  AND country = 'EIRE'
  AND invoice_date >= '2010-01-01'
  AND invoice_date < '2011-12-01'
GROUP BY stock_code;



--Units sold fell substantially while ASP remained stable or even increased.
--CONCLUSION: EIRE's product-level revenue decline appears primarily volume-driven rather than price-driven.



--"Are a few products responsible for most of the decline, or is the decline widespread?"


WITH product_decline AS (
    SELECT
        stock_code,
        SUM(CASE
            WHEN invoice_date >= '2010-01-01'
             AND invoice_date < '2010-12-01'
            THEN revenue ELSE 0
        END) AS revenue_2010,
        SUM(CASE
            WHEN invoice_date >= '2011-01-01'
             AND invoice_date < '2011-12-01'
            THEN revenue ELSE 0
        END) AS revenue_2011
    FROM online_retail_data
    WHERE is_cancellation = 0
      AND is_zero_price = 0
      AND country = 'EIRE'
      AND invoice_date >= '2010-01-01'
      AND invoice_date < '2011-12-01'
    GROUP BY stock_code
),
declines AS (
    SELECT
        stock_code,
        revenue_2011 - revenue_2010 AS revenue_decline
    FROM product_decline
    WHERE revenue_2011 - revenue_2010 < 0
)
SELECT
    stock_code,
    ROUND(revenue_decline, 2) AS revenue_decline,
    ROUND(
        ABS(revenue_decline)
        /
        SUM(ABS(revenue_decline)) OVER ()
        * 100,
        2
    ) AS contribution_pct
FROM declines
ORDER BY revenue_decline;






-- ========================================================================================================

-- OVERALL CONCLUSION:
--
-- EIRE's revenue declined by 25.25% from Jan-Nov 2010 to Jan-Nov 2011.
--
-- The decline was primarily driven by lower order volume and a 40% reduction in active customers.
--
-- New customer acquisition fell from 3 customers to 0, while returning customers increased
-- from 2 to 3, suggesting that customer acquisition was a more significant issue than retention.
--
-- Product-level analysis indicates that the decline was mainly volume-driven, as many products
-- experienced substantial reductions in units sold while ASP remained relatively stable or increased.
--
-- The decline was widespread across multiple products rather than being concentrated in a small
-- number of merchandise products.
--
-- NOTE: EIRE has a very small customer base, so these findings should be treated as directional.
--
--========================================================================================================








--Case 3- “Our product portfolio is generating revenue, but I want to understand whether our revenue is 
          --too dependent on a small number of products. Identify the products that contribute most to revenue,
          -- assess whether there is any concentration risk, and highlight any products that management should pay 
          --particular attention to.”



-- ===============================================================================================================================
-- STEP 1: INDENTIFYING WHICH PRODUCTS GENERATE THE MOST REVENUE.
-- Observation: Product 22423 generates the highest revenue at £330.6K, followed by 85123A at £257.7K and 85099B at £180.6K.
-- ===============================================================================================================================



SELECT
    stock_code,
    SUM(revenue) AS total_revenue
FROM online_retail_data
WHERE is_cancellation = 0
  AND is_zero_price = 0
  AND stock_code NOT IN ('POST', 'DOT', 'M', 'D', 'C2', 'GIFT', 'ADJUST')
GROUP BY stock_code
ORDER BY total_revenue DESC
LIMIT 10;




-- ===============================================================================================================================
-- STEP 2: INDENTIFYING WHAT % OF TOTAL MERCHANDISE REVENUE IS GENERATED BY THE TOP 10 PRODUCTS.
-- Observation: Top 10 products generate only 8.35% of total revenue. Therefore, based on this measure, 
--              revenue is not heavily concentrated in the Top 10 products; revenue is spread across a relatively 
--              large number of products.
-- ===============================================================================================================================




SELECT
    sum(product_revenue)AS top_10_revenue,
    18855533.698 AS grand_total_revenue,
    round((sum(product_revenue) / 18855533.698) * 100.0, 2)AS top_10_percentage
FROM (SELECT sum(revenue)AS product_revenue
      FROM online_retail_data
      WHERE is_cancellation = 0
         AND is_zero_price = 0
         AND stock_code NOT IN ('POST', 'DOT', 'M', 'D', 'C2', 'GIFT', 'ADJUST')
      GROUP BY stock_code
      ORDER BY product_revenue DESC
      limit 10
     )AS top_products;



-- ===============================================================================================================================
-- STEP 2: INDENTIFYING THE REVENUE CONTRIBUTION OF TOP 20 PRODUCTS
-- Observation: Revenue is relatively diversified across the product portfolio. 
--              The Top 10 products contribute 8.35% of revenue, while the Top 50 contribute 20.27%, 
--              indicating that revenue is not highly concentrated in a small number of products.
-- ===============================================================================================================================

SELECT
    sum(product_revenue)AS top_10_revenue,
    18855533.698 AS grand_total_revenue,
    round((sum(product_revenue) / 18855533.698) * 100.0, 2)AS top_10_percentage
FROM (SELECT sum(revenue)AS product_revenue
      FROM online_retail_data
      WHERE is_cancellation = 0
         AND is_zero_price = 0
         AND stock_code NOT IN ('POST', 'DOT', 'M', 'D', 'C2', 'GIFT', 'ADJUST')
      GROUP BY stock_code
      ORDER BY product_revenue DESC
      limit 50
     )AS top_products;




-- OVERALL CONCLUSION: 
-- Top product: 22423 → £330,590.32
-- Top 10: 8.35% of total revenue
-- Top 20: 11.95%
-- Top 30: 15.03%
-- Top 40: 17.73%
-- Top 50: 20.27%
-- Revenue is fairly distributed across the product portfolio, 
-- rather than being heavily concentrated in a small number of products.
-- Product 22423 deserves monitoring because it is the highest-revenue product.





--CASE 4: “I’m concerned that cancellations and returns may be reducing our sales. 
--         Investigate how significant the problem is, identify where it is happening, 
--         and determine which products or markets are most affected.”



-- ===============================================================================================================================
-- STEP 1: INDENTIFYING HOW MUCH CANCELLATIONS & RETURNS HAPPENS YoY
-- Observation:cancellations and negative-quantity transactions decreased in 2011 compared with the same Jan–Nov period in 2010.
-- ===============================================================================================================================


SELECT 
    SUM(CASE
        WHEN invoice_date >= '2010-01-01'
         AND invoice_date < '2010-12-01'
        THEN is_cancellation ELSE 0
    END) AS Cancellations_in_2010,
    SUM(CASE
        WHEN invoice_date >= '2011-01-01'
         AND invoice_date < '2011-12-01'
        THEN is_cancellation ELSE 0
    END) AS Cancelations_in_2011,
    SUM(CASE
        WHEN invoice_date >= '2010-01-01'
         AND invoice_date < '2010-12-01'
        THEN is_negative_quantity ELSE 0
    END) AS negative_quantity_in_2010,
    SUM(CASE
        WHEN invoice_date >= '2011-01-01'
         AND invoice_date < '2011-12-01'
        THEN is_negative_quantity ELSE 0
    END) AS negative_quantity_in_2011
FROM online_retail_data;


--Raw counts can fall simply because the business had fewer transactions overall.


-- ===============================================================================================================================
-- STEP 2: Calculate the cancellation rate and negative-quantity rate relative to total transactions for each year.
-- Observation:Cancellations and negative-quantity transactions did not become more common in 2011. Their rates actually decreased compared with Jan–Nov 2010.
--             So at this point, cancellations/negative quantities do not appear to be worsening as a proportion of transactions.
-- ===============================================================================================================================



SELECT
    EXTRACT(YEAR FROM invoice_date) AS year,
    COUNT(*) AS total_transactions,
    SUM(CASE
        WHEN is_cancellation = 1 THEN 1
        ELSE 0
    END) AS cancellations,
    ROUND(
        SUM(CASE
            WHEN is_cancellation = 1 THEN 1
            ELSE 0
        END)::numeric
        / COUNT(*) * 100,
        2
    ) AS cancellation_rate,
    SUM(CASE
        WHEN is_negative_quantity = 1 THEN 1
        ELSE 0
    END) AS negative_quantity_transactions,
    ROUND(
        SUM(CASE
            WHEN is_negative_quantity = 1 THEN 1
            ELSE 0
        END)::numeric
        / COUNT(*) * 100,
        2
    ) AS negative_quantity_rate
FROM online_retail_data
WHERE invoice_date >= '2010-01-01'
  AND invoice_date < '2011-12-01'
GROUP BY 1
ORDER BY 1;


-- ===============================================================================================================================
-- STEP 3: INVESTIGATING How much revenue is being lost/affected by cancellations and negative-quantity transactions?

-- Observation: The cancellation impact is almost unchanged
-- ===============================================================================================================================



SELECT
    EXTRACT(YEAR FROM invoice_date) AS year,
    SUM(CASE
        WHEN is_cancellation = 1
        THEN revenue
        ELSE 0
    END) AS cancellation_revenue_impact,
    SUM(CASE
        WHEN is_negative_quantity = 1
        THEN revenue
        ELSE 0
    END) AS negative_quantity_revenue_impact
FROM online_retail_data
WHERE invoice_date >= '2010-01-01'
  AND invoice_date < '2011-12-01'
GROUP BY 1
ORDER BY 1;



-- ===============================================================================================================================
-- STEP 4: IDENTIFYING Average revenue impact per cancellation

-- Observation: Cancellations fell 14.5%.
--              But total cancellation revenue impact barely changed: −£616,964.55 → −£614,161.34.
--              Average financial impact per cancellation increased from £64.54 → £75.15, about 16.4% higher.
-- ===============================================================================================================================


SELECT
    EXTRACT(YEAR FROM invoice_date) AS year,
    COUNT(
        CASE
            WHEN is_cancellation = 1
            THEN 1
        END
    ) AS total_cancellations,
    ROUND(
        SUM(
            CASE
                WHEN is_cancellation = 1
                THEN revenue
                ELSE 0
            END
        ), 2
    ) AS total_cancellation_revenue_impact,
    ROUND(
        AVG(
            CASE
                WHEN is_cancellation = 1
                THEN revenue
            END
        ), 2
    ) AS avg_revenue_impact_per_cancellation
FROM online_retail_data
WHERE invoice_date >= '2010-01-01'
  AND invoice_date < '2011-12-01'
GROUP BY 1
ORDER BY 1;






-- ===============================================================================================================================
--STEP 5: Investigate Which countries have the highest cancellation rate and cancellation revenue impact, 
--        and is the issue concentrated in a particular market?

--OBSERVATION: Cancellation impact is concentrated financially in the UK,
--             while some smaller markets have substantially higher cancellation rates. 
--             Therefore, cancellation severity and cancellation frequency need to be evaluated separately.
--             Some small markets have unusually expensive cancellations
-- ===============================================================================================================================


SELECT country,
       SUM(CASE
        WHEN is_cancellation = 1 THEN 1
        ELSE 0
    END) AS cancellations,
       ROUND(
        SUM(CASE
            WHEN is_cancellation = 1 THEN 1
            ELSE 0
        END)::numeric
        / COUNT(*) * 100,
        2
    ) AS cancellation_rate,
       ROUND(
        SUM(
            CASE
                WHEN is_cancellation = 1
                THEN revenue
                ELSE 0
            END
        ), 2
    ) AS total_cancellation_revenue_impact,
    ROUND(
        AVG(
            CASE
                WHEN is_cancellation = 1
                THEN revenue
            END
        ), 2
    ) AS avg_revenue_impact_per_cancellation
FROM online_retail_data
GROUP BY country;



-- ===============================================================================================================================
--STEP 6: Investigate Which products are responsible for the largest cancellation/return revenue impact?

--OBSERVATION: Product-level cancellation impact is highly uneven.
--             Product 23843 had only 1 cancellation but resulted in the largest revenue impact of −£168,469.60, 
--             while product 23166 had 10 cancellations with an impact of −£77,479.64. 
--             In comparison, product 22423 had the highest number of cancellations (341), 
--             but its financial impact was much lower at −£16,545.30.
-- ===============================================================================================================================




SELECT
    stock_code,
    COUNT(*) AS total_transactions,
    SUM(CASE
        WHEN is_cancellation = 1 THEN 1
        ELSE 0
    END) AS cancellations,
    ROUND(
        SUM(CASE
            WHEN is_cancellation = 1 THEN 1
            ELSE 0
        END)::numeric
        / COUNT(*) * 100,
        2
    ) AS cancellation_rate,
    ROUND(
        SUM(CASE
            WHEN is_cancellation = 1
            THEN revenue
            ELSE 0
        END),
        2
    ) AS cancellation_revenue_impact
FROM online_retail_data
WHERE stock_code NOT IN (
    'POST',
    'DOT',
    'M',
    'D',
    'C2',
    'GIFT',
    'ADJUST',
    'AMAZONFEE',
    'BANK CHARGES',
    'CRUK',
    'S'
)
GROUP BY stock_code
ORDER BY cancellation_revenue_impact ASC;




-- ===============================================================================================================================
--STEP 6: Investigate Among products with at least 100 transactions, which have the highest cancellation rate?

--OBSERVATION: Even after applying a minimum 100-transaction threshold, 
--             several products have very high cancellation rates, with 79323B reaching 45.95%.
--       These products warrant further investigation to understand the reasons behind their high cancellation frequency.
-- =========================================================================================================================





SELECT
    stock_code,
    COUNT(*) AS total_transactions,
    SUM(CASE
        WHEN is_cancellation = 1 THEN 1
        ELSE 0
    END) AS cancellations,
    ROUND(
        SUM(CASE
            WHEN is_cancellation = 1 THEN 1
            ELSE 0
        END)::numeric
        / COUNT(*) * 100,
        2
    ) AS cancellation_rate,
    ROUND(
        SUM(CASE
            WHEN is_cancellation = 1
            THEN revenue
            ELSE 0
        END),
        2
    ) AS cancellation_revenue_impact
FROM online_retail_data
WHERE stock_code NOT IN (
    'POST',
    'DOT',
    'M',
    'D',
    'C2',
    'GIFT',
    'ADJUST',
    'AMAZONFEE',
    'BANK CHARGES',
    'CRUK',
    'S'
)
GROUP BY stock_code
HAVING COUNT(*) >= 100
ORDER BY cancellation_rate DESC;




--CONCLUSION:
--Cancellations and negative-quantity transactions do not appear to be worsening overall, 
--as their transaction rates declined from 2010 to 2011.
--However, the financial impact remains significant because the average revenue impact per cancellation increased 
--from £64.54 to £75.15. The issue also varies by market and product: some products have high cancellation frequencies,
--while others have relatively few cancellations but very large financial impacts. 
--Therefore, management should investigate the specific causes of high-frequency cancellations 
--and high-value cancellations separately, rather than relying on cancellation volume alone.





--CASE 6: “I want to understand how customers are purchasing from us. 
--         Identify whether our customer base is driven mainly by new or returning customers, 
--         how frequently customers purchase, and whether a small group of customers contributes a large share of revenue. 
--         Highlight any customer behavior that management should pay attention to.”





-- ===============================================================================================================================
-- STEP 1: Investigating Is the business acquiring new customers or mainly relying on existing customers?
-- Observation: Customer acquisition declined substantially from 3,387 new customers in 2010 to 1,508 in 2011, 
--             a 55.5% decrease. At the same time, returning customers increased from 844 to 2,665, a 215.8% increase.
--             This indicates a shift in the customer base from new-customer acquisition toward existing-customer activity.  
-- ===============================================================================================================================



WITH first_order AS (
    SELECT
        customer_id,
        MIN(invoice_date) AS first_order_date
    FROM online_retail_data
    WHERE is_cancellation = 0
      AND is_zero_price = 0
      AND customer_id IS NOT NULL
    GROUP BY customer_id
)
SELECT
    EXTRACT(YEAR FROM o.invoice_date) AS year,
    CASE
        WHEN EXTRACT(YEAR FROM o.invoice_date)
             = EXTRACT(YEAR FROM f.first_order_date)
        THEN 'New'
        ELSE 'Returning'
    END AS customer_type,
    COUNT(DISTINCT o.customer_id) AS total_customers
FROM online_retail_data o
JOIN first_order f
    ON o.customer_id = f.customer_id
WHERE o.is_cancellation = 0
  AND o.is_zero_price = 0
  AND o.customer_id IS NOT NULL
  AND o.invoice_date >= '2010-01-01'
  AND o.invoice_date < '2011-12-01'
GROUP BY 1, 2
ORDER BY 1, 2;


    

   
-- ===============================================================================================================================
-- STEP 2:  FIND “Are customers making repeat purchases, or are most customers purchasing only once?”

-- OBSERVATION: 
-- ===============================================================================================================================


--FOR YEAR 2010


WITH customer_order_counts AS (
    SELECT 
        customer_id, 
        COUNT(DISTINCT invoice) AS total_invoices 
    FROM online_retail_data
     WHERE customer_id IS NOT NULL
      AND is_cancellation = 0
      AND is_zero_price = 0
      AND invoice_date >= '2010-01-01'
      AND invoice_date < '2010-12-01'
    GROUP BY customer_id
)
SELECT 
     SUM(CASE WHEN total_invoices = 1 THEN 1 ELSE 0 END) AS customer_with_1_orders,
     SUM(CASE WHEN total_invoices IN (2, 3) THEN 1 ELSE 0 END) AS customer_with_2_3_orders,
     SUM(CASE WHEN total_invoices IN (4, 5) THEN 1 ELSE 0 END) AS customer_with_4_5_orders,
     SUM(CASE WHEN total_invoices >= 6 THEN 1 ELSE 0 END) AS customer_with_6_more_orders
FROM customer_order_counts;


--FOR YEAR 2011



WITH customer_order_counts AS (
    SELECT 
        customer_id, 
        COUNT(DISTINCT invoice) AS total_invoices 
    FROM online_retail_data
     WHERE customer_id IS NOT NULL
      AND is_cancellation = 0
      AND is_zero_price = 0
      AND invoice_date >= '2011-01-01'
      AND invoice_date < '2011-12-01'
    GROUP BY customer_id
)
SELECT 
     SUM(CASE WHEN total_invoices = 1 THEN 1 ELSE 0 END) AS customer_with_1_orders,
     SUM(CASE WHEN total_invoices IN (2, 3) THEN 1 ELSE 0 END) AS customer_with_2_3_orders,
     SUM(CASE WHEN total_invoices IN (4, 5) THEN 1 ELSE 0 END) AS customer_with_4_5_orders,
     SUM(CASE WHEN total_invoices >= 6 THEN 1 ELSE 0 END) AS customer_with_6_more_orders
FROM customer_order_counts;




-- ===============================================================================================================================
--STEP 3:  Calculate Customer AOV for 2010 and 2011
--OBSERVATION: Customer AOV decreased by 5.56%, from £1,979.32 in 2010 to £1,869.06 in 2011, 
--             indicating lower revenue generated per customer despite Order AOV increasing.
-- ===============================================================================================================================



SELECT extract(YEAR FROM invoice_date)AS YEAR,
     sum(revenue)AS total_revenue,
     count(DISTINCT invoice)AS total_orders,
     round(sum(revenue) / count(DISTINCT customer_id)::NUMERIC, 2)AS customer_aov
FROM online_retail_data
WHERE customer_id IS NOT NULL
      AND is_cancellation = 0
      AND is_zero_price = 0
      AND invoice_date >= '2010-01-01'
      AND invoice_date < '2011-12-01'
GROUP BY extract(YEAR FROM invoice_date)
ORDER BY YEAR;



-- ===============================================================================================================================
--STEP 4: determine whether a small group of customers generates a disproportionately large share of total revenue.
--OBSERVATION: Revenue is highly concentrated among a small group of customers: 
--             the top 10% generate 63.9% of total revenue, while the bottom 50% contribute only about 8.24%. 
--             This indicates significant dependence on high-value customers.
-- ===============================================================================================================================


WITH customer_revenue AS (
    SELECT 
        customer_id,
        SUM(revenue) AS total_spend
    FROM online_retail_data
    WHERE customer_id IS NOT NULL
       AND is_cancellation = 0
       AND is_zero_price = 0
    GROUP BY customer_id
),
customer_buckets AS (
    SELECT 
        total_spend,
        NTILE(10) OVER (ORDER BY total_spend ASC) AS revenue_bucket
    FROM customer_revenue
)
SELECT 
    revenue_bucket, 
    SUM(total_spend) AS bucket_revenue,
    ROUND(100.0 * SUM(total_spend) / SUM(SUM(total_spend)) OVER (), 2) AS percentage_of_total_revenue
FROM customer_buckets
GROUP BY revenue_bucket
ORDER BY revenue_bucket DESC;





--CONCLUSION:
--The customer base shifted from acquisition toward existing customers, 
--while customer AOV declined and revenue became heavily dependent on a small group of high-value customers.
-- This makes both customer acquisition and high-value customer retention important areas for management to monitor.






--CASE 7: 

-- “We know that a small group of customers contributes a large share of revenue. 
--I want to identify our highest-value customers and the products generating the most revenue.
-- Determine how dependent the business is on these high-value customers and products, 
--and identify anything management should pay attention to.”




-- ===============================================================================================================================
--STEP 1: FINDING OUT TOP 10 CUSTOMER THAT IS GENERATING THE MOST REVENUE 
--OBSERVATION: 
-- ===============================================================================================================================



SELECT 
      customer_id,
      SUM(revenue)AS TOP_10_CUSTOMERS_BY_REVENUE
FROM online_retail_data 
WHERE customer_id IS NOT NULL 
  AND is_cancellation = 0
  AND is_zero_price = 0
GROUP BY customer_id 
ORDER BY top_10_customers_by_revenue DESC
LIMIT 10;



-- ===============================================================================================================================
--STEP 1: Measuring the top 10 customers revenue contribution in the overall company revenue
--OBSERVATION: The top 10 customers generate 16.04% of total valid customer revenue, 
--             showing that a relatively small group of customers makes a meaningful contribution to overall revenue.
-- ===============================================================================================================================



WITH customer_revenue AS (
SELECT customer_id,
       sum(revenue)AS total_revenue
FROM online_retail_data
WHERE customer_id IS NOT NULL 
  AND is_cancellation = 0
  AND is_zero_price = 0
GROUP BY customer_id
),
top_10 AS (
SELECT customer_id,
       total_revenue
FROM customer_revenue
ORDER BY total_revenue  DESC
LIMIT 10
)
SELECT round(sum(total_revenue), 2)AS top_10_revenue,
       round(sum(total_revenue) * 100.0 / (SELECT SUM(total_revenue) FROM customer_revenue),2)AS top_10_revenue_contribution
FROM top_10;



-- ===============================================================================================================================
--STEP 2: Finding top products by revenue
--OBSERVATION: 
-- ===============================================================================================================================



SELECT stock_code,
       sum(revenue)AS top_10_products_revenue
FROM online_retail_data 
WHERE is_cancellation = 0
  AND is_zero_price = 0
  AND stock_code NOT IN (
    'POST',
    'DOT',
    'M',
    'D',
    'C2',
    'GIFT',
    'ADJUST',
    'AMAZONFEE',
    'BANK CHARGES',
    'CRUK',
    'S'
)
GROUP BY stock_code
ORDER BY top_10_products_revenue DESC
LIMIT 10;


-- ===============================================================================================================================
--STEP 3: Measure the top 10 products revenue contribution in the overall company revenue
--OBSERVATION: The top 10 products contribute only 8.07% of total valid product revenue, 
-- indicating that product revenue is relatively diversified rather than heavily dependent on a small group of products.
-- ===============================================================================================================================



WITH company_revenue AS 
(SELECT stock_code,
       sum(revenue)AS total_revenue
FROM online_retail_data
WHERE is_cancellation = 0
  AND is_zero_price = 0
  AND stock_code NOT IN (
    'POST',
    'DOT',
    'M',
    'D',
    'C2',
    'GIFT',
    'ADJUST',
    'AMAZONFEE',
    'BANK CHARGES',
    'CRUK',
    'S'
)
GROUP BY stock_code
),
top_10 AS 
( SELECT stock_code,
         total_revenue
  FROM company_revenue
  ORDER BY total_revenue DESC
  LIMIT 10
)
SELECT round(sum(total_revenue), 2)AS top_10_revenue,
       round(sum(total_revenue) * 100.0 / (SELECT sum(total_revenue) FROM company_revenue), 2) AS top_10_products_revenue_contribution
FROM top_10;



-- ===============================================================================================================================
--STEP 4: Analyzing whether the high-value customers are concentrated around a few products.
--OBSERVATION:
-- ===============================================================================================================================


--STEP 4.1:  Find the products generating the most revenue from the Top 10 customers only.


WITH customer_revenue AS (
    SELECT
        customer_id,
        SUM(revenue) AS total_revenue
    FROM online_retail_data
    WHERE customer_id IS NOT NULL
      AND is_cancellation = 0
      AND is_zero_price = 0
    GROUP BY customer_id
),
top_10_customers AS (
    SELECT
        customer_id
    FROM customer_revenue
    ORDER BY total_revenue DESC
    LIMIT 10
)
SELECT
    o.stock_code,
    SUM(o.revenue) AS total_revenue
FROM online_retail_data o
JOIN top_10_customers t
    ON o.customer_id = t.customer_id
WHERE o.is_cancellation = 0
  AND o.is_zero_price = 0
  AND o.stock_code NOT IN (
    'POST',
    'DOT',
    'M',
    'D',
    'C2',
    'GIFT',
    'ADJUST',
    'AMAZONFEE',
    'BANK CHARGES',
    'CRUK',
    'S'
  )
GROUP BY o.stock_code
ORDER BY total_revenue DESC
LIMIT 10;


--4.2: What percentage of the Top 10 customers' total revenue comes from these Top 10 products?


WITH top_customers AS (
    SELECT
        customer_id,
        SUM(revenue) AS total_cust_rev
    FROM online_retail_data
    WHERE customer_id IS NOT NULL
      AND is_cancellation = 0
      AND is_zero_price = 0
    GROUP BY customer_id
    ORDER BY total_cust_rev DESC
    LIMIT 10
),
top_products AS (
    SELECT
        stock_code,
        SUM(revenue) AS total_prod_rev
    FROM online_retail_data
    WHERE is_cancellation = 0
      AND is_zero_price = 0
      AND stock_code NOT IN (
        'POST','DOT','M','D','C2','GIFT','ADJUST',
        'AMAZONFEE','BANK CHARGES','CRUK','S'
      )
    GROUP BY stock_code
    ORDER BY total_prod_rev DESC
    LIMIT 10
)
SELECT
    SUM(o.revenue) AS revenue_from_top_products,
    (SELECT SUM(total_cust_rev) FROM top_customers)
        AS total_top_customer_revenue,
    ROUND(
        SUM(o.revenue) * 100.0 /
        (SELECT SUM(total_cust_rev) FROM top_customers),
        2
    ) AS intersection_percentage
FROM online_retail_data o
WHERE o.customer_id IN (SELECT customer_id FROM top_customers)
  AND o.stock_code IN (SELECT stock_code FROM top_products)
  AND o.is_cancellation = 0
  AND o.is_zero_price = 0;






--CONCLUSION: 
--The business has a meaningful concentration of revenue among its highest-value customers.
--but those customers are relatively diversified across products.
--The Top 10 products account for only 8.07% of overall product revenue.
--and only 10.31% of Top 10 customer revenue comes from those products.












