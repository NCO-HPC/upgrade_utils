#!/bin/bash
#####
# Purpose:
# This script is run in the root directory of a WCOSS code package. It checks
# for GO TO statements and prints a statistical summary of comments.
#####
# Usage:
# cd /path/to/mycode.v1.2.3 ; compiled_13.sh
# >  # of GOTO statements in ./sorc/mycode.fd/mycode.f: 0
# >  #####################################
# >  ==========
# >  ./sorc/build_mycode.sh
# >  22/26=84.6% of non-empty lines do not contain comments
# >  Longest uncommented block of code (# of non-empty lines): 22 (26)
# >  ==========
# >  ./sorc/mycode.fd/makefile
# >  22/40=55.0% of non-empty lines do not contain comments
# >  Longest uncommented block of code (# of non-empty lines): 10 (40)
# >  ==========
# >  ./sorc/mycode.fd/mycode.f
# >  246/444=55.4% of non-empty lines do not contain comments
# >  Longest uncommented block of code (# of non-empty lines): 19 (444)
#####
# Written by Alex Richert (alexander.richert@noaa.gov)
#

# GO TO:
for f in $(find ./sorc/* -type f | xargs file | grep FORTRAN | awk -F ':' '{print $1}'); do
 echo "# of GOTO statements in $f: $(nocomment.sh $f | grep -ciE '(\b|^)GO\ ?TO\b')"
done
echo '#####################################'
# Comments:
for f in $(find ./sorc/* -type f); do
 wholecount=$(grep -Ev "^[[:space:]]*$" $f | wc -l)
 noncommcount=$(nocomment.sh $f | grep -Ev "^[[:space:]]*$" | wc -l)
 perc=$(printf "%.1f" $(echo "100*$noncommcount/$wholecount" | bc -l))
 echo -e "==========\n$f"
 echo "$noncommcount/$wholecount=$perc% of non-empty lines do not contain comments"
 longestnc=0
 currentnc=0
 while read line; do
  if [ $(echo $line | grep -c "[[:cntrl:]]\[00;38;05;196m") -eq 0 ]; then
   currentnc=$(($currentnc+1))
  else
   if [ $currentnc -gt $longestnc ]; then longestnc=$currentnc; fi
   currentnc=0
  fi
 done < <(nocomment.sh $f -h | grep -Ev "^[[:space:]]*$")
 if [ $currentnc -gt $longestnc ]; then longestnc=$currentnc; fi
 echo "Longest uncommented block of code (# of non-empty lines): $longestnc ($(grep -Ev "^[[:space:]]*$" $f | wc -l))"
done
