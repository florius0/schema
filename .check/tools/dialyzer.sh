#!/bin/bash

mkdir -p reports/dialyzer
mix dialyzer --format github 1> >(tee reports/dialyzer/stdout.log) 2> >(tee reports/dialyzer/stderr.log >&2)
export EXIT_CODE=$?
echo $EXIT_CODE >reports/dialyzer/exit_code
exit $EXIT_CODE
