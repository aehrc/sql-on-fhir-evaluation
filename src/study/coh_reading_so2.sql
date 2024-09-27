-- DEPENDS-ON: st_reading_so2, coh_subject
CREATE OR REPLACE TEMP VIEW coh_reading_so2 AS
SELECT * FROM st_reading_so2 AS rd
WHERE EXISTS( SELECT 1 FROM coh_subject AS cs WHERE rd.subject_id = cs.subject_id)
ORDER BY subject_id, chart_time;