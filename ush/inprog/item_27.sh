#!/bin/bash
#####
# Purpose:
# This script is run in the root directory of a WCOSS code package. It checks
# all scripts for use of the grib_util module, then checks for uses of the
# individual utilities.
#####
# Usage:
# $ cd /path/to/mycode.v1.2.3 ; application_18.sh
# > Number of occurrences of 'grib_util': 3
# > Number of occurrences of 'cnvgrib': 0
# > Number of occurrences of 'copygb': 9
# > Number of occurrences of 'copygb2': 9
# > Number of occurrences of 'degrib2': 2
# > Number of occurrences of 'grb2index': 0
# > Number of occurrences of 'grbindex': 0
# > Number of occurrences of 'grib2grib': 0
# > Number of occurrences of 'tocgrib': 6
# > Number of occurrences of 'tocgrib2': 6
# > Number of occurrences of 'tocgrib2super': 0
# > Number of occurrences of 'wgrib': 17
# > Number of occurrences of 'wgrib2': 17
#####
# Written by Alex Richert (alexander.richert@noaa.gov)
#

target_add=$1
pushd $target_add > /dev/null
TMP=${TMP:-/tmp/}

tmpfile=${TMP}.$(date +%s.%n).$$

patterns=( grib_util cnvgrib copygb copygb2 degrib2 grb2index grbindex grib2grib tocgrib tocgrib2 tocgrib2super wgrib wgrib2 '\$CNVGRIB' '\$COPYGB' '\$COPYGB2' '\$DEGRIB2' '\$GRB2INDEX' '\$GRBINDEX' '\$GRIB2GRIB' '\$TOCGRIB' '\$TOCGRIB2' '\$TOCGRIB2SUPER' '\$WGRIB' '\$WGRIB2' )

for filename in $(find ./ecf ./jobs ./scripts ./ush ); do
nocomment.sh $filename | grep -wE "$(echo ${patterns[@]} | sed 's/\ /|/g' )" >> $tmpfile
done

for pattern in ${patterns[@]}; do
 echo "Number of occurrences of '$pattern': $(grep -Ec $pattern $tmpfile)"
done

rm -rf $tmpfile
popd > /dev/null
