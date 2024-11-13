#!/bin/bash
#####
# application_17.sh
#####
# Purpose:
#
# IT checklist, Application/Coordination #17: "Is the prod_util module loaded and used?"
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
#

TMP=${TMP:-/tmp/}

tmpfile=${TMP}.$(date +%s.%n).$$

patterns=( "prod_util" "fsync_file|\$FSYNC" "mdate|\$MDATE" "ndate|\$NDATE" "nhour|\$NHOUR" )

for filename in $(find ./jobs ./scripts ./ush \( -name "*.sh" -o -name "*.sh.ecf" -o -name "J*" \)); do
nocomment_dummy.sh $filename | grep -E "$(echo ${patterns[@]} | sed 's/\ /|/g' )" >> $tmpfile
done

for pattern in ${patterns[@]}; do
 echo "Number of occurrences of '$pattern': $(grep -Ec $pattern $tmpfile)"
done

rm -rf $tmpfile
