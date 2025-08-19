-- ----------------------------
-- DDL for telco_customers table
-- ----------------------------
CREATE TABLE IF NOT EXISTS telco_customers (
    customer_id VARCHAR(20) PRIMARY KEY,
    gender VARCHAR(10),
    SeniorCitizen BOOLEAN,
    Partner VARCHAR(10),
    Dependents VARCHAR(10),
    tenure INT,
    PhoneService VARCHAR(10),
    MultipleLines VARCHAR(20),
    InternetService VARCHAR(20),
    OnlineSecurity VARCHAR(20),
    OnlineBackup VARCHAR(20),
    DeviceProtection VARCHAR(20),
    TechSupport VARCHAR(20),
    StreamingTV VARCHAR(20),
    StreamingMovies VARCHAR(20),
    Contract VARCHAR(20),
    PaperlessBilling VARCHAR(10),
    PaymentMethod VARCHAR(50),
    MonthlyCharges DECIMAL(10,2),
    TotalCharges DECIMAL(10,2),
    Churn BOOLEAN
);

-- ----------------------------
-- DDL for ab_test table
-- ----------------------------
CREATE TABLE IF NOT EXISTS ab_test (
    test_id INT AUTO_INCREMENT PRIMARY KEY,
    customer_id VARCHAR(20),
    experiment_name VARCHAR(50),
    test_group VARCHAR(10),
    start_date DATE,
    end_date DATE,
    email_opened BOOLEAN,
    clicked_cta BOOLEAN,
    days_active_next_30d INT,
    purchases_next_30d INT,
    revenue_next_30d DECIMAL(10,2),
    retained_30d BOOLEAN,
    FOREIGN KEY (customer_id) REFERENCES telco_customers(customer_id)
);

-- ----------------------------
-- DDL for event_logs table
-- ----------------------------
CREATE TABLE IF NOT EXISTS event_logs (
    event_id INT PRIMARY KEY,
    customer_id VARCHAR(20),
    event_type VARCHAR(50),
    event_timestamp DATETIME,
    event_value DECIMAL(10,2),
    FOREIGN KEY (customer_id) REFERENCES telco_customers(customer_id)
);
