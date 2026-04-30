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

{%- macro duckdb__get_semantic_view_rename_sql(relation, new_name) -%}
    /*
    Rename or move a DuckDB semantic view to the new name.

    Args:
        relation: DuckDBRelation - relation to be renamed
        new_name: Union[str, DuckDBRelation] - new name for `relation`
    Returns: templated string
    */
    alter semantic view if exists {{ relation }} rename to {{ new_name }}
{%- endmacro -%}
