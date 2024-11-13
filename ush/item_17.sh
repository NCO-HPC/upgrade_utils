#!/usr/bin/env bash

#####
# Purpose:
# This script checks whether any absolute paths to libraries remain in Makefiles
# within the 'sorc' directory of a specified package.
#
# Usage:
# $ check_absolute_paths_in_makefiles.sh /path/to/package
#
# The script only searches for absolute paths (starting with '/') in Makefile files 
# located in the /path/to/package/sorc directory.
#
# Written by: Arash Bigdeli (Arash.bigdeli@noaa.gov) Sept 2024
#####

# Ensure that the package directory is provided as an argument
if [ $# -lt 1 ]; then
    echo "Usage: $0 /path/to/package"
    exit 1
fi

package_dir=$1
sorc_dir="$package_dir/sorc"

# Check if the 'sorc' directory exists
if [ ! -d "$sorc_dir" ]; then
    echo "Error: $sorc_dir does not exist."
    exit 1
fi

# Flag to track if absolute paths were found
found_absolute_paths=0

# Function to check for absolute paths in Makefiles within 'sorc' directory
check_makefiles_for_absolute_paths() {
    local dir=$1

    # Find all Makefiles in the 'sorc' directory and its subdirectories
    find "$dir" -type f -name 'Makefile' | while read -r makefile; do
        # Search for absolute paths (those starting with /) in the Makefile (ignoring comments and empty lines)
        # Also, ignore common system paths like /bin, /usr/bin, assignments for system commands like RM, MKDIR, CP, etc.,
        # and exclude sed-style substitutions like -e "s/OMPG/ /g".
        if grep -E '(^|[^:])\s+/\S+' "$makefile" | grep -vE '^\s*#' | grep -vE '^$' | grep -vE '^\s*/bin|^\s*/usr/bin|^\s*(SHELL|RM|MKDIR|CP|ECHO)\s*=' | grep -vE '-e\s*"s/[^/]+/[^/]+/g"' > /dev/null; then
            echo "Absolute paths found in $makefile:"
            grep -E '(^|[^:])\s+/\S+' "$makefile" | grep -vE '^\s*#' | grep -vE '^$' | grep -vE '^\s*/bin|^\s*/usr/bin|^\s*(SHELL|RM|MKDIR|CP|ECHO)\s*=' | grep -vE '-e\s*"s/[^/]+/[^/]+/g"'
            echo
            found_absolute_paths=1
        else
            # List Makefiles that passed the check
            echo "Passed: $makefile"
        fi
    done
}

# Run the function to check Makefiles in the 'sorc' directory
check_makefiles_for_absolute_paths "$sorc_dir"

# Print success message if no absolute paths were found
if [ $found_absolute_paths -eq 0 ]; then
    echo "Success: No absolute paths found in Makefiles."
fi

