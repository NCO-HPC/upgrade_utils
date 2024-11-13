#!/bin/bash
#####
# Purpose:
# This script flips through all instances of dbn_alert in all scripts in a code
# if interactive flag is set this script will cycle through directory using the less command.
#####
# Written by Alex Richert (alexander.richert@noaa.gov)
# Modified by A.Bigdeli Aug-2022 (arash.bigdeli@noaa.gov)
#####

trap ctrl_c INT

target_add=$1
pushd $target_add > /dev/null

function ctrl_c() {
exit 1
}

TMP=${TMP:-/tmp}
uniq=$(date +%s).$$

for file in $(find -type f -not -path '*.svn/*' ); do
 if [[ $(file -b $file) == *"script"* ]]; then
  filebase=$(echo $file | sed 's|^.*/||')
  nocomment.sh $file > $TMP/${uniq}_$filebase
  if [ $(grep -c dbn_alert $TMP/${uniq}_$filebase) -gt 0 ]; then
   nocomment.sh -H $TMP/${uniq}_$filebase | less -R --pattern="dbn_alert" --prompt="${file//\./\.} - 'n'/'N' for next/previous match; 'q' to go to next file; ctrl+c then 'q' to end script"
   echo "$file appears to have dbn_alert calls"
  fi
  rm -f $TMP/${uniq}_$filebase
 fi
done
popd > /dev/null
