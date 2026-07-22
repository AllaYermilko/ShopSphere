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


-- 2.5. Kundenbeitrag (Pareto). Visualisieren Sie, welchen Umsatzanteil die Top-Kunden erwirtschaften.

Tipp: kumulatives Diagramm oder einfacher Vergleich „Top 5 % vs. Rest“.
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

-- 2.6. (Kreativ). Wählen Sie einen noch nicht untersuchten Datenausschnitt und erstellen Sie 
-- eine Visualisierung nach eigenem Ermessen. Überraschen Sie uns mit einem Insight.

Visualisierung nach eigenem Ermessen. Überraschen Sie uns mit einem Insight.  

WITH customer_metrics AS (
    SELECT
        c.customer_id,
        c.region,
        c.acquisition_chan,

        COUNT(DISTINCT o.order_id) AS orders_count,

        ROUND(
            AVG(o.discount_pct),
            2
        ) AS avg_discount_pct,

        ROUND(
            SUM(o.net_amount),
            2
        ) AS customer_ltv

    FROM customers AS c

    LEFT JOIN orders AS o
        ON c.customer_id = o.customer_id

    GROUP BY
        c.customer_id,
        c.region,
        c.acquisition_chan
),

customer_segments AS (
    SELECT
        customer_id,
        region,
        acquisition_chan,
        orders_count,
        avg_discount_pct,
        customer_ltv,

        CASE
            WHEN avg_discount_pct > 20
                THEN 'Discount-heavy customers (>20%)'
            ELSE 'Other customers'
        END AS customer_segment

    FROM customer_metrics
)

SELECT
    customer_segment,

    COUNT(*) AS customers,

    ROUND(
        AVG(orders_count),
        2
    ) AS avg_orders_per_customer,

    ROUND(
        AVG(customer_ltv),
        2
    ) AS avg_ltv,

    ROUND(
        SUM(customer_ltv),
        2
    ) AS total_revenue,

    ROUND(
        AVG(avg_discount_pct),
        2
    ) AS avg_discount_pct

FROM customer_segments

GROUP BY customer_segment

ORDER BY total_revenue DESC;


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

-- Frage 4. Vergleichen Sie die Kanäle nicht nur nach dem Kampagnen-ROI, sondern auch nach dem langfristigen
-- Kundenwert (LTV): Berechnen Sie die durchschnittlichen Kundenausgaben in Abhängigkeit vom
-- acquisition_channel. Stimmen die Schlussfolgerungen mit dem Kampagnen-ROI überein?

SELECT
   c.acquisition_chan,
   AVG(customer_ltv) AS avg_ltv
FROM
(
   SELECT
       customer_id,
       SUM(net_amount) AS customer_ltv
   FROM orders
   GROUP BY customer_id
) ltv
JOIN customers c
ON ltv.customer_id = c.customer_id
GROUP BY c.acquisition_chan
ORDER BY avg_ltv DESC;

--Frage 8.
-- Vergleichen Sie Kunden, die überwiegend mit Rabatt kaufen (durchschnittlicher Rabatt > 20 %), mit
-- den übrigen Kunden hinsichtlich der Bestellanzahl. „Binden“ sich Kunden, die wegen Rabatten
-- gekommen sind, oder kaufen sie einmal und verschwinden?

WITH CustomerStats AS (
    SELECT 
        customer_id,
        COUNT(order_id) AS total_orders_per_user,
        AVG(discount_pct) AS avg_customer_discount
    FROM orders
    GROUP BY customer_id
),
SegmentedCustomers AS (
    SELECT 
        customer_id,
        total_orders_per_user,
        CASE 
            WHEN avg_customer_discount > 20 THEN 'Rabattorientiert (>20%)'
            ELSE 'Übrige Kunden (≤20%)'
        END AS discount_segment
    FROM CustomerStats
)
SELECT 
    discount_segment AS Rabattsegment_Typ,
    AVG(total_orders_per_user) AS Bestellfrequenz_pro_Kunde
FROM SegmentedCustomers
GROUP BY discount_segment;

-- Frage 9.
-- Berechnen Sie, welchen Umsatzanteil die Top-5-%-Kunden erwirtschaften. Wer sind diese Personen
-- (Region, Akquisitionskanal)? Wie kann das Unternehmen sie halten?

WITH CustomerLTV AS (
    SELECT 
        c.customer_id,
        c.acquisition_chan,
        c.region,
        SUM(o.net_amount) AS total_customer_ltv
    FROM customers c
    JOIN orders o ON c.customer_id = o.customer_id
    GROUP BY c.customer_id, c.acquisition_chan, c.region
),
RankedCustomers AS (
    SELECT 
        *,
        ROW_NUMBER() OVER (ORDER BY total_customer_ltv DESC) AS customer_rank
    FROM CustomerLTV
),
TotalCount AS (
    SELECT COUNT(*) AS total_customers FROM CustomerLTV
),
Top5PercentKunden AS (
    SELECT r.*
    FROM RankedCustomers r
    CROSS JOIN TotalCount t
    WHERE r.customer_rank <= (t.total_customers * 0.05)
)
SELECT 
    acquisition_chan AS Kanal,
    region AS Region,
    COUNT(customer_id) AS Anzahl_Top_Kunden,   
    SUM(total_customer_ltv) AS Umsatz_Top_Kunden 
FROM Top5PercentKunden
GROUP BY acquisition_chan, region;
