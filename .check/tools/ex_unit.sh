#!/bin/bash
mkdir -p reports/ex_unit
mix test --no-all-warnings --cover 1> >(tee reports/ex_unit/stdout.log) 2> >(tee reports/ex_unit/stderr.log >&2)
export EXIT_CODE=$?
[ -d cover ] && cp -r cover reports/ex_unit/out
tail -n 10 reports/ex_unit/stdout.log | sed -n 's/^[[:space:]]*Coverage:[[:space:]]*\([0-9]*\.[0-9]*\).*/\1/p' >reports/ex_unit/coverage.txt
echo $EXIT_CODE >reports/ex_unit/exit_code
exit $EXIT_CODE
