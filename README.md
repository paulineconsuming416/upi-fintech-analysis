# 📊 UPI / Fintech Transaction Analysis — 2023

> **Data Analyst Portfolio Project** | Python • Pandas • NumPy • Matplotlib • Seaborn • MySQL

---

## 🧾 Project Overview

End-to-end analysis of **100,000 UPI transactions** across India in 2023. This project simulates the kind of analysis a Data Analyst would perform at a fintech company like Razorpay, PhonePe, or Paytm — covering transaction trends, payment method performance, fraud detection, and user segmentation.

**Key Skills Demonstrated:**
- Data wrangling with Pandas
- Exploratory Data Analysis (EDA)
- Data visualization (Matplotlib, Seaborn)
- SQL queries for business analysis (MySQL)
- Translating data insights into business recommendations

---

## 📁 Project Structure

```
upi-fintech-analysis/
├── data/
│   ├── upi_transactions.csv      ← 100K row dataset (14 columns)
│   └── generate_data.py          ← Script to regenerate the dataset
├── notebooks/
│   └── analysis.ipynb            ← Full analysis (heavily commented)
├── sql/
│   └── queries.sql               ← 18 MySQL queries for business analysis
├── visuals/
│   ├── 01_monthly_trends.png
│   ├── 02_payment_method_share.png
│   ├── 03_peak_hour_heatmap.png
│   ├── 04_category_analysis.png
│   ├── 05_fraud_analysis.png
│   └── 06_city_user_segmentation.png
└── README.md
```

---

## 📊 Dataset

| Column | Description |
|--------|-------------|
| `transaction_id` | Unique ID (TXN00000001...) |
| `user_id` | Anonymized user ID |
| `timestamp` | Date & time of transaction |
| `amount` | Transaction value in INR |
| `payment_method` | GPay, PhonePe, Paytm, BHIM UPI, Amazon Pay |
| `category` | Food, Shopping, Travel, Healthcare, etc. |
| `merchant` | Merchant name |
| `city` | 10 major Indian cities |
| `status` | Success / Failed / Pending |
| `is_fraud` | Binary fraud flag (0/1) |
| `hour` | Hour of transaction (0–23) |
| `day_of_week` | Day name |

---

## 🔍 Analysis Sections

### 1. Monthly Trends
- Volume and value trends throughout 2023
- Month-over-month growth calculation

### 2. Payment Method Analysis
- GPay vs PhonePe vs Paytm market share
- Volume share vs value share comparison

### 3. Peak Hour Heatmap
- Transaction intensity by hour × day of week
- Identifies optimal times for marketing pushes and server scaling

### 4. Category Spending
- Which categories drive the most volume vs value
- Average ticket size per category

### 5. Fraud Detection ⚠️
- Fraud rate by payment method, transaction size, and hour
- High-risk window identification

### 6. User Segmentation
- RFM-style tiering: Low / Medium / High / VIP users
- City-wise geographic performance

---

## 📈 Key Findings

| Metric | Value |
|--------|-------|
| Total Transactions | 1,00,000 |
| Success Rate | 94.0% |
| Total Value Processed | ₹4.02 Crore |
| Average Transaction | ₹427.71 |
| Fraud Rate | 0.88% |
| Unique Users | ~15,000 |
| Top Payment App | GPay (35%) |
| Peak Transaction Hour | 10:00 AM |

---

## 💡 Business Recommendations

1. **Fraud Prevention** — Transactions >₹10,000 between 1AM–4AM show 3–8x higher fraud rates. Recommend mandatory 2FA during these windows.

2. **User Retention** — 80% of users are Low/Medium value. A tiered cashback program targeting Medium value users could accelerate upgrades.

3. **Infrastructure Scaling** — Traffic peaks 10AM–2PM on weekdays. Pre-provision 25–30% extra capacity during this window to maintain SLA.

4. **Category Strategy** — Education and Transfer categories have the highest average ticket size (>₹5,000). Premium features like higher transaction limits would serve these users well.

5. **City Focus** — Delhi and Mumbai contribute the highest transaction value. Hyperlocal merchant partnership programs in these cities would yield the highest ROI.

---

## 🛠️ How to Run

```bash
# 1. Clone the repository
git clone https://github.com/YOUR_USERNAME/upi-fintech-analysis.git
cd upi-fintech-analysis

# 2. Install dependencies
pip install pandas numpy matplotlib seaborn jupyter

# 3. (Optional) Regenerate dataset
python data/generate_data.py

# 4. Open the notebook
jupyter notebook notebooks/analysis.ipynb
```

---

## 🗄️ SQL Setup (MySQL)

```sql
-- Create the table and import data
SOURCE sql/queries.sql;

-- Or import CSV directly:
LOAD DATA INFILE 'data/upi_transactions.csv'
INTO TABLE upi_transactions
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;
```

---

## 👤 Author

**Shubham Jadhav**  
📧 shubhamjadhav2115@gmail.com  
📍 Thane, Navi Mumbai  
🔗 [LinkedIn](#) | [GitHub](#)

---

*This project uses a synthetically generated dataset that mirrors real-world UPI transaction patterns for portfolio demonstration purposes.*
