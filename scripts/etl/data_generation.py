import os
import numpy as np
import pandas as pd

# --------------------------
# Config
# --------------------------
np.random.seed(42)
RAW_DIR = "data/raw"
TELCO_CSV = os.path.join(RAW_DIR, "WA_Fn-UseC_-Telco-Customer-Churn.csv")
AB_OUT = os.path.join(RAW_DIR, "ab_test.csv")
EV_OUT = os.path.join(RAW_DIR, "event_logs.csv")

# Use today's date as an anchor for realistic timestamps
TODAY = pd.Timestamp("2025-08-13")  # adjust if you want

# --------------------------
# Load Telco dataset
# --------------------------
df = pd.read_csv(TELCO_CSV)

# Basic cleanup
df = df.dropna(subset=["customerID"]).copy()
df["customerID"] = df["customerID"].astype(str)
df["ChurnFlag"] = (df["Churn"].astype(str).str.strip().str.upper() == "YES").astype(int)

# --------------------------
# A/B test simulation (one row per customer)
# --------------------------
n = len(df)
groups = np.random.choice(["A", "B"], size=n, p=[0.5, 0.5])
exp_name = np.full(n, "retention_campaign_v1", dtype=object)

# Exposure window (campaign run window)
exp_start = pd.Timestamp("2025-04-01")
exp_end = pd.Timestamp("2025-06-30")
exposure_unix = np.random.randint(exp_start.value // 10**9, exp_end.value // 10**9 + 1, size=n)
exposure_date = pd.to_datetime(exposure_unix, unit="s")

# Engagement probabilities
email_open_prob = 0.35 + (groups == "B") * 0.05
email_opened = (np.random.rand(n) < email_open_prob).astype(int)

clicked_prob = 0.30 + (groups == "B") * 0.05
clicked_cta = (np.random.rand(n) < (clicked_prob * email_opened)).astype(int)

# Activity next 30 days
base_days = np.where(df["ChurnFlag"] == 1, np.random.poisson(3, n), np.random.poisson(8, n))
uplift = (groups == "B") * np.random.binomial(1, 0.5, size=n)  # small uplift occasionally
days_active_next_30d = np.clip(base_days + uplift, 0, 30)

# Purchases & revenue next 30 days
purch_rate = 0.30 + 0.05 * (groups == "B") + 0.20 * (1 - df["ChurnFlag"])
purchases_next_30d = np.where(
    days_active_next_30d == 0, 0, np.random.poisson(purch_rate)
)
avg_price = np.random.normal(loc=45, scale=12, size=n).clip(10, 200)
revenue_next_30d = np.round(purchases_next_30d * avg_price, 2)

# Short-term retention outcome
prob_retained = 0.15 + 0.55 * (1 - df["ChurnFlag"]) + 0.05 * (groups == "B") + 0.05 * clicked_cta
prob_retained = np.clip(prob_retained, 0, 0.98)
retained_30d = (np.random.rand(n) < prob_retained).astype(int)

ab = pd.DataFrame({
    "customerID": df["customerID"],
    "experiment_name": exp_name,
    "group": groups,
    "exposure_date": exposure_date,
    "email_opened": email_opened,
    "clicked_cta": clicked_cta,
    "days_active_next_30d": days_active_next_30d,
    "purchases_next_30d": purchases_next_30d,
    "revenue_next_30d": revenue_next_30d,
    "retained_30d": retained_30d
})
ab.to_csv(AB_OUT, index=False)

# --------------------------
# Event log simulation (many rows per customer)
# --------------------------
event_types = [
    "login", "view_plan", "upgrade_click",
    "support_contact", "payment_attempt",
    "purchase", "cancel_request"
]

def simulate_customer_events(customer_id: str, churn_flag: int):
    # churned users have fewer/farther-in-the-past events
    lam = 6 if churn_flag == 1 else 20
    n_events = np.random.poisson(lam)
    if n_events == 0:
        return []

    # Time window: past 180 days
    if churn_flag == 1:
        # push their recent activity further back in time
        end = TODAY - pd.Timedelta(days=np.random.randint(31, 180))
    else:
        end = TODAY
    start = end - pd.Timedelta(days=180)

    start_s = start.value // 10**9
    end_s = end.value // 10**9 if end > start else (start.value // 10**9 + 1)
    ts = pd.to_datetime(
        np.random.randint(start_s, end_s + 1, size=n_events),
        unit="s"
    )

    # Event-type mix differs by churn
    if churn_flag == 1:
        weights = np.array([0.40, 0.10, 0.06, 0.20, 0.14, 0.04, 0.06])  # more support/cancel, fewer purchases
    else:
        weights = np.array([0.50, 0.20, 0.06, 0.08, 0.08, 0.06, 0.02])  # more logins/views/purchases

    et = np.random.choice(event_types, size=n_events, p=weights/weights.sum())

    # Purchases have an amount; others NaN
    amounts = np.where(et == "purchase",
                       np.round(np.random.gamma(shape=4.0, scale=12.0, size=n_events), 2),
                       np.nan)

    records = []
    for t, e, amt in zip(ts, et, amounts):
        records.append({
            "customerID": customer_id,
            "event_type": e,
            "event_ts": t,
            "amount": amt
        })
    return records

all_rows = []
for cid, churn in zip(df["customerID"].values, df["ChurnFlag"].values):
    all_rows.extend(simulate_customer_events(cid, int(churn)))

events = pd.DataFrame(all_rows)
if not events.empty:
    # Add a surrogate event_id and sort by time
    events = events.sort_values("event_ts").reset_index(drop=True)
    events.insert(0, "event_id", np.arange(1, len(events) + 1))

events.to_csv(EV_OUT, index=False)

print(f"Saved: {AB_OUT}  (rows={len(ab)})")
print(f"Saved: {EV_OUT}  (rows={len(events)})")
