-- DEPENDS-ON: rv_obs_bg
CREATE OR REPLACE TEMP VIEW dv_obs_bg AS
SELECT subject_id,
       hadm_id,
       charttime::TIMESTAMPTZ AT TIME ZONE 'UTC'AS charttime,
       storetime::TIMESTAMPTZ AT TIME ZONE 'UTC'AS storetime,
       value,
       valuenum,
       CAST(itemid AS INTEGER) AS itemid,
       specimen_id
FROM rv_obs_bg;