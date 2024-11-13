#!/bin/bash
#####
# interpreted_12.sh
#####
# Purpose:
#
# IT checklist, Interpreted Code #12: "Are dbnet alerts wrapped by check of
# $SENDDBN or $SENDDBN_NTC (and no other variations of the variable SENDDBN)?"
#
# This script flips through all instances of dbn_alert in all scripts in a code
# directory using the less command. No arguments taken.
#####
# Written by Alex Richert (alexander.richert@noaa.gov)
#####

trap ctrl_c INT

function ctrl_c() {
exit 1
}

TMP=${TMP:-/dev/shm}
uniq=$(date +%s).$$

for file in $(find -type f); do
 if [[ $(file -b $file) == *"script"* ]]; then
  filebase=$(echo $file | sed 's|^.*/||')
  nocomment_dummy.sh $file > $TMP/${uniq}_$filebase
  if [ $(grep -c dbn_alert $TMP/${uniq}_$filebase) -gt 0 ]; then
   nocomment_dummy.sh -H $TMP/${uniq}_$filebase | less -R --pattern="dbn_alert" --prompt="$file - 'n'/'N' for next/previous match; 'q' to go to next file; ctrl+c then 'q' to end script"
   echo "$file appears to have dbn_alert calls"
  fi
  rm -f $TMP/${uniq}_$filebase
 fi
done
