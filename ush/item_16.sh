#!/usr/bin/env bash

#####
# Purpose:
# This script checks if the latest version of all external software (including MPI and compilers)
# is being used by comparing the versions in build.ver with the latest versions available in lmod.
# It resets the modules at the start and restores the original set of modules after it completes.
#
# Usage:
# $ check_software_versions.sh /path/to/package
#
# Written by: Arash Bigdeli (Arash.bigdeli@noaa.gov) Aug 2024
#####

# Temporary file to store the current list of loaded modules
tmpfile=$(mktemp)

# Save the currently loaded modules
module list > "$tmpfile" 2>&1

# Function to extract module names from the saved list
extract_loaded_modules() {
    grep -oP '^\s*\d+\)\s*\K[^ ]+' "$tmpfile" | grep -v '(H)'
}

# Reset all modules to start with a clean environment
module reset
module load intel

# Ensure that the package directory is provided as an argument
if [ $# -lt 1 ]; then
    echo "Usage: $0 /path/to/package"
    exit 1
fi

package_dir=$1
build_ver_file="$package_dir/versions/build.ver"

# Check if the build.ver file exists
if [ ! -f "$build_ver_file" ]; then
    echo "Error: $build_ver_file not found."
    exit 1
fi

# Function to extract versions from the build.ver file
extract_versions() {
    local ver_file=$1
    
    # Extract lines with 'export', remove 'export', split by '=', and format
    grep '^export ' "$ver_file" | while IFS="=" read -r var_name version; do
        software=$(echo "$var_name" | sed 's/^export //; s/_ver$//')  # Remove 'export ' and '_ver'
	version=$(echo "$version" | sed 's/^"//; s/"$//')  # Strip surrounding quotes from version
        echo "$software:$version"
    done
}

# Function to strip non-numeric characters from version strings
strip_non_numeric() {
    echo "$1" | sed 's/[^0-9.]//g'
}

# Function to get the latest version from lmod (using module spider)
get_latest_version() {
    local software=$1

    # Replace underscores with hyphens for module names only if it is PrgEnv
    if [[ $software == PrgEnv* || $software == cray* ]]; then
        module_name=$(echo "$software" | sed 's/_/-/g')
    else
        module_name="$software"
    fi
    # Use module spider to get available versions for the given software
    spider_output=$(module spider $module_name 2>&1)

    # Check if module spider returned valid data
    if [[ $spider_output == *"No module matches"* ]]; then
        return
    fi

    # Try to extract the version from the output
    latest_version=$(echo "$spider_output" | grep -Eo "$module_name/[0-9.]+" | sort -V | tail -1 | awk -F'/' '{print $2}')
    
    # Return the latest version
    echo "$latest_version"
}

# Function to compare the installed version with the latest available version
compare_versions() {
    local software=$1
    local current_version=$2

    # Get the latest version
    latest_version=$(get_latest_version "$software")
    
    if [ -z "$latest_version" ]; then
        printf "Error, missed    %-15s : No version information availabl in lmod \n" $software
        return
    fi

    # Strip non-numeric characters from versions
    stripped_current_version=$(strip_non_numeric "$current_version")
    stripped_latest_version=$(strip_non_numeric "$latest_version")

    if [[ "$stripped_current_version" == "$stripped_latest_version" ]]; then
        printf "Up to date       %-15s : $current_version \n" $software
    else
        printf "Error, Outdated  %-15s : current=$stripped_current_version vs latest=$stripped_latest_version \n" $software
    fi
}

# Main script logic to extract and compare versions
echo "Extracting versions from $build_ver_file..."
echo "==========================================="
extract_versions "$build_ver_file" | while IFS=":" read -r software version; do
    compare_versions "$software" "$version"
done

# Restore the previously loaded modules
echo "==========================================="
echo "Restoring original modules..."
for mod in $(extract_loaded_modules); do
    module load "$mod"
done

# Cleanup temporary file
rm -f "$tmpfile"

echo "Script completed, and original modules have been restored."

