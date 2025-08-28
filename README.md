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
- `docs/` : Word final report document and PowerPoint slides

---

## Day 1 — Project Setup

- Created project folder structure
- Downloaded and saved the Telco Customer Churn CSV file into `data/raw`  
- Prepared initial Python scripts for data augmentation (`data_generation.py`)  
- Planned project pipeline: data augmentation → cloud database → SQL analysis → dashboarding

---

## Day 2 — AWS RDS & MySQL Workbench Setup

- Created an **AWS RDS instance** for MySQL (`telco-db`)  
- Installed **MySQL Workbench** and successfully connected to the RDS instance  
- Created **database `user_behavior_db`** on the RDS instance  
- Fixed and executed **DDL (`01_base_tables.sql`)** to create tables:  
  - `telco_customers`  
  - `ab_test`  
  - `event_logs`  
- Verified tables exist and their structure using `SHOW TABLES;` and `DESCRIBE <table_name>;`  
- Generated synthetic A/B test and event logs using `scripts/data_generation.py`:
  - Outputs created in `data/raw/`: `ab_test.csv`, `event_logs.csv`
- Prepared for next step: **loading local CSVs into RDS tables**

---

## Day 3 — DDL refinements and CSV loader

- Finalized/updated RDS schema in `scripts/01_base_tables.sql` to align with CSVs:
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

---

## Day 4 — Dim/Fact schema and population scripts

- Added DDL scripts under `scripts/ddl/`:
  - `scripts/ddl/ddl_customer_dim.sql`: Defines `customer_dim` with `tenure_bucket` and key customer attributes
  - `scripts/ddl/ddl_customer_activity_fact.sql`: Defines `customer_activity_fact` at customer×experiment grain, includes A/B metrics and aggregated event metrics
- Added insert scripts to populate from raw tables under `scripts/insert/` and `scripts/Insert/`:
  - `scripts/insert/insert_customer_dim.sql`: Populates `customer_dim` from `telco_customers` with tenure bucketing
  - `scripts/insert/insert_customer_activity_fact.sql`: Populates `customer_activity_fact` by joining `ab_test` with `event_logs`

---

## Day 5 — Folder structure, file organization, SQL Analysis, and PowerBI Dashboards

- **Reorganized scripts folder structure**:
  - `scripts/ddl/` - All table definitions (01_base_tables.sql, 02_customer_dim.sql, 03_customer_activity_fact.sql)
  - `scripts/sql/` - Data manipulation scripts (insert_customer_dim.sql, insert_customer_activity_fact.sql)
  - `scripts/etl/` - Python ETL processes only (load_raw_data.py, data_generation.py)
  - `scripts/analysis/` - Analysis and exploration scripts
- **Renamed files for clarity and consistency**:
  - `load_csv_to_rds.py` → `load_raw_data.py` (more descriptive)
  - `ddl_mysql_aws.sql` → `01_base_tables.sql` (sequential, descriptive)
  - `ddl_customer_dim.sql` → `02_customer_dim.sql` (sequential naming)
  - `ddl_customer_activity_fact.sql` → `03_customer_activity_fact.sql` (sequential naming)
- **Separated concerns properly** - SQL files no longer mixed with Python files in ETL folder
- **Established naming convention** - sequential numbering for DDL files, descriptive names for all scripts
- **SQL analysis workflow** (feeds the dashboard):
  - `scripts/analysis/exploration/churn_exploration.sql` - exploration queries
  - `scripts/analysis/summary/churn_summary.sql` - summary metrics
  - `scripts/analysis/outputs/churn summary.csv` - exported output used as the Power BI data source
- **Created Power BI dashboard** for customer churn analysis:
  - `dashboards/powerbi_pbix/churn summary.pbix` - Interactive Power BI dashboard
  - `dashboards/powerbi_pdf/churn summary.pdf` - Static PDF export of dashboard

---

## Day 6 — Financial analysis (active vs historical) and Power BI integration

- Added financial exploration and summary:
  - `scripts/analysis/exploration/financial_exploration.sql` (raw metrics by segment; no rates)
  - `scripts/analysis/summary/financial_summary.sql` (view with raw metrics only)
    - Fields: `TotalCustomers`, `ActiveCustomers`, `ChurnedCustomers`, `ActiveRevenue`, `TotalHistoricalRevenue`, `AvgMonthlyCharges`, plus segment columns (`Contract`, `Payment Method`, `Revenue Segment`, `Tenure Group`)
- Standardized tenure bins across churn and financial views (`0-1 year`, `1-2 years`, `2-4 years`, `4+ years`).
- Exported `financial_summary.csv` to `scripts/analysis/outputs/` for Power BI.
- Built Power BI page for financial impact:
  - Cards: Active Revenue, Churned Revenue (TotalHistoricalRevenue − ActiveRevenue)
  - Charts: Revenue at Risk by Contract / Payment Method / Tenure Group
  - Measures defined in Power BI (examples):
    - `Churn Rate = DIVIDE([Churned Customers], [Total Customers])`
    - `Revenue at Risk = [Active Revenue] * [Churn Rate]`
    - `Revenue Retention % = DIVIDE([Active Revenue], [Total Historical Revenue])`
- Modeling guidance applied:
  - Use conformed dimensions in Power BI (e.g., shared `Tenure Group`) so slicers work across churn and financial tables.

---
