#!/bin/bash
#####
# interpreted_9.sh
#####
# Purpose
#
# IT checklist, Interpreted Code #9: "Are FORTRAN unit numbers used per standards document?"
#
#####
# Usage:
#####
# Written by Alex Richert (alexander.richert@noaa.gov)
#
allprompt="Input 11-49, output 51-79, work files 80-94\. n for next, N for previous\."

pattern="OPEN.*\(|WRITE.*\(|READ.*\(|CLOSE.*\("
for f in $(find ./sorc/ -type f -name '*.f*'); do
prompt="$(echo $f | sed 's|\.|\\\.|g'): 'q' to exit\. $allprompt"
escf=$(echo $f | sed 's|\.|\\\.|g')
type=$(file -b $f | awk '{print $1}')
if [ "$type" == FORTRAN ]; then
if [ $(nocomment_dummy.sh $f | grep -Ec "$pattern" ) -gt 0 ]; then
nocomment_dummy.sh $f | less --prompt="$escf\: $prompt" --pattern="$pattern"
echo "$f appears to include OPEN/WRITE/READ/CLOSE statements"
fi
fi
done


for f in $(find ./jobs/ ./scripts/ ./ush/ -type f); do
escf=$(echo $f | sed 's|\.|\\\.|g')
n=$(nocomment_dummy.sh $f | grep -Ec -e "FORT[0-9]+=" -e "fort.[0-9]+")
if [ $n -gt 0 ]; then
nocomment_dummy.sh $f | less --prompt="$escf\: $allprompt" --pattern="FORT[0-9]+=|fort\.[0-9]+"
echo "$f appears to include FORTRAN unit numbers"
fi
done
