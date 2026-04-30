# dbt-duckdb-semantic-views

A dbt package that registers a `semantic_view` materialisation for [`dbt-duckdb`](https://github.com/duckdb/dbt-duckdb) backed by the [`duckdb-semantic-views`](https://github.com/anentropic/duckdb-semantic-views) DuckDB extension.

Mirrors the macro shape of [`Snowflake-Labs/dbt_semantic_view`](https://github.com/Snowflake-Labs/dbt_semantic_view) so the same dbt model body shape works on both warehouses.

## Requirements

- `dbt-core >= 1.0.0, < 2.0.0`
- `dbt-duckdb >= 1.9.0` (tested against `1.10.1`)
- DuckDB extension `semantic_views >= 0.7.1` (auto-installed by `dbt-duckdb` via `extensions:` config — see below)
- A **stable** `duckdb` Python package (e.g. `duckdb==1.5.2`) — see "Known issue" below

### Known issue: dbt-duckdb ships a duckdb pre-release

At the time of v0.1.0 release, `dbt-duckdb` 1.9.x and 1.10.x both pin a `duckdb` pre-release (`1.6.0.devN`). The DuckDB community-extensions build matrix only publishes binaries for **stable** duckdb releases, so `INSTALL semantic_views FROM community` fails with HTTP 404 against the dev pre-release.

Workaround: pin a stable `duckdb` version alongside `dbt-duckdb` in your project. For example, in your `pyproject.toml` or `requirements.txt`:

```
dbt-duckdb>=1.9.0
duckdb==1.5.2
```

dbt-duckdb tolerates a co-installed stable duckdb. This package's CI matrix exercises this configuration.

When upstream dbt-duckdb starts shipping with a stable duckdb again, the explicit `duckdb` pin can be removed.

## Install

Add to your project's `packages.yml`:

```yaml
packages:
  - package: anentropic/duckdb_semantic_views
    version: 0.1.0
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
)
DIMENSIONS (
  orders.region_id AS region_id
)
METRICS (
  orders.total_amount AS sum(amount)
)
COMMENT = 'Orders semantic view'
```

The first table in `TABLES(...)` must be the base/fact table; all other tables are reachable via `RELATIONSHIPS(...)`. See the [extension docs](https://anentropic.github.io/duckdb-semantic-views/) for full DDL grammar.

## How it works

The `semantic_view` materialisation wraps your model body in:

```sql
CREATE OR REPLACE SEMANTIC VIEW <relation> AS <model body>
```

and ships `drop`/`rename` lifecycle macros that map to the DuckDB extension's DDL.

## License

Apache-2.0. See [LICENSE](./LICENSE).
