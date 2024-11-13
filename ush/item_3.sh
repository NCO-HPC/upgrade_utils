#! /usr/bin/env bash
#####
# Purpose:
#
# This script recives  WCOSS code package address and it makes
# sure that everything in ./jobs/ follows the JXXXXX naming convention, and
# that everything in ./scripts/ begins with 'ex' and ends with '.sh' , 'py'
# or '.pl'.
#####
# Usage:
# $ item_3 /path/to/mycode.v1.2.3
# >  ERROR! File ./jobs/JMYCODE_SEND2WEB does not follow J-job naming conventions.
# >  Yay, all scripts in ./scripts/ begin with 'ex' and end with '.py' '.sh' or 
# '.pl'
#####
# Written by Alex Richert (alexander.richert@noaa.gov)
# Modified by A.Bigdeli Aug-2022 (arash.bigdeli@noaa.gov)
#

target_add=$1

if echo "$target_add" | grep -qE '/[^/]+\.v[0-9]+(\.[0-9]+)*'; then
    # Extract the package name (part before .v)
    packagename=$(echo "$target_add" | sed -E 's|.*/([^/]+)\.v[0-9]+(\.[0-9]+)*.*|\1|')
    echo "Package name (NET): $packagename"
else
    echo "No valid package path found."
    echo "Make sure path is to package.v?.?.?"
    exit 1
fi

pushd $target_add > /dev/null
jobsallgood=YES
for jfile in $(find ./jobs/* -type f -not -path "*/.git*")
do
    basename=$(basename $jfile)
    upperandus=$(echo $basename | perl -pe 's/[^_[:upper:][:digit:]]//g')
    lowercase_basename=$(echo "$basename" | tr '[:upper:]' '[:lower:]')
    lowercase_packagename=$(echo "$packagename" | tr '[:upper:]' '[:lower:]')
    if [ "$basename" != "$upperandus" ] || [ "${basename:0:1}" != "J" ] || [[ "$lowercase_basename" != *"${lowercase_packagename}"* ]]; then
        echo "ERROR! File $jfile does not follow J-job naming conventions."
        jobsallgood=NO
   fi
done
if [ $jobsallgood == "YES" ]; then
    echo "Yay, all files in ./jobs/ all follow J-job naming conventions."
fi

ecfallgood=YES
for ecffile in $(find ./ecf/* -type f -not -path "*/.git*")
do
    if [[ "$ecffile" == *.ecf ]]; then 
        basename=$(basename ${ecffile%.ecf})
        lowerandus=$(echo $basename | perl -pe 's/[^_[:lower:][:digit:]]//g')
        lowercase_basename=$(echo "$basename" | tr '[:upper:]' '[:lower:]')
        lowercase_packagename=$(echo "$packagename" | tr '[:upper:]' '[:lower:]')
        if [ "$basename" != "$lowerandus" ] || [ "${basename:0:1}" != "j" ] || [[ "$lowercase_basename" != *"${lowercase_packagename}"* ]]; then
            echo "ERROR! File $ecffile does not follow "jecf" naming conventions."
            ecfallgood=NO
        fi
    else
       echo "Warning found none ecf file at ecf dir, $ecffile"
    fi
done
if [ $ecfallgood == "YES" ]; then
    echo "Yay, all files in ./ecf/ follow "jecf" naming conventions."
fi

scriptsallgood=YES
for script in $(find ./scripts/ -type f -not -path "*/.git*");
do
    script=$(basename $script)
    if [ "${script:0:2}" != "ex" ]; then doesntbegin="does not begin with 'ex'"; else doesntbegin=""; fi
   	 rightext=$(echo $script | perl -ne 'print if /.*?(\.sh$|\.pl$|\.py$)/')
    if [ -z "$rightext" ]; then doesntend="does not end with '.sh', '.pl', or '.py'"; else doesntend=""; fi
    if [ -n "$doesntbegin" ] || [ -n "$doesntend" ]; then
         echo -n "ERROR! Script '$script' "
         echo -n $doesntbegin
    if [ -n "$doesntbegin" ] && [ -n "$doesntend" ]; then echo -n " and "; fi
        echo -n $doesntend
	echo
        scriptsallgood=NO
    fi
done

if [ $scriptsallgood == "YES" ]; then
    echo "Yay, all scripts in ./scripts/ begin with 'ex' and end with '.sh' , '.py' or '.pl'"
fi
popd > /dev/null
