# Fivetran | Snowflake Hands-On Lab — Healthcare Clinical Decision Support

Welcome! In this hands-on lab you'll build part of a modern data + AI pipeline and experience the finished product end-to-end:

- **Ingest** clinical patient data from a PostgreSQL source into Snowflake using **Fivetran** *(you'll do this)*
- **Transform** the raw data into a Cortex-ready semantic layer with **dbt** *(instructor walkthrough — models already built and materialized)*
- **Analyze** the data with natural language using a **Snowflake Cortex Agent** *(you'll do this)*

The lab takes about **one hour** within a 4-hour session. The dbt project in this repo is pre-built and has already been executed — you don't run dbt yourself. The Cortex Agent is pre-configured and shared across all attendees.

---

<div style="background-color: #fff3cd; padding: 12px 16px; border-left: 6px solid #ffcc00; margin-bottom: 20px; margin-top: 10px;">
  <strong>⚠️ IMPORTANT:</strong><br>
  Before starting the lab, register for your Fivetran account at:<br>
  <strong><a href="https://fivetran-lab.web.app/">https://fivetran-lab.web.app/</a></strong>
</div>

---

## Prerequisites

- A modern web browser (Chrome, Firefox, or Edge)
- A valid email address on your company's domain (used to register for this lab — your instructor will share which domains are allowed)

---

## Getting Started

1. **Register** at [https://fivetran-lab.web.app/](https://fivetran-lab.web.app/).
2. **Check your email** for an invitation from `notifications@fivetran.com` and accept it to set your Fivetran password.
3. **Open the lab credentials page** — your instructor will share the URL and passcode during the session. Keep this tab open; you'll reference Snowflake credentials and PostgreSQL host/user/password values from it throughout.
4. **Log in to Fivetran** using the credentials from your invitation email.

---

## Step 1: Create a Fivetran Connector to Snowflake

In this step you'll create a PostgreSQL connector that syncs healthcare clinical records into your own schema inside the shared Snowflake database `HOL_DATABASE_2`.

### 1.1 Configure the PostgreSQL Source Connector

1. In Fivetran, click **+ Connector**.
2. Search for and select **Google Cloud PostgreSQL**.
3. Configure the connector using the table below — values for *host / user / password* come from your **lab credentials page**:

   | Setting | Value |
   |---|---|
   | **Destination** | `HOL_SF_HOL` (pre-configured — should already be the default) |
   | **Destination Snowflake Virtual Warehouse** | Keep default |
   | **Destination schema prefix** | `yourfirstname_yourlastname` *(lowercase, underscores only)* |
   | **Destination schema names** | Fivetran naming |
   | **Host** | From lab credentials page — pick G1 or G2 based on the first letter of your last name |
   | **Port** | `5432` |
   | **User** | From lab credentials page |
   | **Password** | From lab credentials page |
   | **Database** | `industry` *(case-sensitive)* |
   | **Authentication Method** | Connect with a username and password |
   | **Connection method** | Connect directly |
   | **Update Method** | Query-based |

4. Click **Save & Test**. Wait for the connection test to succeed.

### 1.2 Select the Data to Sync

1. The `healthcare` schema and `cds_records` table will be pre-selected for sync.
2. Click **Continue**.

### 1.3 Handle Schema Changes

1. Select **Allow all** (the default).
2. Click **Continue**.

### 1.4 Start the Initial Sync

1. On the connector Status page, click **Start Initial Sync**.
2. While the sync runs (usually under a minute), continue to step 1.5 to verify in Snowflake.

### 1.5 Verify the Data Landed in Snowflake

1. Open Snowsight using the URL on your lab credentials page.
2. Log in with the shared Snowflake lab credentials from the same page.
3. In the left nav, click **Catalog**, then click `HOL_DATABASE_2`.
4. Find your schema — it will be named `<yourfirstname>_<yourlastname>_healthcare` (lowercase).
5. Expand the schema → **Tables** → `CDS_RECORDS` → **Data Preview**.
6. Scroll to the right to see the Fivetran-added `_fivetran_synced` column.

You've just built a production-grade ingestion pipeline. Every time source data changes, Fivetran keeps Snowflake in sync — no maintenance.

---

## Step 2: Data Transformation with dbt *(Instructor Walkthrough)*

Your instructor will walk through the **pre-built** dbt project in this repo. You don't need to run dbt yourself — the models have already been executed against `HOL_DATABASE_2`, and the resulting tables and views are ready to query.

The dbt project lives at [`dbt_project/models/healthcare/`](dbt_project/models/healthcare/) and has three layers:

| Layer | Path | Materialization | Snowflake object |
|---|---|---|---|
| **Staging** — cleans + normalizes raw records | [`staging/stg_cds_records.sql`](dbt_project/models/healthcare/staging/stg_cds_records.sql) | view | `HOL_DATABASE_2.HEALTHCARE_STAGING.STG_CDS_RECORDS` |
| **Marts** — enriched fact table with business logic | [`marts/fct_clinical_decisions.sql`](dbt_project/models/healthcare/marts/fct_clinical_decisions.sql) | table | `HOL_DATABASE_2.HEALTHCARE_MARTS.FCT_CLINICAL_DECISIONS` |
| **Semantic view** — Cortex Analyst vocabulary | [`semantic/sv_clinical_decisions.sql`](dbt_project/models/healthcare/semantic/sv_clinical_decisions.sql) | semantic_view | `HOL_DATABASE_2.HEALTHCARE_SEMANTIC.CLINICAL_DECISIONS` |

The **semantic view** is what makes the Cortex Agent in Step 3 possible. It defines:

- **Facts** — numeric measures like readmission risk, patient outcome score, cost of care, medical error rate
- **Dimensions** — categorical attributes like diagnosis, treatment plan, medication adherence, readmission risk tier
- **Rich business-context comments** on every field so the agent knows what each column means

Cortex Analyst reads the semantic view and translates natural-language questions into SQL against the mart table.

### 2.1 Sample Queries (Snowsight)

While your instructor walks through the dbt project, try these queries in a Snowsight worksheet:

```sql
-- Patients flagged for clinical review
select patient_id, diagnosis, readmission_risk_level, outcome_quality, medication_adherence
from HOL_DATABASE_2.HEALTHCARE_MARTS.FCT_CLINICAL_DECISIONS
where needs_review = true
limit 20;

-- Diagnosis-level readmission patterns
select diagnosis,
       count(*) as patient_count,
       round(avg(readmission_risk), 4) as avg_readmission_risk,
       round(avg(patient_outcome_score), 4) as avg_outcome_score
from HOL_DATABASE_2.HEALTHCARE_MARTS.FCT_CLINICAL_DECISIONS
group by diagnosis
order by avg_readmission_risk desc;
```

---

## Step 3: Query the Data with a Snowflake Cortex Agent

Now the fun part — use natural language to explore the semantic layer. No SQL required.

### 3.1 Access the Cortex Agent

There are two ways in — use whichever you prefer:

- **Option A — Snowflake Intelligence:** [ai.snowflake.com](https://ai.snowflake.com)
- **Option B — Snowsight:** Log in via the URL on your lab credentials page, then navigate to **AI & ML** → **Cortex Agents**.

Look for the agent named **`CLINICAL_DECISIONS_AGENT`** and open the conversation interface.

### 3.2 Ask These Questions

The agent is tuned against the semantic view — these ten questions are the "golden path":

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

### 3.3 Explore on Your Own

Try your own questions. The agent understands clinical vocabulary because the semantic view comments explicitly teach it concepts like "High risk = above 60%", "Non-adherent is the top readmission driver", and so on. Good experiments:

- Cross-cut two dimensions (e.g. diagnosis × medication adherence)
- Filter on a threshold you care about
- Ask for a chart or visualization
- Ask "why" follow-ups

---

## Wrap-Up

In one hour you've seen:

1. **Fivetran** ingested live clinical data from PostgreSQL into Snowflake with zero pipeline code.
2. **dbt** transformed raw records into a semantic layer tuned for AI — staged views, enriched fact tables, Cortex-ready semantic view.
3. **Snowflake Cortex Agent** answered business questions in natural language by reading the semantic layer.

This is the **AI-ready data stack** — production-grade ingestion, semantic transformation, and natural language analytics in a single Snowflake account.

---

## Reference Documents

- [Cortex Agent DDL](reference_docs/agents/healthcare/create_cortex_agent.sql) — full agent specification including orchestration prompt, tool spec, and the 10 sample questions
- [dbt Project (source)](dbt_project/) — project config, sources, staging, marts, and semantic view models
- [Compiled SQL (what actually ran)](reference_docs/sql/healthcare/) — the pre-compiled DDL that was executed against `HOL_DATABASE_2` to materialize the three layers. Instructors can walk through this during Step 2 without running dbt.
- [profiles.yml.example](dbt_project/profiles.yml.example) — template for running dbt against this project (no credentials shipped)

---

## Need Help?

Ask a lab instructor for assistance.
