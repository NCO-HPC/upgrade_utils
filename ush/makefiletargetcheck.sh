#!/bin/bash
# Check for targets: all debug install clean test
# Run from top-level model directory

for file in $(find ./ -iname makefile -not -path '*.svn/*' -not -path '*.git/*'); do
 for target in all debug install clean test; do
  present=$(grep -E "^$target:" $file)
  if [ -z "$present" ]; then missing=$missing" "$target; fi
 done
 if [ ${#missing} -gt 0 ]; then
  echo "'$file' is missing targets: $(echo $missing | sed 's/://g')"
 fi
done
