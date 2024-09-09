-- DEPENDS ON: md_icustay_detail, md_oxygen_delivery
CREATE OR REPLACE TEMP VIEW st_subject AS
WITH odd AS (SELECT subject_id, stay_id, charttime, o2_delivery_device_1 AS o2_delivery_device
             FROM md_oxygen_delivery
             UNION
             SELECT subject_id, stay_id, charttime, o2_delivery_device_2 AS o2_delivery_device
             FROM md_oxygen_delivery
             UNION
             SELECT subject_id, stay_id, charttime, o2_delivery_device_3 AS o2_delivery_device
             FROM md_oxygen_delivery
             UNION
             SELECT subject_id, stay_id, charttime, o2_delivery_device_4 AS o2_delivery_device
             FROM md_oxygen_delivery),
     odd1 AS (SELECT *,
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
              FROM odd
              WHERE o2_delivery_device IS NOT NULL),
     ventilation_type AS (SELECT subject_id, stay_id, charttime AS starttime, ventilation_status FROM odd1),
     iws AS (SELECT stay_id,
                    starttime                                                   as inttime,
                    ventilation_status                                          AS int_type,
                    row_number() OVER (PARTITION BY stay_id ORDER BY starttime) AS int_sequence
             FROM ventilation_type
             WHERE ventilation_status NOT in ('None', 'SupplementalOxygen')
               AND ventilation_status IS NOT NULL),
     stays_with_intervention AS (SELECT stay_id, inttime, int_type
                                 FROM iws
                                 WHERE int_sequence = 1),
     patient_with_intervention AS (SELECT isd.*, v.inttime, v.int_type
                                   FROM md_icustay_detail AS isd
                                            LEFT OUTER JOIN stays_with_intervention AS v ON isd.stay_id = v.stay_id
                                   WHERE first_icu_stay
                                     AND first_hosp_stay
), subject_with_ip AS (SELECT subject_id,
                              stay_id,
                              gender,
                              race                                                                          AS ethnicity,
                              admittime                                                                     AS ip_starttime,
                              GREATEST(admittime,
                                       LEAST(dischtime, inttime, admittime + interval '5 days'))            AS ip_endtime,
                              inttime,
                              int_type
                       FROM patient_with_intervention
)
SELECT subject_id, stay_id, gender, ethnicity AS race_category, ip_starttime, ip_endtime FROM subject_with_ip
WHERE ethnicity IS NOT NULL and (ip_endtime - ip_starttime) >= INTERVAL '12 hours';
