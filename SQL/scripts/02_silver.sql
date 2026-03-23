/*
====================================================================================
PHASE 2: SILVER LAYER (CLEANING & STANDARDIZATION)
====================================================================================
*/

-- 1. Remove Headers (Defensive check in case ingestion didn't skip them)
DELETE FROM covid_19_india_staging WHERE date = 'Date' OR date = 'date';
DELETE FROM statewisetestingdetails_staging WHERE date = 'Date' OR date = 'date';
DELETE FROM covid_vaccine_statewise_staging WHERE updated_on = 'Updated On' OR updated_on = 'updated_on';

-- 2. Clean Cases Data
DROP TABLE IF EXISTS silver_cases CASCADE;
CREATE TABLE silver_cases AS
SELECT 
    CASE 
        WHEN TRIM(state_unionterritory) = 'Karanataka' THEN 'Karnataka'
        WHEN TRIM(state_unionterritory) = 'Himanchal Pradesh' THEN 'Himachal Pradesh'
        WHEN TRIM(state_unionterritory) = 'Telengana' THEN 'Telangana'
        WHEN TRIM(state_unionterritory) LIKE 'Bihar%' THEN 'Bihar'
        WHEN TRIM(state_unionterritory) LIKE 'Madhya Pradesh%' THEN 'Madhya Pradesh'
        WHEN TRIM(state_unionterritory) LIKE 'Maharashtra%' THEN 'Maharashtra'
        WHEN TRIM(state_unionterritory) IN ('Dadra and Nagar Haveli', 'Daman & Diu') 
             THEN 'Dadra and Nagar Haveli and Daman and Diu'
        ELSE TRIM(state_unionterritory)
    END AS state,
    CASE 
        WHEN date LIKE '%/%' THEN TO_DATE(date, 'MM/DD/YYYY')
        WHEN date LIKE '%-%' THEN date::DATE
        ELSE NULL
    END AS record_date,
    COALESCE(NULLIF(NULLIF(confirmedindiannational, '-'), ''), '0')::INT + 
    COALESCE(NULLIF(NULLIF(confirmedforeignnational, '-'), ''), '0')::INT AS total_confirmed,
    COALESCE(NULLIF(NULLIF(cured, '-'), ''), '0')::INT AS cured,
    COALESCE(NULLIF(NULLIF(deaths, '-'), ''), '0')::INT AS deaths,
    COALESCE(NULLIF(NULLIF(confirmed, '-'), ''), '0')::INT AS confirmed
FROM covid_19_india_staging
WHERE state_unionterritory NOT IN ('Cases being reassigned to states', 'Unassigned');

-- 3. Clean Testing Data
DROP TABLE IF EXISTS silver_testing CASCADE;
CREATE TABLE silver_testing AS
SELECT
    TRIM(state) AS state,
    CASE 
        WHEN date LIKE '%/%' THEN TO_DATE(date, 'MM/DD/YYYY')
        WHEN date LIKE '%-%' THEN date::DATE
        ELSE NULL
    END AS record_date,
    COALESCE(NULLIF(NULLIF(TRIM(totalsamples), '-'), ''), '0')::NUMERIC::BIGINT AS totalsamples,
    COALESCE(NULLIF(NULLIF(TRIM(positive), '-'), ''), '0')::NUMERIC::BIGINT AS positive
FROM statewisetestingdetails_staging;

-- 4. Clean Vaccine Data
DROP TABLE IF EXISTS silver_vaccines CASCADE;
CREATE TABLE silver_vaccines AS
SELECT
    TRIM(state) AS state,
    CASE 
        WHEN updated_on LIKE '%/%' THEN TO_DATE(updated_on, 'DD/MM/YYYY')
        WHEN updated_on LIKE '%-%' THEN updated_on::DATE
        ELSE NULL
    END AS record_date,
    COALESCE(NULLIF(NULLIF(TRIM(sessions), '-'), ''), '0')::NUMERIC::BIGINT AS sessions,
    COALESCE(NULLIF(NULLIF(TRIM(sites), '-'), ''), '0')::NUMERIC::BIGINT AS sites,
    COALESCE(NULLIF(NULLIF(TRIM(total_doses_administered), '-'), ''), '0')::NUMERIC::BIGINT AS total_doses,
    COALESCE(NULLIF(NULLIF(TRIM(first_dose_administered), '-'), ''), '0')::NUMERIC::BIGINT AS first_dose,
    COALESCE(NULLIF(NULLIF(TRIM(second_dose_administered), '-'), ''), '0')::NUMERIC::BIGINT AS second_dose,
    COALESCE(NULLIF(NULLIF(TRIM(male_doses_administered), '-'), ''), '0')::NUMERIC::BIGINT AS male_doses,
    COALESCE(NULLIF(NULLIF(TRIM(female_doses_administered), '-'), ''), '0')::NUMERIC::BIGINT AS female_doses,
    COALESCE(NULLIF(NULLIF(TRIM(transgender_doses_administered), '-'), ''), '0')::NUMERIC::BIGINT AS transgender_doses,
    COALESCE(NULLIF(NULLIF(TRIM(covaxin_doses_administered), '-'), ''), '0')::NUMERIC::BIGINT AS covaxin_doses,
    COALESCE(NULLIF(NULLIF(TRIM(covishield_doses_administered), '-'), ''), '0')::NUMERIC::BIGINT AS covishield_doses,
    COALESCE(NULLIF(NULLIF(TRIM(sputnik_v_doses_administered), '-'), ''), '0')::NUMERIC::BIGINT AS sputnik_v_doses,
    COALESCE(NULLIF(NULLIF(TRIM(aefi), '-'), ''), '0')::NUMERIC::BIGINT AS aefi,
    COALESCE(NULLIF(NULLIF(TRIM(c_18_44_years_doses_administered), '-'), ''), '0')::NUMERIC::BIGINT AS doses_18_44,
    COALESCE(NULLIF(NULLIF(TRIM(c_45_60_years_doses_administered), '-'), ''), '0')::NUMERIC::BIGINT AS doses_45_60,
    COALESCE(NULLIF(NULLIF(TRIM(c_60_plus_years_doses_administered), '-'), ''), '0')::NUMERIC::BIGINT AS doses_60_plus,
    COALESCE(NULLIF(NULLIF(TRIM(c_18_44_yearsindividuals_vaccinated), '-'), ''), '0')::NUMERIC::BIGINT AS ind_vax_18_44,
    COALESCE(NULLIF(NULLIF(TRIM(c_45_60_yearsindividuals_vaccinated), '-'), ''), '0')::NUMERIC::BIGINT AS ind_vax_45_60,
    COALESCE(NULLIF(NULLIF(TRIM(c_60_plus_yearsindividuals_vaccinated), '-'), ''), '0')::NUMERIC::BIGINT AS ind_vax_60_plus,
    COALESCE(NULLIF(NULLIF(TRIM(maleindividuals_vaccinated), '-'), ''), '0')::NUMERIC::BIGINT AS male_ind_vax,
    COALESCE(NULLIF(NULLIF(TRIM(femaleindividuals_vaccinated), '-'), ''), '0')::NUMERIC::BIGINT AS female_ind_vax,
    COALESCE(NULLIF(NULLIF(TRIM(transgenderindividuals_vaccinated), '-'), ''), '0')::NUMERIC::BIGINT AS transgender_ind_vax,
    COALESCE(NULLIF(NULLIF(TRIM(total_individuals_vaccinated), '-'), ''), '0')::NUMERIC::BIGINT AS total_ind_vax
FROM covid_vaccine_statewise_staging
WHERE TRIM(state) != 'India';

-- 5. Add Indexes for Joining Performance
CREATE INDEX idx_silver_cases_state_date ON silver_cases (state, record_date);
CREATE INDEX idx_silver_testing_state_date ON silver_testing (state, record_date);
CREATE INDEX idx_silver_vaccines_state_date ON silver_vaccines (state, record_date);
