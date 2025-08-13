-- ----------------------------
-- DDL for telco_customers table
-- ----------------------------
CREATE TABLE IF NOT EXISTS telco_customers (
    customer_id INT AUTO_INCREMENT PRIMARY KEY,
    first_name VARCHAR(50),
    last_name VARCHAR(50),
    gender VARCHAR(10),
    date_of_birth DATE,
    signup_date DATE,
    churn BOOLEAN,
    tenure INT,
    monthly_charges DECIMAL(10,2),
    total_charges DECIMAL(10,2)
);

-- ----------------------------
-- DDL for ab_test table
-- ----------------------------
CREATE TABLE IF NOT EXISTS ab_test (
    test_id INT AUTO_INCREMENT PRIMARY KEY,
    customer_id INT,
    test_group VARCHAR(10),
    start_date DATE,
    end_date DATE,
    FOREIGN KEY (customer_id) REFERENCES telco_customers(customer_id)
);

-- ----------------------------
-- DDL for event_logs table
-- ----------------------------
CREATE TABLE IF NOT EXISTS event_logs (
    event_id INT AUTO_INCREMENT PRIMARY KEY,
    customer_id INT,
    event_type VARCHAR(50),
    event_timestamp DATETIME,
    event_value DECIMAL(10,2),
    FOREIGN KEY (customer_id) REFERENCES telco_customers(customer_id)
);
