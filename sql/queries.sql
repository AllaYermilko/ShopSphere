-- 1.1. Berechnen Sie den gesamten Nettoumsatz (net_amount), die Anzahl der Bestellungen und den
-- durchschnittlichen Bestellwert für jede REGION und jedes JAHR. Erforderlich ist ein JOIN von orders
-- mit customers.

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


-- 1.2. Finden Sie die Top-10-Kunden nach Gesamtausgaben. Geben Sie deren Region,
-- Akquisitionskanal und die Anzahl der getätigten Bestellungen an.

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


-- 1.3. Berechnen Sie für jede Produktkategorie: den Gesamtumsatz, die durchschnittliche Marge
-- (margin_pct) und den Retourenanteil. Dafür müssen order_items, products und orders
-- zusammengeführt werden.

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


-- 1.4. Finden Sie mittels Unterabfrage die Kunden, deren Gesamtausgaben den durchschnittlichen
-- Ausgabenwert über die gesamte Datenbank hinweg übersteigen. Wie viele sind es? Welchen Anteil am
-- Gesamtumsatz haben sie?

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


-- 1.5. Berechnen Sie für jeden Marketingkanal: das Gesamtbudget, den gesamten zugeschriebenen
-- Umsatz und den ROI (Umsatz / Budget). Verwenden Sie die Tabelle marketing.

SELECT
    channel,
    ROUND(SUM(budget), 2) AS total_budget,
    ROUND(SUM(attributed_reven), 2) AS total_attributed_revenue,
    ROUND(SUM(attributed_reven) / NULLIF(SUM(budget), 0), 2) AS roi
FROM marketing
GROUP BY channel
ORDER BY roi DESC;


-- Pareto
WITH customer_spend AS (
    SELECT
        c.customer_id,
        COALESCE(SUM(o.net_amount), 0) AS total_spend

    FROM customers AS c

    LEFT JOIN orders AS o
        ON c.customer_id = o.customer_id

    GROUP BY
        c.customer_id
),

ranked_customers AS (
    SELECT
        customer_id,
        total_spend,

        ROW_NUMBER() OVER (
            ORDER BY total_spend DESC
        ) AS customer_rank,

        COUNT(*) OVER () AS customer_count,

        SUM(total_spend) OVER (
            ORDER BY total_spend DESC
            ROWS BETWEEN UNBOUNDED PRECEDING
                     AND CURRENT ROW
        ) AS cumulative_revenue,

        SUM(total_spend) OVER () AS total_revenue

    FROM customer_spend
)

SELECT
    customer_id,
    ROUND(total_spend, 2) AS total_spend,
    customer_rank,

    ROUND(
        100.0 * customer_rank / customer_count,
        2
    ) AS cumulative_customer_pct,

    ROUND(
        100.0 * cumulative_revenue
        / NULLIF(total_revenue, 0),
        2
    ) AS cumulative_revenue_pct,

    CASE
        WHEN customer_rank <= (customer_count + 19) / 20
            THEN 'Top 5%'
        ELSE 'Other 95%'
    END AS customer_group

FROM ranked_customers

ORDER BY
    customer_rank;


-- 5.10. Vergleichen Sie den durchschnittlichen Bestellwert (net_amount) zwischen den Gruppen A und B über
-- alle Bestellungen des Experiments hinweg. Ist Version B auf den ersten Blick besser?
    
SELECT
    o.ab_variant,
    CASE 
        WHEN (julianday(o.order_date) - julianday(c.signup_date)) <= 60 THEN 'Neukunden'
        ELSE 'Bestandskunden'
    END AS client_type,
    ROUND(AVG(o.net_amount), 2) AS avg_net_amount,
    COUNT(o.order_id) AS total_orders
FROM orders o
JOIN customers c ON o.customer_id = c.customer_id
WHERE o.order_date >= '2024-06-01'
  AND o.ab_variant IN ('A', 'B')
GROUP BY 
    o.ab_variant,
    CASE 
        WHEN (julianday(o.order_date) - julianday(c.signup_date)) <= 60 THEN 'Neukunden'
        ELSE 'Bestandskunden'
    END
ORDER BY client_type, o.ab_variant;
