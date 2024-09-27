-- based on: mimic-code/mimic-iv/concepts_postgres/measurement/vitalsign.sql
-- DEPENDS-ON: dv_obs_vitalsigns
DROP TABLE IF EXISTS md_vitalsigns;
CREATE TABLE md_vitalsigns AS
SELECT
    ce.subject_id
    , ce.stay_id
    , ce.charttime
    , AVG(CASE WHEN itemid IN (220045)
            AND valuenum > 0
            AND valuenum < 300
            THEN valuenum END
    ) AS heart_rate
    , AVG(CASE WHEN itemid IN (220210, 224690)
                AND valuenum > 0
                AND valuenum < 70
                THEN valuenum END
    ) AS resp_rate
    , AVG(CASE WHEN itemid IN (220277)
                AND valuenum > 0
                AND valuenum <= 100
                THEN valuenum END
    ) AS spo2
FROM dv_obs_vitalsigns ce
WHERE ce.stay_id IS NOT NULL
    AND ce.itemid IN
    (
        220045 -- Heart Rate
        , 225309 -- ART BP Systolic
        , 225310 -- ART BP Diastolic
        , 225312 -- ART BP Mean
        , 220050 -- Arterial Blood Pressure systolic
        , 220051 -- Arterial Blood Pressure diastolic
        , 220052 -- Arterial Blood Pressure mean
        , 220179 -- Non Invasive Blood Pressure systolic
        , 220180 -- Non Invasive Blood Pressure diastolic
        , 220181 -- Non Invasive Blood Pressure mean
        , 220210 -- Respiratory Rate
        , 224690 -- Respiratory Rate (Total)
        , 220277 -- SPO2, peripheral
        -- GLUCOSE, both lab and fingerstick
        , 225664 -- Glucose finger stick
        , 220621 -- Glucose (serum)
        , 226537 -- Glucose (whole blood)
        -- TEMPERATURE
        -- 226329 -- Blood Temperature CCO (C)
        , 223762 -- "Temperature Celsius"
        , 223761  -- "Temperature Fahrenheit"
        , 224642 -- Temperature Site
    )
GROUP BY ce.subject_id, ce.stay_id, ce.charttime;
