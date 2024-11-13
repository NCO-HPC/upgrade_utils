#!/bin/bash
#####
# interpreted_7.sh
#####
# Purpose:
#
# IT checklist, Interpreted Code #7: "For unique working directories, is LSF JOBID used to make the working directory unique (using variable "jobid"?)"
#
# This script flips through all instances of export=DATA in all scripts in a
# code directory using the less command. No arguments taken.
#####
# Written by Alex Richert (alexander.richert@noaa.gov)
#####

trap ctrl_c INT

function ctrl_c() {
exit 1
}

PATTERN="^export DATA="
TMP=${TMP:-/dev/shm}
uniq=$(date +%s).$$

for file in $(find -type f); do
 if [[ $(file -b $file) == *"script"* ]]; then
  filebase=$(echo $file | sed 's|^.*/||')
  nocomment_dummy.sh $file > $TMP/${uniq}_$filebase
  if [ $(grep "$PATTERN" $TMP/${uniq}_$filebase | grep -v "jobid" | wc -l) -gt 0 ]; then
   nocomment_dummy.sh -H $TMP/${uniq}_$filebase | less -R --pattern="$PATTERN" --prompt="$(echo $file | sed 's|\.|\\\.|g') - 'n'/'N' for next/previous match; 'q' to go to next file; ctrl+c then 'q' to end script"
   echo "$file appears to define \$DATA without \$jobid"
  fi
  rm -f $TMP/${uniq}_$filebase
 fi
done
