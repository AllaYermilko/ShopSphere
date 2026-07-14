-- 1.1. Порахуйте загальну чисту виручку (net_amount), кількість замовлень і середній чек по кожному РЕГІОНУ за кожен РІК. Потрібен JOIN orders з customers.
SELECT 
    o.order_year AS year,
    c.region,
    SUM(CASE WHEN o.is_returned = 0 THEN o.net_amount ELSE 0 END) AS total_net_amount,
    COUNT(DISTINCT CASE WHEN o.is_returned = 0 THEN o.order_id END) AS total_orders,
    ROUND(
        SUM(CASE WHEN o.is_returned = 0 THEN o.net_amount ELSE 0 END) / 
        NULLIF(COUNT(DISTINCT CASE WHEN o.is_returned = 0 THEN o.order_id END), 0), 
        2
    ) AS average_order_value
FROM orders o
INNER JOIN customers c ON o.customer_id = c.customer_id
GROUP BY o.order_year, c.region
ORDER BY
	year DESC, total_net_amount DESC;


-- 1.2. Знайдіть топ-10 клієнтів за загальною сумою витрат. Виведіть їхній регіон, канал залучення і скільки замовлень вони зробили.
SELECT 
    o.customer_id,
    c.region,
    c.acquisition_chan,
    SUM(CASE WHEN o.is_returned = 0 THEN o.net_amount ELSE 0 END) AS net_amount,
    COUNT(DISTINCT CASE WHEN o.is_returned = 0 THEN o.order_id END) AS order_count
FROM orders o
INNER JOIN customers c ON o.customer_id = c.customer_id
GROUP BY 
    o.customer_id,
    c.region,
    c.acquisition_chan
ORDER BY 
    net_amount DESC
LIMIT 10;


-- 1.3. Для кожної категорії товарів порахуйте: загальну виручку, середню маржу (margin_pct) і частку повернень. Потрібно об'єднати order_items, products та orders.
SELECT 
    p.category,
    ROUND(SUM(oi.line_total), 2) AS net_amount,
    ROUND(AVG(p.margin_pct), 2) AS margin_pct,
    ROUND(
        (CAST(SUM(CASE WHEN o.is_returned = 1 THEN oi.quantity ELSE 0 END) AS REAL) / 
        SUM(oi.quantity)) * 100, 
        2
    ) AS return_rate_pct
FROM order_items oi
INNER JOIN products p ON oi.product_id = p.product_id
INNER JOIN orders o ON oi.order_id = o.order_id
GROUP BY p.category
ORDER BY net_amount DESC;


-- 1.4. За допомогою підзапиту знайдіть клієнтів, чия загальна сума витрат перевищує середню суму витрат по всій базі. Скільки їх? Яка їхня частка у загальній виручці?
SELECT 
    COUNT(customer_id) AS customers_count,
    ROUND(
        SUM(total_spent) * 100.0 / (SELECT SUM(net_amount) FROM orders WHERE is_returned = 0), 
        2
    ) AS revenue_share_pct
FROM (
    SELECT customer_id, SUM(net_amount) AS total_spent
    FROM orders
    WHERE is_returned = 0
    GROUP BY customer_id
)
WHERE total_spent > (
    SELECT AVG(total_spent) 
    FROM (
        SELECT SUM(net_amount) AS total_spent 
        FROM orders 
        WHERE is_returned = 0 
        GROUP BY customer_id
    )
);


-- 1.5. Порахуйте для кожного маркетингового каналу: сумарний бюджет, сумарну приписану виручку і ROI (виручка / бюджет). Використайте таблицю marketing.
SELECT 
    channel,
    ROUND(SUM(budget), 2) AS total_budget,
    ROUND(SUM(attributed_reven), 2) AS total_attributed_revenue,
    ROUND((SUM(attributed_reven) / SUM(budget)) * 100, 2) AS roi_pct
FROM marketing
GROUP BY channel
ORDER BY roi_pct DESC;
