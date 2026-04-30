{{ config(materialized='semantic_view') }}

TABLES (
  orders AS {{ ref('raw_orders') }} PRIMARY KEY (order_id),
  regions AS {{ ref('raw_regions') }} PRIMARY KEY (region_id)
)
RELATIONSHIPS (
  orders(region_id) REFERENCES regions(region_id)
)
FACTS (
  orders.amount AS amount
)
DIMENSIONS (
  regions.region_name AS region_name
)
METRICS (
  orders.total_amount AS sum(amount),
  orders.order_count AS count(order_id)
)
