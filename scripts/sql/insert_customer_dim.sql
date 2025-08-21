INSERT INTO customer_dim (
    customer_id, gender, SeniorCitizen, Partner, Dependents,
    tenure, tenure_bucket, Contract, PaymentMethod, Churn
)
SELECT
    customer_id,
    gender,
    SeniorCitizen,
    Partner,
    Dependents,
    tenure,
    CASE
        WHEN tenure <= 12 THEN '0-12 months'
        WHEN tenure <= 24 THEN '13-24 months'
        WHEN tenure <= 48 THEN '25-48 months'
        ELSE '49+ months'
    END AS tenure_bucket,
    Contract,
    PaymentMethod,
    Churn
FROM telco_customers;
