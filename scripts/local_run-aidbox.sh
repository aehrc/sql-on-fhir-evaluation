#!/bin/sh
set -e
set -x
BASEDIR=$(dirname "$0")
source "$BASEDIR/_setenv.sh"

OUTPUT_DIR="${PROJ_DIR}/_data/aidbox_mimic-${DS_NAME_INFIX}2.2"

PYTHONPATH="$PROJ_DIR" python "$PROJ_DIR/bin/run-aidbox.py" \
  --aidbox-url "${AIDBOX_URL}" \
  --aidbox-db-url "${AIDBOX_DB_URL}" \
  --auth-username "${AIDBOX_USERNAME}" \
  --auth-password "${AIDBOX_PASSWORD}" \
  --legacy-views "${AIDBOX_LEGACY}" \
  --output-dir "${OUTPUT_DIR}"