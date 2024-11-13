#!/bin/bash
#####
# Purpose:
# This script is run in the root directory of a WCOSS code package. It iterates
# over all scripts and looks for a contiguous block of commented lines
# at the beginning of the file and displays them using 'less'.
#####
# Usage:
# $ cd /path/to/mycode.v1.2.3 ; interpreted_8.sh
#####
# Written by Alex Richert (alexander.richert@noaa.gov)
#

for f in $(find ./jobs/ ./scripts/ ./ush/ -type f); do
 cat <(echo $f:) <(nocomment.sh $f -c -h | grep -Ev "^[[:space:]]*$" | grep "[[:cntrl:]]\[00;38;05;196m" | sed "/[[:cntrl:]]\[00;38;05;196m/!Q") | less -R
done
