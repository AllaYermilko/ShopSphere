-- 1.1. Порахуйте загальну чисту виручку (net_amount), кількість замовлень і середній чек по кожному РЕГІОНУ за кожен РІК. Потрібен JOIN orders з customers.
SELECT
    c.region,
    o.order_year,
    ROUND(SUM(o.net_amount), 2) AS total_net_revenue,
    COUNT(o.order_id) AS orders_count,
    ROUND(AVG(o.net_amount), 2) AS avg_order_value
FROM orders o
JOIN customers c ON o.customer_id = c.customer_id
GROUP BY c.region, o.order_year
ORDER BY o.order_year, total_net_revenue DESC;


-- 1.2. Знайдіть топ-10 клієнтів за загальною сумою витрат. Виведіть їхній регіон, канал залучення і скільки замовлень вони зробили.
SELECT
    c.customer_id,
    c.region,
    c.acquisition_chan,
    COUNT(o.order_id) AS orders_count,
    ROUND(SUM(o.net_amount), 2) AS total_spent
FROM customers c
JOIN orders o ON c.customer_id = o.customer_id
GROUP BY 
    c.customer_id,
    c.region,
    c.acquisition_chan
ORDER BY total_spent DESC
LIMIT 10;


-- 1.3. Для кожної категорії товарів порахуйте: загальну виручку, середню маржу (margin_pct) і частку повернень. Потрібно об'єднати order_items, products та orders.
SELECT
    p.category,
    ROUND(SUM(oi.line_total), 2) AS total_revenue,
    ROUND(AVG(p.margin_pct), 2) AS avg_margin_pct,
    ROUND(100.0 * SUM(o.is_returned) / COUNT(DISTINCT o.order_id), 2) AS return_rate_pct
FROM order_items oi
JOIN products p 
    ON oi.product_id = p.product_id
JOIN orders o ON oi.order_id = o.order_id
GROUP BY p.category
ORDER BY total_revenue DESC;


-- 1.4. За допомогою підзапиту знайдіть клієнтів, чия загальна сума витрат перевищує середню суму витрат по всій базі. Скільки їх? Яка їхня частка у загальній виручці?
WITH customer_spending AS (
    SELECT
        customer_id,
        SUM(net_amount) AS total_spent
    FROM orders
    GROUP BY customer_id
),

avg_spending AS (
    SELECT
        AVG(total_spent) AS avg_total_spent
    FROM customer_spending
),

above_avg_customers AS (
    SELECT
        cs.customer_id,
        cs.total_spent
    FROM customer_spending cs
    CROSS JOIN avg_spending av
    WHERE cs.total_spent > av.avg_total_spent
)

SELECT
    COUNT(*) AS customers_above_average,
    ROUND(SUM(total_spent), 2) AS revenue_from_above_avg_customers,
    ROUND(
        100.0 * SUM(total_spent) / 
        (SELECT SUM(net_amount) FROM orders),
        2
    ) AS revenue_share_pct
FROM above_avg_customers;


-- 1.5. Порахуйте для кожного маркетингового каналу: сумарний бюджет, сумарну приписану виручку і ROI (виручка / бюджет). Використайте таблицю marketing.
SELECT
    channel,
    ROUND(SUM(budget), 2) AS total_budget,
    ROUND(SUM(attributed_reven), 2) AS total_attributed_revenue,
    ROUND(SUM(attributed_reven) / NULLIF(SUM(budget), 0), 2) AS roi
FROM marketing
GROUP BY channel
ORDER BY roi DESC;
