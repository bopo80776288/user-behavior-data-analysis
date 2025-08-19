CREATE TABLE IF NOT EXISTS customer_activity_fact (
    activity_id INT AUTO_INCREMENT PRIMARY KEY,
    customer_id VARCHAR(20),
    experiment_name VARCHAR(50),
    test_group VARCHAR(10),
    email_opened BOOLEAN,
    clicked_cta BOOLEAN,
    days_active_next_30d INT,
    purchases_next_30d INT,
    revenue_next_30d DECIMAL(10,2),
    retained_30d BOOLEAN,
    event_count INT,
    total_event_value DECIMAL(10,2),
    activity_date DATE,
    FOREIGN KEY (customer_id) REFERENCES customer_dim(customer_id)
);
