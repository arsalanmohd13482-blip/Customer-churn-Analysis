-- Create the Data Base.
Create Database Customer_Churn;


-- Create the table Structure.
CREATE TABLE customer_churn (
    customerID VARCHAR(50) PRIMARY KEY,
    gender VARCHAR(20),
    SeniorCitizen INTEGER,
    Partner VARCHAR(20),
    Dependents VARCHAR(20),
    tenure INTEGER,
    PhoneService VARCHAR(20),
    MultipleLines VARCHAR(50),
    InternetService VARCHAR(50),
    OnlineSecurity VARCHAR(50),
    OnlineBackup VARCHAR(50),
    DeviceProtection VARCHAR(50),
    TechSupport VARCHAR(50),
    StreamingTV VARCHAR(50),       
    StreamingMovies VARCHAR(50),   
    Contract VARCHAR(50),
    PaperlessBilling VARCHAR(20),  
    PaymentMethod VARCHAR(100),    
    MonthlyCharges NUMERIC(10, 2), 
    TotalCharges NUMERIC(10, 2),  
    Churn VARCHAR(20),
	Churn_num INT,
	Tenure_Band VARCHAR(20)
	);

-- Lets Have a look Of our Table Before Import the Data.
SELECT
	*
FROM customer_churn ;

-- After Import See the data.
SELECT
* 
FROM customer_churn;

-- How many total Customer We have.
SELECT
	COUNT(DISTINCT CustomerID) AS Total_Customer
FROM
	customer_churn;

-- What is Total Revenue Of Company.
SELECT
	SUM(TotalCharges) AS Total_Revenue
FROM
	customer_churn;

-- Level 1: Core Business Metrics (Aggregations, Grouping, Filtering)

-- 1.Overall Churn Rate: What is the total count of customers, and what is the exact percentage of customers who have churned?
WITH Churn_Customers AS (
	SELECT
		COUNT(DISTINCT CustomerID) AS Total_Customer,
		COUNT(CASE
			WHEN Churn_num = 1 THEN 1
			END) AS Churn_Customer
		FROM
			customer_churn
)
SELECT
	Total_Customer,
	ROUND(
		(Churn_Customer * 100.00)/Total_customer:: Numeric ,1) AS Churn_Rate
FROM
	Churn_Customers;

-- 3.Current Monthly Recurring Revenue (MRR): What is the total Monthly Recurring Revenue generated strictly from active, retained customers?	
SELECT
    SUM(Monthlycharges)   AS current_mrr
FROM customer_churn
WHERE Churn_num = 0;


-- 3.Demographic Footprint: What is the demographic breakdown of the customer base by Gender, Senior Citizen status, and Partner status?
WITH Churn_materic AS(
	SELECT
		CustomerID,
		COUNT(*) AS Total_Customer,
		COUNT(CASE WHEN Churn_num = 1 THEN 1 END) AS Churn_Customer
	FROM
		customer_churn
	GROUP BY
		CustomerID
)
SELECT
	cc.Gender,
	cc.Partner,
	cc.SeniorCitizen,
	ROUND(COUNT(*) * 100.0 / SUM(COUNT(*)) OVER ()::Numeric, 2) AS pct,
	ROUND(SUM(cm.Churn_Customer) * 100.0 / COUNT(*)::Numeric, 2)   AS churn_rate
FROM
	customer_churn AS cc
JOIN Churn_materic AS cm
ON cm.CustomerID = cc.CustomerID
GROUP BY
	cc.Gender,
	cc.Partner,
	cc.SeniorCitizen
ORDER BY 
	churn_rate DESC;

-- 4.Service Overlap: How many customers are currently subscribed to both Phone Service (including multiple lines) and high-speed Internet (Fiber Optic)?
SELECT
	COUNT(*) AS total_customer
FROM	
customer_churn
WHERE PhoneService = 'Yes'
AND InternetService = 'Fiber optic';	

	
-- 5.Payment Friction: Which specific payment method has the highest volume of churned customers,
-- and how does that compare to the preferred payment method of retained customers?	
WITH Churn_cutomers AS (
	SELECT
		PaymentMethod,
		COUNT(*) AS Total_Customers,
		COUNT(CASE WHEN Churn_num = 1 THEN 1 END) AS Churn_Customer
	FROM 
		customer_churn
	GROUP BY	
		PaymentMethod
)
SELECT
	PaymentMethod,
	ROUND(
		(Churn_Customer *100.00)/ Total_Customers::Numeric, 1
	) AS Churn_rate
FROM
	Churn_cutomers;
	
-- =====================================================================================
-- Level 2: Customer Segmentation & Risk (CASE WHEN, Subqueries, Joins)
-- =====================================================================================
-- 6. Contract Value Analysis: What is the average customer tenure and average monthly charge, grouped by the three different contract types?

SELECT
	Contract,
	ROUND(AVG(Tenure) ::NUMERIC ,2) AS Average_tenure,
	ROUND(AVG(MonthlyCharges):: NUMERIC, 2) AS Avg_Monthly_charges
FROM	
	customer_churn
GROUP BY
	Contract;

-- 7. High-Risk Segment Identification: What is the specific churn rate for customers on Month-to-Month contracts using Fiber Optic,
-- internet versus those on One-Year contracts using DSL?
SELECT 
    Contract,
    InternetService,
    COUNT(customerID) AS Total_Customers,
    SUM(CASE WHEN Churn = 'Yes' THEN 1 ELSE 0 END) AS Churned_Customers,
    ROUND(
        SUM(CASE WHEN Churn = 'Yes' THEN 1 ELSE 0 END) * 100.0 / COUNT(customerID), 
        2
    ) AS Churn_Rate_Percentage
FROM customer_churn
WHERE (Contract = 'Month-to-month' AND InternetService = 'Fiber optic')
   OR (Contract = 'One year' AND InternetService = 'DSL')
GROUP BY 
    Contract, 
    InternetService;

-- 8. Tenure Cohort Creation: Using a CASE WHEN statement, bucket customers into three tenure segments ('New: 0-12m', 'Established: 13-36m', 'Loyal: 37m+'),
-- and calculate the total historical revenue (TotalCharges) generated by each cohort.
SELECT
	Tenure_band,
	SUM(TotalCharges) AS Total_Revenue
FROM	
	customer_churn
WHERE 	
	Tenure_band IS NOT NULL
GROUP BY	
	Tenure_band
ORDER BY
	SUM(TotalCharges)  DESC;

-- 9. Financial Impact of Churn: What is the total monetary value (sum of Total Charges) that has walked out the door due to customer churn?
SELECT
	Churn,
	SUM(TotalCharges) AS Total_Revenue
FROM
	customer_churn
GROUP BY
	churn
ORDER BY
	SUM(TotalCharges) DESC;

-- 10. Service Retention Power: Which singular digital add-on (Online Security, Tech Support, or Online Backup)
-- correlates with the lowest churn rate among Internet subscribers?
SELECT 
    'Online Security' AS Digital_Add_On,
    COUNT(customerID) AS Total_Subscribers,
    SUM(CASE WHEN Churn = 'Yes' THEN 1 ELSE 0 END) AS Churned_Subscribers,
    ROUND(SUM(CASE WHEN Churn = 'Yes' THEN 1 ELSE 0 END) * 100.0 / COUNT(customerID), 2) AS Churn_Rate_Percentage
FROM customer_churn
WHERE OnlineSecurity = 'Yes'

UNION ALL

SELECT 
    'Tech Support' AS Digital_Add_On,
    COUNT(customerID) AS Total_Subscribers,
    SUM(CASE WHEN Churn = 'Yes' THEN 1 ELSE 0 END) AS Churned_Subscribers,
    ROUND(SUM(CASE WHEN Churn = 'Yes' THEN 1 ELSE 0 END) * 100.0 / COUNT(customerID), 2) AS Churn_Rate_Percentage
FROM customer_churn
WHERE TechSupport = 'Yes'

UNION ALL

SELECT 
    'Online Backup' AS Digital_Add_On,
    COUNT(customerID) AS Total_Subscribers,
    SUM(CASE WHEN Churn = 'Yes' THEN 1 ELSE 0 END) AS Churned_Subscribers,
    ROUND(SUM(CASE WHEN Churn = 'Yes' THEN 1 ELSE 0 END) * 100.0 / COUNT(customerID), 2) AS Churn_Rate_Percentage
FROM customer_churn
WHERE OnlineBackup = 'Yes'

ORDER BY Churn_Rate_Percentage ASC;

-- ===============================================================================
-- Level 3: Advanced Analytics (CTEs, Window Functions, Rolling Metrics)
-- ===============================================================================

-- 11. Revenue Ranking & Running Totals: Rank the 4 payment methods by total lifetime revenue generated,
-- and use a Window Function to calculate the cumulative running percentage of total company revenue.

WITH PaymentRevenue AS (
    SELECT 
        PaymentMethod,
        SUM(TotalCharges) AS Lifetime_Revenue
    FROM customer_churn
    GROUP BY PaymentMethod
)
SELECT 
    RANK() OVER (ORDER BY Lifetime_Revenue DESC) AS Revenue_Rank,
    PaymentMethod,
    ROUND(Lifetime_Revenue, 2) AS Lifetime_Revenue,
    ROUND(SUM(Lifetime_Revenue) OVER (ORDER BY Lifetime_Revenue DESC), 2) AS Running_Total_Revenue,
    ROUND(
        (SUM(Lifetime_Revenue) OVER (ORDER BY Lifetime_Revenue DESC) / SUM(Lifetime_Revenue) OVER()) * 100, 
        2
    ) AS Cumulative_Percentage
FROM PaymentRevenue
ORDER BY Revenue_Rank;

-- 12. Predictive "Flight Risk" Flagging: Write a CTE to identify "High Value Risk" customers: defined as currently active customers,
-- who pay above the 75th percentile in Monthly Charges but are not locked into an annual contract.

WITH Threshold AS (
	SELECT
		PERCENTILE_CONT(0.75) WITHIN GROUP (ORDER BY MonthlyCharges) AS pct_75
	FROM
		customer_churn
),highvaluerisk AS(
	SELECT
		CustomerID, 
        MonthlyCharges, 
        Contract
    FROM customer_churn
    CROSS JOIN Threshold
    WHERE Churn = 'No' 
      AND Contract = 'Month-to-month'
      AND MonthlyCharges > pct_75
)
SELECT
    COUNT(CustomerID) AS High_Risk_Customer_Count,
    ROUND(AVG(MonthlyCharges), 2) AS Average_Monthly_Charge,
    ROUND(SUM(MonthlyCharges), 2) AS Total_MRR_At_Risk
FROM HighValueRisk;


-- 13. Customer Lifetime Value (LTV): Calculate the Average Lifetime Value (LTV) per customer, grouped by Internet Service type,
-- strictly for customers who survived past the crucial 6-month tenure mark.
SELECT 
    InternetService,
    COUNT(customerID) AS Retained_Customer_Count,
    ROUND(AVG(TotalCharges), 2) AS Average_Lifetime_Value
FROM customer_churn
WHERE tenure > 6
GROUP BY InternetService
ORDER BY Average_Lifetime_Value DESC;

-- 14. Peer Pricing Comparison: Use a Window Function (AVG() OVER (PARTITION BY...)) to find the difference in Monthly Charges between an individual customer and,
-- the average Monthly Charge of all other customers with the exact same core service footprint (Same Internet + Same Phone setup).
SELECT 
    customerID,
    InternetService,
    PhoneService,
    MonthlyCharges AS Individual_Charge,
    ROUND(AVG(MonthlyCharges) OVER (PARTITION BY InternetService, PhoneService), 2) AS Peer_Group_Average,
    ROUND(MonthlyCharges - AVG(MonthlyCharges) OVER (PARTITION BY InternetService, PhoneService), 2) AS Premium_or_Discount
FROM customer_churn
ORDER BY Premium_or_Discount DESC;


-- 15. Rolling Churn Cohort: Group churned customers by the exact tenure month they canceled their service,
-- and calculate the rolling cumulative sum of churners over the first 12 months to see exactly when the highest volume of drop-offs occur.
WITH YearOneChurn AS (
    SELECT 
        tenure AS Cancellation_Month,
        COUNT(customerID) AS Churned_Customers
    FROM customer_churn
    WHERE Churn = 'Yes' 
      AND tenure <= 12
      AND tenure > 0 -- Excludes brand new sign-ups who haven't completed a month
    GROUP BY tenure
)
SELECT 
    Cancellation_Month,
    Churned_Customers,
    SUM(Churned_Customers) OVER (ORDER BY Cancellation_Month) AS Cumulative_Churners
FROM YearOneChurn
ORDER BY Cancellation_Month;
