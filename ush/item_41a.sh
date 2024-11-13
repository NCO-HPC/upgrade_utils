#!/bin/bash
#####
# Purpose:
# This script is run in the root directory of a WCOSS code package. It iterates
# over all files in ./sorc/ and looks for a contiguous block of commented lines
# at the beginning of the file and displays them using 'less'.
#####
# Use ctrl_c to stop the iteration
#####
# Written by Alex Richert (alexander.richert@noaa.gov)
# Modified by A.Bigdeli Aug-2022 (arash.bigdeli@noaa.gov)
#
trap ctrl_c INT

target_add=$1
pushd $target_add > /dev/null

function ctrl_c() {
exit 1
}

for f in $(find ./sorc/* -type f); do
 cat <(echo $f:) <(nocomment.sh $f -c -h | grep -Ev "^[[:space:]]*$" | grep "[[:cntrl:]]\[00;38;05;196m" | sed "/[[:cntrl:]]\[00;38;05;196m/!Q") | less -R --prompt="press 'q' to quit and go to next file"
done
popd > /dev/null
