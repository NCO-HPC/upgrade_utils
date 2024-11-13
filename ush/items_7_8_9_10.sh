#!/bin/bash
#####
# Purpose:
# This script checks the stdout from a WCOSS job, gets certain variable values
# from the output of the 'env' command, and makes sure that those variables are
# properly set.
#####
# Usage:
# $ application_13_14_15.sh /gpfs/dell1/nco/ops/com/output/prod/today/amsu_estimation_0005.o18613728
# > Unable to predict PCOM
# > Could not find variable PCOM
# > Could not find variable GESIN
# > Could not find variable GESOUT
# > Variables COMIN, COMOUT are properly formatted!
#####
# Written by Alex Richert (alexander.richert@noaa.gov)
# Modified by Arash Bigdeli Aug 2022 (arash.bigdeli@noaa.gov)
#####

targetlog="$1"

if [ -z "targetlog" ]; then
echo "$0: this script requires one argument, the path to a stdout file from a test run"
exit 1
fi
whichones="COMROOT|NET|envir|RUN|PDY|NWGES|GEMPAK|WMO|COMIN|COMOUT"

source <(sed -n '/^[[:space:]]*[^[:space:]]\+ + env$/,/[[:space:]]*[[:digit:]]\+ + /p' "$targetlog" | awk "/$whichones/ {print}" | grep -Ev -e "^\w+\(\)=" -e '^\}$' | sed 's|^|export |;s|\(export \w\+=\)\(.*\)|\1\"\2\"|' )

source <(sed -n '/^[[:space:]]*[^[:space:]]\+ + env$/,/[[:space:]]*[[:digit:]]\+ + /p' "$targetlog" | awk "/${NET}_ver/ {print}" | grep -Ev -e "^\w+\(\)=" -e '^\}$' | sed 's|^|export |;s|\(export \w\+=\)\(.*\)|\1\"\2\"|' )



varname=${NET}_ver
NET_ver=${!varname}
NET_ver_2D=$(echo $NET_ver | awk -F'.' '{print $1"."$2}')
export echo NET_ver_2D=${NET_ver_2D}
env
items_7_8_9_10_helper.py
