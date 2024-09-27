-- DEPENDS-ON: st_subject, st_reading_o2_flow, st_reading_spo2, st_reading_so2
CREATE OR REPLACE TEMP VIEW coh_subject AS
SELECT subject_id, gender, race_category FROM st_subject AS pwr
WHERE EXISTS( SELECT 1 FROM st_reading_o2_flow AS rof WHERE pwr.subject_id = rof.subject_id)
    AND EXISTS( SELECT 1 FROM st_reading_spo2 AS rspo2 WHERE pwr.subject_id = rspo2.subject_id)
    AND EXISTS( SELECT 1 FROM st_reading_so2 AS rso2 WHERE pwr.subject_id = rso2.subject_id)