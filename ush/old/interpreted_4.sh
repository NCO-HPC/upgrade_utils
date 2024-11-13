#!/bin/bash
#####
# interpreted_4.sh
#####
# Purpose:
#
# IT checklist, Interpreted Code #4: "Has all background processing been removed?"
#
# This script is run in the root directory of a WCOSS code package. It checks
# Python, Perl, and shell scripts for signs of background processing. It is not
# done dynamically (i.e., with runtime checking), so it is not a perfectly
# exhaustive search. For each offending file, each offending line is printed,
# prefixed by line number and a colon.
#####
# Usage:
# cd /path/to/mycode.v1.2.3 ; interpreted_4.sh
# >  ./ush/script.py:
# >  11:p = subprocess.Popen(args)
# >  ./ush/send.pl:
# >  13:my $pid = fork();
# >  ./ush/forecast.sh:
# >  23:ls &
#####
# Written by Alex Richert (alexander.richert@noaa.gov)
#

grepopts="--line-number --color=always -E"

function dostuff() {
  mapfile -t matchlines < <(nocomment_dummy.sh -q $1 | perl -pe 's|^[[:space:]]*#.*$||g' | grep $grepopts $2 ) #perl chunk can go away when nocomment.sh is reinstated
  if [ ${#matchlines[@]} -gt 0 ] ; then
   echo $1:
   for i in $(seq 0 $((${#matchlines[@]}-1))); do echo ${matchlines[$i]}; allgood=NO; done
   echo
  fi
}

allgood=YES

for file in $(find -type f); do
 type=$(file -b $file)
 if [[ "$type" == *"Python"* ]]; then dostuff $file "(^|\b)Popen(\b)" ;
 elif [[ "$type" == *"Perl"* ]]; then dostuff $file "(\b|^)fork(\b|$)" ;
 elif [[ "$type" == *"shell"* ]]; then dostuff $file "[^&>|]&([[:space:]]|$)" ;
 fi
done

if [ "$allgood" == YES ]; then echo "Yay, no signs of background processing detected!"; fi
