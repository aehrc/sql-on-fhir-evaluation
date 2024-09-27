-- DEPENDS-ON: dv_icu_encounter, dv_patient
DROP TABLE IF EXISTS md_icustay_detail;
CREATE TABLE md_icustay_detail AS
WITH md_icu_encounter AS (
    SELECT *,
        row_number() over (PARTITION BY subject_id ORDER BY admittime ASC) AS icustay_seq
        FROM dv_icu_encounter
), md_patient AS (
    SELECT subject_id,
           CASE
               WHEN gender = 'male' THEN 'M'
               WHEN gender = 'female' THEN 'F'
               END AS gender,
           CASE
               WHEN race_system = 'urn:oid:2.16.840.1.113883.6.238' THEN
                   CASE
                       WHEN race_code = '2106-3' THEN
                           CASE
                               WHEN ethnicity_system = 'urn:oid:2.16.840.1.113883.6.238' AND ethnicity_code = '2135-2' THEN 'HISPANIC'
                               ELSE 'WHITE'
                               END
                       WHEN race_code = '2054-5' THEN 'BLACK'
                       WHEN race_code = '2028-9' THEN 'ASIAN'
                       END
               END AS race
    FROM dv_patient
)
SELECT
    enc.subject_id, enc.stay_id, pat.gender, pat. race, enc.admittime, enc.dischtime, enc.icustay_seq = 1 AS first_icu_stay, TRUE first_hosp_stay
FROM md_icu_encounter enc
LEFT OUTER JOIN md_patient pat ON enc.subject_id = pat.subject_id;