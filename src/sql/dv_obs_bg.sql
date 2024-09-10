-- DEPENDS-ON: rv_obs_bg
CREATE OR REPLACE TEMP VIEW dv_obs_bg AS
SELECT patient_id AS subject_id,
       encounter_id AS hadm_id,
       CAST(charttime AS TIMESTAMP) as charttime,
       storetime,
       valuestr as value,
       value AS valuenum,
       code as itemid,
       specimen_id
FROM rv_obs_bg;