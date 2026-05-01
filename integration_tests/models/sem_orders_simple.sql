{{ config(materialized='semantic_view') }}

TABLES (
  orders AS {{ ref('raw_orders') }} PRIMARY KEY (order_id)
    COMMENT = 'Smoke test for D-08 core clauses (TABLES + DIMENSIONS + METRICS + per-clause COMMENT)'
)
DIMENSIONS (
  orders.region_id AS region_id,
  orders.order_date AS order_date
)
METRICS (
  orders.total_amount AS sum(amount),
  orders.order_count AS count(order_id)
)
