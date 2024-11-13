#!/bin/bash
#####
# gribdiff.sh
#####
# This script is only called by diffoutputdirs
#####
# Written by Alex Richert (alexander.richert@noaa.gov)
#

function ctrl_c() {
#if [ "$KEEPDATA" != YES ]; then
#rm -f $TMPDIR/*${unique}*
#fi
exit ${1:-1}
}

trap ctrl_c INT

if [ -z $WGRIB ]; then echo "\$WGRIB2 not found! Exiting"; exit 1; fi

if [ "$1" == "-r" ]; then
printrecords=YES
shift 1
fi
filenames=( $1 $2 )
TMPDIR=$3/
mkdir -p $TMPDIR

s0=$(basename $0)
if [ ${#filenames[@]} -ne 2 ] ; then echo "$s0: This script takes exactly two filenames! Exiting..." ; exit 1 ; fi
for filename in ${filenames[@]}; do if [ ! -f $filename ]; then echo "$s0: File $filename does not exist!" ; nofile=YES ; fi ; done
if [ "$nofile" == YES ]; then exit 1 ; fi
#function gribtworecords(){ $WGRIB2 $1 -full_name -code_table_4.0 | perl -pe "s|^[^:]*:[^:]*:([^:]*):code\ table\ ([^=]*=\d*).*|\1_\2|g" | sort ; }
function gribtworecords(){ $WGRIB2 $1 -full_name -pdt | awk -F ':' '{$1="";$2="";print}' | sort ; }
function gribonerecords(){ $WGRIB $1 -s | awk -F ':' '{$1="";$2="";$3="";print}' | sort ; }
function checkquit(){ if [ "$1" == "DIFFERENT" ]; then echo ; echo "VERDICT: $1"; ctrl_c 2 ; fi ; }

s1=$(basename $1)
s2=$(basename $2)
unique=$(echo $(date +%s)_$$)

#echo -n "$s1 $s2 "
gribtworecords ${filenames[0]} > $TMPDIR/${s1}.dir1.$unique 2> $TMPDIR/${s1}.dir1.${unique}.stderr
gribtworecords ${filenames[1]} > $TMPDIR/${s2}.dir2.$unique 2> $TMPDIR/${s2}.dir2.${unique}.stderr
if [ $(cat $TMPDIR/{$s1,$s2}.dir{1,2}.${unique}.stderr | grep -Fc 'grib1 message ignored (use wgrib)') -gt 0 ]; then DOWGRIBONE=YES ; fi
if [ "$DOWGRIBONE" == YES ]; then
gribonerecords ${filenames[0]} > $TMPDIR/${s1}.dir1.$unique
gribonerecords ${filenames[1]} > $TMPDIR/${s2}.dir2.$unique
fi
#sdiff -w 2048 $TMPDIR/${s1}.dir1.$unique $TMPDIR/${s2}.dir2.$unique > $TMPDIR/records.$unique
exactdiff $TMPDIR/${s1}.dir1.$unique $TMPDIR/${s2}.dir2.$unique > $TMPDIR/records.$unique
nequalsigns=$(cat $TMPDIR/records.$unique | awk 'NR==2' | grep -P "^=+ " | grep -o = | wc -l)
nspaces=$(cat $TMPDIR/records.$unique | awk 'NR==2' | grep -oP "^=+ " | grep -o ' ' | wc -l)
Aonly=$(cut -c${nequalsigns}-$(($nequalsigns+$nspaces)) $TMPDIR/records.$unique | grep -c "<")
Bonly=$(cut -c${nequalsigns}-$(($nequalsigns+$nspaces)) $TMPDIR/records.$unique | grep -c ">")
if [ "$printrecords" == YES ]; then
  added="($(echo -n $(grep ">" $TMPDIR/records.$unique | perl -pe 's|<||;s|^\s+||;s|\s|-|') | perl -pe 's|\s+|;|g'))"
removed="($(echo -n $(grep "<" $TMPDIR/records.$unique | perl -pe 's|<||;s|^\s+||;s|\s|-|') | perl -pe 's|\s+|;|g'))"
fi
echo -n "+${Bonly}records$added -${Aonly}records$removed "

echo

ctrl_c $exitcode
