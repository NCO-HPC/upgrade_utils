#!/bin/bash
#####
# Purpose:
# This script checks a WCOSS job's stdout file for COMOUT, and ensures that
# it ends in a PDY so that it will get picked up by automated cleanup scripts.
#####
# Usage:
#
# This command takes one argument, which is a WCOSS job's stdout file, from
# which we will get the value of COMOUT.
#####
# Written by Alex Richert (alexander.richert@noaa.gov)
#####

stdoutfile=$1
mapfile -t comouts < <(nocomment.sh $stdoutfile | grep --line-number -P "^(export )?COMOUT=" | sed 's|/\ *$||')

for comout in "${comouts[@]}"; do
 pdy=${comout: -8}
 d=$(date -d $pdy)
 stat=$?
 if [[ "" != "$(echo $pdy | sed 's|^[0-9]\{8\}$||g')" || $stat -ne 0 ]]; then
  echo "ERROR, \$COMOUT ($stdoutfile:$comout) does not end in a YYYYMMDD date and so will not get cleaned up!"
 else
  echo "Yay, \$COMOUT ($stdoutfile:$comout) ends in a YYYYMMDD date and will get cleaned up!"
 fi
done
