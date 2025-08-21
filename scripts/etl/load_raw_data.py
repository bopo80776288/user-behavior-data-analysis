import pymysql
import csv
from decimal import Decimal, InvalidOperation

# DB config
db_config = {
    "host": "telco-db.cdueumqkyhaz.ap-southeast-2.rds.amazonaws.com",
    "user": "admin",
    "password": "bopo80776288",
    "database": "user_behavior_db"
}

def safe_decimal(val):
    try:
        return Decimal(val)
    except (ValueError, TypeError, InvalidOperation):
        return None

def safe_int(val):
    try:
        return int(val)
    except:
        return None

def safe_bool(val):
    return 1 if str(val).lower() in ['yes', 'true', '1'] else 0

def load_csv_to_table(csv_file, table_name, existing_ids=None, limit=1000):
    conn = pymysql.connect(**db_config)
    cursor = conn.cursor()
    
    # Clear table
    cursor.execute(f"DELETE FROM {table_name}")
    conn.commit()
    print(f"{table_name} cleared.")
    
    with open(csv_file, newline='', encoding='utf-8-sig') as f:
        reader = csv.DictReader(f)
        count = 0
        skipped = 0

        for row in reader:
            if count >= limit:
                break

            # Extract customer_id as STRING (IDs are alphanumeric in source CSVs)
            customer_id = (row.get("customerID") or "").strip()
            if table_name != "event_logs" and not customer_id:
                skipped += 1
                continue

            # If checking for existing customerIDs (for ab_test / event_logs)
            if existing_ids is not None and customer_id not in existing_ids:
                skipped += 1
                continue

            if table_name == "telco_customers":
                values = [
                    customer_id,
                    row.get("gender"),
                    safe_bool(row.get("SeniorCitizen")),
                    row.get("Partner"),
                    row.get("Dependents"),
                    safe_int(row.get("tenure")),
                    row.get("PhoneService"),
                    row.get("MultipleLines"),
                    row.get("InternetService"),
                    row.get("OnlineSecurity"),
                    row.get("OnlineBackup"),
                    row.get("DeviceProtection"),
                    row.get("TechSupport"),
                    row.get("StreamingTV"),
                    row.get("StreamingMovies"),
                    row.get("Contract"),
                    row.get("PaperlessBilling"),
                    row.get("PaymentMethod"),
                    safe_decimal(row.get("MonthlyCharges")),
                    safe_decimal(row.get("TotalCharges")),
                    safe_bool(row.get("Churn"))
                ]
                sql = f"""
                INSERT INTO {table_name} 
                (customer_id, gender, SeniorCitizen, Partner, Dependents, tenure, PhoneService, MultipleLines,
                 InternetService, OnlineSecurity, OnlineBackup, DeviceProtection, TechSupport, StreamingTV,
                 StreamingMovies, Contract, PaperlessBilling, PaymentMethod, MonthlyCharges, TotalCharges, Churn)
                VALUES (%s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s)
                """
            elif table_name == "ab_test":
                values = [
                    customer_id,
                    row.get("experiment_name"),
                    row.get("group"),
                    (row.get("exposure_date") or "")[:10],  # YYYY-MM-DD
                    (row.get("exposure_date") or "")[:10],  # start_date = end_date
                    safe_bool(row.get("email_opened")),
                    safe_bool(row.get("clicked_cta")),
                    safe_int(row.get("days_active_next_30d")),
                    safe_int(row.get("purchases_next_30d")),
                    safe_decimal(row.get("revenue_next_30d")),
                    safe_bool(row.get("retained_30d"))
                ]
                sql = f"""
                INSERT INTO {table_name} 
                (customer_id, experiment_name, test_group, start_date, end_date, email_opened, clicked_cta,
                 days_active_next_30d, purchases_next_30d, revenue_next_30d, retained_30d)
                VALUES (%s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s)
                """
            elif table_name == "event_logs":
                values = [
                    safe_int(row.get("event_id")),
                    customer_id,
                    row.get("event_type"),
                    row.get("event_ts"),
                    safe_decimal(row.get("amount"))
                ]
                sql = f"""
                INSERT INTO {table_name} (event_id, customer_id, event_type, event_timestamp, event_value)
                VALUES (%s, %s, %s, %s, %s)
                """
            else:
                continue

            cursor.execute(sql, values)
            count += 1
            if count % 100 == 0:
                print(f"{count} rows processed in {table_name}")

    conn.commit()
    cursor.close()
    conn.close()
    print(f"{table_name} loaded successfully from {csv_file} (limit={limit}, skipped={skipped})")
    return count

# --- Run loader ---
# 1. Load customers first
loaded_ids = set()
def get_loaded_customer_ids():
    conn = pymysql.connect(**db_config)
    cursor = conn.cursor()
    cursor.execute("SELECT customer_id FROM telco_customers")
    ids = {row[0] for row in cursor.fetchall()}
    cursor.close()
    conn.close()
    return ids

count = load_csv_to_table("data/raw/telco_customers.csv", "telco_customers", limit=1000)
loaded_ids = get_loaded_customer_ids()

# 2. Load AB test only for loaded customer_ids
load_csv_to_table("data/raw/ab_test.csv", "ab_test", existing_ids=loaded_ids, limit=1000)

# 3. Load event logs only for loaded customer_ids
load_csv_to_table("data/raw/event_logs.csv", "event_logs", existing_ids=loaded_ids, limit=1000)
