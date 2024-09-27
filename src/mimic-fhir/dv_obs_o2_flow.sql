-- DEPENDS-ON: rv_obs_o2_flow
CREATE OR REPLACE TEMP VIEW dv_obs_o2_flow AS
SELECT subject_id,
        stay_id,
        CAST(charttime AS TIMESTAMP) AS charttime,
        storetime,
        valuenum,
        CAST(itemid AS INTEGER) AS itemid
FROM rv_obs_o2_flow;