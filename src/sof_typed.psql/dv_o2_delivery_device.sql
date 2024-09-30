-- DEPENDS-ON: rv_o2_delivery_device
CREATE OR REPLACE TEMP VIEW dv_o2_delivery_device AS
SELECT subject_id,
       stay_id,
       charttime::TIMESTAMPTZ AT TIME ZONE 'UTC' AS charttime,
       value
FROM rv_o2_delivery_device;