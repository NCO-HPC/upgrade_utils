#! /usr/bin/env bash
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
# Modified by A.Bigdeli Aug-2024 (arash.bigdeli@noaa.gov)
#

TMP=${TMP:-$(pwd)/}
target_add=$1
if [ -d "target_add" ]; then
echo "$0: this script requires one argument, the path to package directory"
exit 1
fi
pushd $target_add > /dev/null

tmpfile=${TMP}/output.$(date +%s).$$

patterns=( "prod_util" "fsync_file|\$FSYNC" "mdate|\$MDATE" "ndate|\$NDATE" "nhour|\$NHOUR" )
grep_pattern=$(echo "${patterns[@]}" | sed 's/\$/\\$/g' | sed 's/ /|/g')

for filename in $(find ./jobs ./scripts ./ush \( -name "*.sh" -o -name "*.ecf" -o -name "J*" \)); do
#    nocomment.sh $filename | grep -E -w -H --label "In filename: $filename" "$grep_pattern" "$filename" >> $tmpfile
    nocomment.sh $filename | grep -E -w -H --label "In filename: $filename" "$grep_pattern" >> $tmpfile
done


for pattern in ${patterns[@]}; do
    escaped_pattern=$(echo "$pattern" | sed 's/\$/\\$/g')
    count=$(grep -Eo "$escaped_pattern" "$tmpfile" | wc -l)
    echo "Number of occurrences of '$pattern': $count"
done

#rm -rf $tmpfile
popd > /dev/null
