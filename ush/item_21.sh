#!/usr/bin/env bash

#####
# Purpose: 
# This script checks if standard file naming conventions have been followed for new publicly distributed output as per WCOSS implementation standards (Section IIIb).
#
# Usage:
# $ ./check_filename_conventions.sh /path/to/COMdir [-p PDY] [-v] [-b] [-x .png] [-x subdir] [-h]
# Where:
#    /path/to/COMdir is the directory to scan for files.
#    -p is used to specify the date (YYYYMMDD). If not provided, the latest date found in the directories will be used.
#    -v enables verbose output.
#    -b enables brief mode, limiting the number of reported errors per subdirectory.
#    -x is used to exclude specific file extensions (e.g., .png, .gif) or subdirectories.
#    -h displays help information.
#####

# Display help
function display_help {
  echo "Usage: $0 /path/to/COMdir [-p PDY] [-v] [-b] [-x .png] [-x subdir] [-h]"
  echo
  echo "Options:"
  echo "  /path/to/COMdir   The directory to scan for files."
  echo "  -p PDY            Specify the date (YYYYMMDD). If not provided, the latest date found in the directories will be used."
  echo "  -v                Enable verbose output."
  echo "  -b                Enable brief mode, limiting the number of reported errors per subdirectory."
  echo "  -x EXT            Exclude specific file extensions (e.g., .png, .gif)."
  echo "  -x subdir         Exclude specific subdirectories from being checked."
  echo "  -h                Display this help message."
  echo
}

# Check for help flag
if [[ "$1" == "-h" ]]; then
  display_help
  exit 0
fi

# Input directory
COMdir="$1"
shift 1  # Shift off the first argument to process other options

# Extract the model name (NET/package_name) from the directory path
NET=$(echo "$COMdir" | sed -n 's#.*/com/\([^/]*\)/.*#\1#p')

# Optional PDY (date)
PDY=""

# Default to non-verbose and non-brief modes
verbose=false
brief=false

# Arrays to hold file extensions and subdirectory exclusions
exclude_exts=()
exclude_subdirs=()

# Max errors to report per subdirectory (when brief mode is enabled)
max_errors=1

# Process options
while [[ "$1" ]]; do
  case "$1" in
    -p)  # If -p is used, the next argument is the PDY
      shift
      PDY="$1"
      ;;
    -v)  # If -v is used, enable verbose mode
      verbose=true
      ;;
    -b)  # If -b is used, enable brief mode
      brief=true
      ;;
    -x)  # If -x is used, dynamically detect whether its a file extension or subdirectory
      shift
      arg="$1"
      if [[ "$arg" == .* ]]; then
        exclude_exts+=("$arg")  # Treat as a file extension
      else
        exclude_subdirs+=("$arg")  # Treat as a subdirectory
      fi
      ;;
    *)
      echo "Unknown argument: $1"
      exit 1
      ;;
  esac
  shift
done

# If PDY is not provided, find the latest PDY
if [ -z "$PDY" ]; then
  echo "No PDY provided. Searching for the latest available PDY..."
  PDY=$(find "$COMdir" -maxdepth 1 -type d | awk -F/ '{print substr($NF, length($NF)-7, 8)}' | sort -nr | head -n1)
  if [ -z "$PDY" ]; then
    echo "Error: No valid PDY found in the directory."
    exit 1
  fi
  echo "Using the latest PDY: $PDY"
else
  echo "Using user defind PDY=$PDY"
fi

# Extract YYYYMM from the PDY
YYYYMM=${PDY:0:6}

# Prepare the exclusion string for the find command
exclude_args=""
for ext in "${exclude_exts[@]}"; do
  exclude_args+=" -not -name '*${ext}'"
done
for subdir in "${exclude_subdirs[@]}"; do
  exclude_args+=" -not -path '*/${subdir}/*'"
done


echo "Running with excluded extensions: ${exclude_exts[@]}"
echo "Running with excluded subdirs: ${exclude_subdirs[@]}"
echo "==============================================================" 

# Function to validate if an 8-digit number looks like a date (YYYYMMDD)
is_valid_date() {
  local date_str="$1"
  local year=${date_str:0:4}
  local month=${date_str:4:2}
  local day=${date_str:6:2}

  if (( year < 1900 || year > 2100 )); then
    return 1  # Invalid year
  fi

  if (( month < 1 || month > 12 )); then
    return 1  # Invalid month
  fi

  if (( day < 1 || day > 31 )); then
    return 1  # Invalid day
  fi

  return 0  # It's a valid date
}

# Function to check file naming conventions with brief mode
check_filename_convention() {
  local filename="$1"
  local fullpath="$2"
  local basedir="$3"
  local error_type="$4"
  
  # Maintain a count of errors per directory and type
  if [[ $brief == true ]]; then
    if [[ -z "${error_counts[$basedir,$error_type]}" ]]; then
      error_counts[$basedir,$error_type]=0
    fi
    # Skip reporting if we've reached the max number of errors for this type in this directory
    if (( ${error_counts[$basedir,$error_type]:-0} >= ${max_errors} )); then
      return 1
    fi
    error_counts[$basedir,$error_type]=$(( ${error_counts[$basedir,$error_type]:-0} + 1 ))
  fi

  echo "Error: $error_type in file '$fullpath'."
  
  return 0
}

# Function to process files
process_files() {
  local dir="$1"
  $verbose && echo "Parsing directory: $dir"
  declare -A error_counts  # Reset error counts per subdirectory

  for fullpath in $(eval "find '$dir' -type f -not -name '*.dbnlog' $exclude_args"); do
    filename=$(basename "$fullpath")
    basedir=$(dirname "$fullpath")

    # Verbose: Print the filename being processed if verbose mode is on
    $verbose && echo "Checking file: $filename in directory $basedir"

    # Skip certain subdirectories or hidden files (optional)
    if [[ "$filename" == .* ]]; then
      continue
    fi

    # Error 1: Detect if a part of the filename resembles a date
    if [[ "$filename" =~ [0-9]{8} ]]; then
      date_str=$(echo "$filename" | grep -oE '[0-9]{8}')
      if is_valid_date "$date_str"; then
        check_filename_convention "$filename" "$fullpath" "$basedir" "contains a valid date"
      fi
    fi

    # Error 2: Incorrect model name (NET)
    if [[ "$basedir" != *"/wmo"* && "$basedir" != *"/gempak"* ]]; then
      first_word=$(echo "$filename" | cut -d'.' -f1)
      if [ "$first_word" != "$NET" ]; then
        check_filename_convention "$filename" "$fullpath" "$basedir" "does not start with the correct model name ($NET)"
      fi
    fi

    # Error 3: Improper use of periods and underscores
    if [[ "$filename" =~ [^._a-z0-9] ]]; then
      check_filename_convention "$filename" "$fullpath" "$basedir" "should use periods for categories and underscores for words within categories"
    fi

    # Error 4: Unrecognized binary format extension
    if [[ ! "$filename" =~ \.(grib2|bin\.idx|grib2\.idx|nc)$ ]]; then
      file_type=$(file -b "$fullpath")
      if [[ "$file_type" != *"ASCII"* ]]; then
        if [[ "$basedir" == *"/wmo"* || "$basedir" == *"/gempak"* ]]; then
          $verbose && echo "Info: File '$fullpath' is in binary format but follows wmo or gempak-specific rules."
        else
          check_filename_convention "$filename" "$fullpath" "$basedir" "is in binary format and has an unrecognized extension"
        fi
      fi
    fi

    # Stop processing further files if maximum errors are reached in brief mode
    if [[ $brief == true ]] && (( ${error_counts[$basedir]:-0} >= ${max_errors} )); then
      $verbose && echo "Reached maximum error reporting for directory: $basedir"
      break
    fi
  done
}

# Function to process directories based on pattern
process_top_level_dirs() {
  $verbose && echo "Processing top-level directories in $COMdir"

  for dir in $(find "$COMdir" -maxdepth 1 -mindepth 1 -type d); do
    base_dir=$(basename "$dir")

    # Case 1: Directories matching *.YYYYMM
    if [[ "$base_dir" =~ \.[0-9]{6}$ ]]; then
      dir_yyyymm=${base_dir: -6}
      if [[ "$dir_yyyymm" == "$YYYYMM" ]]; then
        $verbose && echo "Processing directory with YYYYMM: $base_dir"
        process_files "$dir"
      fi
    # Case 2: Directories without any date
    elif [[ ! "$base_dir" =~ \.[0-9]{8}$ && ! "$base_dir" =~ \.[0-9]{6}$ ]]; then
      $verbose && echo "Processing directory without date: $base_dir"
      process_files "$dir"
    fi
  done
}

# Function to run the find command and iterate over directories with PDY
run_find_command() {
  $verbose && echo "Running find command for PDY directories: $PDY"
  for dir in $(find "$COMdir" -type d -name "*.$PDY"); do
    # Skip excluded subdirectories
    for subdir in "${exclude_subdirs[@]}"; do
      if [[ "$dir" == *"$subdir"* ]]; then
        $verbose && echo "Skipping excluded subdirectory: $dir"
        continue 2  # Skip this iteration of the loop
      fi
    done

    $verbose && echo "Found directory: $dir"
    # Process files in the found directory
    process_files "$dir"
  done
}

# Initial run of the find command (for directories with PDY)
run_find_command

# Process top-level directories (without PDY pattern)
process_top_level_dirs

# Re-run if any files were excluded and the user wants additional processing
if [ "${#exclude_exts[@]}" -gt 0 ]; then
  $verbose && echo "Excluding the following file types: ${exclude_exts[*]}"
fi
if [ "${#exclude_subdirs[@]}" -gt 0 ]; then
  $verbose && echo "Excluding the following subdirectories: ${exclude_subdirs[*]}"
fi

