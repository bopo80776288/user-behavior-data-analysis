-- DDL for customer_dim table

CREATE TABLE IF NOT EXISTS customer_dim (
    customer_id VARCHAR(20) PRIMARY KEY,
    gender VARCHAR(10),
    SeniorCitizen BOOLEAN,
    Partner VARCHAR(10),
    Dependents VARCHAR(10),
    tenure INT,
    tenure_bucket VARCHAR(20),
    Contract VARCHAR(20),
    PaymentMethod VARCHAR(50),
    Churn BOOLEAN
);