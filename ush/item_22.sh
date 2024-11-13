#!/usr/bin/env bash

#####
# Purpose: 
# This script verifies the following:
# 1. Ensures that the system version of Python (Python 2) is NOT being used and Python3 or higher is being used.
# 2. Ensures that execution trace is turned on with 'set -x' in shell scripts.
# 3. Ensures that all interpreted scripts (shell, Python, etc.) have the correct interpreter at the top.
#
# Usage:
# $ ./verify_scripts.sh /path/to/package [-v]
#
#####

# Input directory (package path)
PACKAGE_DIR="$1"
shift  # Shift to process any remaining options

# Default values
verbose=false

# Process options
while [[ "$1" ]]; do
  case "$1" in
    -v)  # Enable verbose mode
      verbose=true
      ;;
    *)
      echo "Unknown option: $1"
      exit 1
      ;;
  esac
  shift
done

# Helper function to check for system Python usage
check_python_version() {
  $verbose && echo "Checking for Python version usage in Python scripts..."
  
  find "$PACKAGE_DIR" -type f \( -path "$PACKAGE_DIR/fix" -o -path "$PACKAGE_DIR/dev" -o -path "$PACKAGE_DIR/.git" \) -prune -o \
    -type f -exec file {} + | grep -E "Python script" | awk -F ':' '{print $1}' | while read -r script; do
    python_calls=$(grep -E '^.*python[[:digit:]]*' "$script")
    if [[ -n "$python_calls" ]]; then
      $verbose && echo "Checking Python version in $script"
      if echo "$python_calls" | grep -qE 'python[2]'; then
        echo "Error: $script is using Python 2 or system Python. Please update to Python 3."
      elif echo "$python_calls" | grep -qE 'python3'; then
        $verbose && echo "$script is using Python 3. This is correct."
      else
        echo "Warning: $script does not specify Python 3. Ensure Python 3 or higher is being used."
      fi
    fi
  done
}

# Helper function to check if 'set -x' is present in shell scripts
check_set_x_in_shell_scripts() {
  $verbose && echo "Checking for 'set -x' in shell scripts..."
  
  find "$PACKAGE_DIR" -type f \( -path "$PACKAGE_DIR/fix" -o -path "$PACKAGE_DIR/dev" -o -path "$PACKAGE_DIR/.git" \) -prune -o \
    -type f -exec file {} + | grep -E "shell script" | awk -F ':' '{print $1}' | while read -r script; do
    if grep -q 'set -x' "$script"; then
      $verbose && echo "'set -x' is present in $script."
    else
      echo "Error: 'set -x' is missing in $script. Please enable execution tracing."
    fi
  done
}

# Helper function to check for correct shebang in scripts
check_shebang_in_scripts() {
  $verbose && echo "Checking for correct shebang in scripts..."
  
  find "$PACKAGE_DIR" -type f \( -path "$PACKAGE_DIR/fix" -o -path "$PACKAGE_DIR/dev" -o -path "$PACKAGE_DIR/.git" \) -prune -o \
    -type f -exec file {} + | grep -E "shell script|Python script" | awk -F ':' '{print $1}' | while read -r script; do
    first_line=$(head -n 1 "$script")
    if [[ "$first_line" =~ ^#!/ ]]; then
      $verbose && echo "Shebang is present in $script."
    else
      echo "Error: Shebang is missing in $script. Add the correct interpreter (e.g., #!/bin/bash, #!/usr/bin/env python3)."
    fi
  done
}

# Run checks
if [[ -z "$PACKAGE_DIR" ]]; then
  echo "Error: No package directory provided. Usage: ./verify_scripts.sh /path/to/package [-v]"
  exit 1
fi

if [[ ! -d "$PACKAGE_DIR" ]]; then
  echo "Error: The provided path is not a valid directory."
  exit 1
fi

# Perform the checks
check_python_version
check_set_x_in_shell_scripts
check_shebang_in_scripts

echo "All checks completed."

