/*
===============================================================================
PROJECT 4 — SUPPLY CHAIN & INVENTORY OPTIMIZATION ANALYTICS
Complete SQL Portfolio Project
Database: MySQL 8.0+
Source: supply_chain_dataset1(1).csv
Rows in source dataset: 91,250
===============================================================================

HOW TO USE
1. Create a MySQL database.
2. Run the database/table section below.
3. Import the CSV into supply_chain_data.
4. Run the cleaning, KPI, analysis and reporting queries.
5. Use the final views for Power BI / reporting.

IMPORTANT:
- The CSV import path is intentionally commented because it depends on your PC.
- If your MySQL Workbench CSV import wizard is used, map all original 15 columns.
===============================================================================
*/

-- ============================================================================
-- 1. DATABASE
-- ============================================================================

CREATE DATABASE IF NOT EXISTS supply_chain_analytics;
USE supply_chain_analytics;

-- ============================================================================
-- 2. RAW TABLE
-- ============================================================================

DROP TABLE IF EXISTS supply_chain_data;

CREATE TABLE supply_chain_data (
    Date DATE,
    SKU_ID VARCHAR(100),
    Warehouse_ID VARCHAR(100),
    Supplier_ID VARCHAR(100),
    Region VARCHAR(100),
    Units_Sold DECIMAL(18,2),
    Inventory_Level DECIMAL(18,2),
    Supplier_Lead_Time_Days DECIMAL(18,2),
    Reorder_Point DECIMAL(18,2),
    Order_Quantity DECIMAL(18,2),
    Unit_Cost DECIMAL(18,4),
    Unit_Price DECIMAL(18,4),
    Promotion_Flag INT,
    Stockout_Flag INT,
    Demand_Forecast DECIMAL(18,2)
);

-- ============================================================================
-- 3. CSV IMPORT EXAMPLE
-- ============================================================================
-- Enable LOCAL INFILE if required by your MySQL installation.
--
-- LOAD DATA LOCAL INFILE 'C:/YOUR_PATH/supply_chain_dataset1(1).csv'
-- INTO TABLE supply_chain_data
-- FIELDS TERMINATED BY ','
-- ENCLOSED BY '"'
-- LINES TERMINATED BY '\n'
-- IGNORE 1 ROWS
-- (Date, SKU_ID, Warehouse_ID, Supplier_ID, Region,
--  Units_Sold, Inventory_Level, Supplier_Lead_Time_Days,
--  Reorder_Point, Order_Quantity, Unit_Cost, Unit_Price,
--  Promotion_Flag, Stockout_Flag, Demand_Forecast);

-- ============================================================================
-- 4. BASIC DATA VALIDATION
-- ============================================================================

-- Total rows
SELECT COUNT(*) AS total_rows
FROM supply_chain_data;

-- Columns / sample records
SELECT *
FROM supply_chain_data
LIMIT 10;

-- Date range
SELECT
    MIN(Date) AS first_date,
    MAX(Date) AS last_date
FROM supply_chain_data;

-- Distinct counts
SELECT
    COUNT(DISTINCT SKU_ID) AS total_skus,
    COUNT(DISTINCT Warehouse_ID) AS total_warehouses,
    COUNT(DISTINCT Supplier_ID) AS total_suppliers,
    COUNT(DISTINCT Region) AS total_regions
FROM supply_chain_data;

-- ============================================================================
-- 5. DATA QUALITY CHECKS
-- ============================================================================

-- NULL checks
SELECT
    SUM(Date IS NULL) AS null_date,
    SUM(SKU_ID IS NULL OR SKU_ID = '') AS null_sku,
    SUM(Warehouse_ID IS NULL OR Warehouse_ID = '') AS null_warehouse,
    SUM(Supplier_ID IS NULL OR Supplier_ID = '') AS null_supplier,
    SUM(Region IS NULL OR Region = '') AS null_region,
    SUM(Units_Sold IS NULL) AS null_units_sold,
    SUM(Inventory_Level IS NULL) AS null_inventory,
    SUM(Supplier_Lead_Time_Days IS NULL) AS null_lead_time,
    SUM(Reorder_Point IS NULL) AS null_reorder_point,
    SUM(Order_Quantity IS NULL) AS null_order_quantity,
    SUM(Unit_Cost IS NULL) AS null_unit_cost,
    SUM(Unit_Price IS NULL) AS null_unit_price,
    SUM(Promotion_Flag IS NULL) AS null_promotion_flag,
    SUM(Stockout_Flag IS NULL) AS null_stockout_flag,
    SUM(Demand_Forecast IS NULL) AS null_forecast
FROM supply_chain_data;

-- Duplicate business records
SELECT
    Date, SKU_ID, Warehouse_ID, Supplier_ID, Region,
    Units_Sold, Inventory_Level, Supplier_Lead_Time_Days,
    Reorder_Point, Order_Quantity, Unit_Cost, Unit_Price,
    Promotion_Flag, Stockout_Flag, Demand_Forecast,
    COUNT(*) AS duplicate_count
FROM supply_chain_data
GROUP BY
    Date, SKU_ID, Warehouse_ID, Supplier_ID, Region,
    Units_Sold, Inventory_Level, Supplier_Lead_Time_Days,
    Reorder_Point, Order_Quantity, Unit_Cost, Unit_Price,
    Promotion_Flag, Stockout_Flag, Demand_Forecast
HAVING COUNT(*) > 1
ORDER BY duplicate_count DESC;

-- Negative-value check
SELECT
    SUM(Units_Sold < 0) AS negative_units_sold,
    SUM(Inventory_Level < 0) AS negative_inventory,
    SUM(Supplier_Lead_Time_Days < 0) AS negative_lead_time,
    SUM(Reorder_Point < 0) AS negative_reorder_point,
    SUM(Order_Quantity < 0) AS negative_order_quantity,
    SUM(Unit_Cost < 0) AS negative_unit_cost,
    SUM(Unit_Price < 0) AS negative_unit_price,
    SUM(Demand_Forecast < 0) AS negative_forecast
FROM supply_chain_data;

-- Flag validation
SELECT Promotion_Flag, COUNT(*) AS records
FROM supply_chain_data
GROUP BY Promotion_Flag
ORDER BY Promotion_Flag;

SELECT Stockout_Flag, COUNT(*) AS records
FROM supply_chain_data
GROUP BY Stockout_Flag
ORDER BY Stockout_Flag;

-- ============================================================================
-- 6. ANALYTICS VIEW
-- Creates the calculated fields needed for business analysis.
-- ============================================================================

DROP VIEW IF EXISTS vw_supply_chain_analytics;

CREATE VIEW vw_supply_chain_analytics AS
SELECT
    s.*,

    -- Financial metrics
    (s.Units_Sold * s.Unit_Price) AS Revenue,
    (s.Units_Sold * s.Unit_Cost) AS Total_Cost,
    (s.Units_Sold * (s.Unit_Price - s.Unit_Cost)) AS Profit,

    CASE
        WHEN s.Unit_Price <> 0
        THEN ((s.Unit_Price - s.Unit_Cost) / s.Unit_Price) * 100
        ELSE 0
    END AS Profit_Margin_Percent,

    -- Inventory value
    (s.Inventory_Level * s.Unit_Cost) AS Inventory_Value,

    -- Forecast metrics
    (s.Units_Sold - s.Demand_Forecast) AS Forecast_Error,
    ABS(s.Units_Sold - s.Demand_Forecast) AS Absolute_Forecast_Error,

    CASE
        WHEN s.Units_Sold <> 0
        THEN ABS(s.Units_Sold - s.Demand_Forecast) / ABS(s.Units_Sold) * 100
        ELSE NULL
    END AS Absolute_Percentage_Error,

    -- Inventory status
    CASE
        WHEN s.Inventory_Level <= 0
            THEN 'Out of Stock'
        WHEN s.Inventory_Level <= s.Reorder_Point
            THEN 'Reorder Required'
        ELSE 'Healthy'
    END AS Inventory_Status,

    -- Estimated inventory coverage
    CASE
        WHEN s.Demand_Forecast > 0
            THEN s.Inventory_Level / s.Demand_Forecast
        ELSE NULL
    END AS Days_of_Inventory,

    -- Inventory risk based on lead time
    CASE
        WHEN s.Demand_Forecast <= 0
            THEN 'No Demand'
        WHEN (s.Inventory_Level / s.Demand_Forecast) < s.Supplier_Lead_Time_Days
            THEN 'High Risk'
        WHEN (s.Inventory_Level / s.Demand_Forecast)
             < (s.Supplier_Lead_Time_Days * 2)
            THEN 'Medium Risk'
        ELSE 'Low Risk'
    END AS Inventory_Risk,

    YEAR(s.Date) AS Year,
    MONTH(s.Date) AS Month_Number,
    MONTHNAME(s.Date) AS Month_Name,
    QUARTER(s.Date) AS Quarter_Number

FROM supply_chain_data s;

-- Test view
SELECT *
FROM vw_supply_chain_analytics
LIMIT 10;

-- ============================================================================
-- 7. EXECUTIVE KPI QUERIES
-- ============================================================================

-- KPI 1: Total Units Sold
SELECT
    SUM(Units_Sold) AS Total_Units_Sold
FROM vw_supply_chain_analytics;

-- KPI 2: Total Revenue
SELECT
    ROUND(SUM(Revenue), 2) AS Total_Revenue
FROM vw_supply_chain_analytics;

-- KPI 3: Total Cost
SELECT
    ROUND(SUM(Total_Cost), 2) AS Total_Cost
FROM vw_supply_chain_analytics;

-- KPI 4: Total Profit
SELECT
    ROUND(SUM(Profit), 2) AS Total_Profit
FROM vw_supply_chain_analytics;

-- KPI 5: Profit Margin
SELECT
    ROUND(
        SUM(Profit) / NULLIF(SUM(Revenue), 0) * 100,
        2
    ) AS Profit_Margin_Percent
FROM vw_supply_chain_analytics;

-- KPI 6: Inventory Value
SELECT
    ROUND(SUM(Inventory_Value), 2) AS Inventory_Value
FROM vw_supply_chain_analytics;

-- KPI 7: Stockout Rate
SELECT
    ROUND(AVG(Stockout_Flag) * 100, 2) AS Stockout_Rate_Percent
FROM vw_supply_chain_analytics;

-- KPI 8: High-risk records
SELECT
    COUNT(*) AS High_Risk_Records
FROM vw_supply_chain_analytics
WHERE Inventory_Risk = 'High Risk';

-- ============================================================================
-- 8. MONTHLY PERFORMANCE
-- ============================================================================

SELECT
    Year,
    Month_Number,
    Month_Name,
    CONCAT(Year, '-', LPAD(Month_Number, 2, '0')) AS Year_Month,
    SUM(Units_Sold) AS Units_Sold,
    ROUND(SUM(Revenue), 2) AS Revenue,
    ROUND(SUM(Total_Cost), 2) AS Total_Cost,
    ROUND(SUM(Profit), 2) AS Profit,
    ROUND(SUM(Inventory_Value), 2) AS Inventory_Value,
    SUM(Stockout_Flag) AS Stockout_Records
FROM vw_supply_chain_analytics
GROUP BY Year, Month_Number, Month_Name
ORDER BY Year, Month_Number;

-- ============================================================================
-- 9. REGION PERFORMANCE
-- ============================================================================

SELECT
    Region,
    SUM(Units_Sold) AS Units_Sold,
    ROUND(SUM(Revenue), 2) AS Revenue,
    ROUND(SUM(Total_Cost), 2) AS Total_Cost,
    ROUND(SUM(Profit), 2) AS Profit,
    ROUND(
        SUM(Profit) / NULLIF(SUM(Revenue), 0) * 100,
        2
    ) AS Profit_Margin_Percent,
    ROUND(SUM(Inventory_Value), 2) AS Inventory_Value,
    SUM(Stockout_Flag) AS Stockout_Records,
    ROUND(AVG(Stockout_Flag) * 100, 2) AS Stockout_Rate_Percent
FROM vw_supply_chain_analytics
GROUP BY Region
ORDER BY Revenue DESC;

-- ============================================================================
-- 10. WAREHOUSE PERFORMANCE
-- ============================================================================

SELECT
    Warehouse_ID,
    SUM(Units_Sold) AS Units_Sold,
    ROUND(SUM(Revenue), 2) AS Revenue,
    ROUND(SUM(Profit), 2) AS Profit,
    ROUND(AVG(Inventory_Level), 2) AS Avg_Inventory_Level,
    ROUND(SUM(Inventory_Value), 2) AS Inventory_Value,
    SUM(Stockout_Flag) AS Stockout_Records,
    ROUND(AVG(Stockout_Flag) * 100, 2) AS Stockout_Rate_Percent
FROM vw_supply_chain_analytics
GROUP BY Warehouse_ID
ORDER BY Revenue DESC;

-- Best warehouse
SELECT
    Warehouse_ID,
    ROUND(SUM(Revenue), 2) AS Revenue
FROM vw_supply_chain_analytics
GROUP BY Warehouse_ID
ORDER BY Revenue DESC
LIMIT 1;

-- Worst warehouse by stockout rate
SELECT
    Warehouse_ID,
    ROUND(AVG(Stockout_Flag) * 100, 2) AS Stockout_Rate_Percent
FROM vw_supply_chain_analytics
GROUP BY Warehouse_ID
ORDER BY Stockout_Rate_Percent DESC
LIMIT 1;

-- ============================================================================
-- 11. SUPPLIER PERFORMANCE
-- ============================================================================

SELECT
    Supplier_ID,
    ROUND(AVG(Supplier_Lead_Time_Days), 2) AS Avg_Lead_Time_Days,
    SUM(Order_Quantity) AS Total_Order_Quantity,
    SUM(Units_Sold) AS Units_Sold,
    SUM(Stockout_Flag) AS Stockout_Records,
    ROUND(AVG(Stockout_Flag) * 100, 2) AS Stockout_Rate_Percent,
    ROUND(SUM(Inventory_Value), 2) AS Inventory_Value
FROM vw_supply_chain_analytics
GROUP BY Supplier_ID
ORDER BY Avg_Lead_Time_Days DESC;

-- Suppliers with longest lead time
SELECT
    Supplier_ID,
    ROUND(AVG(Supplier_Lead_Time_Days), 2) AS Avg_Lead_Time_Days
FROM vw_supply_chain_analytics
GROUP BY Supplier_ID
ORDER BY Avg_Lead_Time_Days DESC
LIMIT 10;

-- ============================================================================
-- 12. SKU PERFORMANCE
-- ============================================================================

SELECT
    SKU_ID,
    SUM(Units_Sold) AS Units_Sold,
    ROUND(SUM(Revenue), 2) AS Revenue,
    ROUND(SUM(Total_Cost), 2) AS Total_Cost,
    ROUND(SUM(Profit), 2) AS Profit,
    ROUND(
        SUM(Profit) / NULLIF(SUM(Revenue), 0) * 100,
        2
    ) AS Profit_Margin_Percent,
    ROUND(AVG(Inventory_Level), 2) AS Avg_Inventory_Level,
    SUM(Stockout_Flag) AS Stockout_Records,
    ROUND(AVG(Stockout_Flag) * 100, 2) AS Stockout_Rate_Percent
FROM vw_supply_chain_analytics
GROUP BY SKU_ID
ORDER BY Revenue DESC;

-- Top 10 SKUs
SELECT
    SKU_ID,
    SUM(Units_Sold) AS Units_Sold,
    ROUND(SUM(Revenue), 2) AS Revenue,
    ROUND(SUM(Profit), 2) AS Profit
FROM vw_supply_chain_analytics
GROUP BY SKU_ID
ORDER BY Revenue DESC
LIMIT 10;

-- Bottom 10 SKUs by revenue
SELECT
    SKU_ID,
    SUM(Units_Sold) AS Units_Sold,
    ROUND(SUM(Revenue), 2) AS Revenue,
    ROUND(SUM(Profit), 2) AS Profit
FROM vw_supply_chain_analytics
GROUP BY SKU_ID
ORDER BY Revenue ASC
LIMIT 10;

-- ============================================================================
-- 13. INVENTORY STATUS
-- ============================================================================

SELECT
    Inventory_Status,
    COUNT(*) AS Records,
    ROUND(
        COUNT(*) / (SELECT COUNT(*) FROM vw_supply_chain_analytics) * 100,
        2
    ) AS Percentage
FROM vw_supply_chain_analytics
GROUP BY Inventory_Status
ORDER BY Records DESC;

-- Inventory status by warehouse
SELECT
    Warehouse_ID,
    Inventory_Status,
    COUNT(*) AS Records
FROM vw_supply_chain_analytics
GROUP BY Warehouse_ID, Inventory_Status
ORDER BY Warehouse_ID, Records DESC;

-- ============================================================================
-- 14. INVENTORY RISK
-- ============================================================================

SELECT
    Inventory_Risk,
    COUNT(*) AS Records,
    ROUND(AVG(Inventory_Level), 2) AS Avg_Inventory,
    ROUND(AVG(Days_of_Inventory), 2) AS Avg_Days_of_Inventory,
    ROUND(AVG(Supplier_Lead_Time_Days), 2) AS Avg_Lead_Time
FROM vw_supply_chain_analytics
GROUP BY Inventory_Risk
ORDER BY
    CASE Inventory_Risk
        WHEN 'High Risk' THEN 1
        WHEN 'Medium Risk' THEN 2
        WHEN 'Low Risk' THEN 3
        WHEN 'No Demand' THEN 4
        ELSE 5
    END;

-- Top high-risk SKU/Warehouse combinations
SELECT
    SKU_ID,
    Warehouse_ID,
    Region,
    ROUND(AVG(Inventory_Level), 2) AS Avg_Inventory,
    ROUND(AVG(Demand_Forecast), 2) AS Avg_Forecast_Demand,
    ROUND(AVG(Days_of_Inventory), 2) AS Avg_Days_of_Inventory,
    ROUND(AVG(Supplier_Lead_Time_Days), 2) AS Avg_Lead_Time,
    SUM(Stockout_Flag) AS Stockout_Records,
    SUM(Units_Sold) AS Units_Sold
FROM vw_supply_chain_analytics
WHERE Inventory_Risk = 'High Risk'
GROUP BY SKU_ID, Warehouse_ID, Region
ORDER BY Stockout_Records DESC, Units_Sold DESC
LIMIT 20;

-- ============================================================================
-- 15. REORDER ANALYSIS
-- ============================================================================

SELECT
    SKU_ID,
    Warehouse_ID,
    Inventory_Level,
    Reorder_Point,
    Order_Quantity,
    Supplier_Lead_Time_Days,
    Inventory_Status
FROM vw_supply_chain_analytics
WHERE Inventory_Status = 'Reorder Required'
ORDER BY
    (Reorder_Point - Inventory_Level) DESC;

-- ============================================================================
-- 16. STOCKOUT ANALYSIS
-- ============================================================================

-- Overall
SELECT
    SUM(Stockout_Flag) AS Stockout_Records,
    ROUND(AVG(Stockout_Flag) * 100, 2) AS Stockout_Rate_Percent
FROM vw_supply_chain_analytics;

-- Stockouts by region
SELECT
    Region,
    SUM(Stockout_Flag) AS Stockout_Records,
    ROUND(AVG(Stockout_Flag) * 100, 2) AS Stockout_Rate_Percent
FROM vw_supply_chain_analytics
GROUP BY Region
ORDER BY Stockout_Rate_Percent DESC;

-- Stockouts by SKU
SELECT
    SKU_ID,
    SUM(Stockout_Flag) AS Stockout_Records,
    SUM(Units_Sold) AS Units_Sold
FROM vw_supply_chain_analytics
GROUP BY SKU_ID
ORDER BY Stockout_Records DESC
LIMIT 20;

-- Stockouts by warehouse
SELECT
    Warehouse_ID,
    SUM(Stockout_Flag) AS Stockout_Records,
    ROUND(AVG(Stockout_Flag) * 100, 2) AS Stockout_Rate_Percent
FROM vw_supply_chain_analytics
GROUP BY Warehouse_ID
ORDER BY Stockout_Rate_Percent DESC;

-- ============================================================================
-- 17. PROMOTION ANALYSIS
-- ============================================================================

SELECT
    Promotion_Flag,
    COUNT(*) AS Records,
    ROUND(AVG(Units_Sold), 2) AS Avg_Units_Sold,
    SUM(Units_Sold) AS Total_Units_Sold,
    ROUND(SUM(Revenue), 2) AS Revenue,
    ROUND(SUM(Profit), 2) AS Profit,
    ROUND(
        SUM(Profit) / NULLIF(SUM(Revenue), 0) * 100,
        2
    ) AS Profit_Margin_Percent
FROM vw_supply_chain_analytics
GROUP BY Promotion_Flag
ORDER BY Promotion_Flag;

-- Promotion uplift in average units sold
SELECT
    ROUND(
        (
            AVG(CASE WHEN Promotion_Flag = 1 THEN Units_Sold END)
            -
            AVG(CASE WHEN Promotion_Flag = 0 THEN Units_Sold END)
        )
        /
        NULLIF(AVG(CASE WHEN Promotion_Flag = 0 THEN Units_Sold END), 0)
        * 100,
        2
    ) AS Promotion_Units_Sold_Uplift_Percent
FROM vw_supply_chain_analytics;

-- ============================================================================
-- 18. DEMAND FORECAST ACCURACY
-- ============================================================================

-- MAE
SELECT
    ROUND(AVG(Absolute_Forecast_Error), 2) AS MAE
FROM vw_supply_chain_analytics;

-- MAPE excluding zero actual demand
SELECT
    ROUND(
        AVG(
            CASE
                WHEN Units_Sold <> 0
                THEN Absolute_Forecast_Error / ABS(Units_Sold) * 100
                ELSE NULL
            END
        ),
        2
    ) AS MAPE_Percent
FROM vw_supply_chain_analytics;

-- Forecast accuracy = 100 - MAPE
SELECT
    ROUND(
        100 -
        AVG(
            CASE
                WHEN Units_Sold <> 0
                THEN Absolute_Forecast_Error / ABS(Units_Sold) * 100
                ELSE NULL
            END
        ),
        2
    ) AS Forecast_Accuracy_Percent
FROM vw_supply_chain_analytics;

-- Forecast accuracy by region
SELECT
    Region,
    ROUND(AVG(Absolute_Forecast_Error), 2) AS MAE,
    ROUND(
        AVG(
            CASE
                WHEN Units_Sold <> 0
                THEN Absolute_Forecast_Error / ABS(Units_Sold) * 100
                ELSE NULL
            END
        ),
        2
    ) AS MAPE_Percent
FROM vw_supply_chain_analytics
GROUP BY Region
ORDER BY MAPE_Percent;

-- ============================================================================
-- 19. ACTUAL VS FORECAST BY MONTH
-- ============================================================================

SELECT
    Year,
    Month_Number,
    Month_Name,
    SUM(Units_Sold) AS Actual_Units_Sold,
    ROUND(SUM(Demand_Forecast), 2) AS Forecast_Units,
    ROUND(
        SUM(Units_Sold) - SUM(Demand_Forecast),
        2
    ) AS Forecast_Error
FROM vw_supply_chain_analytics
GROUP BY Year, Month_Number, Month_Name
ORDER BY Year, Month_Number;

-- ============================================================================
-- 20. PRICE AND PROFITABILITY ANALYSIS
-- ============================================================================

SELECT
    Region,
    ROUND(AVG(Unit_Cost), 2) AS Avg_Unit_Cost,
    ROUND(AVG(Unit_Price), 2) AS Avg_Unit_Price,
    ROUND(AVG(Profit_Margin_Percent), 2) AS Avg_Profit_Margin
FROM vw_supply_chain_analytics
GROUP BY Region
ORDER BY Avg_Profit_Margin DESC;

-- Products with highest average margin
SELECT
    SKU_ID,
    ROUND(AVG(Unit_Cost), 2) AS Avg_Unit_Cost,
    ROUND(AVG(Unit_Price), 2) AS Avg_Unit_Price,
    ROUND(AVG(Profit_Margin_Percent), 2) AS Avg_Profit_Margin
FROM vw_supply_chain_analytics
GROUP BY SKU_ID
ORDER BY Avg_Profit_Margin DESC
LIMIT 20;

-- ============================================================================
-- 21. ABC-STYLE SKU CLASSIFICATION BY REVENUE
-- ============================================================================

WITH sku_revenue AS (
    SELECT
        SKU_ID,
        SUM(Revenue) AS Revenue
    FROM vw_supply_chain_analytics
    GROUP BY SKU_ID
),
ranked AS (
    SELECT
        SKU_ID,
        Revenue,
        SUM(Revenue) OVER () AS Total_Revenue,
        SUM(Revenue) OVER (
            ORDER BY Revenue DESC
            ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
        ) AS Cumulative_Revenue
    FROM sku_revenue
)
SELECT
    SKU_ID,
    ROUND(Revenue, 2) AS Revenue,
    ROUND(
        Revenue / NULLIF(Total_Revenue, 0) * 100,
        2
    ) AS Revenue_Percent,
    ROUND(
        Cumulative_Revenue / NULLIF(Total_Revenue, 0) * 100,
        2
    ) AS Cumulative_Revenue_Percent,
    CASE
        WHEN Cumulative_Revenue / NULLIF(Total_Revenue, 0) <= 0.80 THEN 'A'
        WHEN Cumulative_Revenue / NULLIF(Total_Revenue, 0) <= 0.95 THEN 'B'
        ELSE 'C'
    END AS ABC_Class
FROM ranked
ORDER BY Revenue DESC;

-- ============================================================================
-- 22. TOP REVENUE SKU PER REGION
-- ============================================================================

WITH region_sku AS (
    SELECT
        Region,
        SKU_ID,
        SUM(Revenue) AS Revenue,
        ROW_NUMBER() OVER (
            PARTITION BY Region
            ORDER BY SUM(Revenue) DESC
        ) AS rn
    FROM vw_supply_chain_analytics
    GROUP BY Region, SKU_ID
)
SELECT
    Region,
    SKU_ID,
    ROUND(Revenue, 2) AS Revenue
FROM region_sku
WHERE rn = 1
ORDER BY Region;

-- ============================================================================
-- 23. TOP REVENUE WAREHOUSE PER REGION
-- ============================================================================

WITH region_warehouse AS (
    SELECT
        Region,
        Warehouse_ID,
        SUM(Revenue) AS Revenue,
        ROW_NUMBER() OVER (
            PARTITION BY Region
            ORDER BY SUM(Revenue) DESC
        ) AS rn
    FROM vw_supply_chain_analytics
    GROUP BY Region, Warehouse_ID
)
SELECT
    Region,
    Warehouse_ID,
    ROUND(Revenue, 2) AS Revenue
FROM region_warehouse
WHERE rn = 1
ORDER BY Region;

-- ============================================================================
-- 24. FINAL POWER BI DATASET VIEW
-- Use this view when connecting Power BI to MySQL.
-- ============================================================================

DROP VIEW IF EXISTS vw_powerbi_supply_chain;

CREATE VIEW vw_powerbi_supply_chain AS
SELECT
    Date,
    SKU_ID,
    Warehouse_ID,
    Supplier_ID,
    Region,
    Units_Sold,
    Inventory_Level,
    Supplier_Lead_Time_Days,
    Reorder_Point,
    Order_Quantity,
    Unit_Cost,
    Unit_Price,
    Promotion_Flag,
    Stockout_Flag,
    Demand_Forecast,

    Revenue,
    Total_Cost,
    Profit,
    Profit_Margin_Percent,
    Inventory_Value,
    Forecast_Error,
    Absolute_Forecast_Error,
    Absolute_Percentage_Error,
    Inventory_Status,
    Days_of_Inventory,
    Inventory_Risk,

    Year,
    Month_Number,
    Month_Name,
    Quarter_Number

FROM vw_supply_chain_analytics;

-- Verify Power BI view
SELECT *
FROM vw_powerbi_supply_chain
LIMIT 10;

-- ============================================================================
-- 25. FINAL DASHBOARD KPI QUERY
-- ============================================================================

SELECT
    COUNT(*) AS Total_Records,
    COUNT(DISTINCT SKU_ID) AS Total_SKUs,
    COUNT(DISTINCT Warehouse_ID) AS Total_Warehouses,
    COUNT(DISTINCT Supplier_ID) AS Total_Suppliers,
    COUNT(DISTINCT Region) AS Total_Regions,
    SUM(Units_Sold) AS Total_Units_Sold,
    ROUND(SUM(Revenue), 2) AS Total_Revenue,
    ROUND(SUM(Total_Cost), 2) AS Total_Cost,
    ROUND(SUM(Profit), 2) AS Total_Profit,
    ROUND(
        SUM(Profit) / NULLIF(SUM(Revenue), 0) * 100,
        2
    ) AS Profit_Margin_Percent,
    ROUND(SUM(Inventory_Value), 2) AS Inventory_Value,
    ROUND(AVG(Stockout_Flag) * 100, 2) AS Stockout_Rate_Percent,
    ROUND(AVG(Absolute_Forecast_Error), 2) AS MAE
FROM vw_supply_chain_analytics;

-- ============================================================================
-- END OF PROJECT 4 SQL
-- ============================================================================
