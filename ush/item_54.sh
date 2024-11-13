#!/bin/bash
#####
# Purpose:
# This script checks for all instances of "export DATA" to check that
# they're using LSF $jobid to ensure uniqueness.
#####
# Written by Alex Richert (alexander.richert@noaa.gov)
#####

trap ctrl_c INT

function ctrl_c() {
exit 1
}

target_add=$1
pushd $target_add > /dev/null

PATTERN="^export DATA="
TMP=${TMP:-/tmp}
uniq=$(date +%s).$$

for file in $(find ./jobs ./scripts -type f); do
 if [[ $(file -b $file) == *"script"* ]]; then
  filebase=$(echo $file | sed 's|^.*/||')
  nocomment.sh $file > $TMP/${uniq}_$filebase
  if [ $(grep "$PATTERN" $TMP/${uniq}_$filebase | grep -v "jobid" | wc -l) -gt 0 ]; then
   echo "$file appears to define \$DATA without \$jobid:"
   grep "$PATTERN" $TMP/${uniq}_$filebase
   foundone=YES
  fi
  rm -f $TMP/${uniq}_$filebase
 fi
done

if [ -z $foundone ]; then echo "Yay, no instances found of \$DATA defined without \$jobid!"; fi

popd > /dev/null
