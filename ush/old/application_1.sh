#!/bin/bash
#####
# application_1.sh
#####
# Purpose:
#
# IT checklist, Application/Coordination #1: "Did developer start with current
# production version of code/scripts before making changes?"
#
# For filepaths, and for file contents, we want to know:
#  How much was taken away?
#  How much was added?
# This script takes two arguments, the paths of the old and new code
# directories to be compared. A full comparison of filenames/paths is piped to
# less, and some statistics are printed to stdout.
#####
# Usage:
# $ application_1.sh path/to/mycode.v1.2.3 path/to/mycode.v1.2.4
# >  path/to/mycode.v1.2.3
# >  path/to/mycode.v1.2.4
# >  1 file deleted going from path/to/mycode.v1.2.3 to path/to/mycode.v1.2.4
# >  0 files added going from path/to/mycode.v1.2.3 to path/to/mycode.v1.2.4
# >  ========================================
# >  ecf/jmycode_00.ecf: +1 -9
# >  path/to/mycode.v1.2.3/scripts/exmycode.sh.ecf: -57 (file removed)
# >  ========================================
# >  Total added lines (relative to path/to/mycode.v1.2.3): 1/7822 (0.01%)
# >  Total subtracted lines (relative to path/to/mycode.v1.2.3): 57/7822 (0.73%)
#
# In the above example, for file ecf/jmycode_00.ecf, going from the old to the
# new version of the code, 1 line was added, 9 lines were deleted. 
#####
# Environmental variables:
# $TMP: temporary file directory; defaults to /dev/shm
#####
# Written by Alex Richert (alexander.richert@noaa.gov)
#

TMP=${TMP:-/dev/shm/}
uniq=$(date +%s.%N).$$.a1differ
tmpbase=$TMP/$uniq

ignorecomments=NO
if [ "$1" == "--hidefilenames" ]; then
hidefilenames="--hidefilenames"
shift 1
fi
for arg in $1 $2 $3; do
 if [ "$arg" == "-c" ]; then ignorecomments=YES;
 else
  if [ -z $dir0 ]; then dir0=${arg%%/}
  else dir1=${arg%%/}
  fi
 fi
done

if [ $ignorecomments == YES ]; then
 mycat="nocomment_dummy.sh -c"
else
 mycat=cat
fi

echo $dir0
echo $dir1
if [[ -z $dir0 || -z $dir1 ]]; then echo "This script takes two arguments: olddir and newdir"; exit; fi

#sdiff <(find $dir0 -type f | sed "s|$dir0/||g" | sort ) <(find $dir1 -type f | sed "s|$dir1/||g" | sort) > ${tmpbase}.a
exactdiff.py $hidefilenames <(find $dir0 -type f | grep -Fv '.svn' | sed "s|$dir0/||g" | sort ) <(find $dir1 -type f | grep -Fv '.svn' | sed "s|$dir1/||g" | sort) > ${tmpbase}.a
echo "$(grep -c "<" ${tmpbase}.a) files deleted going from $dir0 to $dir1" | perl -pe "s|(?<=1 )files|file|"
echo "$(grep -c ">" ${tmpbase}.a) files added going from $dir0 to $dir1" | perl -pe "s|(?<=1 )files|file|"
cat <(echo -e "$dir0: $dir1:\n========== ==========" ) ${tmpbase}.a | column -t | less
echo '========================================'
totalsubtracted=0 ; totaladded=0 ; total=0
while read line
do
 f=($line)
 if [ ${f[0]} == ">" ]; then
  added=$($mycat $dir1/${f[1]} | wc -l)
  totaladded=$(($totaladded+$added))
  echo "$dir1/${f[1]}: +$added (file added)"
  continue
 fi
 if [ ${f[1]} == "<" ]; then
  subtracted=$($mycat $dir0/${f[0]} | wc -l)
  totalsubtracted=$(($totalsubtracted+$subtracted))
  echo "$dir0/${f[0]}: -$subtracted (file removed)"
  total=$(($total+$subtracted))
  continue
 fi
 nold=$($mycat $dir0/${f[0]} | wc -l)
 total=$(($total+$nold))
 diff -u <($mycat $dir0/${f[0]}) <($mycat $dir1/${f[1]}) | awk 'NR>3' > ${tmpbase}.b
 added=$(cut -c1 ${tmpbase}.b | grep -c "+")
 subtracted=$(cut -c1 ${tmpbase}.b | grep -c "-")
 totaladded=$(($totaladded+$added))
 totalsubstracted=$(($totalsubstracted+$subtracted))
 if [ $(($added+$subtracted)) -gt 0 ]; then echo "${f[1]}: +$added -$subtracted"; fi
done < ${tmpbase}.a
echo '========================================'
printf "Total added lines (relative to $dir0): $totaladded/$total (%.2f%%)\n" $(bc -l <<< "100*$totaladded/$total")
printf "Total subtracted lines (relative to $dir0): $totalsubtracted/$total (%.2f%%)\n" $(bc -l <<< "100*$totalsubtracted/$total")

rm -f $tmpbase*
