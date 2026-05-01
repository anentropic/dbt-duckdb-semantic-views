-- Asserts that semantic_view('sem_orders_simple', ...) returns the expected aggregates.
-- Per dbt singular test convention: any rows returned == failure.
-- depends_on: {{ ref('sem_orders_simple') }}

with results as (
  select region_id, total_amount, order_count
  from semantic_view(
    '{{ target.database }}.{{ target.schema }}.sem_orders_simple',
    dimensions := ['region_id'],
    metrics := ['total_amount', 'order_count']
  )
),
expected as (
  select 1 as region_id, 690.00::decimal(10,2) as total_amount, 6 as order_count
  union all
  select 2 as region_id, 800.00::decimal(10,2) as total_amount, 4 as order_count
)

select 'mismatch' as failure_reason, e.region_id, e.total_amount as expected_total, r.total_amount as actual_total, e.order_count as expected_count, r.order_count as actual_count
from expected e
left join results r on r.region_id = e.region_id
where r.region_id is null or r.total_amount != e.total_amount or r.order_count != e.order_count
