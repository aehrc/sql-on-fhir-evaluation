-- DEPENDS-ON: md_icustay_detail, st_ventilation
DROP TABLE IF EXISTS st_subject;
CREATE TABLE st_subject AS
WITH vent_intervention AS (
    SELECT stay_id,
        charttime  AS inttime,
        ventilation_status AS int_type,
        row_number() OVER (PARTITION BY stay_id ORDER BY charttime) AS int_sequence
    FROM st_ventilation
    WHERE ventilation_status NOT in ('None', 'SupplementalOxygen')
        AND ventilation_status IS NOT NULL
), first_vent_intervention AS (
    SELECT *
    FROM vent_intervention
    WHERE int_sequence = 1
), first_icu_stay_with_intervention AS (
    SELECT
        isd.*,
        fvi.inttime
    FROM md_icustay_detail AS isd
    LEFT OUTER JOIN first_vent_intervention AS fvi ON isd.stay_id = fvi.stay_id
    WHERE first_icu_stay AND first_hosp_stay
), stay_with_index_period AS (
    SELECT subject_id,
        stay_id,
        gender,
        race  AS race_category,
        admittime AS ip_starttime,
        GREATEST(admittime,LEAST(dischtime, inttime, admittime + interval '5 days')) AS ip_endtime
    FROM first_icu_stay_with_intervention
)
SELECT subject_id, stay_id, gender, race_category, ip_starttime, ip_endtime
FROM stay_with_index_period
WHERE race_category IS NOT NULL and (ip_endtime - ip_starttime) >= INTERVAL '12 hours';
