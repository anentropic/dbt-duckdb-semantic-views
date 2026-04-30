{{ config(materialized='semantic_view') }}

TABLES (
  orders AS {{ ref('raw_orders') }} PRIMARY KEY (order_id)
)
DIMENSIONS (
  orders.region_id AS region_id
)
METRICS (
  orders.total_amount AS sum(amount)
)
MATERIALIZATIONS (
  AGGREGATIONS (
    sum(amount) GROUP BY region_id
  )
)
