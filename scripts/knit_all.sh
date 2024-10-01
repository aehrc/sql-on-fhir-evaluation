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
  Rscript -e "rmarkdown::render('${input_file}', output_format = 'html_document', output_file = '${output_file}', output_dir = '${output_dir}')"
}

# Call the function with the desired parameters
knit_rmd "${R_DIR}/compare.Rmd" "compare.html" "${OUTPUT_DIR}"
knit_rmd "${R_DIR}/study.Rmd" "study.html" "${OUTPUT_DIR}"
