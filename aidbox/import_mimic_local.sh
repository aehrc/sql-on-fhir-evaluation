#!/bin/sh
set -e
set -x
BASEDIR=$(dirname "$0")

"${BASEDIR}/bin"/import_mimic.py \
  --mimic-ds-dir "work/mimic4/mimic-iv-on-fhir-demo-1.1.3_af91a8f/fhir" \
  --auth-username "basic" \
  --auth-password "secret"