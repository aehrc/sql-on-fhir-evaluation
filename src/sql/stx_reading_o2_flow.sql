-- DEPENDS ON: md_oxygen_delivery, st_subject
CREATE OR REPLACE TEMP VIEW stx_reading_o2_flow AS
WITH nc_o2 AS (
    SELECT *, LEAST(o2_flow, o2_flow_additional) AS o2_flow_nc FROM md_oxygen_delivery WHERE o2_delivery_device_1 = 'Nasal cannula' AND o2_delivery_device_2 IS NULL
), nc_o2_flow AS (
SELECT subject_id, stay_id, charttime, o2_flow_nc AS o2_flow FROM nc_o2 WHERE o2_flow_nc <= 6
)
SELECT sb.subject_id, charttime AS chart_time, o2_flow
FROM nc_o2_flow AS ncf
JOIN st_subject sb ON ncf.subject_id = sb.subject_id AND ncf.stay_id = sb.stay_id
WHERE ncf.charttime BETWEEN sb.ip_starttime AND sb.ip_endtime AND ncf.o2_flow IS NOT NULL