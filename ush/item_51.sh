#!/bin/bash
#####
# Purpose:
# This script recives  WCOSS code package address and checks
# Python, Perl, and shell scripts for signs of background processing. It is not
# done dynamically (i.e., with runtime checking), so it is not a perfectly
# exhaustive search. For each offending file, each offending line is printed,
# prefixed by line number and a colon.
#####
# Usage:
# $ item_5.sh path_to_package
# >  ./ush/script.py:
# >  11:p = subprocess.Popen(args)
# >  ./ush/send.pl:
# >  13:my $pid = fork();
# >  ./ush/forecast.sh:
# >  23:ls &
#####
# Modified by A.Bigdeli Aug-2022 (arash.bigdeli@noaa.gov)
# Written by Alex Richert (alexander.richert@noaa.gov)
#

target_add=$1
pushd $target_add > /dev/null
grepopts="--line-number --color=always -E"

function dostuff() {
  mapfile -t matchlines < <(nocomment.sh -q $1 | perl -pe 's|^[[:space:]]*#.*$||g' | grep $grepopts $2 ) #perl chunk can go away when nocomment.sh is reinstated
  if [ ${#matchlines[@]} -gt 0 ] ; then
   echo $1:
   for i in $(seq 0 $((${#matchlines[@]}-1))); do echo ${matchlines[$i]}; allgood=NO; done
   echo
  fi
}

allgood=YES

for file in $(find -type f -not -path '*.svn/*' -not -path '*.git/*'); do
 type=$(file -b $file)
 if [[ "$type" == *"Python"* ]]; then dostuff $file "(^|\b)Popen(\b)" ;
 elif [[ "$type" == *"Perl"* ]]; then dostuff $file "(\b|^)fork(\b|$)" ;
 elif [[ "$type" == *"shell"* ]]; then  dostuff $file "[^&>|]&([[:space:]]|$)" ; 
 fi
done

if [ "$allgood" == YES ]; then echo "Yay, no signs of background processing detected!"; fi
popd > /dev/null
