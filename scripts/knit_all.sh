#!/bin/sh
set -e
set -x

# set the project dir in PROJ_DIR as the parent directory of this script
PROJ_DIR=$(cd "`dirname $0`/.."; pwd)
echo $PROJ_DIR
R_DIR="${PROJ_DIR}/R"
OUTPUT_DIR="${PROJ_DIR}/knitted"


# define knit function
# Function to knit an R Markdown file
knit_rmd() {
  local input_file=$1
  local output_file=$2
  local output_dir=$3
  local params=${4:-"NULL"}
  Rscript -e "rmarkdown::render('${input_file}', output_format = 'html_document', output_file = '${output_file}', output_dir = '${output_dir}', params=${params})"
}

# Call the function with the desired parameters
knit_rmd "${R_DIR}/compare.Rmd" "compare_ptl_vs_aidbox.html" "${OUTPUT_DIR}"
knit_rmd "${R_DIR}/study.Rmd" "study_ptl.html" "${OUTPUT_DIR}" "list(dataset='_data/ptl_mimic-2.2')"
knit_rmd "${R_DIR}/study.Rmd" "study_aidbox.html" "${OUTPUT_DIR}" "list(dataset='_data/aidbox_mimic-2.2')"

