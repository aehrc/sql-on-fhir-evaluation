#
# Common configuration
#
# The location of the mimic dataset
MIMIC_DS_ROOT_DIR='/datasets/mimic-iv'
#
#Aidbox configuration
#
AIDBOX_URL='http://localhost:8080'
AIDBOX_DB_URL='postgresql+psycopg2://aidbox:fIF2TkhhH0@localhost:8432/aidbox'
AIDBOX_USERNAME='basic'
AIDBOX_PASSWORD='secret'
AIDBOX_LEGACY='no'
AIDBOX_OUTPUT_DIR="${PROJ_DIR:?Not defined}/target/aidbox_mimic-demo-2.2"
#
# Pathling configuration
#
MIMIC_PTL_DIR="${MIMIC_DS_ROOT_DIR}/work/mimic4/mimic-iv-on-fhir-demo-1.1.3_af91a8f/parquet.ptl_issue_1759_37a999d1"
PTL_OUTPUT_DIR="${PROJ_DIR:?Not defined}/target/ptl_mimic-demo-2.2"

#DuckDB configuration
DUCKDB_INIT_SQL="ATTACH 'dbname=mimic4 user=postgres' AS mimic4 (TYPE POSTGRES, READ_ONLY); USE mimic4"
DUCKDB_OUTPUT_DIR="${PROJ_DIR:?Not defined}/target/duckdb_mimic-demo-2.2"