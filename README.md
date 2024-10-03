Using SQL on FHIR to reproduce the results of study on racial and differences in oxygen supplementation.
--------------------------------------------------------------------------------------------------------

This in an example of using SQL on FHIR view in combination with ANSI SQL queries to qualitatively 
reproduce selected results of the study:
[Assessment of Racial and Ethnic Differences in Oxygen Supplementation Among Patients in the Intensive Care Unit](https://jamanetwork.com/journals/jamainternalmedicine/fullarticle/2794196).

The focus of this example is 
- the feasibility of using SQL on FHIR/ANSI SQL to select the data required for the study from a FHIR dataset.
- the interoperability of the SQL on FHIR/ANSI SQL views between implementations of FHIR servers.


# Introduction

## The original study

The objective of the original study was to o determine if there are racial and ethnic disparities 
in supplemental oxygen administration associated with inconsistent pulse oximeter performance (for ICU patient).

The analysis was conducted as a retrospective cohort study  based on the Medical Information Mart for Intensive Care (MIMIC)-IV dataset
and concluded that Asian, Black, and Hispanic patients received less supplemental oxygen than White patients, 
and this was associated with differences in pulse oximeter performance.

Although this is not explicitly stated in the study, we concluded that it was based on [MIMIC-VI version 1.0](https://physionet.org/content/mimiciv/1.0/).
Rather than using MIMIC-VI data directly the study was based on the derived concepts (_mimic_derived_) 
available in the BigQuery dataset `physionet-data.mimic_derived` (see: https://github.com/MIT-LCP/mimic-code) 

## The replication

This example demonstrates how SQL on FHIR/ANSI SQL can be used to select the data required for the 
study from FHIR version of the MIMIC-VI.

We intend to qualitatively reproduce the selected results of the study as the exact replication is not possible due to:
- the differences in the MIMIC-IV version used; MIMIC-FHIR is based on MIMIC-VI version 2.2 (not version 1.0 as in the original study)
- lack of sufficient details on data selection and processing in the study
- simplifications and assumptions made in the replication

In particular, we would like to show:
- differences in the oxygen delivery rates between the racial groups (non-parametric Wilcoxon test of the difference of means of the oxygen delivery rates)
- differences in SpO2 for a given hemoglobin oxygen saturation (so2) between races and ethnicities when controlling for gender (simplified regression model 1)

We have made the following assumptions the data selection:
- TBD


# Analytical pipeline design

![View Layers](assets/sof_layes.png)



# Running the Analysis pipeline

## Exporting data

Set up a virtual environment (e.g. using `venv` or `conda`) with python 3.11 and install the required packages:
```
pip install -r python/requirements.txt
```

Build the python package `https://github.com/aehrc/pathling/tree/issue/1759` branch of Pathling with SQL on FHIR support and install it in the python environment:

```bash
git clone --branch issue/1759 --single-branch https://github.com/aehrc/pathling.git
cd pathling
mvn install -DskipTests -am -pl lib/python
pip install lib/python/target/py-dist/pathling-7.1.0.dev0.tar.gz
```

Install the `sof-mimic` package from the  `python` directory:

```bash
pip install -e python`
```

### Exporting data with Pathling

Pre-requisites:
- Pathling with SQL on FHIR support installed in the python environment
- Pathling encoded FHIR-MIMIC data (full or demo)

To export the study data run the following command:

```bash
./bin/export-ptl.py \
  --mimic-ptl-dir "${MIMIC_PTL_DIR}" \
  --output-dir "${PTL_OUTPUT_DIR}"
```

Where:
- `MIMIC_PTL_DIR` is the directory where the Pathling encoded FHIR-MIMIC data is stored
- `PTL_OUTPUT_DIR` is the directory where the output export files will be saved (e.g.: `.target/ptl-export`)

Alternatively, you can define the variables in file (e.g. `local-env.sh`) and run:

```bash
./scripts/export-ptl.sh <config-file-name>
```

The parameter is optional if not provided the variables defined in the current shell environment will be used.

The example of the configuration file is provided in `conf/local-env.sh`.

### Exporting data with Aidbox

Pre-requisites:
- Aidbox (version ?.?) instance with mimic-fhir (or mimic-demo-fhir loaded)
- Aidbox REST API endpoint configured with basic authentication
- Direct access to the postgres database backing the Aidbox instance (connection details)

To export the study data run the following command:

```bash
./bin/export-aidbox.py  --aidbox-url "${AIDBOX_URL}" \
  --aidbox-db-url "${AIDBOX_DB_URL}" \
  --auth-username "${AIDBOX_USERNAME}" \
  --auth-password "${AIDBOX_PASSWORD}" \
  --legacy-views "${AIDBOX_LEGACY}" \
  --output-dir "${AIDBOX_OUTPUT_DIR}"
```

Where:
- `AIDBOX_URL` is the URL of the Aidbox REST API endpoint (e.g.: `https://localhost:8080`)
- `AIDBOX_DB_URL` is the SQLAlchemy compatible connection URL of the Aidbox PostgreSQL database (e.g.: `postgresql+psycopg2://aidbox:fIF2TkhhH0@localhost:8432/aidbox`)
- `AIDBOX_USERNAME` is the username for basic authentication (e.g.: `basic`)
- `AIDBOX_PASSWORD` is the password for basic authentication (e.g.: `secret`)
- `AIDBOX_LEGACY` `['yes'|'no']` is the flag to use view compatible with the older version of Aidbox (e.g.: `no`)
- `AIDBOX_OUTPUT_DIR` is the directory where the output export files will be saved (e.g.: `.target/aidbox-export`)


Alternatively, you can define the variables in file (e.g. `local-env.sh`) and run:

```bash
./scripts/export-aidbox.sh <config-file-name>
```
The parameter is optional if not provided the variables defined in the current shell environment will be used.

The example of the configuration file is provided in `conf/local-env.sh`. 
This is based on a local Aidbox instance running in a docker container.

### Exporting data with PostgreSQL

Pre-requisites:
- PosgreSQL database with MIMIC-IV version 2.2 loaded and mimic_derived tables created

To export the study data run the following command:

```bash
./bin/export-psql \
  --mimic-db-url "${PSQL_DB_URL}" \
  --output-dir "${PSQL_OUTPUT_DIR}"
```

Where:
- `PSQL_DB_URL` is the SQLAlchemy compatible connection URL to the PostgreSQL database (e.g.: `postgresql+psycopg2://posgres@localhost:5432/mimic4`)
- `PSQL_OUPUT_DIR` is the directory where the output export files will be saved (e.g.: `.target/psql-export`)

Alternatively, you can define the variables in file (e.g. `local-env.sh`) and run:

```bash
./scripts/export-psql.sh <config-file-name>
```

The parameter is optional if not provided the variables defined in the current shell environment will be used.

The example of the configuration file is provided in `conf/local-env.sh`.

### Exporting data with DuckDB (bridge to PostgreSQL)

Pre-requisites:
- PosgreSQL database with MIMIC-IV version 2.2 loaded and mimic_derived tables created

To export the study data run the following command:

```bash
./bin/export-duckdb.py \
  --init-sql "${DUCKDB_INIT_SQL}" \
  --output-dir "${DUCKDB_OUTPUT_DIR}"
```

Where:
- `DUCKDB_INIT_SQL` is the DuckDB sql to attach and use the PostgreSQL database (e.g.: `ATTACH 'dbname=mimic4 user=postgres' AS mimic4 (TYPE POSTGRES, READ_ONLY); USE mimic4`)
- `DUCKDB_OUTPUT_DIR` is the directory where the output export files will be saved (e.g.: `.target/duckdb-export`)

Alternatively, you can define the variables in file (e.g. `local-env.sh`) and run:

```bash
./scripts/export-duckdb.sh <config-file-name>
```

The parameter is optional if not provided the variables defined in the current shell environment will be used.

The example of the configuration file is provided in `conf/local-env.sh`.


## Generating analysis results

Pre-requisites:
- R environment with the required packages installed:
  - `rmarkdown`
  - `ggplot2`
  - `dplyr`
  - `lubridate`
  - `MLmetrics`

The analysis is performed using a Rmd script `R/study.Rmd` that uses the exported data to generate the results. 
It accepts the `dataset` parameter that specifies the path to the directory with the exported data.

To generate the report run the following command:

```bash
./scripts/make-report.sh ${EXPORT_DIR} ${OUTPUT_FILE}
```

Where:
- `EXPORT_DIR` is the directory with the exported data (e.g.: `target/ptl-export`)
- `OUTPUT_FILE` is the path to the output file (e.g.: `target/ptl-report.html`)

Note: The report only works on exports from the full mimic-iv datasets. 
It fails on the mimic-demo-iv exports due to the lack of data for certain races/ethnicities.

# Resources
- [Assessment of Racial and Ethnic Differences in Oxygen Supplementation Among Patients in the Intensive Care Unit](https://jamanetwork.com/journals/jamainternalmedicine/fullarticle/2794196)