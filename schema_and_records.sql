-- 1. Create Tables
CREATE TABLE customers (
    customer_id VARCHAR(20) PRIMARY KEY,
    customer_state VARCHAR(5),
    signup_date DATE
);

CREATE TABLE sellers (
    seller_id VARCHAR(20) PRIMARY KEY,
    seller_state VARCHAR(5),
    seller_tier VARCHAR(15) -- 'Gold', 'Silver', 'Standard'
);

CREATE TABLE orders (
    order_id VARCHAR(20) PRIMARY KEY,
    customer_id VARCHAR(20) REFERENCES customers(customer_id),
    order_status VARCHAR(20), -- 'delivered', 'shipped', 'canceled'
    order_purchase_ts TIMESTAMP,
    order_approved_ts TIMESTAMP,
    order_delivered_carrier_ts TIMESTAMP,
    order_delivered_customer_ts TIMESTAMP,
    order_estimated_delivery_ts TIMESTAMP
);

CREATE TABLE order_items (
    order_id VARCHAR(20) REFERENCES orders(order_id),
    item_seq INT,
    product_category VARCHAR(50),
    seller_id VARCHAR(20) REFERENCES sellers(seller_id),
    price NUMERIC(10,2),
    freight_value NUMERIC(10,2),
    PRIMARY KEY (order_id, item_seq)
);

-- 2. Generate Realistic Scale Data (PostgreSQL generate_series)
INSERT INTO customers
SELECT 
    'CUST_' || LPAD(i::TEXT, 5, '0'),
    (ARRAY['SP','RJ','MG','RS','PR','BA'])[floor(random()*6 + 1)],
    DATE '2024-01-01' + (random()*365)::INT
FROM generate_series(1, 2000) i;

INSERT INTO sellers
SELECT 
    'SELL_' || LPAD(i::TEXT, 3, '0'),
    (ARRAY['SP','RJ','MG','SC','PR'])[floor(random()*5 + 1)],
    (ARRAY['Gold','Silver','Standard'])[floor(random()*3 + 1)]
FROM generate_series(1, 50) i;

INSERT INTO orders
SELECT 
    'ORD_' || LPAD(i::TEXT, 6, '0'),
    'CUST_' || LPAD((floor(random()*2000 + 1))::INT::TEXT, 5, '0'),
    CASE WHEN random() < 0.04 THEN 'canceled' ELSE 'delivered' END,
    ts,
    ts + INTERVAL '2 hours' * random(),
    ts + INTERVAL '1 day' * (1 + random()*4),
    ts + INTERVAL '1 day' * (3 + random()*12),
    ts + INTERVAL '1 day' * (8 + random()*4)
FROM (
    SELECT i, TIMESTAMP '2025-01-01 08:00:00' + (random()*365 * INTERVAL '1 day') AS ts
    FROM generate_series(1, 15000) i
) sub;

-- Nullify delivery timestamps for canceled orders
UPDATE orders 
SET order_delivered_carrier_ts = NULL, order_delivered_customer_ts = NULL 
WHERE order_status = 'canceled';

INSERT INTO order_items
SELECT 
    'ORD_' || LPAD(i::TEXT, 6, '0'),
    1,
    (ARRAY['Electronics','Home_Decor','Health_Beauty','Sports','Watches'])[floor(random()*5 + 1)],
    'SELL_' || LPAD((floor(random()*50 + 1))::INT::TEXT, 3, '0'),
    ROUND((20 + random()*480)::NUMERIC, 2),
    ROUND((8 + random()*45)::NUMERIC, 2)
FROM generate_series(1, 15000) i;
