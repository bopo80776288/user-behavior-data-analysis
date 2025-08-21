INSERT INTO customer_activity_fact
(customer_id, experiment_name, test_group, email_opened, clicked_cta, 
 days_active_next_30d, purchases_next_30d, revenue_next_30d, retained_30d,
 event_count, total_event_value, activity_date)
SELECT 
    a.customer_id,
    a.experiment_name,
    a.test_group,
    a.email_opened,
    a.clicked_cta,
    a.days_active_next_30d,
    a.purchases_next_30d,
    a.revenue_next_30d,
    a.retained_30d,
    COUNT(e.event_id) AS event_count,
    COALESCE(SUM(e.event_value), 0) AS total_event_value,
    CURDATE() AS activity_date
FROM ab_test a
LEFT JOIN event_logs e
    ON a.customer_id = e.customer_id
GROUP BY a.customer_id, a.experiment_name, a.test_group;