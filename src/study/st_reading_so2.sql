-- DEPENDS-ON: st_subject, md_bg
CREATE OR REPLACE TEMP VIEW st_reading_so2 AS
SELECT pwr.subject_id, bg.charttime as chart_time, bg.so2
FROM st_subject AS pwr
JOIN md_bg AS bg ON  pwr.subject_id = bg.subject_id
WHERE bg.charttime BETWEEN pwr.ip_starttime AND pwr.ip_endtime AND bg.so2 IS NOT NULL AND bg.specimen = 'ART.'
