#!/bin/bash
#####
# compiled_14.sh
#####
# Purpose:
#
# IT checklist, Compiled Code #14: "Do C and Fortran source ingest data into
# dynamically allocated arrays?"
#
# This script is run in the root directory of a WCOSS code package. It checks
# FORTRAN, C, and C++ files for signs of dynamically allocated arrays and
# presents them to the user using 'less'. It is not smart enough to know when
# data is being read in.
#####
# Usage:
# cd /path/to/mycode.v1.2.3 ; compiled_14.sh
#####
# Written by Alex Richert (alexander.richert@noaa.gov)
#


fortgrep="^[^\"|\'|c|C|"'!'"]*((\"[^\"]*?\")|(\'[^']*?\')|[^\"|\'|c|C|"'!'"])*\K\ballocatable\b"
cppgrep="\bnew \w+\["
cgrep="\b(m|c)alloc\b"
promptadd=" ('n'/'N' to go to next/previous match; 'q' to close file and resume script; Ctrl-Z to stop the whole script)" 

for f in $(find -type f); do
 ftype=$(file -b $f | awk '{print $1}')
 prompttext=$(echo $f | sed 's|\.|\\\.|g')$promptadd
 has=NO
 case $ftype in
 "FORTRAN")
  linenum=$(grep -m 1 --line-number -P -i "$fortgrep" $f | awk -F ':' '{print $1}')
  if [ ! -z $linenum ]; then grep -P -i "$fortgrep" -A 99999 -B 99999 --color=always $f | less -R -i --pattern allocatable --prompt="$prompttext" ; has=YES ; fi
  ;;
 "C++")
  linenum=$(nocomment_dummy.sh -q $f | grep -m 1 --line-number -P "$cppgrep" | awk -F ':' '{print $1}')
  if [ ! -z $linenum ]; then grep -P "$cppgrep" -A 99999 -B 99999 --color=always $f | less -R --pattern "new " --prompt="$prompttext" ; has=YES ; fi
  ;;
 # C:
 "C")
  linenum=$(nocomment_dummy.sh -q $f | grep -m 1 --line-number -P "$cgrep" | awk -F ':' '{print $1}')
  if [ ! -z $linenum ]; then grep -P "$cgrep" -A 99999 -B 99999 --color=always $f | less -R --pattern "(c|m)alloc" --prompt="$prompttext" ; has=YES ; fi
  ;;
 esac
 if [ $has == YES ]; then echo "$f appears to use allocatable arrays"; fi
done
