-- DEPENDS-ON: rv_obs_vitalsigns
CREATE OR REPLACE TEMP VIEW dv_obs_vitalsigns AS
SELECT subject_id,
       stay_id,
       CAST(charttime AS TIMESTAMP) AS charttime,
       storetime,
       valuenum,
       CAST(itemid AS INTEGER) AS itemid
FROM rv_obs_vitalsigns;