#!/bin/bash
#####
# Purpose:
# Checks for README files under ./sorc/.
#####
# Usage:
# Run in code package root directory.
#####
# Written by Alex Richert (alexander.richert@noaa.gov)
# Modified by A.Bigdeli Aug-2022 (arash.bigdeli@noaa.gov)
target_add=$1
pushd $target_add > /dev/null

if [ -e ./sorc/README* ] || [ -e ./README* ]; then
echo "Yay, README file found!"
else
echo "ERROR, no README file found in ./  or ./sorc!"
fi
popd > /dev/null
