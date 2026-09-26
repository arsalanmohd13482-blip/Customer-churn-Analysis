# 📊 Customer Churn EDA & Retention Segmentation

**Full Analysis Report — Python + SQL**  
*15 SQL Queries (3 Levels) | 6 Python Charts | 7,043 Customers | $1.67M/year at risk*

---

## 🎯 Project Objective

**Primary Objective:** To identify why customers leave a telecom company, which customer segments are at highest risk, and how much revenue is at stake — then translate those findings into specific, prioritised business actions the retention team can execute immediately.

* **🐍 Python Objective:** Clean and explore 7,043 customer records using Pandas. Build 6 visualisations (Seaborn + Matplotlib) that surface churn patterns by contract, tenure, charges, internet service, and payment method. Produce a correlation chart ranking the strongest churn drivers.
* **🗄️ SQL Objective:** Answer 15 business questions across 3 difficulty levels in PostgreSQL — from basic aggregations and CTEs (Level 1) through conditional segmentation and `CASE WHEN` (Level 2) to advanced window functions including `PERCENTILE_CONT`, rolling cumulative sums, and `PARTITION BY` peer comparison (Level 3).

**Dataset Overview:** 
* **Source:** IBM Telco Customer Churn
* **Size:** 7,043 rows, 21 columns
* **Data Quality Fixes:** `TotalCharges` stored as VARCHAR with empty strings for 11 new customers (tenure=0). Converted using `pd.to_numeric(errors='coerce')`, filled NaN with `0`.

---

## 🐍 Python EDA: Key Insights

* **Baseline Churn:** 26.54% (representing 1,869 customers and significant MRR).
* **Contract Loyalty (The Biggest Driver):** Month-to-month customers churn at 42.7%, while two-year contract customers churn at just 2.8%. Month-to-month users are 15× more likely to leave.
* **The "Danger Zone":** Churned customers average 17.9 months of tenure vs. 37.6 months for retained customers. The 0-12 month window sees a ~50% churn rate.
* **Product Vulnerability:** Fiber Optic customers pay the most but churn the most (41.9% vs DSL at 19.0%). 
* **Add-On Effectiveness:** Fiber customers *with* Tech Support churn at ~15%, while those *without* it churn at ~41% (a massive 26-point difference).
* **Correlation Highlights:** The top positive churn drivers are Month-to-month contracts, Fiber optic, No TechSupport, and Electronic check payments. The top retention drivers are Two-year contracts and longer tenure.

---

## 🗄️ SQL Analysis Highlights (15 Queries)

The analysis was broken down into three tiers of SQL complexity:

### Level 1: Core Metrics (Aggregations, CTEs, Filters)
* **Demographic Risk (`CTE + Window`):** Senior citizens without partners exhibit the highest churn rate across demographics.
* **Payment Methods (`CTE`):** Electronic check is the highest-churn payment method (~45%), whereas auto-pay methods (bank/credit) drop to ~15%.

### Level 2: Segmentation & Risk (CASE WHEN, Subqueries)
* **High-Risk Segment (`CASE WHEN`):** Fiber + Month-to-month customers have a ~52% churn rate vs DSL + One year at ~9% (a 43-point gap).
* **Add-on Power (`UNION ALL`):** Online Security (~15%) and Tech Support (~15%) drastically outperform the 26.5% baseline churn rate.
* **Financial Impact:** Identified ~$2.86M in total historical charges lost to churned customers.

### Level 3: Advanced Analytics (Window Functions, Rolling)
* **"Flight Risk" Flagging (`PERCENTILE_CONT` & `CROSS JOIN`):** Computed the 75th percentile of monthly charges and cross-joined to filter active month-to-month customers above that threshold, generating an exact call-list for the retention team.
* **Peer Pricing Comparison (`AVG OVER PARTITION BY`):** Calculated average charges for exact service matches to flag customers paying a "Premium" over their peers, making them high flight risks.
* **Rolling Cohort (`SUM OVER` rolling):** Proved the sharpest drop-offs occur exactly in months 1, 2, and 3.

---

## 💡 3 Strategic Business Decisions

1. **Contract Conversion (10% Discount Offer):**
   Month-to-month customers churn at 15× the rate of two-year customers. The business should offer a 10% bill discount to convert M2M customers to annual contracts within their first 90 days.
2. **Tech Support Auto-Trial:**
   Fiber customers with TechSupport churn at 15% vs 41% without it. Auto-include a 3-month TechSupport trial for all new Fiber customers. The cost of the trial is negligible compared to retaining a ~$74/month average churner.
3. **Auto-Pay Incentive:**
   Electronic check payers churn at 45%. Offer a $5/month bill credit to switch to auto-pay (bank/credit card), which psychologically locks customers in during their most vulnerable early months.

**Combined Impact:** Reducing overall churn from 26.5% to 20% would recover approximately **$408,000/year** in previously lost recurring revenue.
