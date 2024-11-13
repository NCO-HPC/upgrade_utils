#!/bin/bash
#####
# Purpose:
#
# This script is run in the root directory of a WCOSS code package. It checks
# whether compiled executables match their parent directory names. Non-matching
# ones are printed to stdout.
#####
# Usage:
# $ cd /path/to/mycode.v1.2.3 ; compiled_6.sh
# >  Executable name does not match parent directory for /path/to/mycode.v1.2.3/sorc/mycode.fd/run.exe
#####
# Written by Alex Richert (alexander.richert@noaa.gov)
#
target_add=$1
pushd $target_add > /dev/null
types=(makefile FORTRAN C C++ Python POSIX Bourne-Again Korn ELF)

allgood=YES
for f in $(find $PWD/sorc -type f -executable -exec file -i '{}' \; | grep 'x-executable; charset=binary' | awk -F ":" '{print $1}'); do
q=$(echo $f | perl -pe "s|.*?([^\/]*?)(\.\w+)?\/([^\/]*)$|\1 \3|g;s|\s|\n|g" | uniq | wc -l)
if [ $q -ne 1 ]; then
echo "ERROR! Executable name does not match parent directory for $f"
allgood=NO
fi
done
if [ $allgood == YES ]; then echo "Yay, no executables were found in ./sorc/ whose names didn't match their respective parent directories"; fi
popd > /dev/null
