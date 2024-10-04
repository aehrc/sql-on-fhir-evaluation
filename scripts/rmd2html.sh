#!/bin/sh
input_file="${1:?arg1 (input file) is required}"
output_dir=$(dirname "${2:?arg2 (output file) is required}")
output_file_name=$(basename "${2}")
params=${3:-"NULL"}
Rscript -e "rmarkdown::render('${input_file}', output_format = 'html_document', output_file = '${output_file_name}', output_dir = '${output_dir}', params=${params})"
