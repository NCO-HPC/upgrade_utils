#!/bin/bash
#####
# Purpose:
#
# This script is run in the root directory of a WCOSS code package. It checks
# all scripts for use of the prod_util module and its utilities (fsync_file, 
# mdate, ndate, nhour).
#####
# Usage:
# $ cd /path/to/mycode.v1.2.3 ; application_17.sh
# > Number of occurrences of 'prod_util': 2
# > Number of occurrences of 'fsync_file|$FSYNC': 0
# > Number of occurrences of 'mdate|$MDATE': 3
# > Number of occurrences of 'ndate|$NDATE': 2
# > Number of occurrences of 'nhour|$NHOUR': 0
#####
# Written by Alex Richert (alexander.richert@noaa.gov)
# Modified by A.Bigdeli Aug-2022 (arash.bigdeli@noaa.gov)
#

target_add=$1
pushd $target_add > /dev/null
TMP=${TMP:-/tmp/}

tmpfile=${TMP}.$(date +%s.%n).$$

patterns=( "prod_util" "fsync_file|\$FSYNC" "mdate|\$MDATE" "ndate|\$NDATE" "nhour|\$NHOUR" )

for filename in $(find ./jobs ./scripts ./ush \( -name "*.sh" -o -name "*.ecf" -o -name "J*" \)); do
nocomment.sh $filename | grep -E "$(echo ${patterns[@]} | sed 's/\ /|/g' )" >> $tmpfile
done

for pattern in ${patterns[@]}; do
 echo "Number of occurrences of '$pattern': $(grep -Ec $pattern $tmpfile)"
done

rm -rf $tmpfile
popd > /dev/null
