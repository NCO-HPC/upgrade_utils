#!/bin/bash
#####
# Purpose:
# Prints out the number of executables in each subdirectory of ./sorc/ (including ./sorc/ itself).
#####
# Usage:
# Run in code package root directory AFTER COMPILATION.
#####
# Written by Alex Richert (alexander.richert@noaa.gov)
#

for dir in $(find ./sorc/ -type d); do
 execount=$(find $dir -maxdepth 1 -type f -executable -exec file -i '{}' \; | grep 'x-executable; charset=binary' -c)
 echo "$dir: $execount executables"
done
