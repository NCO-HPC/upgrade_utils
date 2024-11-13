#!/bin/bash
#####
# interpreted_10.sh
#####
# Purpose:
#
# IT checklist, Interpreted Code #10: "Is debug logging turned on with set -x
# in shell scripts?"
#
# This code is run in the root directory of a WCOSS code package. It checks all
# shell scripts for appearances of set -x and prints the number of occurrences
# for each file to stdout.
#####
# Usage:
# $ cd /path/to/mycode.v1.2.3 ; interpreted_10.sh
# >  ./ush/forecast.sh: 0
# >  ./sorc/build_mycode.sh: 1
# >  ./scripts/exmycode.sh.ecf: 3
# >  ./ecf/jmycode_12.ecf: 1
# >  ./ecf/jmycode_00.ecf: 1
# >  ./jobs/JMYCODE: 1
#####
# Written by Alex Richert (alexander.richert@noaa.gov)
#

allgood=YES
output=""
for f in $(find ./jobs ./scripts ./ush -type f | xargs file | grep -e ".ecf" -e "shell script" | awk -F ':' '{print $1}'); do
 out=$(grep -c "set -x" $f | sed "s|^|$f: |")
 output="$output\n$out"
 if [ $(echo $out | awk '{print NF}') -eq 0 ]; then allgood=NO; fi
done

if [ $allgood == YES ]; then
echo "Yay, set -x found in every shell script!"
else
echo "Occurrences of 'set -x' in each shell script:"
echo -e $output
fi
