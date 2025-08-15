# User Behavior Analytics Project

## Project Overview

This project aims to simulate a real-world user behavior analytics pipeline using the Telco Customer Churn dataset. It includes data cleaning, augmentation, cloud database ingestion, SQL analysis, and Power BI dashboarding.

---

## Dataset

- Original dataset: Telco Customer Churn from Kaggle  
- Downloaded as `data/raw/WA_Fn-UseC_-Telco-Customer-Churn.csv` named as `telco_customers.csv`

---

## Project Structure

- `data/` : raw and processed data  
- `scripts/` : Python and SQL scripts  
- `notebooks/` : exploratory data analysis and modeling  
- `dashboards/` : Power BI files

---

## Day 1 — Project Setup

- Created project folder structure: `data/raw`, `data/processed`, `scripts/`, `notebooks/`, `dashboards/`  
- Downloaded and saved the Telco Customer Churn CSV file into `data/raw`  
- Prepared initial Python scripts for data augmentation (`data_generation.py`)  
- Planned project pipeline: data augmentation → cloud database → SQL analysis → dashboarding

---

## Day 2 — AWS RDS & MySQL Workbench Setup

- Created an **AWS RDS instance** for MySQL (`telco-db`)  
- Installed **MySQL Workbench** and successfully connected to the RDS instance  
- Created **database `user_behavior_db`** on the RDS instance  
- Fixed and executed **DDL (`ddl_mysql_aws.sql`)** to create tables:  
  - `telco_customers`  
  - `ab_test`  
  - `event_logs`  
- Verified tables exist and their structure using `SHOW TABLES;` and `DESCRIBE <table_name>;`  
- Confirmed connection status in MySQL Workbench  
- Generated synthetic A/B test and event logs using `scripts/data_generation.py`:
  - Outputs created in `data/raw/`: `ab_test.csv`, `event_logs.csv`
- Prepared for next step: **loading local CSVs into RDS tables**

---

## Day 3 — DDL refinements and CSV loader

- Finalized/updated RDS schema in `scripts/ddl_mysql_aws.sql` to align with CSVs:
  - `customer_id` set to `VARCHAR(20)` across tables; foreign keys maintained
  - `ab_test.start_date`, `ab_test.end_date` are `DATE` (derived from `exposure_date`)
  - `event_logs` uses `event_timestamp` (from `event_ts`) and `event_value` (from `amount`)
- Implemented CSV loader `scripts/load_csv_to_rds.py` with safeguards:
  - Loads first `limit=1000` rows from `telco_customers.csv` into `telco_customers`
  - Builds an allowlist of loaded `customer_id`s, then loads only matching rows from `ab_test.csv` and `event_logs.csv`
  - Per-file `limit=1000` applies to inserted (matching) rows; non-matching rows are skipped
  - Coerces booleans (`Yes/No`) to 1/0 and decimals via safe parsing
  - Note: the loader clears each target table (`DELETE FROM <table>`) before loading
  - Ran the loader successfully to insert the first 1000 customers and matched A/B + event rows

## Next Steps
- SQL analysis and queries  
- Build Power BI dashboards

# Run code by

- python3 scripts/load_csv_to_rds.py

