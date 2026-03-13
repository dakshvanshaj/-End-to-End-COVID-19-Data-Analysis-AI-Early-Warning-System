/*
====================================================================================
PHASE 1: BRONZE LAYER (STAGING TABLES)
====================================================================================
*/

DROP TABLE IF EXISTS covid_19_india_staging CASCADE;
CREATE TABLE covid_19_india_staging (
    sno TEXT,
    date TEXT,
    time TEXT,
    state_unionterritory TEXT,
    confirmedindiannational TEXT,
    confirmedforeignnational TEXT,
    cured TEXT,
    deaths TEXT,
    confirmed TEXT
);

DROP TABLE IF EXISTS covid_vaccine_statewise_staging CASCADE;
CREATE TABLE covid_vaccine_statewise_staging (
    updated_on TEXT,
    state TEXT,
    total_doses_administered TEXT,
    sessions TEXT,
    sites TEXT,
    first_dose_administered TEXT,
    second_dose_administered TEXT,
    male_doses_administered TEXT,
    female_doses_administered TEXT,
    transgender_doses_administered TEXT,
    covaxin_doses_administered TEXT,
    covishield_doses_administered TEXT,
    sputnik_v_doses_administered TEXT,
    aefi TEXT,
    c_18_44_years_doses_administered TEXT,
    c_45_60_years_doses_administered TEXT,
    c_60_plus_years_doses_administered TEXT,
    c_18_44_yearsindividuals_vaccinated TEXT,
    c_45_60_yearsindividuals_vaccinated TEXT,
    c_60_plus_yearsindividuals_vaccinated TEXT,
    maleindividuals_vaccinated TEXT,
    femaleindividuals_vaccinated TEXT,
    transgenderindividuals_vaccinated TEXT,
    total_individuals_vaccinated TEXT
);

DROP TABLE IF EXISTS statewisetestingdetails_staging CASCADE;
CREATE TABLE statewisetestingdetails_staging (
    date TEXT,
    state TEXT,
    totalsamples TEXT,
    negative TEXT,
    positive TEXT
);
