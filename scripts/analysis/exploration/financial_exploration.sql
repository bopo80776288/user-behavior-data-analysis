-- =====================================
-- Financial Analysis Exploration Queries
-- File: financial_exploration.sql
-- Purpose: exploratory analysis on financial metrics and revenue segments
-- Note: Provides raw metrics for Power BI calculations
-- =====================================

-- 1) Revenue segments by MonthlyCharges (raw counts and amounts)
SELECT
    CASE
        WHEN telco_customers.MonthlyCharges < 40 THEN 'Low Revenue'
        WHEN telco_customers.MonthlyCharges BETWEEN 40 AND 80 THEN 'Mid Revenue'
        ELSE 'High Revenue'
    END AS RevenueSegment,
    COUNT(*) AS TotalCustomers,
    SUM(CASE WHEN customer_dim.Churn = 0 THEN 1 ELSE 0 END) AS ActiveCustomers,
    SUM(CASE WHEN customer_dim.Churn = 1 THEN 1 ELSE 0 END) AS ChurnedCustomers,
    SUM(telco_customers.MonthlyCharges) AS TotalRevenue,
    SUM(CASE WHEN customer_dim.Churn = 0 THEN telco_customers.MonthlyCharges ELSE 0 END) AS ActiveRevenue
FROM customer_dim
JOIN telco_customers ON telco_customers.customer_id = customer_dim.customer_id
GROUP BY 
    CASE
        WHEN telco_customers.MonthlyCharges < 40 THEN 'Low Revenue'
        WHEN telco_customers.MonthlyCharges BETWEEN 40 AND 80 THEN 'Mid Revenue'
        ELSE 'High Revenue'
    END
ORDER BY TotalRevenue DESC;

-- 2) Financial metrics by Contract type (raw metrics)
SELECT
    customer_dim.Contract,
    COUNT(*) AS TotalCustomers,
    SUM(CASE WHEN customer_dim.Churn = 0 THEN 1 ELSE 0 END) AS ActiveCustomers,
    SUM(CASE WHEN customer_dim.Churn = 1 THEN 1 ELSE 0 END) AS ChurnedCustomers,
    SUM(telco_customers.MonthlyCharges) AS TotalRevenue,
    SUM(CASE WHEN customer_dim.Churn = 0 THEN telco_customers.MonthlyCharges ELSE 0 END) AS ActiveRevenue,
    AVG(telco_customers.MonthlyCharges) AS AvgMonthlyCharges
FROM customer_dim
JOIN telco_customers ON telco_customers.customer_id = customer_dim.customer_id
GROUP BY customer_dim.Contract
ORDER BY TotalRevenue DESC;

-- 3) Financial metrics by Payment Method (raw metrics)
SELECT
    customer_dim.PaymentMethod,
    COUNT(*) AS TotalCustomers,
    SUM(CASE WHEN customer_dim.Churn = 0 THEN 1 ELSE 0 END) AS ActiveCustomers,
    SUM(CASE WHEN customer_dim.Churn = 1 THEN 1 ELSE 0 END) AS ChurnedCustomers,
    SUM(telco_customers.MonthlyCharges) AS TotalRevenue,
    SUM(CASE WHEN customer_dim.Churn = 0 THEN telco_customers.MonthlyCharges ELSE 0 END) AS ActiveRevenue,
    AVG(telco_customers.MonthlyCharges) AS AvgMonthlyCharges
FROM customer_dim
JOIN telco_customers ON telco_customers.customer_id = customer_dim.customer_id
GROUP BY customer_dim.PaymentMethod
ORDER BY TotalRevenue DESC;

-- 4) Revenue by Contract and Churn status (raw metrics)
SELECT
    customer_dim.Contract,
    customer_dim.Churn,
    COUNT(*) AS CustomerCount,
    SUM(telco_customers.MonthlyCharges) AS TotalRevenue,
    AVG(telco_customers.MonthlyCharges) AS AvgMonthlyCharges
FROM customer_dim
JOIN telco_customers ON telco_customers.customer_id = customer_dim.customer_id
GROUP BY customer_dim.Contract, customer_dim.Churn
ORDER BY customer_dim.Contract, customer_dim.Churn;

-- 5) Revenue by Tenure Bucket and Churn (raw metrics)
SELECT
    customer_dim.tenure_bucket,
    customer_dim.Churn,
    COUNT(*) AS CustomerCount,
    SUM(telco_customers.MonthlyCharges) AS TotalRevenue,
    AVG(telco_customers.MonthlyCharges) AS AvgMonthlyCharges
FROM customer_dim
JOIN telco_customers ON telco_customers.customer_id = customer_dim.customer_id
GROUP BY customer_dim.tenure_bucket, customer_dim.Churn
ORDER BY 
    CASE customer_dim.tenure_bucket
        WHEN '0-12 months' THEN 1
        WHEN '13-24 months' THEN 2
        WHEN '25-48 months' THEN 3
        WHEN '49+ months' THEN 4
        ELSE 5
    END,
    customer_dim.Churn;

-- 6) Top 10 highest revenue customers (individual level)
SELECT
    customer_dim.customer_id,
    telco_customers.MonthlyCharges,
    customer_dim.Contract,
    customer_dim.Churn,
    customer_dim.tenure_bucket
FROM customer_dim
JOIN telco_customers ON telco_customers.customer_id = customer_dim.customer_id
ORDER BY telco_customers.MonthlyCharges DESC
LIMIT 10;
