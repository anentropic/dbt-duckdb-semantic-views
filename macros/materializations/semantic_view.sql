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

{% materialization semantic_view, adapter='duckdb' -%}

    {% do duckdb_semantic_views.duckdb__create_or_replace_semantic_view() %}

    {% set target_relation = this.incorporate(type='view') %}

    {# TODO: enable persist_docs once DuckDB SemanticView is a first-class relation type #}
    {# {% do persist_docs(target_relation, model, for_columns=false) %} #}

    {% do return({'relations': [target_relation]}) %}

{%- endmaterialization %}
