-- DEPENDS-ON: rv_patient
CREATE OR REPLACE TEMP VIEW dv_patient AS
SELECT subject_id,
       gender,
       race_system,
       race_code,
       ethnicity_system,
       ethnicity_code
FROM rv_patient;