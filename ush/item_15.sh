#! /usr/bin/env bash
#####
# Purpose:
# This script compares the libraries used by a package and checks if they are approved for production.
#
# Currently  approved locations 
# like /apps/prod, /pe/intel, /lib64, or /opt/cray.
#
# Outputs:
# (A)pproved: Libraries in approved directories
# (N)ot Approved: Libraries not in approved directories
#
# Usage:
# $ check_libraries.sh /path/to/package
#
# Written by: Arash Bigdeli (Arash.bigdeli@noaa.gov) Aug 2024
######

# Function to check if a library is approved for production
check_library() {
    local lib=$1

    # Check if the library path starts with /apps/prod
    if [[ "$lib" == /apps/prod/* || \
	"$lib" == /pe/intel/* || \
	"$lib" == /lib64/* || \
	"$lib" == /usr/lib64/* || \
	"$lib" == /opt/cray/* ]]; then
        echo "Approved: $lib"
    else
        echo "Not Approved: $lib"
    fi
}

# Function to list dynamic libraries of the executables in the package
check_package_libraries() {
    local package_dir=$1

    # Find all executables and shared libraries in the package
    find "$package_dir" \
	-not -path "*/fix/*" \
	-not -path "*/parm/*" \
	-not -path "*/.git/*" \
	-not -path "*/.svn/*" \
	-type f -exec file {} \; \
       | grep 'executable\|shared object' | grep -v "\.py" | grep -v "\.sh" \
       | awk -F: '{print $1}' \
       | while read -r executable; do
        echo "Checking libraries for: $executable"

        # Use ldd to list dynamic libraries
        ldd "$executable" 2>/dev/null | grep "=> /" | awk '{print $3}' | while read -r lib; do
            check_library "$lib"
        done
    done
}

# Ensure a package directory is provided as an argument
if [ $# -eq 0 ]; then
    echo "Usage: $0 <package-directory>"
    exit 1
fi

# Run the check on the provided package directory
package_dir="$1"
check_package_libraries "$package_dir"

