#!/bin/bash
#####
# interpreted_1.sh
#####
# Purpose:
#
# IT checklist, Interpreted Code #1: "Are scripts written in bash, ksh, perl or
# python?"
#
# This code is run in the root directory of a WCOSS code package. It checks
# each file in ./ush/ to ensure that it is a bash, ksh, perl, or python script.
# An error is spit out for each non-conforming file.
#####
# Usage:
# $ cd /path/to/mycode.v1.2.3 ; interpreted_1.sh
# >  D'OH! './ush/script.zsh' is not a script of acceptable type!
# >  D'OH! './ush/run.exe' is not a script of acceptable type!
#####
# Written by Alex Richert (alexander.richert@noaa.gov)
#

goodtypes=( Bourne-Again Korn Perl Python POSIX )

allgood=YES
for filename in $(find ./ush/ -type f); do
 ftype=$(file -b $filename | grep -oE "^[^[:space:]]*")
 if [[ ! " ${goodtypes[@]} " =~ " ${ftype} " ]]; then echo "D'OH! '$filename' is not a script of acceptable type!"; allgood=NO; fi
done

if [ $allgood == YES ]; then echo "Yay, all scripts are written in bash/ksh/perl/python"; fi
