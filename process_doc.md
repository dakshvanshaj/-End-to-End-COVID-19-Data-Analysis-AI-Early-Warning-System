# 🚀 COVID-19 DataOps & AI Alerting Pipeline

## 1. System Architecture Overview

This project implements an end-to-end DataOps pipeline adopting a Medallion Architecture (Bronze, Silver, Gold layers). Raw heterogeneous data is processed via a robust SQL ETL pipeline into a central PostgreSQL data warehouse. This database acts as the single source of truth for two downstream systems: Power BI serves as the passive monitoring layer for historical dashboards, while n8n acts as the active monitoring layer. The n8n automation queries the data warehouse daily, evaluates complex epidemiological risk conditions, and utilizes an LLM (GenAI) to generate automated, human-readable early-warning alerts and explanations for stakeholders.

---

## 2. The ETL Pipeline: Phase-by-Phase Breakdown

### Phase 1: Bronze Layer (Ingestion)

During the construction of the ingestion layer, it was observed that flat file imports often accidentally ingest the CSV header row as actual data, which breaks downstream type-casting. To establish pipeline resilience, the staging tables were configured to accept raw `TEXT`, and defensive SQL deletion steps were applied to filter out headers before any transformations occurred.

### Phase 2: Silver Layer (Standardization)

The raw COVID datasets contained inconsistent missing values—some rows had empty strings, while others used dashes as placeholders. Direct integer casting would have resulted in pipeline failures. To handle this defensively, `NULLIF` functions were chained to catch dashes and empty strings, normalizing them into true database `NULL`s. This logic was subsequently wrapped in a `COALESCE` function to default any `NULL`s to zero, ensuring perfect data hygiene before casting to Integer types.

**Defensive Date Parsing:** To dynamically handle heterogeneous data formats from upstream CSVs without breaking the automated pipeline, conditional `CASE` logic utilizing `LIKE '%/%'` was implemented. This routed non-standard date strings through an explicit `TO_DATE()` translator while allowing ISO-standard dates to pass through a default cast, ensuring zero ingestion failures.

### Phase 3: Gold Layer (Feature Engineering & Imputation)

* **Imputation:** To handle sparse reporting days where states failed to publish testing or vaccination data, a forward-fill imputation strategy was implemented. By utilizing a cumulative `MAX()` window function partitioned by state, the last known cumulative value was carried forward. This preserved the integrity of the time-series data when joining multiple tables together.
* **Feature Engineering:** The `daily_new_cases` feature was engineered natively in the database utilizing the `LAG()` window function. By subtracting yesterday's lagged cumulative total from today's cumulative total, the daily delta was dynamically generated without the need for external processing scripts.

### Phase 4: Business Logic Integration

Rather than building the risk classification logic inside Power BI or n8n, the business rule engine (evaluating Case Fatality Rates > 2% and Positivity > 10%) was pushed down into the database layer. This ensures that the dashboard and the AI automation tool trigger off the exact same centralized definitions.

### Phase 5: Data Integrity & Deduplication

To guarantee data integrity and prevent "join fan-outs" from corrupting the final dashboards, a robust deduplication step was implemented to enforce the table grain to exactly one row per state per day. The `ROW_NUMBER()` window function, ordered by confirmed cases descending, acted as a tie-breaker to successfully filter out duplicate timeline anomalies.

---

## 3. The Automation Layer (n8n + GenAI)

Because public health officials require proactive alerting rather than just passive dashboards, an n8n workflow was designed to execute daily against the Gold Layer database. It applies algorithmic risk assessments—detecting patterns such as 3 consecutive days of rising cases combined with stalled vaccination growth.

When these risk thresholds are breached, the system constructs a targeted data payload and passes it to an LLM. The GenAI model dynamically translates the raw metrics into a concise, non-technical situation report, detailing *what is happening*, *why it is concerning*, and *what needs attention*, before routing the alert to stakeholder communication channels.

---

## 4. Pipeline Handoff (The Final Export)

After the Gold Layer aggregations and deduplication processes were complete, the final `covid_summary_clean` table was materialized and exported into a flat CSV format. This output acts as the strict hand-off point between the Data Engineering pipeline and the Data Analytics tools (Excel/Power BI), ensuring all visualizations are powered by a single, rigorously validated source of truth.