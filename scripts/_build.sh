#!/bin/sh
set -e
set -x
BASEDIR=$(dirname "$0")
PROJ_DIR=$(cd "$BASEDIR/.."; pwd)
MY_NAME=$(basename "$0")

IFS='_' read -r ENV_NAME SCRIPT_NAME <<< "$MY_NAME"
CONFIG_FILE="$HOME/.config/mimic-sof/${ENV_NAME:?Not defied}.sh"
echo "Loading environment variables from: $CONFIG_FILE"
sh "${PROJ_DIR}/scripts/${SCRIPT_NAME:?Not defined}" "$CONFIG_FILE"