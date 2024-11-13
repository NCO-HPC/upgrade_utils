#!/bin/bash
#####
# Purpose:
# Prints out the number of executables in each subdirectory of ./sorc/ (including ./sorc/ itself).
#####
# Usage:
# Run in code package root directory AFTER COMPILATION.
#####
# Written by Alex Richert (alexander.richert@noaa.gov)
# Modified by A.Bigdeli Aug-2022 (arash.bigdeli@noaa.gov)
#
target_add=$1
pushd $target_add > /dev/null

for dir in $(find ./sorc/ -type d); do
 execount=$(find $dir -maxdepth 1 -type f -executable -exec file -i '{}' \; | grep 'x-executable; charset=binary' -c)
 echo "$dir: $execount executables"
done
popd > /dev/null
