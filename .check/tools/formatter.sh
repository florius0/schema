#!/bin/bash
mkdir -p reports/formatter
mix format --check-formatted 1> >(tee reports/formatter/stdout.log) 2> >(tee reports/formatter/stderr.log >&2)
export EXIT_CODE=$?
echo $EXIT_CODE >reports/formatter/exit_code
exit $EXIT_CODE
