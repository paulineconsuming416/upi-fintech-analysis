-- ============================================================
-- UPI Fintech Transaction Analysis — SQL Queries
-- Author: Shubham Jadhav
-- Database: MySQL
-- ============================================================

-- ── CREATE TABLE ─────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS upi_transactions (
    transaction_id  VARCHAR(12)    PRIMARY KEY,
    user_id         VARCHAR(10)    NOT NULL,
    timestamp       DATETIME       NOT NULL,
    amount          DECIMAL(12,2)  NOT NULL,
    payment_method  VARCHAR(20)    NOT NULL,
    category        VARCHAR(30)    NOT NULL,
    merchant        VARCHAR(30)    NOT NULL,
    city            VARCHAR(20)    NOT NULL,
    status          VARCHAR(10)    NOT NULL,
    is_fraud        TINYINT(1)     DEFAULT 0,
    date            DATE,
    month           INT,
    hour            INT,
    day_of_week     VARCHAR(12)
);


-- ════════════════════════════════════════════════════════════
-- SECTION 1: BASIC OVERVIEW
-- ════════════════════════════════════════════════════════════

-- Q1: Total transactions, value, and success rate
SELECT
    COUNT(*)                                        AS total_transactions,
    ROUND(SUM(amount), 2)                           AS total_value,
    ROUND(SUM(CASE WHEN status = 'Success' THEN amount ELSE 0 END), 2)  AS successful_value,
    ROUND(AVG(amount), 2)                           AS avg_transaction,
    ROUND(SUM(CASE WHEN status = 'Success' THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 2) AS success_rate_pct
FROM upi_transactions;


-- Q2: Breakdown by transaction status
SELECT
    status,
    COUNT(*)                                AS transaction_count,
    ROUND(SUM(amount), 2)                   AS total_value,
    ROUND(COUNT(*) * 100.0 / (SELECT COUNT(*) FROM upi_transactions), 2) AS pct_of_total
FROM upi_transactions
GROUP BY status
ORDER BY transaction_count DESC;


-- ════════════════════════════════════════════════════════════
-- SECTION 2: MONTHLY TRENDS
-- ════════════════════════════════════════════════════════════

-- Q3: Monthly transaction volume and value
SELECT
    month,
    COUNT(*)                    AS transaction_count,
    ROUND(SUM(amount), 2)       AS total_value,
    ROUND(AVG(amount), 2)       AS avg_value,
    ROUND(MAX(amount), 2)       AS max_transaction
FROM upi_transactions
WHERE status = 'Success'
GROUP BY month
ORDER BY month;


-- Q4: Month-over-month growth in transaction count
SELECT
    curr.month,
    curr.txn_count,
    prev.txn_count                                                      AS prev_month_count,
    ROUND((curr.txn_count - prev.txn_count) * 100.0 / prev.txn_count, 2) AS mom_growth_pct
FROM (
    SELECT month, COUNT(*) AS txn_count
    FROM upi_transactions WHERE status = 'Success'
    GROUP BY month
) curr
LEFT JOIN (
    SELECT month, COUNT(*) AS txn_count
    FROM upi_transactions WHERE status = 'Success'
    GROUP BY month
) prev ON curr.month = prev.month + 1
ORDER BY curr.month;


-- ════════════════════════════════════════════════════════════
-- SECTION 3: PAYMENT METHOD ANALYSIS
-- ════════════════════════════════════════════════════════════

-- Q5: Payment method performance — count, value, and avg ticket
SELECT
    payment_method,
    COUNT(*)                    AS transaction_count,
    ROUND(SUM(amount), 2)       AS total_value,
    ROUND(AVG(amount), 2)       AS avg_ticket_size,
    ROUND(COUNT(*) * 100.0 / (
        SELECT COUNT(*) FROM upi_transactions WHERE status = 'Success'
    ), 2)                       AS market_share_pct
FROM upi_transactions
WHERE status = 'Success'
GROUP BY payment_method
ORDER BY total_value DESC;


-- Q6: Failure rate by payment method (quality signal)
SELECT
    payment_method,
    COUNT(*)                                                            AS total_attempts,
    SUM(CASE WHEN status = 'Failed' THEN 1 ELSE 0 END)                 AS failed_count,
    ROUND(SUM(CASE WHEN status = 'Failed' THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 2) AS failure_rate_pct
FROM upi_transactions
GROUP BY payment_method
ORDER BY failure_rate_pct DESC;


-- ════════════════════════════════════════════════════════════
-- SECTION 4: CATEGORY & MERCHANT ANALYSIS
-- ════════════════════════════════════════════════════════════

-- Q7: Top spending categories
SELECT
    category,
    COUNT(*)                    AS transaction_count,
    ROUND(SUM(amount), 2)       AS total_value,
    ROUND(AVG(amount), 2)       AS avg_value,
    ROUND(MIN(amount), 2)       AS min_value,
    ROUND(MAX(amount), 2)       AS max_value
FROM upi_transactions
WHERE status = 'Success'
GROUP BY category
ORDER BY total_value DESC;


-- Q8: Top 10 merchants by transaction value
SELECT
    merchant,
    category,
    COUNT(*)                    AS transaction_count,
    ROUND(SUM(amount), 2)       AS total_revenue
FROM upi_transactions
WHERE status = 'Success'
GROUP BY merchant, category
ORDER BY total_revenue DESC
LIMIT 10;


-- ════════════════════════════════════════════════════════════
-- SECTION 5: PEAK HOUR & TIME ANALYSIS
-- ════════════════════════════════════════════════════════════

-- Q9: Transaction volume by hour of day
SELECT
    hour,
    COUNT(*)                    AS transaction_count,
    ROUND(SUM(amount), 2)       AS total_value,
    ROUND(AVG(amount), 2)       AS avg_value
FROM upi_transactions
WHERE status = 'Success'
GROUP BY hour
ORDER BY hour;


-- Q10: Busiest days of the week
SELECT
    day_of_week,
    COUNT(*)                    AS transaction_count,
    ROUND(SUM(amount), 2)       AS total_value,
    ROUND(AVG(amount), 2)       AS avg_value
FROM upi_transactions
WHERE status = 'Success'
GROUP BY day_of_week
ORDER BY transaction_count DESC;


-- ════════════════════════════════════════════════════════════
-- SECTION 6: FRAUD ANALYSIS
-- ════════════════════════════════════════════════════════════

-- Q11: Overall fraud metrics
SELECT
    SUM(is_fraud)                                   AS total_fraud_txns,
    ROUND(SUM(CASE WHEN is_fraud = 1 THEN amount ELSE 0 END), 2) AS total_fraud_value,
    ROUND(AVG(is_fraud) * 100, 4)                   AS fraud_rate_pct,
    ROUND(AVG(CASE WHEN is_fraud = 1 THEN amount END), 2) AS avg_fraud_amount
FROM upi_transactions;


-- Q12: Fraud rate by payment method
SELECT
    payment_method,
    COUNT(*)                                        AS total_txns,
    SUM(is_fraud)                                   AS fraud_count,
    ROUND(AVG(is_fraud) * 100, 4)                   AS fraud_rate_pct
FROM upi_transactions
GROUP BY payment_method
ORDER BY fraud_rate_pct DESC;


-- Q13: Fraud rate by transaction amount bucket
SELECT
    CASE
        WHEN amount < 500       THEN '1. Low   (< 500)'
        WHEN amount < 2000      THEN '2. Med   (500-2K)'
        WHEN amount < 10000     THEN '3. High  (2K-10K)'
        WHEN amount < 50000     THEN '4. Large (10K-50K)'
        ELSE                         '5. VeryLarge (50K+)'
    END                             AS amount_bucket,
    COUNT(*)                        AS total_txns,
    SUM(is_fraud)                   AS fraud_count,
    ROUND(AVG(is_fraud) * 100, 4)   AS fraud_rate_pct
FROM upi_transactions
GROUP BY amount_bucket
ORDER BY amount_bucket;


-- Q14: High-risk time windows (hour + fraud rate — for security alerts)
SELECT
    hour,
    COUNT(*)                        AS total_txns,
    SUM(is_fraud)                   AS fraud_count,
    ROUND(AVG(is_fraud) * 100, 4)   AS fraud_rate_pct
FROM upi_transactions
GROUP BY hour
HAVING fraud_rate_pct > 1.0    -- flag hours above 1% fraud rate
ORDER BY fraud_rate_pct DESC;


-- ════════════════════════════════════════════════════════════
-- SECTION 7: USER SEGMENTATION
-- ════════════════════════════════════════════════════════════

-- Q15: User-level spending summary
SELECT
    user_id,
    COUNT(*)                    AS total_transactions,
    ROUND(SUM(amount), 2)       AS total_spend,
    ROUND(AVG(amount), 2)       AS avg_transaction,
    COUNT(DISTINCT category)    AS categories_used,
    COUNT(DISTINCT payment_method) AS apps_used,
    MAX(amount)                 AS largest_transaction
FROM upi_transactions
WHERE status = 'Success'
GROUP BY user_id
ORDER BY total_spend DESC
LIMIT 20;


-- Q16: User tier segmentation (Pareto analysis)
SELECT
    CASE
        WHEN total_spend < 1000    THEN '1. Low Value    (< 1K)'
        WHEN total_spend < 10000   THEN '2. Medium Value (1K-10K)'
        WHEN total_spend < 50000   THEN '3. High Value   (10K-50K)'
        ELSE                            '4. VIP          (50K+)'
    END                             AS user_segment,
    COUNT(*)                        AS user_count,
    ROUND(AVG(total_spend), 2)      AS avg_spend_per_user,
    ROUND(SUM(total_spend), 2)      AS segment_total_spend
FROM (
    SELECT user_id, SUM(amount) AS total_spend
    FROM upi_transactions
    WHERE status = 'Success'
    GROUP BY user_id
) user_totals
GROUP BY user_segment
ORDER BY user_segment;


-- ════════════════════════════════════════════════════════════
-- SECTION 8: GEOGRAPHIC ANALYSIS
-- ════════════════════════════════════════════════════════════

-- Q17: City-wise performance
SELECT
    city,
    COUNT(*)                    AS transaction_count,
    ROUND(SUM(amount), 2)       AS total_value,
    ROUND(AVG(amount), 2)       AS avg_transaction,
    COUNT(DISTINCT user_id)     AS unique_users
FROM upi_transactions
WHERE status = 'Success'
GROUP BY city
ORDER BY total_value DESC;


-- Q18: City + Category cross analysis — what do people buy in each city?
SELECT
    city,
    category,
    COUNT(*)                    AS txn_count,
    ROUND(SUM(amount), 2)       AS total_value
FROM upi_transactions
WHERE status = 'Success'
GROUP BY city, category
ORDER BY city, total_value DESC;
