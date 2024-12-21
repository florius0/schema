#!/bin/bash

REPORT_DIR="reports"
MANIFEST_FILE="$REPORT_DIR/manifest"

# Print table header
printf "| %-15s | %-8s |\n" "Tool" "Status"
printf "| %-15s | %-8s |\n" "---------------" "--------"

# Read the manifest line by line and format the output
while read -r line; do
  # Extract status and tool name
  STATUS=$(echo "$line" | awk '{print $1}')
  TOOL=$(echo "$line" | awk '{print $2}')

  # Print the row
  printf "| %-15s | %-8s |\n" "$TOOL" "$STATUS"
done <"$MANIFEST_FILE"
