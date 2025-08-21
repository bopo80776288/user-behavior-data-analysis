-- =====================================
-- Churn Analysis Final Summary
-- File: churn_summary.sql
-- Purpose: reproducible summary table
-- =====================================

-- Create or replace a view summarizing churn
CREATE OR REPLACE VIEW churn_summary AS
SELECT 
    Contract,
    PaymentMethod,
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
GROUP BY Contract, PaymentMethod, tenure_group
ORDER BY Contract, tenure_group;
