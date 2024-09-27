-- DEPENDS-ON: rv_icu_encounter
CREATE OR REPLACE TEMP VIEW dv_icu_encounter AS
SELECT subject_id,
       stay_id,
       CAST(admittime AS TIMESTAMP) AS admittime,
       CAST(dischtime AS TIMESTAMP) AS dischtime
FROM rv_icu_encounter