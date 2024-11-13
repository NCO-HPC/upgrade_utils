#!/bin/bash
#####
# Purpose:
# This script is run in the root directory of a WCOSS code package. It checks
# whether a module file is being used. If so, it quits with status 0 with no
# output. If a module file is not found, it prints an error to stdout and exits
# 1.
#####
# Usage:
# $ cd /path/to/mycode.v1.2.3
# >  ERROR! No module file found...
#####
# Written by Alex Richert (alexander.richert@noaa.gov)
#
target_add=$1
pushd $target_add > /dev/null

if [[ ! -d modulefiles || ! "$(find modulefiles -type f | xargs grep '%Module')" ]]; then
 echo "ERROR! No module file found..."
else
 echo "Yay, modulefile found!"
fi
popd > /dev/null
