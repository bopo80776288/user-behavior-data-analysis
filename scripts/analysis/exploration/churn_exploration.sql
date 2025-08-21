-- =====================================
-- Churn Analysis Exploration Queries
-- File: churn_exploration.sql
-- Purpose: exploratory analysis on customer_dim
-- =====================================

-- 1) Overall churn rate
SELECT 
    COUNT(*) AS total_customers,
    SUM(Churn) AS churned_customers,
    ROUND(AVG(Churn) * 100, 2) AS churn_rate_pct
FROM customer_dim;

-- 2) Churn rate by Contract type
SELECT 
    Contract,
    COUNT(*) AS total_customers,
    SUM(Churn) AS churned_customers,
    ROUND(AVG(Churn) * 100, 2) AS churn_rate_pct
FROM customer_dim
GROUP BY Contract
ORDER BY churn_rate_pct DESC;

-- 3) Churn rate by Tenure bucket
SELECT 
    CASE 
        WHEN tenure BETWEEN 0 AND 12 THEN '0-1 year'
        WHEN tenure BETWEEN 13 AND 24 THEN '1-2 years'
        WHEN tenure BETWEEN 25 AND 48 THEN '2-4 years'
        ELSE '4+ years'
    END AS tenure_group,
    COUNT(*) AS total_customers,
    SUM(Churn) AS churned_customers,
    ROUND(AVG(Churn) * 100, 2) AS churn_rate_pct
FROM customer_dim
GROUP BY tenure_group
ORDER BY tenure_group;

-- 4) Churn rate by Payment Method
SELECT 
    PaymentMethod,
    COUNT(*) AS total_customers,
    SUM(Churn) AS churned_customers,
    ROUND(AVG(Churn) * 100, 2) AS churn_rate_pct
FROM customer_dim
GROUP BY PaymentMethod
ORDER BY churn_rate_pct DESC;

-- 5) Optional: Churn by Contract × Tenure group
SELECT
    Contract,
    CASE 
        WHEN tenure BETWEEN 0 AND 12 THEN '0-1 year'
        WHEN tenure BETWEEN 13 AND 24 THEN '1-2 years'
        WHEN tenure BETWEEN 25 AND 48 THEN '2-4 years'
        ELSE '4+ years'
    END AS tenure_group,
    COUNT(*) AS total_customers,
    SUM(Churn) AS churned_customers,
    ROUND(AVG(Churn) * 100, 2) AS churn_rate_pct
FROM customer_dim
GROUP BY Contract, tenure_group
ORDER BY Contract, tenure_group;
