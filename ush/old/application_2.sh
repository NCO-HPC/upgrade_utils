#!/bin/bash
#####
# application_2.sh
#####
# Purpose:
#
# IT checklist, Application/Coordination #2: "Is vertical structure implemented
# according to NCO standards?"
#
# This script is run in the root directory of a WCOSS code package and checks
# that all directories are properly named. Paths of illegal directory names are
# printed to stdout. If executables have not yet been compiled, then
# directories in ./sorc/ may get incorrectly flagged.
#####
# Usage:
# $ application_2.sh
# >  ./illegaldir
# $ ls
# >  ecf  exec  fix  illegaldir  jobs  modulefiles  parm  scripts  sorc  ush  versions
#####
# Written by Alex Richert (alexander.richert@noaa.gov)
#

maindirs=( '.' './doc' './ecf' './exec' './fix' './gempak' './jobs' './lib' './modulefiles' './parm' './scripts' './sorc' './ush' './versions')

function gettype() {
 file --brief --mime $1 | perl -pe "s|;.*||g"
}

modelname=$(basename $PWD | perl -pe "s|\..*||g")
allgood=YES
echo "Printing top-level directories (and files) that do not clearly belong..."
for dir in $(find -maxdepth 1); do
 if [[ " ${maindirs[@]} " =~ " $dir " ]]; then continue; fi
 prefix=$(echo $dir | perl -pe 's|(?<!\.)\/.*||g')
 if [[ " ( ./fix ./lib ./parm ) " =~ " $prefix " ]]; then continue; fi
 if [ "$dir" == "./modulefiles/$modelname" ]; then continue; fi
 if [ "$dir" == "./sorc/$modelname.fd" ]; then continue; fi
 if [ "$prefix" == "./sorc" ]; then
  exepath=$(echo $dir | perl -pe "s|./sorc/(\w+)\.fd|./sorc/\1.fd/\1|g")
  if [ "$(gettype $exepath)" == "application/x-executable" ]; then continue; fi
 fi
 echo $dir
 allgood=NO
done

if [ $allgood == YES ]; then echo "All good!"; fi
