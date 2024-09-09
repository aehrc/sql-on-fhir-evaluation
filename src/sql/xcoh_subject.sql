CREATE OR REPLACE TEMP VIEW coh_subject AS
SELECT subject_id, gender, race_category FROM st_subject AS pwr
WHERE EXISTS( SELECT 1 FROM stx_o2_flow AS rof WHERE pwr.subject_id = rof.subject_id);
