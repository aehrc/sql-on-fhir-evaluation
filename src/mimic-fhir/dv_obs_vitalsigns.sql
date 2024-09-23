-- DEPENDS-ON: rv_obs_vitalsigns
CREATE OR REPLACE TEMP VIEW dv_obs_vitalsigns AS
SELECT patient_id AS subject_id, encounter_id AS stay_id, CAST(charttime AS TIMESTAMP) as charttime, storetime, value AS valuenum,
       CAST(code AS INTEGER) as itemid
FROM rv_obs_vitalsigns;