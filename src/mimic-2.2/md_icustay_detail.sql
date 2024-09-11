CREATE OR REPLACE TEMP VIEW md_icustay_detail AS
SELECT subject_id,
       stay_id,
       gender,
       CASE
           WHEN race LIKE 'ASIAN%' THEN 'ASIAN'
           WHEN race LIKE 'BLACK%' THEN 'BLACK'
           WHEN race LIKE 'WHITE%' THEN 'WHITE'
           WHEN race LIKE 'HISPANIC%' THEN 'HISPANIC'
           END AS race,
       admittime,
       dischtime,
       first_icu_stay,
       first_hosp_stay
FROM mimiciv_derived.icustay_detail;