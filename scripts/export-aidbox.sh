#!/bin/sh
set -e
set -x
BASEDIR=$(dirname "$0")
source "$BASEDIR/_setenv.sh"
PYTHONPATH="$PROJ_DIR" python "$PROJ_DIR/bin/export-aidbox.py" \
  --aidbox-url "${AIDBOX_URL:?Variable is not set}" \
  --aidbox-db-url "${AIDBOX_DB_URL:?Variable is not set}" \
  --auth-username "${AIDBOX_USERNAME:?Variable is not set}" \
  --auth-password "${AIDBOX_PASSWORD:?Variable is not set}" \
  --legacy-views "${AIDBOX_LEGACY:=no}" \
  --output-dir "${AIDBOX_OUTPUT_DIR:?Variable is not set}"