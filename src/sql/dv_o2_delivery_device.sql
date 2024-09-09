-- DEPENDS-ON: rv_o2_delivery_device
CREATE OR REPLACE TEMP VIEW dv_o2_delivery_device AS
SELECT patient_id AS subject_id, encounter_id AS stay_id, CAST(charttime AS TIMESTAMP) as charttime, value AS o2_delivery_device
FROM rv_o2_delivery_device;