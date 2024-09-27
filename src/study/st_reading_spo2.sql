-- DEPENDS-ON: st_subject, md_vitalsigns
CREATE OR REPLACE TEMP VIEW st_reading_spo2 AS
SELECT sbj.subject_id,
    vs.charttime as chart_time,
    vs.spo2
FROM st_subject AS sbj
JOIN md_vitalsigns AS vs ON  sbj.stay_id = vs.stay_id
WHERE vs.charttime BETWEEN sbj.ip_starttime AND sbj.ip_endtime
    AND vs.spo2 IS NOT NULL