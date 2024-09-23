-- DEPENDS-ON: rv_obs_o2_flow
CREATE OR REPLACE TEMP VIEW dv_obs_o2_flow AS
SELECT patient_id AS subject_id, encounter_id AS stay_id, CAST(charttime AS TIMESTAMP) as charttime, storetime, value AS o2_flow,
       CAST(code AS INTEGER) as itemid
FROM rv_obs_o2_flow;