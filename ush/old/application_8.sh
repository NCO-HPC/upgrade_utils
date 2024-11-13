#!/bin/bash
#####
# application_8.sh
#####
# Purpose:
#
# IT checklist, Application/Coordination #8: "Are all executables wrapped with
# production utilities, prep_step, startmsg, err_chk?"
#
# This script is run in the root directory of a WCOSS code package. It finds
# all shell scripts and checks usage of various utilities, as well as setting
# of FORT variables.
#####
# Usage:
# $ cd /path/to/mycode.v1.2.3 ; application_8.sh
#####
# Written by Alex Richert (alexander.richert@noaa.gov)
#

# err_chk check:
files=$(find ./jobs ./scripts ./ush -type f | xargs file | grep -e "shell script" -e ".ecf:" | awk -F':' '{print $1}')
outarr=( )
for file in $(find ./jobs | xargs file | grep "shell script" | awk -F':' '{print $1}'); do
 mapfile -t output < <(nocomment_dummy.sh $file | grep --line-number -Ff <(sed 's|^.*/||g' <(echo ${files} | sed 's|\ |\n|g')) -A 2)
 count=$(echo ${output[@]:1:2} | grep -wc "err_chk")
 if [ $count -eq 0 ]; then outarr+=( "${output[0]}" ); fi
done
if [ ${#outarr[@]} -ne 0 ]; then
echo "D'OH, 'err_chk' not found in the following places:"
for out in "${outarr[@]}"; do
if [ ${#out} -gt 0 ]; then echo "$out"; fi
done
fi

echo '###############'
# prep_step check. look for FORT variables; if they exist, make sure we've got prep_step
for file in ${files}; do
 nfort=$(nocomment_dummy.sh $file | grep -cP 'export FORT(?!_BUFFERED)')
 nprep=$(nocomment_dummy.sh $file | grep --max-count=1 "export FORT" -B 9999999 | grep -c prep_step)
 if [[ $nfort -gt 0 && $nprep -eq 0 ]]; then
  echo "D'OH, '$file' is setting FORT variables without using prep_step first!"
 fi
done
