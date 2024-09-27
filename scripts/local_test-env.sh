#!/bin/sh
set -e
set -x
BASEDIR=$(dirname "$0")
source "$BASEDIR/_setenv.sh"

OUTPUT_DIR="${PROJ_DIR}/_data/aidbox_mimic-${DS_NAME_INFIX}2.2"

echo "ENV_NAME: $ENV_NAME"
echo "BASEDIR: $BASEDIR"
echo "PROJ_DIR: $PROJ_DIR"
echo "OUTPUT_DIR: $OUTPUT_DIR"
