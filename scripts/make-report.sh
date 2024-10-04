#!/bin/sh
set -e
set -x

# set the project dir in PROJ_DIR as the parent directory of this script
PROJ_DIR=$(cd "`dirname $0`/.."; pwd)
EXPORT_DIR="${1:?arg1 (export directory) is required}"
OUTPUT_FILE="${2:?arg2 (output) is required}"

echo "Generating report for: $EXPORT_DIR to: $OUTPUT_FILE"
"${PROJ_DIR}/scripts/rmd2html.sh" "${PROJ_DIR}/R/study.Rmd" "$OUTPUT_FILE" "list(dataset='$EXPORT_DIR')"