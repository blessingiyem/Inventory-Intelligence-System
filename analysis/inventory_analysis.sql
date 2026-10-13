-- ============================================================
-- INVENTORY INTELLIGENCE SYSTEM
-- Inventory & Business Intelligence Analysis
-- ============================================================

-- ============================================================
-- 01. CURRENT STOCK BY PRODUCT
-- Calculates current stock from inventory IN and OUT movements.
-- ============================================================

SELECT
    p.product_id,
    p.product_name,
    c.category_name,
    p.reorder_level,
    p.maximum_stock,
    COALESCE(SUM(
        CASE
            WHEN it.transaction_type = 'IN' THEN it.quantity
            WHEN it.transaction_type = 'OUT' THEN -it.quantity
            ELSE 0
        END
    ), 0) AS current_stock
FROM products p
LEFT JOIN categories c
    ON p.category_id = c.category_id
LEFT JOIN inventory_transactions it
    ON p.product_id = it.product_id
GROUP BY
    p.product_id,
    p.product_name,
    c.category_name,
    p.reorder_level,
    p.maximum_stock
ORDER BY current_stock ASC;


-- ============================================================
-- 02. INVENTORY VALUE BY PRODUCT
-- ============================================================

SELECT
    p.product_id,
    p.product_name,
    c.category_name,
    p.cost_price,
    COALESCE(SUM(
        CASE
            WHEN it.transaction_type = 'IN' THEN it.quantity
            WHEN it.transaction_type = 'OUT' THEN -it.quantity
            ELSE 0
        END
    ), 0) AS current_stock,
    p.cost_price *
    COALESCE(SUM(
        CASE
            WHEN it.transaction_type = 'IN' THEN it.quantity
            WHEN it.transaction_type = 'OUT' THEN -it.quantity
            ELSE 0
        END
    ), 0) AS inventory_value
FROM products p
LEFT JOIN categories c
    ON p.category_id = c.category_id
LEFT JOIN inventory_transactions it
    ON p.product_id = it.product_id
GROUP BY
    p.product_id,
    p.product_name,
    c.category_name,
    p.cost_price
ORDER BY inventory_value DESC;


-- ============================================================
-- 03. INVENTORY VALUE BY CATEGORY
-- ============================================================

WITH product_stock AS (
    SELECT
        p.product_id,
        p.category_id,
        p.cost_price,
        COALESCE(SUM(
            CASE
                WHEN it.transaction_type = 'IN' THEN it.quantity
                WHEN it.transaction_type = 'OUT' THEN -it.quantity
                ELSE 0
            END
        ), 0) AS current_stock
    FROM products p
    LEFT JOIN inventory_transactions it
        ON p.product_id = it.product_id
    GROUP BY
        p.product_id,
        p.category_id,
        p.cost_price
)

SELECT
    c.category_name,
    SUM(ps.current_stock) AS total_stock,
    SUM(ps.current_stock * ps.cost_price) AS inventory_value
FROM product_stock ps
JOIN categories c
    ON ps.category_id = c.category_id
GROUP BY c.category_name
ORDER BY inventory_value DESC;


-- ============================================================
-- 04. POTENTIAL SALES VALUE BY CATEGORY
-- Estimates the sales value of current inventory.
-- ============================================================

WITH product_stock AS (
    SELECT
        p.product_id,
        p.category_id,
        p.selling_price,
        COALESCE(SUM(
            CASE
                WHEN it.transaction_type = 'IN' THEN it.quantity
                WHEN it.transaction_type = 'OUT' THEN -it.quantity
                ELSE 0
            END
        ), 0) AS current_stock
    FROM products p
    LEFT JOIN inventory_transactions it
        ON p.product_id = it.product_id
    GROUP BY
        p.product_id,
        p.category_id,
        p.selling_price
)

SELECT
    c.category_name,
    SUM(ps.current_stock) AS current_stock,
    SUM(ps.current_stock * ps.selling_price) AS potential_sales_value
FROM product_stock ps
JOIN categories c
    ON ps.category_id = c.category_id
GROUP BY c.category_name
ORDER BY potential_sales_value DESC;


-- ============================================================
-- 05. LOW-STOCK PRODUCTS
-- ============================================================

WITH product_stock AS (
    SELECT
        p.product_id,
        p.product_name,
        p.category_id,
        p.reorder_level,
        p.maximum_stock,
        COALESCE(SUM(
            CASE
                WHEN it.transaction_type = 'IN' THEN it.quantity
                WHEN it.transaction_type = 'OUT' THEN -it.quantity
                ELSE 0
            END
        ), 0) AS current_stock
    FROM products p
    LEFT JOIN inventory_transactions it
        ON p.product_id = it.product_id
    GROUP BY
        p.product_id,
        p.product_name,
        p.category_id,
        p.reorder_level,
        p.maximum_stock
)

SELECT
    ps.product_id,
    ps.product_name,
    c.category_name,
    ps.current_stock,
    ps.reorder_level,
    ps.maximum_stock,
    ps.maximum_stock - ps.current_stock AS suggested_reorder_quantity
FROM product_stock ps
JOIN categories c
    ON ps.category_id = c.category_id
WHERE ps.current_stock <= ps.reorder_level
ORDER BY ps.current_stock ASC;


-- ============================================================
-- 06. REORDER RECOMMENDATIONS
-- ============================================================

WITH product_stock AS (
    SELECT
        p.product_id,
        p.product_name,
        p.category_id,
        p.reorder_level,
        p.maximum_stock,
        COALESCE(SUM(
            CASE
                WHEN it.transaction_type = 'IN' THEN it.quantity
                WHEN it.transaction_type = 'OUT' THEN -it.quantity
                ELSE 0
            END
        ), 0) AS current_stock
    FROM products p
    LEFT JOIN inventory_transactions it
        ON p.product_id = it.product_id
    GROUP BY
        p.product_id,
        p.product_name,
        p.category_id,
        p.reorder_level,
        p.maximum_stock
)

SELECT
    ps.product_id,
    ps.product_name,
    c.category_name,
    ps.current_stock,
    ps.reorder_level,
    ps.maximum_stock,
    GREATEST(ps.maximum_stock - ps.current_stock, 0)
        AS suggested_reorder_quantity
FROM product_stock ps
JOIN categories c
    ON ps.category_id = c.category_id
WHERE ps.current_stock <= ps.reorder_level
ORDER BY suggested_reorder_quantity DESC;


-- ============================================================
-- 07. STOCK HEALTH CLASSIFICATION
-- ============================================================

WITH product_stock AS (
    SELECT
        p.product_id,
        p.product_name,
        p.reorder_level,
        p.maximum_stock,
        COALESCE(SUM(
            CASE
                WHEN it.transaction_type = 'IN' THEN it.quantity
                WHEN it.transaction_type = 'OUT' THEN -it.quantity
                ELSE 0
            END
        ), 0) AS current_stock
    FROM products p
    LEFT JOIN inventory_transactions it
        ON p.product_id = it.product_id
    GROUP BY
        p.product_id,
        p.product_name,
        p.reorder_level,
        p.maximum_stock
)

SELECT
    product_id,
    product_name,
    current_stock,
    reorder_level,
    maximum_stock,
    CASE
        WHEN current_stock <= reorder_level THEN 'Low Stock'
        WHEN current_stock >= maximum_stock THEN 'Fully Stocked'
        ELSE 'Healthy'
    END AS stock_status
FROM product_stock
ORDER BY current_stock ASC;


-- ============================================================
-- 08. STOCK STATUS SUMMARY
-- ============================================================

WITH product_stock AS (
    SELECT
        p.product_id,
        p.reorder_level,
        p.maximum_stock,
        COALESCE(SUM(
            CASE
                WHEN it.transaction_type = 'IN' THEN it.quantity
                WHEN it.transaction_type = 'OUT' THEN -it.quantity
                ELSE 0
            END
        ), 0) AS current_stock
    FROM products p
    LEFT JOIN inventory_transactions it
        ON p.product_id = it.product_id
    GROUP BY
        p.product_id,
        p.reorder_level,
        p.maximum_stock
)

SELECT
    CASE
        WHEN current_stock <= reorder_level THEN 'Low Stock'
        WHEN current_stock >= maximum_stock THEN 'Fully Stocked'
        ELSE 'Healthy'
    END AS stock_status,
    COUNT(*) AS product_count
FROM product_stock
GROUP BY stock_status
ORDER BY product_count DESC;


-- ============================================================
-- 09. FAST-MOVING PRODUCTS
-- Measures products by quantity sold.
-- ============================================================

SELECT
    p.product_id,
    p.product_name,
    c.category_name,
    SUM(it.quantity) AS quantity_sold
FROM inventory_transactions it
JOIN products p
    ON it.product_id = p.product_id
JOIN categories c
    ON p.category_id = c.category_id
WHERE it.transaction_type = 'OUT'
GROUP BY
    p.product_id,
    p.product_name,
    c.category_name
ORDER BY quantity_sold DESC;


-- ============================================================
-- 10. SLOW-MOVING PRODUCTS
-- ============================================================

SELECT
    p.product_id,
    p.product_name,
    c.category_name,
    COALESCE(SUM(it.quantity), 0) AS quantity_sold
FROM products p
JOIN categories c
    ON p.category_id = c.category_id
LEFT JOIN inventory_transactions it
    ON p.product_id = it.product_id
    AND it.transaction_type = 'OUT'
GROUP BY
    p.product_id,
    p.product_name,
    c.category_name
ORDER BY quantity_sold ASC;


-- ============================================================
-- 11. INVENTORY MOVEMENT BY MONTH
-- ============================================================

SELECT
    DATE_TRUNC('month', transaction_date) AS month,
    SUM(
        CASE
            WHEN transaction_type = 'IN' THEN quantity
            ELSE 0
        END
    ) AS quantity_received,
    SUM(
        CASE
            WHEN transaction_type = 'OUT' THEN quantity
            ELSE 0
        END
    ) AS quantity_sold
FROM inventory_transactions
GROUP BY DATE_TRUNC('month', transaction_date)
ORDER BY month;


-- ============================================================
-- 12. MONTHLY NET INVENTORY MOVEMENT
-- ============================================================

SELECT
    DATE_TRUNC('month', transaction_date) AS month,
    SUM(
        CASE
            WHEN transaction_type = 'IN' THEN quantity
            WHEN transaction_type = 'OUT' THEN -quantity
            ELSE 0
        END
    ) AS net_inventory_change
FROM inventory_transactions
GROUP BY DATE_TRUNC('month', transaction_date)
ORDER BY month;


-- ============================================================
-- 13. INVENTORY MOVEMENT BY CATEGORY
-- ============================================================

SELECT
    c.category_name,
    SUM(
        CASE
            WHEN it.transaction_type = 'IN' THEN it.quantity
            ELSE 0
        END
    ) AS quantity_received,
    SUM(
        CASE
            WHEN it.transaction_type = 'OUT' THEN it.quantity
            ELSE 0
        END
    ) AS quantity_sold
FROM inventory_transactions it
JOIN products p
    ON it.product_id = p.product_id
JOIN categories c
    ON p.category_id = c.category_id
GROUP BY c.category_name
ORDER BY quantity_sold DESC;


-- ============================================================
-- 14. SUPPLIER INVENTORY VALUE
-- ============================================================

WITH product_stock AS (
    SELECT
        p.product_id,
        p.supplier_id,
        p.cost_price,
        COALESCE(SUM(
            CASE
                WHEN it.transaction_type = 'IN' THEN it.quantity
                WHEN it.transaction_type = 'OUT' THEN -it.quantity
                ELSE 0
            END
        ), 0) AS current_stock
    FROM products p
    LEFT JOIN inventory_transactions it
        ON p.product_id = it.product_id
    GROUP BY
        p.product_id,
        p.supplier_id,
        p.cost_price
)

SELECT
    s.supplier_id,
    s.supplier_name,
    SUM(ps.current_stock) AS total_stock,
    SUM(ps.current_stock * ps.cost_price) AS inventory_value
FROM product_stock ps
JOIN suppliers s
    ON ps.supplier_id = s.supplier_id
GROUP BY
    s.supplier_id,
    s.supplier_name
ORDER BY inventory_value DESC;


-- ============================================================
-- 15. SUPPLIER PRODUCT COUNT
-- ============================================================

SELECT
    s.supplier_id,
    s.supplier_name,
    COUNT(p.product_id) AS product_count
FROM suppliers s
LEFT JOIN products p
    ON s.supplier_id = p.supplier_id
GROUP BY
    s.supplier_id,
    s.supplier_name
ORDER BY product_count DESC;


-- ============================================================
-- 16. PURCHASE ORDER STATUS SUMMARY
-- ============================================================

SELECT
    status,
    COUNT(*) AS order_count,
    SUM(quantity_ordered) AS total_quantity_ordered
FROM purchase_orders
GROUP BY status
ORDER BY order_count DESC;


-- ============================================================
-- 17. PURCHASE ORDERS BY MONTH
-- ============================================================

SELECT
    DATE_TRUNC('month', order_date) AS month,
    COUNT(*) AS purchase_orders,
    SUM(quantity_ordered) AS quantity_ordered
FROM purchase_orders
GROUP BY DATE_TRUNC('month', order_date)
ORDER BY month;


-- ============================================================
-- 18. PENDING PURCHASE ORDERS
-- ============================================================

SELECT
    po.order_id,
    p.product_name,
    c.category_name,
    s.supplier_name,
    po.quantity_ordered,
    po.order_date,
    po.status
FROM purchase_orders po
JOIN products p
    ON po.product_id = p.product_id
JOIN categories c
    ON p.category_id = c.category_id
JOIN suppliers s
    ON p.supplier_id = s.supplier_id
WHERE po.status = 'Pending'
ORDER BY po.order_date ASC;


-- ============================================================
-- 19. CANCELLED PURCHASE ORDERS
-- ============================================================

SELECT
    po.order_id,
    p.product_name,
    s.supplier_name,
    po.quantity_ordered,
    po.order_date
FROM purchase_orders po
JOIN products p
    ON po.product_id = p.product_id
JOIN suppliers s
    ON p.supplier_id = s.supplier_id
WHERE po.status = 'Cancelled'
ORDER BY po.order_date DESC;


-- ============================================================
-- 20. PURCHASE ORDER QUANTITY BY SUPPLIER
-- ============================================================

SELECT
    s.supplier_name,
    COUNT(po.order_id) AS purchase_order_count,
    SUM(po.quantity_ordered) AS total_quantity_ordered
FROM purchase_orders po
JOIN products p
    ON po.product_id = p.product_id
JOIN suppliers s
    ON p.supplier_id = s.supplier_id
GROUP BY s.supplier_name
ORDER BY total_quantity_ordered DESC;


-- ============================================================
-- 21. PRODUCT PROFIT POTENTIAL
-- Difference between selling price and cost price.
-- ============================================================

SELECT
    p.product_id,
    p.product_name,
    c.category_name,
    p.cost_price,
    p.selling_price,
    p.selling_price - p.cost_price AS profit_per_unit
FROM products p
JOIN categories c
    ON p.category_id = c.category_id
ORDER BY profit_per_unit DESC;


-- ============================================================
-- 22. POTENTIAL GROSS PROFIT FROM CURRENT INVENTORY
-- ============================================================

WITH product_stock AS (
    SELECT
        p.product_id,
        p.product_name,
        p.cost_price,
        p.selling_price,
        COALESCE(SUM(
            CASE
                WHEN it.transaction_type = 'IN' THEN it.quantity
                WHEN it.transaction_type = 'OUT' THEN -it.quantity
                ELSE 0
            END
        ), 0) AS current_stock
    FROM products p
    LEFT JOIN inventory_transactions it
        ON p.product_id = it.product_id
    GROUP BY
        p.product_id,
        p.product_name,
        p.cost_price,
        p.selling_price
)

SELECT
    product_id,
    product_name,
    current_stock,
    cost_price,
    selling_price,
    current_stock * (selling_price - cost_price)
        AS potential_gross_profit
FROM product_stock
ORDER BY potential_gross_profit DESC;


-- ============================================================
-- 23. CATEGORY PROFIT POTENTIAL
-- ============================================================

WITH product_stock AS (
    SELECT
        p.product_id,
        p.category_id,
        p.cost_price,
        p.selling_price,
        COALESCE(SUM(
            CASE
                WHEN it.transaction_type = 'IN' THEN it.quantity
                WHEN it.transaction_type = 'OUT' THEN -it.quantity
                ELSE 0
            END
        ), 0) AS current_stock
    FROM products p
    LEFT JOIN inventory_transactions it
        ON p.product_id = it.product_id
    GROUP BY
        p.product_id,
        p.category_id,
        p.cost_price,
        p.selling_price
)

SELECT
    c.category_name,
    SUM(ps.current_stock * ps.cost_price) AS inventory_cost_value,
    SUM(ps.current_stock * ps.selling_price) AS potential_sales_value,
    SUM(
        ps.current_stock * (ps.selling_price - ps.cost_price)
    ) AS potential_gross_profit
FROM product_stock ps
JOIN categories c
    ON ps.category_id = c.category_id
GROUP BY c.category_name
ORDER BY potential_gross_profit DESC;


-- ============================================================
-- 24. EXECUTIVE INVENTORY KPIs
-- ============================================================

WITH product_stock AS (
    SELECT
        p.product_id,
        p.reorder_level,
        p.maximum_stock,
        p.cost_price,
        p.selling_price,
        COALESCE(SUM(
            CASE
                WHEN it.transaction_type = 'IN' THEN it.quantity
                WHEN it.transaction_type = 'OUT' THEN -it.quantity
                ELSE 0
            END
        ), 0) AS current_stock
    FROM products p
    LEFT JOIN inventory_transactions it
        ON p.product_id = it.product_id
    GROUP BY
        p.product_id,
        p.reorder_level,
        p.maximum_stock,
        p.cost_price,
        p.selling_price
)

SELECT
    COUNT(*) AS total_products,
    SUM(current_stock) AS total_units_in_stock,
    SUM(current_stock * cost_price) AS total_inventory_value,
    SUM(current_stock * selling_price) AS total_potential_sales_value,
    SUM(
        current_stock * (selling_price - cost_price)
    ) AS total_potential_gross_profit,
    COUNT(*) FILTER (
        WHERE current_stock <= reorder_level
    ) AS low_stock_products,
    COUNT(*) FILTER (
        WHERE current_stock >= maximum_stock
    ) AS fully_stocked_products
FROM product_stock;


-- ============================================================
-- 25. CATEGORY INVENTORY HEALTH
-- ============================================================

WITH product_stock AS (
    SELECT
        p.product_id,
        p.category_id,
        p.reorder_level,
        p.maximum_stock,
        COALESCE(SUM(
            CASE
                WHEN it.transaction_type = 'IN' THEN it.quantity
                WHEN it.transaction_type = 'OUT' THEN -it.quantity
                ELSE 0
            END
        ), 0) AS current_stock
    FROM products p
    LEFT JOIN inventory_transactions it
        ON p.product_id = it.product_id
    GROUP BY
        p.product_id,
        p.category_id,
        p.reorder_level,
        p.maximum_stock
)

SELECT
    c.category_name,
    COUNT(*) AS total_products,
    COUNT(*) FILTER (
        WHERE ps.current_stock <= ps.reorder_level
    ) AS low_stock_products,
    COUNT(*) FILTER (
        WHERE ps.current_stock > ps.reorder_level
        AND ps.current_stock < ps.maximum_stock
    ) AS healthy_products,
    COUNT(*) FILTER (
        WHERE ps.current_stock >= ps.maximum_stock
    ) AS fully_stocked_products
FROM product_stock ps
JOIN categories c
    ON ps.category_id = c.category_id
GROUP BY c.category_name
ORDER BY low_stock_products DESC;


-- ============================================================
-- 26. TOP PRODUCTS BY POTENTIAL SALES VALUE
-- ============================================================

WITH product_stock AS (
    SELECT
        p.product_id,
        p.product_name,
        p.selling_price,
        COALESCE(SUM(
            CASE
                WHEN it.transaction_type = 'IN' THEN it.quantity
                WHEN it.transaction_type = 'OUT' THEN -it.quantity
                ELSE 0
            END
        ), 0) AS current_stock
    FROM products p
    LEFT JOIN inventory_transactions it
        ON p.product_id = it.product_id
    GROUP BY
        p.product_id,
        p.product_name,
        p.selling_price
)

SELECT
    product_id,
    product_name,
    current_stock,
    selling_price,
    current_stock * selling_price AS potential_sales_value
FROM product_stock
ORDER BY potential_sales_value DESC
LIMIT 20;


-- ============================================================
-- 27. TRANSACTION VOLUME BY MONTH
-- ============================================================

SELECT
    DATE_TRUNC('month', transaction_date) AS month,
    COUNT(*) AS transaction_count,
    SUM(quantity) AS total_units_moved
FROM inventory_transactions
GROUP BY DATE_TRUNC('month', transaction_date)
ORDER BY month;


-- ============================================================
-- 28. INVENTORY IN VS OUT SUMMARY
-- ============================================================

SELECT
    transaction_type,
    COUNT(*) AS transaction_count,
    SUM(quantity) AS total_quantity
FROM inventory_transactions
GROUP BY transaction_type
ORDER BY transaction_type;


-- ============================================================
-- 29. PRODUCTS WITH NO OUTBOUND MOVEMENT
-- Useful for identifying potentially stagnant inventory.
-- ============================================================

SELECT
    p.product_id,
    p.product_name,
    c.category_name,
    s.supplier_name
FROM products p
JOIN categories c
    ON p.category_id = c.category_id
JOIN suppliers s
    ON p.supplier_id = s.supplier_id
LEFT JOIN inventory_transactions it
    ON p.product_id = it.product_id
    AND it.transaction_type = 'OUT'
GROUP BY
    p.product_id,
    p.product_name,
    c.category_name,
    s.supplier_name
HAVING COUNT(it.transaction_id) = 0
ORDER BY p.product_name;


-- ============================================================
-- 30. OVERALL INVENTORY SUMMARY BY CATEGORY
-- Combines stock, cost value and potential sales value.
-- ============================================================

WITH product_stock AS (
    SELECT
        p.product_id,
        p.category_id,
        p.cost_price,
        p.selling_price,
        COALESCE(SUM(
            CASE
                WHEN it.transaction_type = 'IN' THEN it.quantity
                WHEN it.transaction_type = 'OUT' THEN -it.quantity
                ELSE 0
            END
        ), 0) AS current_stock
    FROM products p
    LEFT JOIN inventory_transactions it
        ON p.product_id = it.product_id
    GROUP BY
        p.product_id,
        p.category_id,
        p.cost_price,
        p.selling_price
)

SELECT
    c.category_name,
    COUNT(ps.product_id) AS product_count,
    SUM(ps.current_stock) AS total_stock,
    SUM(ps.current_stock * ps.cost_price) AS inventory_value,
    SUM(ps.current_stock * ps.selling_price) AS potential_sales_value,
    SUM(
        ps.current_stock * (ps.selling_price - ps.cost_price)
    ) AS potential_gross_profit
FROM product_stock ps
JOIN categories c
    ON ps.category_id = c.category_id
GROUP BY c.category_name
ORDER BY inventory_value DESC;