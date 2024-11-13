#!/bin/bash
#####
# application_3.sh
#####
# Purpose:
#
# IT checklist, Application/Coordination #3: "Has the NCO script naming
# convention been followed?"
#
# This script is run in the root directory of a WCOSS code package. It makes
# sure that everything in ./jobs/ follows the JXXXXX naming convention, and
# that everything in ./scripts/ begins with 'ex' and ends with '.sh.ecf' or
# '.pl'.
#####
# Usage:
# $ cd /path/to/mycode.v1.2.3
# $ application_3.sh
# >  D'OH! File ./jobs/JMYCODE_SEND2WEB does not follow J-job naming conventions.
# >  Yay, all scripts in ./scripts/ begin with 'ex' and end with '.sh.ecf' or '.pl'
#####
# Written by Alex Richert (alexander.richert@noaa.gov)
#

jobsallgood=YES
for jfile in $(find ./jobs/* -type f)
do
 basename=$(basename $jfile)
 upperandus=$(echo $basename | perl -pe 's/[^_[:upper:]]//g')
 if [ "$basename" != "$upperandus" ] || [ "${basename:0:1}" != J ]; then
  echo "D'OH! File $jfile does not follow J-job naming conventions."
  jobsallgood=NO
 fi
done

if [ $jobsallgood == "YES" ]; then
 echo "Yay, all files in ./jobs/ all follow J-job naming conventions."
fi

scriptsallgood=YES
for script in $(find ./scripts/ -type f);
do
 script=$(basename $script)
 if [ "${script:0:2}" != "ex" ]; then doesntbegin="does not begin with 'ex'"; else doesntbegin=""; fi
 rightext=$(echo $script | perl -ne 'print if /.*?((\.sh\.\w*?$|\.pl))/')
 if [ -z "$rightext" ]; then doesntend="does not end with '.sh.ecf' or '.pl'"; else doesntend=""; fi
 if [ -n "$doesntbegin" ] || [ -n "$doesntend" ]; then
  echo -n "D'OH! Script '$script' "
  echo -n $doesntbegin
  if [ -n "$doesntbegin" ] && [ -n "$doesntend" ]; then echo -n " and "; fi
  echo -n $doesntend
  echo
  scriptsallgood=NO
 fi
done

if [ $scriptsallgood == "YES" ]; then
 echo "Yay, all scripts in ./scripts/ begin with 'ex' and end with '.sh.ecf' or '.pl'"
fi
