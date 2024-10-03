#!/bin/sh
set -e
set -x

# set the project dir in PROJ_DIR as the parent directory of this script
PROJ_DIR=$(cd "`dirname $0`/.."; pwd)
# define knit function
# Function to knit an R Markdown file
knit_rmd() {
  local input_file=$1
  local output_dir=$(dirname "$2")
  local output_file_name=$(basename "$2")
  local params=${3:-"NULL"}
  Rscript -e "rmarkdown::render('${input_file}', output_format = 'html_document', output_file = '${output_file_name}', output_dir = '${output_dir}', params=${params})"
}
EXPORT_DIR="${1:?arg1 (export directory) is required}"
OUTPUT_FILE="${2:?arg2 (output) is required}"

echo "Generating report for: $EXPORT_DIR to: $OUTPUT_FILE"
knit_rmd "${PROJ_DIR}/R/study.Rmd" "$OUTPUT_FILE" "list(dataset='$EXPORT_DIR')"