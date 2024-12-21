#!/bin/bash
mkdir -p reports/doctor
mix doctor 1> >(tee reports/doctor/stdout.log) 2> >(tee reports/doctor/stderr.log >&2)
export EXIT_CODE=$?
echo $EXIT_CODE >reports/doctor/exit_code
exit $EXIT_CODE
