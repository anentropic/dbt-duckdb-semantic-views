-- Asserts that joining via RELATIONSHIPS returns per-region rollups by region_name.
with results as (
  select region_name, total_amount, order_count
  from semantic_view(
    'sem_orders_relationships',
    dimensions := ['region_name'],
    metrics := ['total_amount', 'order_count']
  )
),
expected as (
  select 'EMEA' as region_name, 690.00::decimal(10,2) as total_amount, 6 as order_count
  union all
  select 'APAC' as region_name, 800.00::decimal(10,2) as total_amount, 4 as order_count
)

select 'mismatch' as failure_reason, e.region_name, e.total_amount as expected_total, r.total_amount as actual_total, e.order_count as expected_count, r.order_count as actual_count
from expected e
left join results r on r.region_name = e.region_name
where r.region_name is null or r.total_amount != e.total_amount or r.order_count != e.order_count
