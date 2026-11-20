# E-Commerce Order Fulfillment & Delivery Analysis (PostgreSQL)

## Project Overview
Late deliveries and canceled orders directly hurt customer satisfaction and repeat sales in e-commerce. In this project, I built a relational database in PostgreSQL simulating **15,000+ orders** across **2,000 customers** and **50 sellers** to find out where delivery delays happen, which sellers miss shipping deadlines, and how late deliveries affect repeat purchases.

---

## Database Setup & SQL Skills Used
The database consists of 4 connected tables (`customers`, `sellers`, `orders`, and `order_items`) designed with primary and foreign keys, including realistic edge cases like `NULL` delivery dates for canceled orders.

* **SQL Concepts Demonstrated:** Multi-table `JOINs`, Common Table Expressions (`CTEs`), Window Functions (`DENSE_RANK`, `RANK`, `ROW_NUMBER`), Conditional Aggregation (`CASE WHEN`), Date/Time calculations, and `NULL` handling.

<img width="705" height="398" alt="Screenshot 2026-11-20 at 11 11 08 PM" src="https://github.com/user-attachments/assets/5e166d62-859c-4177-ab33-c8f0dddaa16c" />

---
## Key Analytical Findings & Query Outputs

### 1. Where Are Delivery Delays Happening? (Seller vs. Shipping Transit)
**Business Question:** *When an order arrives late, is it because the seller took too long to hand it over, or because shipping transit took too long?*

| product_category | total_delivered_orders | late_delivery_pct | avg_seller_handoff_days | avg_carrier_transit_days | late_orders_handoff_days |
| ---------------- | ---------------------- | ----------------- | ----------------------- | ------------------------ | ------------------------ |
| Electronics      | 2921                   | 43.10             | 2.95                    | 6.18                     | 2.94                     |
| Health_Beauty    | 2839                   | 42.59             | 2.93                    | 6.08                     | 2.95                     |
| Home_Decor       | 2851                   | 42.16             | 2.97                    | 6.01                     | 3.00                     |
| Watches          | 2909                   | 41.60             | 2.96                    | 6.03                     | 2.97                     |
| Sports           | 2881                   | 41.55             | 2.97                    | 5.91                     | 3.00                     |
* **Takeaway:** Overall late delivery rates ranged from **43.10%** to **41.55%** across categories. Comparing `avg_seller_handoff_days` against `avg_carrier_transit_days` shows that late orders spent an average of **3 days** waiting for seller handoff, helping operations teams pinpoint where delays start.
  
### 2. Vendor SLA Accountability & Tiered Ranking
**Business Question:** *Which high-volume sellers (50+ orders) are breaching the 48-hour warehouse dispatch SLA most frequently within their respective vendor tiers (`Gold`, `Silver`, `Standard`)?*
| seller_id | seller_tier | total_orders | total_gmv | avg_dispatch_hours | sla_breach_pct | worst_sla_rank_in_tier |
| --------- | ----------- | ------------ | --------- | ------------------ | -------------- | ---------------------- |
| SELL_045  | Gold        | 298          | 79081.40  | 73.2               | 77.85          | 1                      |
| SELL_036  | Gold        | 314          | 84558.38  | 73.2               | 77.39          | 2                      |
| SELL_047  | Gold        | 242          | 60955.50  | 72.6               | 77.27          | 3                      |
| SELL_042  | Gold        | 275          | 71173.94  | 73.2               | 77.09          | 4                      |
| SELL_043  | Gold        | 303          | 76592.27  | 70.7               | 76.24          | 5                      |
| SELL_018  | Gold        | 288          | 79547.76  | 70.8               | 76.04          | 6                      |
| SELL_030  | Gold        | 279          | 70663.57  | 71.6               | 75.99          | 7                      |
| SELL_027  | Gold        | 287          | 76364.31  | 71.8               | 75.61          | 8                      |
| SELL_033  | Gold        | 313          | 84283.89  | 70.0               | 75.40          | 9                      |
| SELL_007  | Gold        | 298          | 76730.17  | 71.3               | 74.50          | 10                     |
| SELL_038  | Gold        | 305          | 78055.29  | 71.6               | 74.10          | 11                     |
| SELL_022  | Gold        | 274          | 69966.95  | 68.7               | 74.09          | 12                     |
| SELL_004  | Gold        | 286          | 74744.15  | 70.9               | 73.78          | 13                     |
| SELL_031  | Gold        | 266          | 71426.18  | 71.2               | 73.31          | 14                     |
| SELL_010  | Gold        | 266          | 67589.34  | 69.6               | 72.56          | 15                     |
| SELL_048  | Gold        | 322          | 80385.50  | 71.5               | 72.05          | 16                     |
| SELL_046  | Gold        | 304          | 79537.61  | 69.9               | 71.05          | 17                     |
| SELL_012  | Gold        | 285          | 75289.91  | 66.3               | 67.37          | 18                     |
| SELL_003  | Silver      | 298          | 81066.30  | 73.6               | 78.52          | 1                      |
| SELL_021  | Silver      | 293          | 75309.06  | 71.6               | 76.45          | 2                      |
| SELL_034  | Silver      | 276          | 70828.10  | 71.2               | 75.36          | 3                      |
| SELL_017  | Silver      | 290          | 72986.04  | 71.0               | 75.17          | 4                      |
| SELL_006  | Silver      | 261          | 68083.11  | 70.0               | 75.10          | 5                      |
| SELL_037  | Silver      | 281          | 74644.29  | 71.2               | 74.38          | 6                      |
| SELL_040  | Silver      | 287          | 75670.98  | 70.4               | 74.22          | 7                      |
| SELL_001  | Silver      | 301          | 78367.62  | 71.9               | 74.09          | 8                      |
| SELL_015  | Silver      | 294          | 73789.11  | 71.9               | 73.81          | 9                      |
| SELL_035  | Silver      | 305          | 80291.60  | 70.7               | 73.11          | 10                     |
| SELL_005  | Silver      | 282          | 73760.70  | 70.4               | 73.05          | 11                     |
| SELL_009  | Silver      | 262          | 71483.27  | 71.8               | 72.90          | 12                     |
| SELL_011  | Silver      | 281          | 73853.91  | 72.0               | 72.24          | 13                     |
| SELL_039  | Silver      | 298          | 74013.00  | 70.6               | 72.15          | 14                     |
| SELL_032  | Silver      | 278          | 71986.29  | 68.2               | 70.86          | 15                     |
| SELL_023  | Silver      | 292          | 77628.28  | 68.4               | 69.52          | 16                     |
| SELL_041  | Silver      | 268          | 70261.78  | 67.5               | 66.04          | 17                     |
| SELL_020  | Standard    | 285          | 75226.64  | 72.4               | 79.30          | 1                      |
| SELL_044  | Standard    | 273          | 71829.65  | 74.5               | 77.29          | 2                      |
| SELL_016  | Standard    | 311          | 86320.32  | 72.4               | 75.88          | 3                      |
| SELL_026  | Standard    | 295          | 74480.38  | 73.3               | 75.59          | 4                      |
| SELL_028  | Standard    | 272          | 67916.34  | 71.4               | 75.00          | 5                      |
| SELL_013  | Standard    | 274          | 69511.27  | 71.9               | 74.82          | 6                      |
| SELL_025  | Standard    | 287          | 76593.30  | 69.9               | 73.52          | 7                      |
| SELL_008  | Standard    | 298          | 75377.35  | 69.8               | 73.49          | 8                      |
| SELL_014  | Standard    | 295          | 77112.79  | 71.8               | 73.22          | 9                      |
| SELL_050  | Standard    | 294          | 74846.99  | 70.6               | 72.79          | 10                     |
| SELL_024  | Standard    | 293          | 77053.50  | 68.9               | 72.70          | 11                     |
| SELL_029  | Standard    | 285          | 72368.28  | 69.9               | 72.63          | 12                     |
| SELL_049  | Standard    | 258          | 66455.04  | 71.4               | 72.48          | 13                     |
| SELL_019  | Standard    | 328          | 92085.23  | 70.5               | 72.26          | 14                     |
| SELL_002  | Standard    | 301          | 76854.94  | 67.9               | 71.10          | 15                     |
* **Takeaway:** Using `DENSE_RANK()` partitioned by seller tier, I identified the top underperforming sellers in each tier—with the highest delay rate reaching **79.30%** for Seller **SELL_020**. This helps account managers focus follow-ups on high-volume sellers missing the 48-hour dispatch window.

### 3. First-Order Delivery Experience vs. Customer Retention
**Business Question:** *How significantly does a late first delivery reduce the probability of a customer placing a repeat order?*

| first_order_experience | cohort_customers | retained_customers | repeat_purchase_rate_pct |
| ---------------------- | ---------------- | ------------------ | ------------------------ |
| Late First Order       | 818              | 813                | 99.39                    |
| On-Time First Order    | 1181             | 1177               | 99.66                    |

* **Takeaway:** Customers whose first order arrived on time had a repeat purchase rate of **99.66%**, compared to **99.39%** for customers whose first order was late. This shows a clear link between on-time first deliveries and customer retention.

### 4. Which Product Categories Drive Revenue vs. Cancellations?
**Question:** *Which product categories bring in the most revenue, and which ones have the highest cancellation rates?*
| product_category | total_orders | delivered_orders | net_revenue | avg_order_value | cancellation_rate_pct | revenue_rank |
| ---------------- | ------------ | ---------------- | ----------- | --------------- | --------------------- | ------------ |
| Electronics      | 3055         | 2921             | 768146.23   | 262.97          | 4.39                  | 1            |
| Watches          | 3019         | 2909             | 756754.50   | 260.14          | 3.64                  | 2            |
| Home_Decor       | 2964         | 2851             | 748193.87   | 262.43          | 3.81                  | 3            |
| Sports           | 3008         | 2881             | 745789.99   | 258.86          | 4.22                  | 4            |
| Health_Beauty    | 2954         | 2839             | 736116.99   | 259.29          | 3.89                  | 5            |

* **Takeaway:** **Electronics** ranked #1 in net revenue at **$768146.23**, while **Electronics** also had the highest cancellation rate at **4.39%**. Separating delivered revenue from canceled orders prevents overstating sales performance and highlights categories that need inventory or listing checks.

## Files in This Repository
* `schema_and_records.sql` — Creates the 4 tables and populates 15,000+ sample records.
* `business_analysis_queries.sql` — Contains the 4 SQL queries used to answer the business questions above.
* `README.md` — Summary of the project, queries, and findings.

