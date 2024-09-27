#!/bin/sh
set -e
set -x
BASEDIR=$(dirname "$0")
source "$BASEDIR/_setenv.sh"

MIMIC_FHIR_PATH="${MIMIC_DS_ROOT_DIR}/work/mimic4/mimic-iv-on-fhir-${DS_NAME_INFIX}1.1.3_af91a8f/parquet.ptl_issue_1759_37a999d1"
OUTPUT_DIR="${PROJ_DIR}/_data/ptl_mimic-${DS_NAME_INFIX}2.2"
PYTHONPATH="$PROJ_DIR" python "$PROJ_DIR/bin/run-ptl.py" \
  --mimic-ptl-dir "${MIMIC_FHIR_PATH}" \
  --output-dir "${OUTPUT_DIR}"
