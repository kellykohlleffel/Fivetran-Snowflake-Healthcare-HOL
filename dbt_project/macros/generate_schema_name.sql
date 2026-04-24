{#
  Override dbt's default generate_schema_name to return the model-level
  +schema override as-is, without prefixing with the profile's schema.

  Default behavior: profile_schema + "_" + custom_schema
    e.g. healthcare_staging_healthcare_marts
  Desired behavior: custom_schema only
    e.g. healthcare_marts

  This keeps a single dbt project organized across many HOL runs without
  producing doubled-up schema names in Snowflake.
#}
{% macro generate_schema_name(custom_schema_name, node) -%}
    {%- if custom_schema_name is none -%}
        {{ target.schema | trim }}
    {%- else -%}
        {{ custom_schema_name | trim }}
    {%- endif -%}
{%- endmacro %}
