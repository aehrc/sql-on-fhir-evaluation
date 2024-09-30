-- DEPENDS-ON: rv_obs_vitalsigns
CREATE OR REPLACE TEMP VIEW dv_obs_vitalsigns AS
SELECT subject_id,
       stay_id,
       charttime::TIMESTAMPTZ AT TIME ZONE 'UTC' AS charttime,
       storetime::TIMESTAMPTZ AT TIME ZONE 'UTC' AS storetime,
       valuenum,
       CAST(itemid AS INTEGER) AS itemid
FROM rv_obs_vitalsigns;