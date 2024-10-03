#!/bin/sh
set -e
set -x
BASEDIR=$(dirname "$0")
source "$BASEDIR/_setenv.sh"

PYTHONPATH="$PROJ_DIR" python "$PROJ_DIR/bin/export-duckdb.py" \
  --init-sql "${DUCKDB_INIT_SQL:?Variable is not set}" \
  --output-dir "${DUCKDB_OUTPUT_DIR:?Variable is not set}"
