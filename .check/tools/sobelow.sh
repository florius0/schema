#!/bin/bash
mkdir -p reports/sobelow
mix sobelow 1> >(tee reports/sobelow/stdout.log) 2> >(tee reports/sobelow/stderr.log >&2)
mix sobelow --format sarif 1>reports/sobelow/sarif.json 2> >(tee reports/sobelow/stderr.log >&2)
export EXIT_CODE=$?
echo $EXIT_CODE >reports/sobelow/exit_code
exit $EXIT_CODE
