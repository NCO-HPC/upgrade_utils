#!/bin/bash
#####
# Purpose:
# This code is run in the root directory of a WCOSS code package. It checks
# each file in ./ush/ to ensure that it is a bash, ksh, perl, or python script.
# An error is spit out for each non-conforming file.
#####
# Usage:
# $ cd /path/to/mycode.v1.2.3 ; interpreted_1.sh
# >  ERROR! './ush/script.zsh' is not a script of acceptable type!
# >  ERROR! './ush/run.exe' is not a script of acceptable type!
#####
# Written by Alex Richert (alexander.richert@noaa.gov)
# Modified by A.Bigdeli Aug-2022 (arash.bigdeli@noaa.gov)
#
target_add=$1
pushd $target_add > /dev/null

goodtypes=( Bourne-Again Korn Perl Python POSIX )

allgood=YES
for filename in $(find ./ush/ -type f); do
 ftype=$(file -b $filename | grep -oE "^[^[:space:]]*")
 if [[ ! " ${goodtypes[@]} " =~ " ${ftype} " ]]; then echo "ERROR! '$filename' is not a script of acceptable type!"; allgood=NO; fi
done

if [ $allgood == YES ]; then echo "Yay, all scripts are written in bash/ksh/perl/python"; fi
popd > /dev/null
