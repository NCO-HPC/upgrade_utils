#!/bin/bash
#####
# Purpose:
# This script is run in the root directory of a WCOSS code package. It checks
# for the use of prep_step.
#####
# Usage:
# $ cd /path/to/mycode.v1.2.3 ; application_8.sh
#####
# Written by Alex Richert (alexander.richert@noaa.gov)
# Modified by A.Bigdeli Aug-2022 (arash.bigdeli@noaa.gov)
#

target_add=$1
pushd $target_add > /dev/null
echo '###############'
# prep_step check. look for FORT variables; if they exist, make sure we've got prep_step
files=$(find ./jobs ./scripts ./ush -type f | xargs file | grep -e "shell script" -e ".ecf:" | awk -F':' '{print $1}')
for file in ${files}; do
 nfort=$(nocomment.sh $file | grep -cP 'export FORT(?!_BUFFERED)')
 nprep=$(nocomment.sh $file | grep --max-count=1 "export FORT" -B 9999999 | grep -c prep_step)
 if [[ $nfort -gt 0 && $nprep -eq 0 ]]; then
  echo "ERROR, '$file' is setting FORT variables without using prep_step first!"
 fi
done
popd > /dev/null
