#!/bin/bash
#####
# interpreted_13.sh
#####
# Purpose:
#
# IT checklist, Interpreted Code #13: "Does each executable redirect stdout and
# stderr to files (pgmout and errfile, for example)"
#
# This script is run in the root directory of a WCOSS code package. By default,
# it checks scripts in ./scripts/ for EXECmodel invocations and checks whether
# there are redirects to stdout and stderr. Possible violations are echo'd.
#####
# Usage:
# $ cd /path/to/mycode.v1.2.3
# >  scripts/exmycode.sh.ecf:196:$EXECmycode/mycode
#####
# Written by Alex Richert (alexander.richert@noaa.gov)
#

if [ -z $1 ]; then
pattern='\${?EXEC'$(basename $PWD | perl -pe "s|\..*||g")'}?'
else pattern=$1
fi

#shellre="^[^\"|\'|#]*((\"[^\"]*?\")|(\'[^']*?\')|[^\"|\'|#])*\K[^=]\b\${?$pattern}?\b(?!.*[^2]>.*2>)(?!.*2>.+[^2]>)"
shellre="^[[:space:]]*$pattern(?!.*[^2]>.*2>)(?!.*2>.+[^2]>)"

allgood=YES
outputs=( )
for script in $(find scripts/ -name '*sh.ecf'); do
 nmatch=$(grep -cP "$shellre" $script)
 if [ $nmatch -gt 0 ]; then
  mapfile -t newoutputs < <(grep --line-number -P "$shellre" $script | sed "s|^|$script:|")
  outputs+=( "${newoutputs[@]}" )
  allgood=NO
 fi
done

if [ $allgood == YES ]; then echo "Yay, all executables appear to have stdout/stderr redirected to files!"
else
if [ ${#outputs[@]} -eq 1 ]; then s1=""; s2="s"; else s1="s"; s2=""; fi
echo "D'OH! The following executable$s1 appear$s2 to be running without stdout/stderr file redirection:"
for out in "${outputs[@]}"; do echo $out; done
fi
