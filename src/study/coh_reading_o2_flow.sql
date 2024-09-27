-- DEPENDS-ON: st_reading_o2_flow, coh_subject
CREATE OR REPLACE TEMP VIEW coh_reading_o2_flow AS
SELECT * FROM st_reading_o2_flow AS rd
WHERE EXISTS( SELECT 1 FROM coh_subject AS cs WHERE rd.subject_id = cs.subject_id)
ORDER BY subject_id, chart_time

