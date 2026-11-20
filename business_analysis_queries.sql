-- ============================================================================
-- KPI 1: Delivery Breach Rate & Root Cause (Seller vs. Carrier Delay)
-- Business Question: When orders arrive late, is the bottleneck seller handoff 
-- or last-mile transit?
-- ============================================================================
WITH delivery_metrics AS (
    SELECT 
        o.order_id,
        oi.product_category,
        EXTRACT(EPOCH FROM (o.order_delivered_carrier_ts - o.order_approved_ts))/86400.0 AS seller_handoff_days,
        EXTRACT(EPOCH FROM (o.order_delivered_customer_ts - o.order_delivered_carrier_ts))/86400.0 AS transit_days,
        CASE 
            WHEN o.order_delivered_customer_ts > o.order_estimated_delivery_ts THEN 1 
            ELSE 0 
        END AS is_late
    FROM orders o
    JOIN order_items oi ON o.order_id = oi.order_id
    WHERE o.order_status = 'delivered'
      AND o.order_delivered_customer_ts IS NOT NULL
)
SELECT 
    product_category,
    COUNT(*) AS total_delivered_orders,
    ROUND(AVG(is_late) * 100, 2) AS late_delivery_pct,
    ROUND(AVG(seller_handoff_days)::NUMERIC, 2) AS avg_seller_handoff_days,
    ROUND(AVG(transit_days)::NUMERIC, 2) AS avg_carrier_transit_days,
    ROUND(AVG(CASE WHEN is_late = 1 THEN seller_handoff_days END)::NUMERIC, 2) AS late_orders_handoff_days
FROM delivery_metrics
GROUP BY product_category
ORDER BY late_delivery_pct DESC;


-- ============================================================================
-- KPI 2: Vendor Accountability & Ranking Within Tiers
-- Business Question: Which high-revenue sellers are breaching the 48-hour 
-- warehouse dispatch SLA and hurting customer experience?
-- ============================================================================
WITH seller_performance AS (
    SELECT 
        s.seller_id,
        s.seller_tier,
        s.seller_state,
        COUNT(DISTINCT o.order_id) AS total_orders,
        SUM(oi.price) AS total_gmv,
        ROUND(AVG(EXTRACT(EPOCH FROM (o.order_delivered_carrier_ts - o.order_approved_ts))/3600.0)::NUMERIC, 1) AS avg_dispatch_hours,
        ROUND(SUM(CASE WHEN EXTRACT(EPOCH FROM (o.order_delivered_carrier_ts - o.order_approved_ts))/3600.0 > 48 THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 2) AS sla_breach_pct
    FROM sellers s
    JOIN order_items oi ON s.seller_id = oi.seller_id
    JOIN orders o ON oi.order_id = o.order_id
    WHERE o.order_status = 'delivered'
    GROUP BY s.seller_id, s.seller_tier, s.seller_state
    HAVING COUNT(DISTINCT o.order_id) >= 50
)
SELECT 
    seller_id,
    seller_tier,
    total_orders,
    total_gmv,
    avg_dispatch_hours,
    sla_breach_pct,
    DENSE_RANK() OVER (PARTITION BY seller_tier ORDER BY sla_breach_pct DESC) AS worst_sla_rank_in_tier
FROM seller_performance
WHERE sla_breach_pct > 30
ORDER BY seller_tier, worst_sla_rank_in_tier;


-- ============================================================================
-- KPI 3: Repeat Purchase Retention & Impact of First-Order Delay
-- Business Question: How much does a late first delivery reduce the probability 
-- of a customer placing a second order?
-- ============================================================================
WITH customer_order_sequence AS (
    SELECT 
        customer_id,
        order_id,
        order_purchase_ts,
        CASE WHEN order_delivered_customer_ts > order_estimated_delivery_ts THEN 'Late First Order' ELSE 'On-Time First Order' END AS first_order_experience,
        ROW_NUMBER() OVER (PARTITION BY customer_id ORDER BY order_purchase_ts) AS order_num,
        COUNT(*) OVER (PARTITION BY customer_id) AS lifetime_orders
    FROM orders
    WHERE order_status = 'delivered'
)
SELECT 
    first_order_experience,
    COUNT(*) AS cohort_customers,
    SUM(CASE WHEN lifetime_orders > 1 THEN 1 ELSE 0 END) AS retained_customers,
    ROUND(AVG(CASE WHEN lifetime_orders > 1 THEN 1.0 ELSE 0.0 END) * 100, 2) AS repeat_purchase_rate_pct
FROM customer_order_sequence
WHERE order_num = 1
GROUP BY first_order_experience;


-- ============================================================================
-- KPI 4: Category Revenue Performance & Cancellation Rate
-- Business Question: Which product categories generate the highest revenue, 
-- and which ones suffer from the highest order cancellation rates?
-- ============================================================================
WITH category_summary AS (
    SELECT 
        oi.product_category,
        COUNT(DISTINCT o.order_id) AS total_orders,
        SUM(CASE WHEN o.order_status = 'delivered' THEN 1 ELSE 0 END) AS delivered_orders,
        SUM(CASE WHEN o.order_status = 'canceled' THEN 1 ELSE 0 END) AS canceled_orders,
        ROUND(SUM(CASE WHEN o.order_status = 'delivered' THEN oi.price ELSE 0 END), 2) AS net_revenue,
        ROUND(AVG(CASE WHEN o.order_status = 'delivered' THEN oi.price END), 2) AS avg_order_value
    FROM orders o
    JOIN order_items oi ON o.order_id = oi.order_id
    GROUP BY oi.product_category
)
SELECT 
    product_category,
    total_orders,
    delivered_orders,
    net_revenue,
    avg_order_value,
    ROUND(canceled_orders * 100.0 / NULLIF(total_orders, 0), 2) AS cancellation_rate_pct,
    RANK() OVER (ORDER BY net_revenue DESC) AS revenue_rank
FROM category_summary
ORDER BY revenue_rank;
