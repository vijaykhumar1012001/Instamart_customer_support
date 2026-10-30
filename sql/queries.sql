--Q1: WHERE and HAVING
--customers whose individual completed orders exceed ₹500 and whose combined total for those qualifying orders exceeds ₹8,000.

SELECT
    customer_id,
    SUM(order_amount) AS total_spend
FROM orders
WHERE LOWER(TRIM(status)) = 'completed'
  AND order_amount > 500
GROUP BY customer_id
HAVING SUM(order_amount) > 8000
ORDER BY total_spend DESC;

--Q2: Three-table JOIN
--Calculate completed-order revenue for every city and product category.

SELECT 
    c.city,
    p.category,
    ROUND(SUM(o.order_amount), 2) AS total_revenue
FROM orders AS o
JOIN customers AS c
    on o.customer_id = c.customer_id
JOIN products AS p
    on o.product_id = p.product_id
WHERE LOWER(TRIM(o.status)) = 'completed'
GROUP BY
    c.city,
    p.category
ORDER BY
    c.city,
    p.category;

--Q3: Scalar subquery
--Question: Find products whose prices are greater than the average price of all products.

SELECT
    product_id,
    product_name,
    price
FROM products
WHERE price > (
    SELECT AVG(price)
    FROM products
)
ORDER BY price DESC;

--Q4. LEFT JOIN
--Question: Find customers who do not have even one completed order.

SELECT
    c.customer_id,
    c.customer_name
FROM customers AS c
LEFT JOIN orders AS o
    ON c.customer_id = o.customer_id
   AND LOWER(TRIM(o.status)) = 'completed'
WHERE o.customer_id IS NULL
ORDER BY c.customer_id;

--Q5. Common Table Expression (CTE)
--Question: Calculate each customer's total completed spending, find the average of those customer totals, and return customers who spent more than that average.

WITH customer_spending AS (
    SELECT
        customer_id,
        SUM(order_amount) AS total_spend
    FROM orders
    WHERE LOWER(TRIM(status)) = 'completed'
    GROUP BY customer_id
),
average_spending AS (
    SELECT
        AVG(total_spend) AS avg_spend
    FROM customer_spending
)
SELECT
    cs.customer_id,
    cs.total_spend,
    ROUND(a.avg_spend, 2) AS average_customer_spend
FROM customer_spending AS cs
CROSS JOIN average_spending AS a
WHERE cs.total_spend > a.avg_spend
ORDER BY cs.total_spend DESC;

--Q6. Window functions and ranking
--Question: Rank customers by completed spending within their own city using RANK(), DENSE_RANK(), and ROW_NUMBER().

WITH customer_spending AS (
    SELECT
        c.customer_id,
        c.customer_name,
        c.city,
        SUM(o.order_amount) AS total_spend
    FROM customers AS c
    JOIN orders AS o
        ON c.customer_id = o.customer_id
    WHERE LOWER(TRIM(o.status)) = 'completed'
    GROUP BY
        c.customer_id,
        c.customer_name,
        c.city
)
SELECT
    customer_id,
    customer_name,
    city,
    ROUND(total_spend, 2) AS total_spend,

    RANK() OVER (
        PARTITION BY city
        ORDER BY total_spend DESC
    ) AS spending_rank,

    DENSE_RANK() OVER (
        PARTITION BY city
        ORDER BY total_spend DESC
    ) AS dense_spending_rank,

    ROW_NUMBER() OVER (
        PARTITION BY city
        ORDER BY total_spend DESC, customer_id
    ) AS row_number
FROM customer_spending
ORDER BY city, spending_rank, customer_id;

--Q7. Running total
--Question: Calculate revenue for each day, then calculate the cumulative revenue from the first day through each successive day.

WITH daily_revenue AS (
    SELECT
        DATE(order_date) AS order_day,
        SUM(order_amount) AS daily_total
    FROM orders
    WHERE LOWER(TRIM(status)) = 'completed'
    GROUP BY DATE(order_date)
)
SELECT
    order_day,
    ROUND(daily_total, 2) AS daily_revenue,
    ROUND(
        SUM(daily_total) OVER (
            ORDER BY order_day
            ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
        ),
        2
    ) AS cumulative_revenue
FROM daily_revenue
ORDER BY order_day;