#!/bin/bash
#####
# Purpose:
# This script is run in the root directory of a WCOSS code package. It checks
# whether are files under ./sorc/ are of the appropriate types.
#####
# Usage:
# item_13 /path/to/mycode.v1.2.3 interactive[Y/N]
# >  ERROR! File ./sorc/forecast.pl is not an acceptable file type (type is 'Perl script, ASCII text executable')
# >  ERROR! File ./sorc/hello.adb is not an acceptable file type (type is 'ASCII text')
#####
# Written by Alex Richert (alexander.richert@noaa.gov)
# Modified by A.Bigdeli Aug-2022 (arash.bigdeli@noaa.gov)
#

target_add=$1
pushd $target_add > /dev/null
types=(makefile FORTRAN C C++ Python POSIX Bourne-Again Korn ELF)

interactive_flag=$2

allgood=YES
for f in $(find ./sorc/* -type f ! \( -path '*/modulefiles/*' -o -path '*/.svn/*' -o -path '*/.git/*' -o -path '*/doc/*' -o -path '*/test/*' -o -name '*.sh' -o -name '*.log' -o -name '*.log.*' -o -name '*cmake*' -o -name '.git*' -o -name "README" \)); do
  if [ $(echo $f | perl -pe 's/\.((f|F)\d*|txt)$//') != "$f" ]; then continue; fi
  fulltype=$(file -b $f)
  type=$(echo $fulltype | grep -oE "^[^[:space:]|,]*")
  basename=$(basename $f)
  ext=$(echo $basename | grep -oE "\..+$")
  if [[ ! " ${types[@]} " =~ " ${type} " ]]; then
    if ! ([ $type == ASCII ] && [[ " .h .inc " =~ " $ext " || ${basename^^} == MAKEFILE ]]); then
      echo "ERROR! File $f is not an acceptable file type (type is '$fulltype')"
      allgood=NO
    fi
  fi
done

if [ $allgood == YES ]; then
  echo "Yay, all files in ./sorc/ are of the appropriate file types"
fi
popd > /dev/null
