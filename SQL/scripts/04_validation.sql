/*
====================================================================================
PHASE 4: DATA VALIDATION & FEEDBACK LOGS
====================================================================================
*/

DROP TABLE IF EXISTS covid_summary_clean CASCADE;
CREATE TABLE covid_summary_clean AS
SELECT 
    state, date, confirmed, deaths, cured, daily_new_cases, 
    totalsamples, positive, positive_test_rate, total_doses_administered, 
    population, vaccination_rate, case_fatality_rate,
        ROUND(
        (positive_test_rate * 0.4) + 
        ((100 - vaccination_rate) * 0.3) + 
        ((case_fatality_rate * 10) * 0.3), 2) AS weighted_risk_score 
FROM (
    SELECT *, ROW_NUMBER() OVER (PARTITION BY state, date ORDER BY confirmed DESC) AS duplicate_flag
    FROM covid_summary
) deduplicated_set
WHERE duplicate_flag = 1;

-- =================================================================================
-- PERSISTENT TABLES: Do NOT drop these, only create if they are missing.
-- =================================================================================

-- Table for Closed-Loop Alert Feedback
CREATE TABLE IF NOT EXISTS alert_feedback (
    feedback_id SERIAL PRIMARY KEY,
    state VARCHAR(100),
    alert_date DATE,
    status VARCHAR(50), -- 'Confirmed', 'False Positive'
    feedback_received_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Table for storing the latest AI intelligence report
CREATE TABLE IF NOT EXISTS latest_ai_report (
    id SERIAL PRIMARY KEY,
    report_html TEXT,
    generated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);