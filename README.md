# 📦 Supply Chain & Inventory Analytics

> End-to-end Supply Chain & Inventory Analytics project using **Python, MySQL, SQL, and Power BI**.

![Python](https://img.shields.io/badge/Python-3.x-blue?logo=python)
![MySQL](https://img.shields.io/badge/MySQL-8.0-orange?logo=mysql)
![Power%20BI](https://img.shields.io/badge/Power%20BI-Dashboard-yellow?logo=powerbi)
![Jupyter](https://img.shields.io/badge/Jupyter-Notebook-orange?logo=jupyter)
![Status](https://img.shields.io/badge/Status-Completed-success)

---

## 🎯 Project Overview

This project transforms raw supply-chain data into an interactive business intelligence solution.

### Business questions answered

- Which SKUs generate the most revenue and profit?
- Which warehouses have the highest stockout rates?
- Which suppliers have long lead times?
- Which inventory is at high risk?
- How much inventory value is being held?
- Do promotions increase sales?
- How accurate is demand forecasting?
- Which products require inventory attention?

### End-to-end workflow

```text
Raw CSV
   ↓
Python Data Cleaning & EDA
   ↓
MySQL Database & SQL Analysis
   ↓
Power BI Data Model & DAX
   ↓
4-Page Interactive Dashboard
   ↓
Business Insights
```

---

## 📊 Dataset

**File:** `supply_chain_dataset1.csv`

**Size:** 91,250 records × 15 original columns

| Category | Fields |
|---|---|
| Date | `Date` |
| Product | `SKU_ID` |
| Location | `Warehouse_ID`, `Region` |
| Supplier | `Supplier_ID`, `Supplier_Lead_Time_Days` |
| Sales | `Units_Sold`, `Unit_Price` |
| Inventory | `Inventory_Level`, `Reorder_Point`, `Order_Quantity` |
| Cost | `Unit_Cost` |
| Promotion | `Promotion_Flag` |
| Stockout | `Stockout_Flag` |
| Forecast | `Demand_Forecast` |

---

# 🛠️ Tools & Technologies

| Tool | Purpose |
|---|---|
| 🐍 Python | Cleaning, EDA, feature engineering and insights |
| 📓 Jupyter Notebook | Reproducible analysis |
| 🗄️ MySQL 8.0+ | Database and SQL analytics |
| 📊 Power BI | Data model, DAX and dashboard |
| 📈 DAX | Business KPI calculations |

---

# 📁 Recommended Repository Structure

```text
supply-chain-inventory-analytics/
│
├── Dataset/
│   └── supply_chain_dataset1.csv
│
├── Python/
│   └── Project_4_Supply_Chain_Analytics.ipynb
│
├── SQL/
│   └── Project_4_Supply_Chain_Analytics.sql
│
├── PowerBI/
│   ├── Project_4_Supply_Chain_Analytics.pbix
│   ├── Dashboard_Executive.png
│   ├── Dashboard_Inventory.png
│   ├── Dashboard_Supplier.png
│   └── Dashboard_Forecast.png
│
├── Output/
│   ├── cleaned_data.csv
│   ├── inventory_analysis.csv
│   ├── supplier_analysis.csv
│   ├── warehouse_analysis.csv
│   └── forecast_analysis.csv
│
├── README.md
└── .gitignore
```

> **Tip:** Avoid committing very large raw files or PBIX files if they exceed your GitHub repository limits. Keep screenshots and documentation in GitHub, and provide the data/report separately when necessary.

---

# 🐍 Python Analysis

The notebook performs:

1. Dataset loading
2. Shape and structure validation
3. Missing-value analysis
4. Duplicate checks
5. Data-type checks
6. Date analysis
7. Revenue calculation
8. Cost calculation
9. Profit calculation
10. Profit-margin analysis
11. Inventory-value analysis
12. Inventory status classification
13. Inventory-risk analysis
14. Stockout analysis
15. Supplier analysis
16. Warehouse analysis
17. Regional analysis
18. Promotion analysis
19. Demand forecast analysis
20. Business insights
21. Export of analysis outputs

### Important calculated fields

```text
Revenue
Total_Cost
Profit
Profit_Margin_Percent
Inventory_Value
Forecast_Error
Absolute_Forecast_Error
Inventory_Status
Days_of_Inventory
Inventory_Risk
```

---

# 🗄️ SQL Analysis

The SQL script creates:

```text
supply_chain_analytics
        ↓
supply_chain_data
        ↓
vw_supply_chain_analytics
        ↓
vw_powerbi_supply_chain
```

### SQL topics covered

- Database creation
- Table creation
- CSV import
- Data-quality validation
- NULL checks
- Duplicate checks
- Negative-value checks
- Executive KPIs
- Monthly performance
- Region performance
- Warehouse performance
- Supplier performance
- SKU performance
- Inventory status
- Inventory risk
- Reorder analysis
- Stockout analysis
- Promotion analysis
- Forecast accuracy
- MAE / MAPE
- ABC-style SKU classification
- Window functions
- Ranking
- Power BI-ready SQL view

---

# 📈 Power BI Dashboard

The report is organized into **4 professional pages**.

## 1️⃣ Executive Overview

### KPI Cards

- Total Revenue
- Total Profit
- Total Units Sold
- Inventory Value
- Stockout Rate
- Profit Margin

### Visuals

- Monthly Revenue Trend
- Revenue by Region
- Top 10 SKUs by Revenue
- Stockouts by Warehouse

### Slicers

- Date
- Region
- Warehouse
- Supplier

---

## 2️⃣ Inventory & Stockout Analysis

### KPIs

- Inventory Value
- Stockout Count
- Stockout Rate
- High-Risk Records

### Visuals

- Inventory Status
- Inventory Risk Distribution
- Stockouts by Region
- Inventory Value by Warehouse
- High-Risk Inventory Table

---

## 3️⃣ Supplier & Warehouse Performance

### Visuals

- Supplier Performance
- Average Supplier Lead Time
- Warehouse Revenue
- Warehouse Profit
- Warehouse Stockout Rate

This page helps identify operational bottlenecks and underperforming supply-chain areas.

---

## 4️⃣ Demand & Forecast Analysis

### KPIs

- Total Units Sold
- Forecast MAE
- Total Revenue
- Stockout Rate

### Visuals

- Actual Demand vs Forecast
- Forecast Error by Region
- Promotion Impact on Sales
- Top SKUs by Forecast Error

---

# 🧮 Core DAX Measures

```DAX
Total Revenue =
SUM('project4_supply_chain_cleaned'[Revenue])
```

```DAX
Total Profit =
SUM('project4_supply_chain_cleaned'[Profit])
```

```DAX
Total Units Sold =
SUM('project4_supply_chain_cleaned'[Units_Sold])
```

```DAX
Inventory Value =
SUM('project4_supply_chain_cleaned'[Inventory_Value])
```

```DAX
Profit Margin =
DIVIDE(
    [Total Profit],
    [Total Revenue],
    0
)
```

```DAX
Stockout Count =
SUM('project4_supply_chain_cleaned'[Stockout_Flag])
```

```DAX
Stockout Rate =
DIVIDE(
    [Stockout Count],
    COUNTROWS('project4_supply_chain_cleaned'),
    0
)
```

```DAX
Forecast MAE =
AVERAGE(
    'project4_supply_chain_cleaned'[Absolute_Forecast_Error]
)
```

---

# 🚀 How to Run

## 1. Python

Open:

```text
Python/Project_4_Supply_Chain_Analytics.ipynb
```

Run all cells and review the generated analysis/output files.

## 2. SQL

Open:

```text
SQL/Project_4_Supply_Chain_Analytics.sql
```

Create the database, create/import the table, then run the analysis.

The Power BI-ready view is:

```text
vw_powerbi_supply_chain
```

## 3. Power BI

Connect Power BI to the SQL database:

```text
Get Data
    ↓
MySQL database
    ↓
supply_chain_analytics
    ↓
vw_powerbi_supply_chain
```

Then create:

- Date table
- Date relationship
- DAX measures
- 4 dashboard pages

---

# 💡 Business Value

This solution can help supply-chain teams:

- Identify high-risk inventory
- Reduce stockout problems
- Improve reorder planning
- Monitor supplier lead times
- Compare warehouse performance
- Identify high-value SKUs
- Evaluate promotion performance
- Improve demand forecasting
- Reduce unnecessary inventory holding

---

# 📌 GitHub Repository Setup

### Recommended repository name

```text
supply-chain-inventory-analytics
```

### Recommended description

```text
End-to-end Supply Chain & Inventory Analytics using Python, MySQL, SQL and Power BI.
```

### Recommended topics

```text
data-analytics
python
sql
mysql
power-bi
supply-chain
inventory-analytics
business-intelligence
data-visualization
jupyter-notebook
```

---

# 🖼️ Dashboard Screenshots

After completing the Power BI report, add screenshots here:

```markdown
## 📊 Dashboard Preview

### Executive Overview
![Executive Dashboard](PowerBI/Dashboard_Executive.png)

### Inventory & Stockout
![Inventory Dashboard](PowerBI/Dashboard_Inventory.png)

### Supplier & Warehouse
![Supplier Dashboard](PowerBI/Dashboard_Supplier.png)

### Demand & Forecast
![Forecast Dashboard](PowerBI/Dashboard_Forecast.png)
```

Screenshots make the repository much easier for recruiters and clients to understand.

---

# 🎓 Skills Demonstrated

```text
Python
SQL
MySQL
Power BI
DAX
Data Cleaning
Exploratory Data Analysis
Data Modeling
Business Intelligence
Inventory Analytics
Supply Chain Analytics
Forecast Analysis
KPI Development
Dashboard Design
Business Insights
```

---

# ⭐ Project Status

**Status:** ✅ Completed

**Project:** Supply Chain & Inventory Analytics

**Dataset:** 91,250 records

**Original Features:** 15

**Dashboard Pages:** 4

**Pipeline:**

```text
CSV → Python → SQL → Power BI → Business Insights
```

---

## ⭐ If you find this project useful

Give the repository a ⭐ and feel free to use it as a learning reference.
