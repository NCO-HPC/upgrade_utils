#!/bin/bash
#####
# compiled_1.sh
#####
# Purpose:
#
# IT checklist, Compiled Code #1: "Is all code written in C, C++, FORTRAN or Python?"
#
# This script is run in the root directory of a WCOSS code package. It checks
# whether are files under ./sorc/ are of the appropriate types.
#####
# Usage:
# cd /path/to/mycode.v1.2.3 ; compiled_1.sh
# >  D'OH! File ./sorc/forecast.pl is not an acceptable file type (type is 'Perl script, ASCII text executable')
# >  D'OH! File ./sorc/hello.adb is not an acceptable file type (type is 'ASCII text')
#####
# Written by Alex Richert (alexander.richert@noaa.gov)
#

types=(makefile FORTRAN C C++ Python POSIX Korn)

allgood=YES
for f in $(find ./sorc/* -type f ! \( -path '*/fix/*' -o -path '*/parm/*' -o -path '*/modulefiles/*' -o -path '*/ush/*' -o -path '*/scripts/*' -o -path '*/.svn/*' -o -path '*/.git/*' -o -path '*/jobs/*' -o -path '*/doc/*' -o -name '*.sh' -o -name '*.log' -o -name '*.log.*' -o -name '*cmake*' -o -name '.git*' -o -name "README" \)); do
 if [ $(echo $f | perl -pe 's/\.((f|F)\d*|txt)$//') != "$f" ]; then continue; fi
 fulltype=$(file -b $f)
 type=$(echo $fulltype | grep -oE "^[^[:space:]|,]*")
 if [[ ! " ${types[@]} " =~ " ${type} " ]]; then
  echo "D'OH! File $f is not an acceptable file type (type is '$fulltype')"
  allgood=NO
 fi
done

if [ $allgood == YES ]; then
 echo "Yay, all files in ./sorc/ are of the appropriate file types"
fi
