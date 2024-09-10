-- DEPENDS-ON: dv_obs_bg
DROP TABLE IF EXISTS md_bg;
CREATE TABLE md_bg AS
SELECT
    -- specimen_id only ever has 1 measurement for each itemid
    -- so, we may simply collapse rows using MAX()
    MAX(subject_id) AS subject_id
    , MAX(hadm_id) AS hadm_id
    , MAX(charttime) AS charttime
    -- specimen_id *may* have different storetimes, so this
    -- is taking the latest
    , MAX(storetime) AS storetime
    , MAX(CASE WHEN itemid = 52033 THEN value ELSE NULL END) AS specimen
    , MAX(
        CASE
            WHEN itemid = 50817 AND valuenum <= 100 THEN valuenum ELSE NULL
        END
    ) AS so2
    , MAX(CASE WHEN itemid = 50818 THEN valuenum ELSE NULL END) AS pco2
FROM dv_obs_bg le
WHERE le.itemid IN
    -- blood gases
    (
        52033 -- specimen
        , 50801 -- aado2
        , 50802 -- base excess
        , 50803 -- bicarb
        , 50804 -- calc tot co2
        , 50805 -- carboxyhgb
        , 50806 -- chloride
        -- , 52390 -- chloride, WB CL-
        , 50807 -- comments
        , 50808 -- free calcium
        , 50809 -- glucose
        , 50810 -- hct
        , 50811 -- hgb
        , 50813 -- lactate
        , 50814 -- methemoglobin
        , 50815 -- o2 flow
        , 50816 -- fio2
        , 50817 -- o2 sat
        , 50818 -- pco2
        , 50819 -- peep
        , 50820 -- pH
        , 50821 -- pO2
        , 50822 -- potassium
        -- , 52408 -- potassium, WB K+
        , 50823 -- required O2
        , 50824 -- sodium
        -- , 52411 -- sodium, WB NA +
        , 50825 -- temperature
    )
GROUP BY le.specimen_id;