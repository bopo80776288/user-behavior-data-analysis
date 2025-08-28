-- =====================================
-- Comprehensive Financial Analysis Summary View
-- File: financial_summary.sql
-- Purpose: create view for Power BI dashboard with raw metrics for Power BI calculations
-- =====================================

-- Create or replace the comprehensive financial summary view
CREATE OR REPLACE VIEW financial_summary AS
WITH customer_financials AS (
    SELECT
        customer_dim.customer_id,
        customer_dim.Contract,
        customer_dim.PaymentMethod,
        customer_dim.tenure_bucket,
        customer_dim.Churn,
        telco_customers.MonthlyCharges,
        CASE
            WHEN telco_customers.MonthlyCharges < 40 THEN 'Low Revenue'
            WHEN telco_customers.MonthlyCharges BETWEEN 40 AND 80 THEN 'Mid Revenue'
            ELSE 'High Revenue'
        END AS RevenueSegment
    FROM customer_dim
    JOIN telco_customers ON telco_customers.customer_id = customer_dim.customer_id
)
SELECT
    Contract,
    PaymentMethod,
    RevenueSegment,
    tenure_bucket,
    -- Customer counts (raw metrics for Power BI calculations)
    COUNT(*) AS TotalCustomers,
    SUM(CASE WHEN Churn = 0 THEN 1 ELSE 0 END) AS ActiveCustomers,
    SUM(CASE WHEN Churn = 1 THEN 1 ELSE 0 END) AS ChurnedCustomers,
    -- Revenue metrics (raw amounts for Power BI calculations)
    SUM(CASE WHEN Churn = 0 THEN MonthlyCharges ELSE 0 END) AS ActiveRevenue,
    SUM(MonthlyCharges) AS TotalHistoricalRevenue,
    AVG(MonthlyCharges) AS AvgMonthlyCharges
FROM customer_financials
GROUP BY 
    Contract, 
    PaymentMethod,
    RevenueSegment,
    tenure_bucket
ORDER BY 
    Contract,
    PaymentMethod,
    RevenueSegment,
    tenure_bucket;
