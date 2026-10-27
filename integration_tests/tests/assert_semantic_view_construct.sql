-- Asserts that the SEMANTIC_VIEW(...) query construct (extension v0.16.0+) accepts the
-- quoted three-part name ref() renders, and that its WHERE filters before aggregation.
with expected as (
  select 'EMEA' as region_name, 375.00::decimal(10,2) as total_amount, 2 as order_count
  union all
  select 'APAC' as region_name, 800.00::decimal(10,2) as total_amount, 4 as order_count
),
results as (
  select region_name, total_amount, order_count
  from SEMANTIC_VIEW(
    {{ ref('sem_orders_relationships') }}
    DIMENSIONS regions.region_name
    METRICS orders.total_amount, orders.order_count
    WHERE orders.line_amount > 100
  )
)

select 'mismatch' as failure_reason, coalesce(e.region_name, r.region_name) as region_name, e.total_amount as expected_total, r.total_amount as actual_total, e.order_count as expected_count, r.order_count as actual_count
from expected e
full outer join results r on r.region_name = e.region_name
where e.region_name is null or r.region_name is null or r.total_amount != e.total_amount or r.order_count != e.order_count
