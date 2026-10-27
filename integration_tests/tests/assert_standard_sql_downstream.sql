-- Asserts that a table model built from a semantic view with standard SQL over ref()
-- has the filtered per-region rollups. Unfiltered EMEA would be 690.00 / 6, so a
-- WHERE that was dropped or applied after aggregation fails this test.
with expected as (
  select 'EMEA' as region_name, 375.00::decimal(10,2) as total_amount, 2 as order_count
  union all
  select 'APAC' as region_name, 800.00::decimal(10,2) as total_amount, 4 as order_count
),
results as (
  select region_name, total_amount, order_count from {{ ref('orders_by_region_name') }}
)

select 'mismatch' as failure_reason, coalesce(e.region_name, r.region_name) as region_name, e.total_amount as expected_total, r.total_amount as actual_total, e.order_count as expected_count, r.order_count as actual_count
from expected e
full outer join results r on r.region_name = e.region_name
where e.region_name is null or r.region_name is null or r.total_amount != e.total_amount or r.order_count != e.order_count
