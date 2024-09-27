#!/bin/sh
set -e
set -x
PROJ_DIR=$(cd "`dirname $0`/.."; pwd)

SRC_MIMIC_FHIR_PATH="/Volumes/{hb-mimic-iv}/work/mimic4/mimic-iv-on-fhir-demo-1.1.3_af91a8f"
LOCAL_MIMIC_FHIR_PATH="/Users/szu004/datasets/mimic-iv/work/mimic4/mimic-iv-on-fhir-demo-1.1.3_af91a8f"
PATHLING_DS="parquet.ptl_issue_1759_37a999d1"

mkdir -p "${LOCAL_MIMIC_FHIR_PATH}"
rsync -avz "${SRC_MIMIC_FHIR_PATH}/${PATHLING_DS}" "${LOCAL_MIMIC_FHIR_PATH}/"