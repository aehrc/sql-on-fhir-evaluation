-- DEPENDS-ON: rv_obs_bg
CREATE OR REPLACE TEMP VIEW dv_obs_bg AS
SELECT subject_id,
       hadm_id,
       CAST(charttime AS TIMESTAMP) AS charttime,
       storetime,
       value,
       valuenum,
       CAST(itemid AS INTEGER) AS itemid,
       specimen_id
FROM rv_obs_bg;