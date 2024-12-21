#!/bin/bash
mkdir -p reports/credo
mix credo 1> >(tee reports/credo/stdout.log) 2> >(tee reports/credo/stderr.log >&2)
mix credo --format sarif 1>reports/credo/sarif.json 2> >(tee reports/credo/stderr.log >&2)
export EXIT_CODE=$?
echo $EXIT_CODE >reports/credo/exit_code
exit $EXIT_CODE
