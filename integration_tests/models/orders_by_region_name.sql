{{ config(materialized='table') }}

-- A downstream model that reads a semantic view through ref() with standard SQL
-- (extension v0.17.0+): GROUP BY names the dimensions and AGG() wraps each metric.
-- The WHERE on a fact filters rows before aggregation.
select
  region_name,
  agg(total_amount) as total_amount,
  agg(order_count) as order_count
from {{ ref('sem_orders_relationships') }}
where line_amount > 100
group by region_name
