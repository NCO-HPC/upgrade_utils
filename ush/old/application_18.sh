#!/bin/bash
#####
# application_18.sh
#####
# Purpose:
#
# IT checklist, Application/Coordination #18: "If GRIB utilities are needed, is
# the grib_util module loaded and used?"
#
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

TMP=${TMP:-/tmp/}

tmpfile=${TMP}.$(date +%s.%n).$$

patterns=( grib_util cnvgrib copygb copygb2 degrib2 grb2index grbindex grib2grib tocgrib tocgrib2 tocgrib2super wgrib wgrib2 )

for filename in $(find ./jobs ./scripts ./ush \( -name "*.sh" -o -name "*.sh.ecf" -o -name "J*" \)); do
nocomment_dummy.sh $filename | grep -E "$(echo ${patterns[@]} | sed 's/\ /|/g' )" >> $tmpfile
done

for pattern in ${patterns[@]}; do
 echo "Number of occurrences of '$pattern': $(grep -Ec $pattern $tmpfile)"
done

rm -rf $tmpfile

