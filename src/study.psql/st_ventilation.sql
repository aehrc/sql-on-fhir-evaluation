-- based on: mimic-code/mimic-iv/concepts_postgres/treatment/ventilation.sql
-- DEPENDS-ON: md_oxygen_delivery
DROP TABLE IF EXISTS st_ventilation;
CREATE TABLE st_ventilation AS
WITH unpivot_o2_delivery AS (
    SELECT subject_id, stay_id, charttime, o2_delivery_device_1 AS o2_delivery_device
             FROM md_oxygen_delivery
             UNION
             SELECT subject_id, stay_id, charttime, o2_delivery_device_2 AS o2_delivery_device
             FROM md_oxygen_delivery
             UNION
             SELECT subject_id, stay_id, charttime, o2_delivery_device_3 AS o2_delivery_device
             FROM md_oxygen_delivery
             UNION
             SELECT subject_id, stay_id, charttime, o2_delivery_device_4 AS o2_delivery_device
             FROM md_oxygen_delivery
)
SELECT subject_id, stay_id, charttime, o2_delivery_device,
         CASE
             -- tracheostomy
             WHEN o2_delivery_device IN (
                                         'Tracheostomy tube',
                                         'Trach mask ' -- 16435 observations
                 -- 'T-piece', -- 1135 observations (T-piece could be either InvasiveVent or Tracheostomy)
                 ) THEN 'Tracheostomy'
             -- mechanical / invasive ventilation
             WHEN o2_delivery_device IN (
                 'Endotracheal tube'
                 ) THEN 'InvasiveVent'
             -- NIV
             WHEN o2_delivery_device IN (
                                         'Bipap mask ', -- 8997 observations
                                         'CPAP mask ' -- 5568 observations
                 ) THEN 'NonInvasiveVent'
             -- high flow nasal cannula
             when o2_delivery_device IN (
                 'High flow nasal cannula' -- 925 observations
                 ) THEN 'HFNC'
             -- non rebreather
             WHEN o2_delivery_device IN (
                                         'Non-rebreather', -- 5182 observations
                                         'Face tent', -- 24601 observations
                                         'Aerosol-cool', -- 24560 observations
                                         'Venti mask ', -- 1947 observations
                                         'Medium conc mask ', -- 1888 observations
                                         'Ultrasonic neb', -- 9 observations
                                         'Vapomist', -- 3 observations
                                         'Oxymizer', -- 1301 observations
                                         'High flow neb', -- 10785 observations
                                         'Nasal cannula'
                 ) THEN 'SupplementalOxygen'
             WHEN o2_delivery_device in (
                 'None'
                 ) THEN 'None'
             -- not categorized: other
             ELSE NULL END AS ventilation_status
FROM unpivot_o2_delivery;
