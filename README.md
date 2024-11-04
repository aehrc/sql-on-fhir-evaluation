# Using SQL on FHIR to reproduce the results of study on racial and differences in oxygen supplementation

This in an example of using SQL on FHIR view in combination with ANSI SQL
queries to qualitatively reproduce selected results of the study: [Assessment of
Racial and Ethnic Differences in Oxygen Supplementation Among Patients in the
Intensive Care
Unit](https://jamanetwork.com/journals/jamainternalmedicine/fullarticle/2794196).

The purpose of this example is to demonstrate:

- The feasibility of using SQL on FHIR/ANSI SQL to select the data required for 
  the study from a FHIR dataset.
- The interoperability of the SQL on FHIR/ANSI SQL views between multiple view 
  runner implementations.

## Introduction

### The original study

The objective of the original study was to determine if there are racial and
ethnic disparities in supplemental oxygen administration associated with
inconsistent pulse oximeter performance (for ICU patients).

The analysis was conducted as a retrospective cohort study based on the Medical
Information Mart for Intensive Care (MIMIC-IV) dataset. The study concluded
that Asian, Black, and Hispanic patients received less supplemental oxygen than
White patients, and this was associated with differences in pulse oximeter
performance.

Although this is not explicitly stated in the study, we concluded that it was
based on [MIMIC-VI version 1.0](https://physionet.org/content/mimiciv/1.0/).
Rather than using MIMIC-IV data directly, the study was based on the derived
concepts (`mimic_derived`) available in the BigQuery dataset
`physionet-data.mimic_derived` (see: [MIMIC Code
Respository](https://github.com/MIT-LCP/mimic-code)).

### Replication

The purpose of this replication is to demonstrate how SQL on FHIR and ANSI SQL
can be used to select the data required for the study from FHIR version of the
MIMIC-IV.

We intend to qualitatively reproduce selected results of the study. Exact
replication is not possible due to:

- Differences in the MIMIC-IV version used - MIMIC-FHIR is based on MIMIC-IV version 2.2 (not version 1.0 as in the original study)
- Lack of sufficient details on data selection and processing in the study
- Information loss in the FHIR conversion
- Simplifications and assumptions made in the replication

In particular, we would like to show:

- Differences in the oxygen delivery rates between the racial groups 
  (non-parametric Wilcoxon test of the difference of means of the oxygen delivery rates)
- Differences in SpO<sub>2</sub> for a given hemoglobin oxygen saturation between races 
  and ethnicities when controlling for gender (simplified regression model 1)

The data were transformed using SQL on FHIR view definitions executed using two different view runner implementations:

- [Pathling](https://pathling.csiro.au)
- [Aidbox](https://www.health-samurai.io/aidbox)

We also provide two additional examples of using PostgreSQL and DuckDB to export the data, these were not used to produce the results in the study.

The results of the replication produced by the pipeline described below are available in the `results` directory:

- [Results using Pathling](results/study_ptl.html)
- [Results using Aidbox](results/study_aidbox.html)

## Analytic pipeline

To reproduce the results of the study, we used the following approach:

- Transform the FHIR data to a set of CSV files using a combination of SQL on
  FHIR views and ANSI SQL queries.
- Analyze the exported data using R to generate the results.

### Data transformation

Because the original study was based on `mimic_derived` rather than the raw
MIMIC-IV data, we decided to create `mimic_derived`-like views on the MIMIC-FHIR
data and base our study-specific views on it. The SQL queries to create this
layer were borrowed from the [MIMIC Code
Respository](https://github.com/MIT-LCP/mimic-code).

The introduction of `mimic_derived`-like layers allows us to use the same
study-specific queries to extract data form both MIMIC-IV and MIMIC-FHIR
datasets. This has the following benefits:

- Makes it easier to identify sources of required data (as the `mimic_derived`
  concepts are referenced in the study).
- Allows us to compare both approaches.

The views have a layered structure with the specific combination sets of view packages used depending on the data source, as shown in the diagram below:

![View Layers](assets/sof_layers.png)

All view packages are defined the `src` directory.

Here is the list of the view packages:

- `sof` - The SQL on FHIR views to extract raw data required for the
  `mimic_derived`-like views
- `sof-types.*` - A thin layer that adapts the types of SOF produced relations
  to uniform database types (e.g. `TIMESTAMP`) in an implementation-specific
  manner.
- `mimic-fhir` - Combines/transforms basic views into the complex
  `mimic_derived`-like views.
- `study` - The study-specific views that extract the data required for the
  study
- `mimic-2.2` - A thin adapter layer from `mimic_derived` to
  `mimic_derived`-like views.

Two auxiliary packages are:

- `sof.legacy` - The SQL on FHIR views compatible with an older version of
  Aidbox (with what appears to be a bug in accessing choice values in
  extensions with `.ofType()` function).
- `study.psql` - A version of study-specific views using materialized tables
  instead of temporary views to improve performance on PostgreSQL.

## Running the pipeline

The analysis pipeline consists of the following steps:

1. Exporting data from the FHIR server (Pathling, Aidbox) to a set of CSV files
   using a subset of SQL on FHIR/SQL views from the `src` and the `mimic-sof`
   python package (in the `python/` directory).
2. Analyzing the exported data using an Rmd script to notebook to generate the
   results (`R/study.Rmd`).

We assume that MIMIC-FHIR data was already loaded to the view runner prior to
running the analysis pipeline, in an implementation-specific manner.

## Transforming data

Set up a virtual environment (e.g. using `venv` or `conda`) with python 3.11 and install the required packages:

```
pip install -r python/requirements.txt
```

Build the python package of the `sof-paper` branch of Pathling with SQL on FHIR
support and install it in the Python environment:

```bash
git clone --branch sof-paper --single-branch https://github.com/aehrc/pathling.git
cd pathling
mvn install -DskipTests -am -pl lib/python
pip install lib/python/target/py-dist/pathling-7.1.0.dev0.tar.gz
```

Install the `sof-mimic` package from the  `python` directory:

```bash
pip install -e python`
```

### Pathling

Pre-requisites:

- Pathling with SQL on FHIR support installed in the Python environment
- Pathling encoded MIMIC-IV on FHIR data

To export the study data run the following command:

```bash
./bin/export-ptl.py \
  --mimic-ptl-dir "${MIMIC_PTL_DIR}" \
  --output-dir "${PTL_OUTPUT_DIR}"
```

Where:
- `MIMIC_PTL_DIR` is the directory where the Pathling encoded MIMIC-IV on FHIR
  data is stored
- `PTL_OUTPUT_DIR` is the directory where the output export files will be saved
  (e.g.: `.target/ptl-export`)

Alternatively, you can define the variables in file (e.g. `local-env.sh`) and run:

```bash
./scripts/export-ptl.sh <config-file-name>
```

The parameter is optional if not provided the variables defined in the current shell environment will be used.

The example of the configuration file is provided in `conf/local-env.sh`.

### Aidbox

Pre-requisites:

- Aidbox (version `2407`) instance with MIMIC-IV on FHIR loaded
- Aidbox REST API endpoint configured with basic authentication
- Direct access to the PostgreSQL database backing the Aidbox instance 

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
- `AIDBOX_DB_URL` is the SQLAlchemy compatible connection URL of the Aidbox PostgreSQL database (e.g.: `postgresql+psycopg2://aidbox:password@localhost:8432/aidbox`)
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
This is based on a local Aidbox instance running in a Docker container.

### PostgreSQL

Pre-requisites:

- PosgreSQL database with MIMIC-IV version 2.2 loaded, and `mimic_derived`
  tables created

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

### DuckDB (bridge to PostgreSQL)

Pre-requisites:

- PosgreSQL database with MIMIC-IV version 2.2 loaded, and mimic_derived tables created

To export the study data run the following command:

```bash
./bin/export-duckdb.py \
  --init-sql "${DUCKDB_INIT_SQL}" \
  --output-dir "${DUCKDB_OUTPUT_DIR}"
```

Where:

- `DUCKDB_INIT_SQL` is the DuckDB sql to attach and use the PostgreSQL database
  (e.g.: `ATTACH 'dbname=mimic4 user=postgres' AS mimic4 (TYPE POSTGRES,
  READ_ONLY); USE mimic4`)
- `DUCKDB_OUTPUT_DIR` is the directory where the output export files will be
  saved (e.g.: `.target/duckdb-export`)

Alternatively, you can define the variables in file (e.g. `local-env.sh`) and run:

```bash
./scripts/export-duckdb.sh <config-file-name>
```

The parameter is optional if not provided the variables defined in the current shell environment will be used.

The example of the configuration file is provided in `conf/local-env.sh`.

## Generating results

Pre-requisites:

An R environment with the required packages installed:
- `rmarkdown`
- `ggplot2`
- `dplyr`
- `lubridate`
- `MLmetrics`

The analysis is performed using a Rmd script `R/study.Rmd` that uses the exported data to generate the results. It accepts the `dataset` parameter that specifies the path to the directory with the exported data.

To generate the report run the following command:

```bash
./scripts/make-report.sh ${EXPORT_DIR} ${OUTPUT_FILE}
```

Where:

- `EXPORT_DIR` is the directory with the exported data (e.g.: `target/ptl-export`)
- `OUTPUT_FILE` is the path to the output file (e.g.: `target/ptl-report.html`)

Note: The report only works on exports from the full MIMIC-IV dataset. It fails
on the MIMIC-Demo-IV exports due to the lack of data for certain races/ethnicities.