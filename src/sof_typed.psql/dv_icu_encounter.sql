-- DEPENDS-ON: rv_icu_encounter
CREATE OR REPLACE TEMP VIEW dv_icu_encounter AS
SELECT subject_id,
       stay_id,
       admittime::TIMESTAMPTZ AT TIME ZONE 'UTC' AS admittime,
       dischtime::TIMESTAMPTZ AT TIME ZONE 'UTC' AS dischtime
FROM rv_icu_encounter