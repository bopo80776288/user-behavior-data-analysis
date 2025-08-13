# User Behavior Analytics Project

## Project Overview

This project aims to simulate a real-world user behavior analytics pipeline using the Telco Customer Churn dataset. It includes data cleaning, augmentation, cloud database ingestion, SQL analysis, and Power BI dashboarding.

---

## Dataset

- Original dataset: Telco Customer Churn from Kaggle  
- Stored in `data/raw/WA_Fn-UseC_-Telco-Customer-Churn.csv`

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
- Prepared for next step: **loading local CSVs into RDS tables**

---

## Next Steps

- Data augmentation  
- Load local CSVs into cloud database  
- SQL analysis and queries  
- Build Power BI dashboards
