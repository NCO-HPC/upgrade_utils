#!/bin/bash
#####
# application_9.sh
#####
# Purpose:
#
# IT checklist, Application/Coordination #9: "Are production date utilities
# used for all date manipulation?"
#
# This script is run in the root directory of a WCOSS code package. It greps
# for non-commented uses of the word "date" to help identify any date
# manipulations being made without production date utilities.
#####
# Usage:
# $ cd /path/to/mycode.v1.2.3 ; application_9.sh
# >  ecf/jthanks_send2web.ecf:23:export cyc=`date -u +%H`
# >  ecf/jthanks_00.ecf:21:date
# >  scripts/exthanks.sh.ecf:93:export runtime=`date -u +"%a %b %d %H:%M:%S UTC %Y"`
# >  scripts/exthanks.sh.ecf:94:export rundate=`date -u +%Y%m%d%H%M%S`
#####
# Written by Alex Richert (alexander.richert@noaa.gov)
#

for file in $(find ecf/ scripts/ ush/ -type f); do
 nocomment_dummy.sh $file | perl -pe 's|echo.*date||;s|^[[:space:]]*#.+||' | grep -nE "(\b|^)date(\b|$)" | perl -pe "s|^|$file:|g"
done
