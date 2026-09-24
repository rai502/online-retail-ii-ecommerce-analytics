# Online Retail II — E-commerce Business Analytics

## Project Overview

This project analyzes the Online Retail II dataset to investigate
real-world e-commerce business problems using SQL, Power Query,
PostgreSQL, and Power BI.

The project focuses on identifying business problems, investigating
their root causes, validating findings, and translating the analysis
into actionable business insights.

---

## Business Objectives

The analysis investigates six business cases:

1. Sales Decline Investigation
2. Underperforming Market — EIRE
3. Product Revenue Concentration
4. Cancellations & Negative-Quantity Transactions
5. Customer Purchasing Behavior
6. High-Value Customers & Products

---

## Tools & Technologies

- Power Query — Data cleaning and validation
- PostgreSQL — SQL-based business analysis
- DBeaver — Database management and SQL development
- Power BI — Dashboarding and business communication
- Excel — Data inspection and validation

---

## Project Workflow

Raw Online Retail II Data
        ↓
Power Query
        ↓
Data Cleaning & Validation
        ↓
PostgreSQL
        ↓
Business Problem Investigation
        ↓
Business Insights
        ↓
Power BI Dashboard

## Dataset

The project uses the **Online Retail II** dataset, which contains transactional
data from an online retail business.

Key fields used in the analysis include:

- Invoice
- Stock Code
- Description
- Quantity
- Invoice Date
- Price
- Customer ID
- Country

The dataset contains both customer transactions and operational records such
as cancellations and adjustments.

## Data Cleaning & Preparation

Data preparation was performed using Power Query before importing the cleaned
data into PostgreSQL.

### Cleaning Steps

- Converted columns to appropriate data types.
- Preserved `Invoice` as text because cancellation invoices contain the
  `C` prefix.
- Investigated missing Customer IDs rather than automatically removing them.
- Replaced missing product descriptions with `UNKNOWN`.
- Investigated negative quantities and kept them because they can represent
  cancellations or other operational adjustments.
- Identified zero-price transactions and retained them for auditability.
- Created an `IsCancellation` flag.
- Created an `IsZeroPrice` flag.
- Created an `IsNegativeQuantity` flag.
- Created a `Revenue` column using:
  
  `Revenue = Quantity × Price`

- Identified and removed exact duplicate rows based on the original
  transaction fields.
- Validated the resulting dataset before loading it into PostgreSQL.

### Data Quality Results

| Check | Result |
|---|---:|
| Original rows | 1,067,371 |
| Exact duplicate rows removed | 34,335 |
| Final cleaned rows | 1,033,036 |
| Missing Customer IDs | 243,007 |
| Zero-price rows | 6,014 |
| Cancellation rows | 19,104 |

The cleaned dataset was then imported into PostgreSQL for business analysis.

## Business Cases & Key Findings

### 1. Sales Decline Investigation

The analysis initially identified a significant revenue decline between
November and December 2011.

However, the dataset ends on **December 9, 2011**, making December an
incomplete reporting period with only **8 active reporting days**.

Therefore, the November-to-December change was not treated as a reliable
full-month sales decline.

**Key learning:** Before interpreting a period-over-period change, validate
whether the comparison periods contain complete and comparable data.

---

### 2. Underperforming Market — EIRE

EIRE was investigated as an underperforming market using a comparable
January-November period.

| Metric | Jan-Nov 2010 | Jan-Nov 2011 |
|---|---:|---:|
| Revenue | £355,527.05 | £265,766.37 |
| Orders | 318 | 261 |
| Active Customers | 5 | 3 |

Revenue declined by **25.25%**, while orders declined by **17.92%**.

Customer analysis showed:

- New customers: **3 → 0**
- Returning customers: **2 → 3**
- Active customers: **5 → 3**

The analysis therefore points toward lower customer acquisition and lower
order volume as important factors associated with the decline.

Product-level analysis also indicated that the decline was spread across
multiple products rather than being dominated by a single normal merchandise
product.

---

### 3. Product Revenue Concentration

The analysis examined whether the business depends heavily on a small number
of products.

The **top 10 products contributed approximately 8.07% of total valid
merchandise revenue**.

This indicates that revenue is distributed across a relatively broad product
base rather than being dominated by a small group of products.

Operational codes were excluded from the product analysis to avoid treating
records such as postage, manual adjustments, and bank charges as normal
merchandise.

---

### 4. Cancellations & Negative-Quantity Transactions

Cancellation and negative-quantity transactions were analyzed separately
because a negative quantity does not necessarily represent a customer return.

Between January-November 2010 and January-November 2011:

- Cancellation rate decreased from **1.94% to 1.74%**.
- Negative-quantity transaction rate decreased from **2.35% to 2.00%**.
- Average financial impact per cancellation increased from approximately
  **£64.54 to £75.15**.

The analysis also showed that cancellation behavior varies considerably by
product and market.

Some products have high cancellation frequencies, while other products have
relatively few cancellations but much larger financial impacts.

**Key learning:** Cancellation volume and financial impact should be analyzed
as separate dimensions.

---

### 5. Customer Purchasing Behavior

Customer analysis examined acquisition, returning customers, purchase
frequency, customer AOV, and revenue concentration.

New customers declined from **3,387 in 2010 to 1,508 in 2011**, while
returning customers increased from **844 to 2,665** for the comparable
January-November periods.

Customer AOV declined from **£1,979.32 to £1,869.06**.

The analysis also found significant revenue concentration among high-value
customers, with the **top 10 customers contributing approximately 16.04% of
total revenue**.

This highlights the importance of monitoring both customer acquisition and
high-value customer retention.

---

### 6. High-Value Customers & Products

The final analysis focused on the concentration of revenue among high-value
customers and products.

Key findings:

- Top 10 customers contributed approximately **16.04% of total revenue**.
- Top 10 products contributed approximately **8.07% of total valid
  merchandise revenue**.
- The top 10 products accounted for approximately **10.31% of the revenue
  generated by the top 10 customers**.

The results indicate meaningful customer-level revenue concentration while
showing that high-value customers are not dependent on only a small group of
top products.

## Power BI Dashboard

The Power BI dashboard was created to communicate the results of the
business investigations and provide an executive-level view of the
e-commerce business.

### Dashboard Pages

#### 1. Executive Overview

Provides a high-level view of:

- Total Orders
- Total Revenue
- Total Customers
- Average Order Value
- Monthly Revenue Trend
- Monthly Orders Trend
- Monthly Active Customers
- Revenue by Country

#### 2. Revenue & Market Performance

Focuses on market-level performance using:

- Revenue by Country
- Orders by Country
- Average Order Value by Country
- Country Performance Matrix

#### 3. EIRE Underperformance Analysis

Provides a detailed investigation of the EIRE market, including:

- 2010 vs 2011 Revenue
- 2010 vs 2011 Orders
- Average Order Value
- Active Customers
- New vs Returning Customers
- Business findings from the investigation

#### 4. EIRE Product Performance

Drills further into the EIRE decline through:

- Top products contributing to revenue decline
- Units sold comparison
- Product-level observations
- Volume and product performance analysis

### Dashboard Screenshots

Screenshots of the Power BI report are included in the
`Screenshots/` folder.

## Repository Structure

```text
online-retail-ii-ecommerce-analytics/
│
├── README.md
│
├── SQL/
│   └── Online_Retail_Business_Cases.sql
│
├── Power_Query/
│   └── cleaning_steps.m
│
├── Power_BI/
│   └── Online_Retail_II_Dashboard.pbix
│
├── Screenshots/
│   ├── executive_overview.png
│   ├── market_performance.png
│   ├── eire_analysis.png
│   └── product_performance.png
│
└── Documentation/
    ├── data_cleaning.md
    └── business_cases.md
