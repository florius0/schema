#!/bin/bash

REPORT_DIR="reports"
MANIFEST="$REPORT_DIR/manifest"

# Function to process a single log file and create annotations
process_log() {
  local severity=$1
  local stderr_file=$2
  local tool=$3

  if [[ -f "$stderr_file" ]]; then
    local buffer=""
    local capture=false
    local severity_pattern="^[[:space:]]*$severity:"

    while IFS= read -r line; do
      # Check if the line starts with the severity
      if [[ "$line" =~ $severity_pattern ]]; then
        # Output the previous buffer as an annotation, if capturing
        if [[ "$capture" == true ]]; then
          printf "::${severity} title=$tool::$buffer::endgroup::\n"
          buffer=""
        fi
        # Start capturing the new message
        capture=true
        buffer="${BASH_REMATCH[1]}: ${line#*:}"
      elif [[ "$capture" == true ]]; then
        # Append lines to the buffer
        buffer+="\n${line}"
      fi
    done <"$stderr_file"

    # Output the last buffer if any
    if [[ "$capture" == true ]]; then
      printf "::${severity} title=$tool::$buffer::endgroup::\n"
    fi
  fi
}

# Iterate over each tool in the manifest
while IFS= read -r line; do
  STATUS=$(echo "$line" | awk '{print $1}')
  TOOL=$(echo "$line" | awk '{print $2}')

  STDERR_FILE="$REPORT_DIR/$TOOL/stderr.log"

  for SEVERITY in error warning hint; do
    process_log "$SEVERITY" "$STDERR_FILE" "$TOOL"
  done
done <"$MANIFEST"
