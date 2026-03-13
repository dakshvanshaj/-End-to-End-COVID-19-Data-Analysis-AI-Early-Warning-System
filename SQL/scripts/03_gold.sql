/*
====================================================================================
PHASE 3: GOLD LAYER (INTEGRATION & FEATURE ENGINEERING)
====================================================================================
*/

-- Add population for each state as a feature
DROP TABLE IF EXISTS dim_state_population CASCADE;
CREATE TABLE dim_state_population (state VARCHAR(100), population BIGINT);
INSERT INTO dim_state_population (state, population) VALUES
('Andaman and Nicobar Islands', 380581), ('Andhra Pradesh', 49577103), ('Arunachal Pradesh', 1504000),
('Assam', 35607039), ('Bihar', 124799926), ('Chandigarh', 1158473), ('Chhattisgarh', 29436231),
('Dadra and Nagar Haveli and Daman and Diu', 586956), ('Delhi', 19814000), ('Goa', 1586250),
('Gujarat', 67936000), ('Haryana', 29260000), ('Himachal Pradesh', 7400000), ('Jammu and Kashmir', 13800000),
('Jharkhand', 38593948), ('Karnataka', 69144000), ('Kerala', 35699443), ('Ladakh', 293000),
('Lakshadweep', 64473), ('Madhya Pradesh', 85358965), ('Maharashtra', 123144223), ('Manipur', 3070000),
('Meghalaya', 3366710), ('Mizoram', 1239244), ('Nagaland', 2249695), ('Odisha', 46356334),
('Punjab', 30141373), ('Rajasthan', 81032689), ('Sikkim', 690251), ('Tamil Nadu', 77841267),
('Telangana', 35003674), ('Tripura', 4169794), ('Uttar Pradesh', 241066874), ('Uttarakhand', 11840895),
('West Bengal', 99609303), ('Puducherry', 1549000);



DROP TABLE IF EXISTS covid_summary CASCADE;
CREATE TABLE covid_summary AS
WITH engineered_cases AS (
    SELECT 
        state,
        record_date,
        confirmed,
        deaths,
        cured,
        confirmed - LAG(confirmed, 1, 0) OVER (PARTITION BY state ORDER BY record_date) AS daily_new_cases
    FROM silver_cases
),
joined_data AS (
    SELECT 
        c.state,
        c.record_date AS date,
        c.confirmed,
        c.deaths,
        c.cured,
        c.daily_new_cases,
        MAX(t.totalsamples) OVER (PARTITION BY c.state ORDER BY c.record_date 
            ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS totalsamples,
        MAX(t.positive) OVER (PARTITION BY c.state ORDER BY c.record_date 
            ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS positive,
        MAX(v.total_doses) OVER (PARTITION BY c.state ORDER BY c.record_date 
            ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS total_doses_administered,
        p.population
    FROM engineered_cases c
    LEFT JOIN silver_testing t ON c.state = t.state AND c.record_date = t.record_date
    LEFT JOIN silver_vaccines v ON c.state = v.state AND c.record_date = v.record_date
    LEFT JOIN dim_state_population p ON c.state = p.state
)
SELECT 
    state,
    date,
    confirmed,
    deaths,
    cured,
    daily_new_cases,
    totalsamples,
    positive,
    total_doses_administered,
    population,
    CASE WHEN confirmed > 0 THEN ROUND((deaths::DECIMAL / confirmed) * 100, 2) ELSE 0 END AS case_fatality_rate,
    CASE WHEN totalsamples > 0 THEN ROUND((positive::DECIMAL / totalsamples) * 100, 2) ELSE 0 END AS positive_test_rate,
    CASE WHEN population > 0 THEN ROUND((total_doses_administered::DECIMAL / population) * 100, 2) ELSE 0 END AS vaccination_rate

FROM joined_data;


-- Weighted Risk Score and Critical Alerts View
DROP VIEW IF EXISTS v_critical_alerts;
CREATE VIEW v_critical_alerts AS
SELECT 
    state,
    date,
    daily_new_cases,
    positive_test_rate,
    vaccination_rate,
    case_fatality_rate,
    -- Weighted Risk Score logic
    ROUND(
        (positive_test_rate * 0.4) + 
        ((100 - vaccination_rate) * 0.3) + 
        ((case_fatality_rate * 10) * 0.3), 
    2) AS weighted_risk_score
FROM covid_summary
-- we can modify this according to stakholders interest
WHERE positive_test_rate > 5 OR daily_new_cases > 1000 OR case_fatality_rate > 2;

