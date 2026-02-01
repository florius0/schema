#!/bin/bash
mkdir -p reports/compiler
mix compile.machine --force --warnings-as-errors --format sarif --output reports/compiler/sarif.json 1> >(tee reports/compiler/stdout.log) 2> >(tee reports/compiler/stderr.log >&2)
EXIT_CODE=$?
echo $EXIT_CODE >reports/compiler/exit_code
exit $EXIT_CODE
