#!/bin/sh
set -e
set -x
BASEDIR=$(dirname "$0")

"${BASEDIR}/bin"/import_mimic.py \
  --aidbox-url "http://localhost:9080" \
  --mimic-ds-dir "work/mimic4/mimic-iv-on-fhir-1.1.3_af91a8f/fhir" \
  --auth-username "szu004" \
  --auth-password "secret123"