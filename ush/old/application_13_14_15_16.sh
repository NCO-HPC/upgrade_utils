#!/bin/bash
#####
# application_13_14_15.sh
#####
# Purpose:
# IT checklist, Application/Coordination
# #13: "Does the com directory structure follow the standard: $COMROOT/$NET/$envir/$RUN.$PDY?"
# #14: "Does the pcom directory structure follow the standard: $PCOMROOT/$envir/$RUN"
# #15: "Does the nwges directory structure follow the standard: $GESROOT/$envir/$RUN.$PDY or $GESROOT/$envir/$RUN"
#
# This script checks the stdout from a WCOSS job, gets certain variable values
# from the output of the 'env' command, and makes sure that those variables are
# properly set.
#####
# Usage:
##
# $ application_13_14_15.sh /gpfs/dell1/nco/ops/com/output/prod/today/amsu_estimation_0005.o18613728
# > Unable to predict PCOM
# > Could not find variable PCOM
# > Could not find variable GESIN
# > Could not find variable GESOUT
# > Variables COMIN, COMOUT are properly formatted!
#####
# Written by Alex Richert (alexander.richert@noaa.gov)
#####

if [ -z $1 ]; then
echo "$0: this script requires one argument, the path to a stdout file from a test run"
exit 1
fi

whichones="COMROOT|NET|envir|RUN|PDY|PCOMROOT|GESROOT|COMIN|COMOUT|PCOM|GESIN|GESOUT"

source <(sed -n '/^[[:space:]]*[^[:space:]]\+ + env$/,/[[:space:]]*[[:digit:]]\+ + /p' $1 | awk "/$whichones/ {print}" | grep -Ev -e "^\w+\(\)=" -e '^\}$' | sed 's|^|export |;s|\(export \w\+=\)\(.*\)|\1\"\2\"|' )
application_13_14_15_16_helper.py
