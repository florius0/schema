#!/bin/bash
mkdir -p reports/gettext
mix gettext.extract --check-up-to-date 1> >(tee reports/gettext/stdout.log) 2> >(tee reports/gettext/stderr.log >&2)
export EXIT_CODE=$?
echo $EXIT_CODE >reports/gettext/exit_code
exit $EXIT_CODE
