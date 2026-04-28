# Clinical Decision Support — Snowflake Cortex Agent

Reference DDL for the healthcare Cortex Agent used in the Fivetran + Snowflake Healthcare HOL. The agent helps clinicians and analysts identify high-readmission-risk patients, optimize treatment outcomes, reduce medical errors, and monitor medication adherence.

## Files

| File | Purpose |
|------|---------|
| [create_cortex_agent.sql](create_cortex_agent.sql) | `CREATE OR REPLACE AGENT` DDL with full agent specification |

## Agent at a glance

| Attribute | Value |
|-----------|-------|
| Agent name | `CLINICAL_DECISIONS_AGENT` |
| Display name | Clinical Decision Support Analyst |
| Database | `HOL_DATABASE_2` |
| Schema | `HEALTHCARE_SEMANTIC` |
| Backing semantic view | `SV_CLINICAL_DECISIONS` |
| Orchestration model | `auto` |
| Budget | 900s / 400,000 tokens |
| Tool | `query_clinical_data` (Cortex Analyst text-to-SQL) |

## Prerequisites

1. **Healthcare data loaded** — Fivetran has synced the source healthcare dataset into the bronze layer.
2. **dbt project run** — silver and gold layers exist in `HEALTHCARE_SEMANTIC`.
3. **Semantic view created** — `SV_CLINICAL_DECISIONS` exists and is queryable by the lab role.
4. **Permissions** — the role running the DDL has `CREATE AGENT` on the schema and `USAGE` on the semantic view.

## Deploy

Run the DDL in Snowsight (or via `snow sql`) as a role with the privileges above:

```sql
-- from this directory
!source create_cortex_agent.sql
```

Or paste the contents of `create_cortex_agent.sql` directly into a Snowsight worksheet and execute.

To grant the lab role access:

```sql
GRANT USAGE ON AGENT HOL_DATABASE_2.HEALTHCARE_SEMANTIC.CLINICAL_DECISIONS_AGENT
  TO ROLE <lab_role>;
```

## How the agent decides what to do

The orchestration prompt routes **all** patient / diagnosis / treatment / readmission / cost / medication questions to the single `query_clinical_data` tool, which is a Cortex Analyst text-to-SQL tool bound to the semantic view.

### Key thresholds the agent applies

| Metric | Threshold | Meaning |
|--------|-----------|---------|
| Readmission risk | `> 0.6` | High — needs proactive discharge planning |
| Patient outcome score | `< 0.4` | Poor — review treatment protocol |
| Medical error rate | `> 0.08` | Concerning — systemic review needed |
| Medication adherence | `Non-Adherent` | Top driver of readmission |

### Key dimensions

- **Diagnosis** — Kidney Disease, Stroke, Asthma, Diabetes, Heart Disease, Cancer, etc.
- **Readmission risk level** — Low (<30%), Medium (30–60%), High (>60%)
- **Outcome quality** — Good (>0.7), Fair (0.4–0.7), Poor (<0.4)
- **Medication adherence** — Adherent, Partially Adherent, Non-Adherent

### Response guardrails

- Tone is clinical and precise; patient safety is paramount.
- Responses lead with patient count and risk level and always include adherence status.
- The agent **does not** provide specific treatment recommendations — it is an analytics agent, not a clinical advice tool.
- Non-adherent patients with high readmission risk are flagged as priority cases.

## Sample questions

These are wired into the agent spec and surfaced in the Snowsight UI:

1. Which patients have the highest readmission risk?
2. What is the average outcome score by diagnosis?
3. Show me non-adherent patients with high readmission risk.
4. Compare treatment outcomes across treatment plans.
5. Which diagnoses have the highest medical error rates?
6. What is the cost of care by diagnosis and outcome quality?
7. How many patients need clinical review?
8. Show me the relationship between length of stay and readmission risk.
9. Compare medication adherence across diagnoses.
10. Which patients have poor outcomes and high costs?

## Testing the agent

In Snowsight → **AI & ML → Agents**, open `CLINICAL_DECISIONS_AGENT` and run any of the sample questions. Verify that:

- The agent calls `query_clinical_data` (visible in the trace).
- Returned SQL targets `SV_CLINICAL_DECISIONS`.
- Results include the dimensions and thresholds documented above.

For the HOL handoff, the `run_attendee_e2e_test` builder tool also validates that exactly one Cortex Agent is visible to the lab role and that semantic-view row counts match expectations.

## Modifying the agent

Edit `create_cortex_agent.sql` and re-run it — `CREATE OR REPLACE AGENT` is idempotent. Common changes:

- **Thresholds** — adjust the values in the `instructions.orchestration` block.
- **Sample questions** — add or remove entries under `sample_questions`.
- **Tool budget** — tune `orchestration.budget` (`seconds`, `tokens`).
- **Warehouse** — set `tool_resources.query_clinical_data.execution_environment.warehouse` to a specific warehouse name to override the default.

## Notes

- This file contains **no PII and no credentials**. Database, schema, and view names are HOL placeholders.
- The agent is read-only — it issues SELECT-style queries via Cortex Analyst against the semantic view.
- For the broader lab flow (source → move → transform → agent → activate), see the repo root [README.md](../../../README.md).
