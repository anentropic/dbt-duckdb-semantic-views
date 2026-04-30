-- Copyright 2026 Paul Anenotropic
-- SPDX-License-Identifier: Apache-2.0
--
-- Licensed under the Apache License, Version 2.0 (the "License");
-- you may not use this file except in compliance with the License.
-- You may obtain a copy of the License at
--
-- http://www.apache.org/licenses/LICENSE-2.0
--
-- Unless required by applicable law or agreed to in writing, software
-- distributed under the License is distributed on an "AS IS" BASIS,
-- WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
-- See the License for the specific language governing permissions and
-- limitations under the License.

{% macro duckdb__get_create_semantic_view_sql(relation, sql) -%}
{#-
--  Produce DDL that creates a DuckDB semantic view.
--
--  Args:
--  - relation: Union[DuckDBRelation, str]
--      - DuckDBRelation - required for relation.render()
--      - str - is already the rendered relation name
--  - sql: str - the model body (DDL fragments: TABLES(...) DIMENSIONS(...) METRICS(...) ...)
--  Returns:
--      A valid DDL statement which will result in a new DuckDB semantic view.
--      Note: DuckDB requires the `AS` keyword between the relation and the body
--      (Snowflake's grammar elides `AS`). See:
--      https://anentropic.github.io/duckdb-semantic-views/docs/reference/create-semantic-view.html
-#}

  create or replace semantic view {{ relation }} as
  {{ sql }}

{%- endmacro %}


{% macro duckdb__create_or_replace_semantic_view() %}
  {%- set identifier = model['alias'] -%}

  {%- set target_relation = api.Relation.create(
      identifier=identifier, schema=schema, database=database,
      type='view') -%}

  {{ run_hooks(pre_hooks) }}

  -- build model
  {% call statement('main') -%}
    {{ duckdb_semantic_views.duckdb__get_create_semantic_view_sql(target_relation, sql) }}
  {%- endcall %}

  {{ run_hooks(post_hooks) }}

  {{ return({'relations': [target_relation]}) }}

{% endmacro %}
