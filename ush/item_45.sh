#!/bin/bash
#####
# Purpose:
# This script is run in the root directory of a WCOSS code package. It checks
# FORTRAN, C, and C++ files for signs of dynamically allocated arrays and
# presents them to the user using 'less'. It is not smart enough to know when
# data is being read in.
#####
# Usage:
# cd /path/to/mycode.v1.2.3 ; compiled_14.sh
#####
# Written by Alex Richert (alexander.richert@noaa.gov)
# Modified by A.Bigdeli Aug-2022 (arash.bigdeli@noaa.gov)
#####
target_add=$1
pushd $target_add > /dev/null

fortgrep="^[^\"|\'|c|C|"'!'"]*((\"[^\"]*?\")|(\'[^']*?\')|[^\"|\'|c|C|"'!'"])*\K\ballocatable\b"
cppgrep="\bnew \w+\["
cgrep="\b(m|c)alloc\b"

for f in $(find -type f  -not -path '*.svn/*' -not -path '*.git/*'); do
 ftype=$(file -b $f | awk '{print $1}')
 case $ftype in
 "FORTRAN")
  linenum=$(grep -m 1 --line-number -P -i "$fortgrep" $f | awk -F ':' '{print $1}')
  ;;
 "C++")
  linenum=$(nocomment.sh -q $f | grep -m 1 --line-number -P "$cppgrep" | awk -F ':' '{print $1}')
  ;;
 "C")
  linenum=$(nocomment.sh -q $f | grep -m 1 --line-number -P "$cgrep" | awk -F ':' '{print $1}')
  ;;
 esac
 if [ ! -z $linenum ]; then echo "$f appears to use allocatable arrays" ; any=YES ; fi
done

if [ -z $any ]; then echo "No evidence of allocatable arrays found!"; fi

popd > /dev/null
