import pandas as pd
import numpy as np
from datetime import datetime, timedelta
import random

np.random.seed(42)
random.seed(42)

N = 100_000

# Date range: Jan 2023 - Dec 2023
start_date = datetime(2023, 1, 1)
dates = [start_date + timedelta(seconds=random.randint(0, 365*24*3600)) for _ in range(N)]
dates.sort()

# Payment methods with realistic weights
payment_methods = ['GPay', 'PhonePe', 'Paytm', 'BHIM UPI', 'Amazon Pay']
pm_weights      = [0.35,   0.30,      0.18,    0.10,       0.07]

# Categories
categories = ['Food & Dining', 'Shopping', 'Recharge & Bills', 'Travel', 
              'Entertainment', 'Healthcare', 'Education', 'Groceries', 'Transfer']
cat_weights = [0.18, 0.16, 0.15, 0.12, 0.08, 0.07, 0.05, 0.12, 0.07]

# Cities
cities = ['Mumbai', 'Delhi', 'Bangalore', 'Hyderabad', 'Pune', 
          'Chennai', 'Kolkata', 'Ahmedabad', 'Jaipur', 'Surat']
city_weights = [0.18, 0.17, 0.15, 0.11, 0.10, 0.09, 0.07, 0.05, 0.04, 0.04]

# Merchant types
merchants = {
    'Food & Dining':       ['Zomato', 'Swiggy', 'Dominos', 'McDonalds', 'Local Restaurant'],
    'Shopping':            ['Flipkart', 'Amazon', 'Myntra', 'Nykaa', 'Meesho'],
    'Recharge & Bills':    ['Jio', 'Airtel', 'Vi', 'BSNL', 'Electricity Board'],
    'Travel':              ['MakeMyTrip', 'RedBus', 'IRCTC', 'Ola', 'Uber'],
    'Entertainment':       ['BookMyShow', 'Netflix', 'Hotstar', 'Spotify', 'Gaana'],
    'Healthcare':          ['PharmEasy', '1mg', 'Practo', 'Apollo', 'Local Clinic'],
    'Education':           ['Byju\'s', 'Unacademy', 'Coursera', 'College Fee', 'Udemy'],
    'Groceries':           ['BigBasket', 'Blinkit', 'Zepto', 'DMart', 'Local Kirana'],
    'Transfer':            ['Bank Transfer', 'Self Transfer', 'Family', 'Friend', 'Rent'],
}

# Generate base amounts per category (log-normal distribution for realism)
amount_params = {
    'Food & Dining':       (4.5, 0.7),   # mean ~90, skewed
    'Shopping':            (5.5, 0.9),   # mean ~245
    'Recharge & Bills':    (4.8, 0.6),
    'Travel':              (5.8, 1.0),
    'Entertainment':       (4.3, 0.6),
    'Healthcare':          (5.2, 0.8),
    'Education':           (6.5, 1.0),
    'Groceries':           (5.0, 0.7),
    'Transfer':            (7.0, 1.2),   # large transfers
}

# Build dataset
transaction_ids = [f"TXN{str(i).zfill(8)}" for i in range(1, N+1)]
user_ids        = [f"USR{str(random.randint(1, 15000)).zfill(5)}" for _ in range(N)]

category_list = random.choices(categories, weights=cat_weights, k=N)
merchant_list = [random.choice(merchants[c]) for c in category_list]
city_list     = random.choices(cities, weights=city_weights, k=N)
pm_list       = random.choices(payment_methods, weights=pm_weights, k=N)

amounts = []
for cat in category_list:
    mu, sigma = amount_params[cat]
    amt = round(np.random.lognormal(mu, sigma), 2)
    amt = max(1.0, min(amt, 500000))  # cap between 1 and 5L
    amounts.append(amt)

# Status: 94% success, 4% failed, 2% pending
statuses = random.choices(['Success', 'Failed', 'Pending'], weights=[0.94, 0.04, 0.02], k=N)

# Fraud flag: ~1.2% of transactions flagged (higher for large amounts)
fraud_flags = []
for amt, status in zip(amounts, statuses):
    if status == 'Failed':
        fraud_flags.append(0)
    elif amt > 50000:
        fraud_flags.append(1 if random.random() < 0.08 else 0)
    elif amt > 10000:
        fraud_flags.append(1 if random.random() < 0.03 else 0)
    else:
        fraud_flags.append(1 if random.random() < 0.008 else 0)

df = pd.DataFrame({
    'transaction_id':   transaction_ids,
    'user_id':          user_ids,
    'timestamp':        dates,
    'amount':           amounts,
    'payment_method':   pm_list,
    'category':         category_list,
    'merchant':         merchant_list,
    'city':             city_list,
    'status':           statuses,
    'is_fraud':         fraud_flags,
})

df['date']  = pd.to_datetime(df['timestamp']).dt.date
df['month'] = pd.to_datetime(df['timestamp']).dt.month
df['hour']  = pd.to_datetime(df['timestamp']).dt.hour
df['day_of_week'] = pd.to_datetime(df['timestamp']).dt.day_name()

df.to_csv('/home/claude/upi-fintech-analysis/data/upi_transactions.csv', index=False)
print(f"Dataset generated: {len(df):,} rows")
print(df.head())
print(f"\nFraud rate: {df['is_fraud'].mean()*100:.2f}%")
print(f"Success rate: {(df['status']=='Success').mean()*100:.2f}%")
