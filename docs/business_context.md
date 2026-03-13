# Business Context: COVID-19 Surveillance Strategy

## Industry Background
In the Public Health and Epidemiology sector, data is the most critical weapon against outbreaks. However, during a pandemic, decision-makers often face **"Raw Data Overload"** - where different sources of data live in different systems. This fragmentation leads to huge downtime in analysis and alerting, leading to longer decision time making it impossible to act before a surge occurs. This project aims to solve this problem by providing a proactive, automated reporting and early warning surveillance system.

### **The Goal: Moving from Reactive to Proactive**
Most systems are **Reactive**: they show what happened last week.
This system is **Proactive**: it uses real-time ETL and GenAI to flag emerging risks *now*.

---

## 👥 Stakeholders & Users

| Stakeholder Persona | Strategic Need | Core Objective | Project Solution |
| :--- | :--- | :--- | :--- |
| **Executive Leadership** | Unified situational awareness and national-level risk briefings. | Make informed policy decisions and optimize large-scale resource allocation. | **GenAI Situation Room**: Automated LLM-powered briefings and alerts that convert SQL data into human strategy. |
| **Operational & Logistics Teams** | Precise data on infection velocity and population protection gaps. | Prioritize the deployment of medical supplies, oxygen, and vaccination units. | **Suggestive Alerting**: Logic-driven triggers flagging states with high positivity, low vax coverage or high fatality rates. |
| **Epidemiological Analysts** | Access to cleaned, feature-engineered datasets for deep-dive trend research. | Discover hidden transmission patterns and evaluate the efficacy of interventions. | **ETL Pipeline**: Production-grade datasets with engineered metrics like positive_test_rate, case_fatality_rate, daily_new_cases, and more.|
| **Data Governance & IT** | Automated, reliable data pipelines and high-integrity, real-time reporting. | Minimize manual reporting lag and maintain a single source of truth. | **Dockerized ETL Pipeline**: Staging to gold layers, Postgres as single source of truth(data warehouse). |


## Risk level formulated by stakeholders
A state is flagged risky, if it has `positive_test_rate` > x OR `daily_new_cases` > y OR `case_fatality_rate` > z.

For example:
x = 5, y = 1000, z = 2

And a weighted risk score is calculated for each state:
`weighted_risk_score` = (positive_test_rate * 0.4) + ((100 - vaccination_rate) * 0.3) + ((case_fatality_rate * 10) * 0.3)

for states were:
 `positive_test_rate` > x
   OR `daily_new_cases` > y 
   OR `case_fatality_rate` > z;

**Variables**: These parameters (x, y, z) can be adjusted by stakeholders to fine-tune the risk assessment and trigger alerts.

## Surveillance & Risk Assessment Questions (Excel)
To meet the risk thresholds formulated above, the system must provide stakeholders with tools to answer these core surveillance questions:

- **Infection Velocity**: "Which states are exceeding the daily new case threshold (y)?"
- **Surveillance Integrity**: "Is a rise in positivity (x) real spread or just a result of decreased testing volume?"
- **Population Vulnerability**: "Are surges happening in states with low vaccination coverage (weighted risk)?"
- **System Severity**: "Is the Case Fatality Rate (z) rising, indicating hospital saturation or new variants?"
- **Data Freshness**: "Which states have reporting lags that create critical blind spots in our risk map?"

**Output format required**: Excel Interactive Dashboard

## BI Dashboard Requirements (Power BI)
While Excel is used for surgical logic audits and suggestive alerts, the Power BI dashboard acts as the **National Situational Awareness Layer**. It converts the complex Medallion data into a high-level visual narrative for leadership.

### **Primary Visual Objectives**:
1.  **National Pulse (Executive KPIs)**: High-visibility cards showing `Total Confirmed`, `Active Cases`, `Recovery Rate %`, and `Vaccination Coverage`. This provides an immediate answer to "Where do we stand today?"
2.  **Outbreak Velocity (Trend Analysis)**: Line charts utilizing **7-Day Moving Averages** to filter out daily reporting noise and reveal the true direction of epidemic waves (Peaking vs. Receding).
3.  **Geospatial Risk Mapping**: A regional heat-map driven by the `weighted_risk_score`. This allows stakeholders to identify geographic clusters of high-risk states at a single glance.
4.  **Strategic Correlation (Impact Assessment)**: Scatter plots and bubble charts to evaluate the relationship between `vaccination_rate` and `case_fatality_rate`. This answers the critical question: "Is our vaccination strategy effectively reducing mortality?"


## Requirements & Objectives

1.  **Unified Source of Truth**: Consolidate disparate CSVs into a production-grade Medallion architecture (Postgres).
2.  **Zero-Lag Intelligence**: Automate the transformation pipeline so the latest data is always available.
3.  **Actionable Synthesis**: Use GenA to convert complex SQL metrics into qualitative situation reports.
4.  **Human-in-the-Loop**: Implement a feedback mechanism to reduce false positives and tune alert sensitivity.

---

## Problem Statement vs. Solution

### **Problem 1: Fragmented Data Quality**
*   **The Issue**: Raw data contains inconsistent date formats, misspelled state names (e.g., 'Karanataka'), and missing values.
*   **Our Solution**: A **Medallion Architecture**. We use a Bronze staging layer to prevent crashes and a Silver layer for rigorous standardization.

### **Problem 2: "Alert Fatigue"**
*   **The Issue**: If a system sends an email for every rise in cases, users eventually ignore it.
*   **Our Solution**: **Weighted Risk Scoring**. We only trigger alerts based on a combination of High Positivity + Low Vaccination, focusing attention only where it matters most.

### **Problem 3: The "So What?" Factor**
*   **The Issue**: Charts show numbers, but they don't tell you *what to do*.
*   **Our Solution**: **GenAI Strategic Assessment**. Gemini analyzes the outliers and suggests specific containment actions (e.g., "Shift oxygen supply to State X").

---

## Industry Best Practices Followed
*   **Idempotent Pipelines**: The ETL can be re-run safely at any time.
*   **Infrastructure as Code (IaC)**: The entire stack is defined in `compose.yaml` for consistency across environments.
*   **Portability**: Scripts are environment-agnostic, using dynamic path resolution.
