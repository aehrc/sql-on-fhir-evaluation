-- DEPENDS-ON: rv_icu_encounter
CREATE OR REPLACE TEMP VIEW dv_icu_encounter AS
WITH tv AS (
    SELECT
        patient_id AS subject_id,
        encounter_id AS stay_id,
        CAST(admit_date AS TIMESTAMP) icu_intime,
        CAST(disch_date  AS TIMESTAMP) icu_outtime
    FROM rv_icu_encounter)
SELECT *,
       row_number() over (PARTITION BY subject_id, stay_id ORDER BY icu_intime ASC) AS icustay_seq
FROM tv;