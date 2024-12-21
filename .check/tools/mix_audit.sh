#!/bin/bash
mkdir -p reports/mix_audit
mix deps.audit 1> >(tee reports/mix_audit/stdout.log) 2> >(tee reports/mix_audit/stderr.log >&2)
export EXIT_CODE=$?
echo $EXIT_CODE >reports/mix_audit/exit_code
exit $EXIT_CODE
