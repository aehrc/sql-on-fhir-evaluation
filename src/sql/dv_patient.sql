-- DEPENDS-ON: rv_patient
CREATE OR REPLACE TEMP VIEW dv_patient AS
SELECT patient_id AS subject_id,
       CASE
           WHEN gender = 'male' THEN 'M'
           WHEN gender = 'female' THEN 'F'
           END AS gender,
       CASE
           WHEN race_system = 'urn:oid:2.16.840.1.113883.6.238' THEN
               CASE
                   WHEN race_code = '2106-3' THEN
                       CASE
                           WHEN ethnicity_system = 'urn:oid:2.16.840.1.113883.6.238' AND ethnicity_code = '2135-2' THEN 'HISPANIC'
                           ELSE 'WHITE'
                           END
                   WHEN race_code = '2054-5' THEN 'BLACK'
                   WHEN race_code = '2028-9' THEN 'ASIAN'
                   END
           END AS race
FROM rv_patient;