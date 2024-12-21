#!/bin/bash
mkdir -p reports/unused_deps
mix deps.unlock --check-unused 1> >(tee reports/unused_deps/stdout.log) 2> >(tee reports/unused_deps/stderr.log >&2)
export EXIT_CODE=$?
echo $EXIT_CODE >reports/unused_deps/exit_code
exit $EXIT_CODE
