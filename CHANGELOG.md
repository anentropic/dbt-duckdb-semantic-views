# Changelog

All notable changes to this package will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Changed

- Moved to DuckDB 2.0. The package now requires `duckdb == 2.0.0` and extension
  `semantic_views >= 0.17.0`. Extension `v0.15.0` onwards runs only on DuckDB 2.0,
  so stay on `v0.2.0` with extension `v0.14.x` if you need DuckDB 1.5. The CI matrix
  pins `duckdb==2.0.0` and covers `dbt-duckdb` 1.10.0 (with `dbt-core` 1.8) and 1.11.1.
- `require-dbt-version` is now `>=1.8.0`, the oldest `dbt-core` that `dbt-duckdb`
  1.10 installs with. It was `>=1.0.0`.
- From extension `v0.17.0`, `CREATE SEMANTIC VIEW` binds every table and member, so a
  model whose body names a missing table or column fails at `dbt run` instead of at
  query time.
- The README installs the package from git, since it is not on the dbt Package Hub yet.

### Added

- Integration tests for reading a semantic view downstream through `ref()`: a table
  model that queries it with standard SQL (`GROUP BY` dimensions, `AGG(metric)`,
  `WHERE` on a fact), and a test that uses the `SEMANTIC_VIEW(...)` construct.

## [0.3.0] — 2026-06-09

### Changed

- Extension floor bumped to `semantic_views >= 0.10.2`. This build targets
  `duckdb == 1.5.3` (the community-extension build is duckdb-version-specific;
  `duckdb 1.5.2` builds do not load on `1.5.3` and vice-versa). The CI matrix
  now pins `duckdb==1.5.3` so it deterministically exercises the `v0.10.2` build.
- Verified end-to-end against extension `v0.10.2` on `duckdb 1.5.3`: the
  integration suite passes on the file-backed target, `list_semantic_views()`
  is populated, and the `CREATE OR REPLACE` idempotency re-run is clean.

### Breaking

- Extension `v0.10.0` removed primary-key auto-inference from catalog
  constraints. Every `TABLES(...)` entry must now declare an explicit
  `PRIMARY KEY (...)`. Consumers who relied on implicit PK inference under
  `semantic_views v0.9.x` must add an explicit `PRIMARY KEY` to each table
  before upgrading. The materialisation macro is unchanged — this is an
  extension-grammar requirement surfaced through the floor bump.

## [0.2.0] — 2026-05-18

### Changed

- Materialisation macro now issues an explicit `{{ adapter.commit() }}` after
  the `CREATE OR REPLACE SEMANTIC VIEW` statement, mirroring dbt-core's
  standard table/view materialisation shape. Required for compatibility with
  `semantic_views` extension v0.8.0+, where semantic-view DDL became fully
  transactional rather than autocommit. Without this commit, the DDL never
  lands in the on-disk catalog and `list_semantic_views()` returns empty.
  See: <https://s-layer.github.io/duckdb-semantic-views/explanation/transactional-ddl-and-limitations.html>
- Extension floor bumped to `semantic_views >= 0.9.0`. v0.9.0 includes the
  FQN-quoting fix in catalog storage — introspection queries now resolve
  `semantic_view('name', ...)` correctly without project-level quoting
  workarounds.

### Removed

- The "Known issue: dbt-duckdb ships a duckdb pre-release" workaround
  recommendation is no longer needed. Upstream `dbt-duckdb` 1.10.1 now
  resolves `duckdb` to the latest stable (currently 1.5.2) without a forced
  pre-release pin, so `INSTALL semantic_views FROM community` works against a
  default `pip install dbt-duckdb`. The CI matrix no longer pins
  `duckdb==1.5.2` explicitly.

### Migrating from v0.1.0

Consumers who applied the project-level workaround suggested for v0.1.0:

```yaml
# dbt_project.yml
quoting:
  database: false
  schema: false
  identifier: false
```

can now remove that block entirely. The extension v0.9.0 + macro v0.2.0
combination handles FQN quoting correctly under dbt's default `quoting:`
settings.

## [0.1.0] — 2026-05-01

### Added

- Initial release.
- `semantic_view` materialisation for `dbt-duckdb` backed by the
  `duckdb-semantic-views` DuckDB extension.
- `create.sql`, `drop.sql`, `rename.sql` lifecycle macros mirroring the
  shape of `Snowflake-Labs/dbt_semantic_view`.
