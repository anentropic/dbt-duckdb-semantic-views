# dbt-duckdb-semantic-views

A dbt package that registers a `semantic_view` materialisation for [`dbt-duckdb`](https://github.com/duckdb/dbt-duckdb) backed by the [`duckdb-semantic-views`](https://github.com/anentropic/duckdb-semantic-views) DuckDB extension.

Mirrors the macro shape of [`Snowflake-Labs/dbt_semantic_view`](https://github.com/Snowflake-Labs/dbt_semantic_view) so the same dbt model body shape works on both warehouses.

## Release notes

See [CHANGELOG.md](./CHANGELOG.md) for full history.

### v0.2.0 (2026-05-18)

- Extension floor bumped to `semantic_views >= 0.9.0`.
- Materialisation macro now issues an explicit commit, required under extension v0.8.0+ transactional-DDL semantics.
- **Consumers can now drop the project-level `quoting: { database: false, schema: false, identifier: false }` workaround** that was suggested for v0.1.0 — extension v0.9.0 stores FQNs unquoted, so the workaround is no longer needed.

## Requirements

- `dbt-core >= 1.0.0, < 2.0.0`
- `dbt-duckdb >= 1.10.0` (tested against `1.10.0` and `1.10.1`)
- DuckDB extension `semantic_views >= 0.9.0` (auto-installed by `dbt-duckdb` via `extensions:` config — see below). Verified against `v0.10.2` on `duckdb==1.5.3`.

> **Note on `v0.10.0+`:** extension `v0.10.0` removed primary-key auto-inference from
> catalog constraints — you must declare `PRIMARY KEY (...)` explicitly in every
> `TABLES(...)` entry (as the example below does). Models that relied on implicit
> PK inference under `v0.9.x` must add an explicit `PRIMARY KEY`.

### Known issue: dbt-duckdb 1.9.0 is not supported

The originally-intended floor of `dbt-duckdb >= 1.9.0` was dropped during v0.1.0 hardening. `dbt-duckdb 1.9.0` deadlocks during connection initialisation against a file-backed database when paired with the stable `duckdb` that carries a published `semantic_views` community-extension build. `dbt-duckdb >= 1.10.0` works correctly. (As of 2026-06, `dbt-duckdb 1.10.x` resolves `duckdb==1.5.3`, which carries the extension `v0.10.2` build; the earlier `duckdb==1.5.2` build is also still supported.)

## Install

Add to your project's `packages.yml`:

```yaml
packages:
  - package: anentropic/duckdb_semantic_views
    version: 0.2.0
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

The first table in `TABLES(...)` must be the base/fact table; all other tables are reachable via `RELATIONSHIPS(...)`. See the [extension docs](https://anentropic.github.io/duckdb-semantic-views/) for full DDL grammar.

## How it works

The `semantic_view` materialisation wraps your model body in:

```sql
CREATE OR REPLACE SEMANTIC VIEW <relation> AS <model body>
```

and ships `drop`/`rename` lifecycle macros that map to the DuckDB extension's DDL.

## License

Apache-2.0. See [LICENSE](./LICENSE).
