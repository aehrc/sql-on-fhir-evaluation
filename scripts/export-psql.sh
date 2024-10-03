#!/bin/sh
set -e
set -x
BASEDIR=$(dirname "$0")
source "$BASEDIR/_setenv.sh"

python "$PROJ_DIR/bin/export-psql.py" \
  --mimic-db-url "${PSQL_DB_URL:?Variable is not set}" \
  --output-dir "${PSQL_OUTPUT_DIR:?Variable is not set}"
