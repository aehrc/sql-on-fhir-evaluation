






# SOF

## Notes
- weak typing and validation in fhirpath makes if difficult to catch bugs in view definitions. Fields that do not exits are silently ignored and produce NULLs.


# Setup



## Aidbox

### Notes:

Setting up basic auth: http://localhost:8080/ui/console?#/sandbox/basic


Curl to create a view:


file: `tmp/view_request.yaml`

```yaml
name: patient_view
resource: Patient
description: Patient flat view
status: draft
select:
- column:
  - name: id
    path: id
  - name: bod
    path: birthDate
  - name: gender
    path: gender
```

```bash
curl -X POST -H "Content-Type: application/yaml" -u basic:secret --data-binary @tmp/view_request.yaml http://localhost:8080/ViewDefinition/
```

To start local HTTP server in a dir:

```bash
python3 -m http.server 8000
```


Python script to create a view
```python
import requests

# URL and authentication details
url = 'http://localhost:8080/ViewDefinition/'
auth = ('basic', 'secret')

# Read the YAML file
with open('tmp/view_request.yaml', 'r') as file:
    data = file.read()

# Set the headers
headers = {
    'Content-Type': 'application/yaml'
}

# Make the POST request
response = requests.post(url, headers=headers, data=data, auth=auth)

# Print the response
print(response.status_code)
print(response.text)
```



### Pulse Oximetry and Vital Signs

Vital sign records within the index period, including temperatures (converted to Celsius), heart rates, mean arterial pressures, respiratory rates, and SpO2, were extracted. For each vital sign type, area under the curve was calculated using the trapezoid method with the “MLmetrics” R package21 and was divided by the number of minutes between the first and last reading to produce a time-weighted average value.

```sql
create table vitalsign
(
    subject_id  integer,
    stay_id     integer,
    charttime   timestamp,
    heart_rate  double precision,
    mbp         double precision, -- mean blood pressure
    mbp_ni      double precision, -- ?? mean blood pressure 
    resp_rate   double precision,
    temperature numeric,
    spo2        double precision
)
```


### Hemoglobin Oxygen Saturation

To avoid aberrant values as well as likely venous blood gas values, which are not directly distinguished from arterial blood gas values under some laboratory codes, readings were removed if the hemoglobin oxygen saturation was less than 70% or greater than 100%. For each patient, the area under the curve was calculated from all remaining timed blood gas records during the index period and was divided by the difference in time between the first and last blood gas reading to give a time-weighted average value. If patients had only 1 blood gas reading, this value was used instead of a calculated average. The number of blood gas tests on each day of the index period was determined as well.

```sql
create table bg
(
    subject_id integer,
    hadm_id    integer,
    charttime  timestamp,
    specimen   text,
    so2        double precision -- hemoglobin oxygen saturation
)
```

Notes:
- we are only looking for arterial blood gas values (`specimen = 'ART'`)


### Supplemental Oxygen Rate

To compute estimates of average supplemental oxygen rates, all nasal cannula flow rates and time on room air records within the index period were downloaded from a derived oxygen supplementation table in MIMIC-IV. Numbers of oxygen records of other device types were reviewed to determine that these were infrequent relative to nasal cannula for most patients and could reasonably be excluded. For example, if a patient had a nasal cannula record at hour 1, face tent at hour 2, and a nasal cannula again at hour 3, the patient was recorded as having a nasal cannula at the respective rates from hour 1 through hour 3. Supplemental oxygen area under the curve was calculated and was divided by the duration of time in seconds between the first and last recorded rate. For 100 patients for whom only 1 oxygen rate was recorded, this rate was used instead of the average.

```sql
create table oxygen_delivery
(
    subject_id           integer,
    stay_id              integer,
    charttime            timestamp,
    o2_flow              double precision,
    o2_flow_additional   double precision,
    o2_delivery_device_1 text,
    o2_delivery_device_2 text,
    o2_delivery_device_3 text,
    o2_delivery_device_4 text
);
```

TBD:
- should only `Nasal cannula` readings from `o2_delivery_device_1` are considered? 
- if `Nasal cannula` is `o2_delivery_device_2` should `o2_flow_additional` be considered?
- `and time on room air` what does that mean? 
- there seem to be cases where o2_flow_additional needs to be used if (o2_flow >> 20)?



### Other Data Elements

The SOFA score is available in another derived table in MIMIC-IV. It includes 6 components based on organ systems (respiration, coagulation, liver, cardiovascular, central nervous system, and kidney), with a score of 1 to 4 for each system and an overall maximum score of 24 (most severe organ dysfunction).22 For each patient, the maximum of these scores during the index period was extracted. Vasopressor or inotrope dose rates of infusion were extracted from the fluid input table, and a binary variable was created to indicate whether any vasopressors or inotropes were required during the index period. Elixhauser comorbidity scores were computed from International Classification of Diseases, Ninth Revision (ICD-9) and International Statistical Classification of Diseases and Related Health Problems, Tenth Revision (ICD-10) codes using the R “Comorbidity” package.23,24

```sql

create table sofa
(
    stay_id                integer,
    starttime              timestamp,
    endtime                timestamp,
    ...
    sofa_24hours           integer
);
```


### Linear models

#### Model 1

```
SpO2 
~ SO2 + race_ethnicity + Avg Resp Rate + Initial pCO2 + No. of blood gas tests day 1 + Hgb + Required pressoers/intropes + Gender(Male Sex) + Index Period Duration + Elixhauser Score
```

- SpO2 [%]: `avg(vitalsign.spo2)` (`mimic-chartevents-d-items|20277|O2 saturation pulseoxymetry`)
- SO2 [%]: `avg(bg.so2)`
- race_ethnicity: `to_race_code(icustay_detail.race)`
- Avg Resp Rate [breaths/min]: `avg(vitalsign.resp_rate)` (`mimic-chartevents-d-items|224690|Respiratory Rate (Total)`) (also d-item: 220210)
- Initial pCO2 [mmHg]: `first(bg.pco2)`
- No. of blood gas tests day 1 [count]: `{count of bg tests on day 1 where so2 is not null}`
- Hgb(Hemoglobin) [g/dL]: `avg(bg.hemoglobin)`
- Gender(Male Sex): `icustay_detail.gender`
- Index Period Duration [days]: `{computed duration of index period}`
- Elixhauser Score: `{based on the ICD codes from mimiciv_hosp.diagnoses_icd}` (??? not clear if codes are per subject or per stay/admission. Feed the codes to the comorbidity R package. ??? Also not clear what weights were used for the calculation of the score)
- Required pressors/intropess: `{exits(not null COALESCE(domapmine, ...) vasoactive_agent) in index period}` (not need to refer to the per agent tables)

## Resources
- [Assessment of Racial and Ethnic Differences in Oxygen Supplementation Among Patients in the Intensive Care Unit](https://jamanetwork.com/journals/jamainternalmedicine/fullarticle/2794196)
- [R-Unpaired Two Samples Wilson-Cox Test](http://www.sthda.com/english/wiki/unpaired-two-samples-wilcoxon-test-in-r#:~:text=The%20unpaired%20two%2Dsamples%20Wilcoxon,two%20independent%20groups%20of%20samples)
- [R - comorbidity package](https://www.theoj.org/joss-papers/joss.00648/10.21105.joss.00648.pdf)


## TODO

- [ ] Write script for pathling encoding from JSON (the parquet version does not seem to work)
- [ ] Connect export notebook the demo datasource
- [ ] Discuss with John the correct approach for dealing with codes (race + ethnicity)
- 


## Notes
- setting  `spark.sql.ansi.enabled` to true result in exception in Pathling.
