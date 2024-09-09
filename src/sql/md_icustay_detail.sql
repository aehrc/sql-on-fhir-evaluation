-- DEPENDS-ON: dv_icu_encounter, dv_patient
CREATE OR REPLACE TEMP VIEW md_icustay_detail AS
SELECT
    enc.subject_id, enc.stay_id, pat.gender, pat. race, enc.icu_intime AS admittime, enc.icu_outtime AS dischtime, enc.icustay_seq = 1 AS first_icu_stay, TRUE first_hosp_stay
FROM dv_icu_encounter enc
LEFT OUTER JOIN dv_patient pat ON enc.subject_id = pat.subject_id;