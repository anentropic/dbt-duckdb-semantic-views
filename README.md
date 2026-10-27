# dbt-duckdb-semantic-views

A dbt package that registers a `semantic_view` materialisation for [`dbt-duckdb`](https://github.com/duckdb/dbt-duckdb) backed by the [`duckdb-semantic-views`](https://github.com/s-layer/duckdb-semantic-views) DuckDB extension.

Mirrors the macro shape of [`Snowflake-Labs/dbt_semantic_view`](https://github.com/Snowflake-Labs/dbt_semantic_view) so the same dbt model body shape works on both warehouses.

## Release notes

See [CHANGELOG.md](./CHANGELOG.md) for full history.

### Unreleased

- Moves to DuckDB 2.0: requires `duckdb == 2.0.0` and extension `semantic_views >= 0.17.0`.
- Downstream models can query a semantic view through `ref()` with standard SQL or
  `SEMANTIC_VIEW(...)`.

### v0.3.0 (2026-06-09)

- Extension floor bumped to `semantic_views >= 0.10.2` (requires `duckdb == 1.5.3`).
- **Breaking:** extension `v0.10.0` removed primary-key auto-inference, so every
  `TABLES(...)` entry must now declare an explicit `PRIMARY KEY (...)`. Models that
  relied on implicit PK inference under `v0.9.x` must be updated.
- Verified end-to-end against extension `v0.10.2` on `duckdb 1.5.3` (file-backed,
  idempotent, `list_semantic_views()` populated).

### v0.2.0 (2026-05-18)

- Extension floor bumped to `semantic_views >= 0.9.0`.
- Materialisation macro now issues an explicit commit, required under extension v0.8.0+ transactional-DDL semantics.
- **Consumers can now drop the project-level `quoting: { database: false, schema: false, identifier: false }` workaround** that was suggested for v0.1.0 — extension v0.9.0 stores FQNs unquoted, so the workaround is no longer needed.

## Requirements

- `dbt-core >= 1.8.0, < 2.0.0` (tested against `1.8` and `1.12`)
- `dbt-duckdb >= 1.10.0` (tested against `1.10.0` and `1.11.1`)
- `duckdb == 2.0.0`. The `semantic_views` community-extension build is
  duckdb-version-specific, and extension `v0.15.0` onwards runs only on DuckDB 2.0.
  On DuckDB 1.5, stay on this package's `v0.2.0` with extension `v0.14.x`.
- DuckDB extension `semantic_views >= 0.17.0` (auto-installed by `dbt-duckdb` via
  `extensions:` config, see below). Verified against `v0.17.0` on `duckdb 2.0.0`.

Every `TABLES(...)` entry must declare an explicit `PRIMARY KEY (...)` (extension
`v0.10.0` removed primary-key inference), and from extension `v0.17.0` every table
and member must bind when the view is created, so the tables it references must
already exist. `ref()` makes dbt build them first.

### Known issue: dbt-duckdb 1.9.0 is not supported

`dbt-duckdb 1.9.0` deadlocks during connection initialisation against a file-backed
database when paired with a `duckdb` that carries a published `semantic_views` build.
Use `dbt-duckdb >= 1.10.0`.

## Install

The package is not on the dbt Package Hub yet. Install it from git in your project's
`packages.yml`:

```yaml
packages:
  - git: https://github.com/s-layer/dbt-duckdb-semantic-views
    revision: main
```

Then run `dbt deps`.

## Configure (profiles.yml)

The `duckdb-semantic-views` extension must be loaded by `dbt-duckdb` on connect. Add `extensions:` to your profile:

```yaml
my_project:
  target: dev
  outputs:
    dev:
      type: duckdb
      path: ./dev.duckdb
      extensions:
        - name: semantic_views
          repo: community
```

Note: the field is `repo:`, not `repository:`. dbt-duckdb installs and loads the extension automatically on first connect.

## Use in a model

```sql
-- models/sem_orders.sql
{{ config(materialized='semantic_view') }}

TABLES (
  orders AS {{ ref('stg_orders') }} PRIMARY KEY (order_id)
    COMMENT = 'Orders semantic view'
)
DIMENSIONS (
  orders.region_id AS region_id
)
METRICS (
  orders.total_amount AS sum(amount)
)
```

The first table in `TABLES(...)` must be the base/fact table; all other tables are reachable via `RELATIONSHIPS(...)`. See the [extension docs](https://s-layer.github.io/duckdb-semantic-views/) for full DDL grammar.

## How it works

The `semantic_view` materialisation wraps your model body in:

```sql
CREATE OR REPLACE SEMANTIC VIEW <relation> AS <model body>
```

and ships `drop`/`rename` lifecycle macros that map to the DuckDB extension's DDL.

## Query a semantic view downstream

Downstream models can read a semantic view through `ref()`. With extension `v0.17.0`
you can use standard SQL: `GROUP BY` names the dimensions and `AGG()` wraps each metric.

```sql
-- models/orders_by_region.sql
{{ config(materialized='table') }}

select region_id, agg(total_amount) as total_amount
from {{ ref('sem_orders') }}
group by region_id
```

The `SEMANTIC_VIEW(...)` construct works too:

```sql
select *
from SEMANTIC_VIEW(
  {{ ref('sem_orders') }}
  DIMENSIONS orders.region_id
  METRICS orders.total_amount
)
```

`SELECT *` straight from a semantic view is refused: name the dimensions and metrics
you want. See the extension docs for the full query rules.

## License

Apache-2.0. See [LICENSE](./LICENSE).
