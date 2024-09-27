-- DEPENDS-ON: st_subject, md_vitalsigns
CREATE OR REPLACE TEMP VIEW st_reading_spo2 AS
SELECT pwr.subject_id, vs.charttime as chart_time, vs.spo2
FROM st_subject AS pwr
JOIN md_vitalsigns AS vs ON  pwr.stay_id = vs.stay_id
WHERE vs.charttime BETWEEN pwr.ip_starttime AND pwr.ip_endtime AND vs.spo2 IS NOT NULL