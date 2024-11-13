#!/bin/bash
#####
# Purpose:
# Checks for README files under ./sorc/.
#####
# Usage:
# Run in code package root directory.
#####
# Written by Alex Richert (alexander.richert@noaa.gov)

if [ -e ./sorc/README ]; then
echo "Yay, README file found!"
else
echo "D'OH, no README file found in ./sorc!"
fi
