#!/bin/bash
mkdir -p reports/ex_doc
mix docs 1> >(tee reports/ex_doc/stdout.log) 2> >(tee reports/ex_doc/stderr.log >&2)
export EXIT_CODE=$?
[ -d doc ] && cp -r doc reports/ex_doc/out
echo $EXIT_CODE >reports/ex_doc/exit_code
exit $EXIT_CODE
