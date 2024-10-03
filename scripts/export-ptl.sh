#!/bin/sh
set -e
set -x
BASEDIR=$(dirname "$0")
source "$BASEDIR/_setenv.sh"

python "$PROJ_DIR/bin/export-ptl.py" \
  --mimic-ptl-dir "${MIMIC_PTL_DIR:?Variable is not set}" \
  --output-dir "${PTL_OUTPUT_DIR:?Variable is not set}"
