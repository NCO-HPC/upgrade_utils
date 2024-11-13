#!/bin/bash
#
# nocomment.sh: This script uses GNU source-highlight to strip comments from files from any number of languages.
# -q option matches quoted strings in addition to comments
# -h enables highlighting only (no stripping)
# -e takes one argument; functions like -q except only matches quoted strings when the given argument is matched anywhere on that line
# -c clears empty lines

perl=YES
q=""
gete=NO
sedprint='/.*/!d'
for arg in $*; do
case $arg in
"-h") perl=NO ;;
"-H") plainhighlight=YES ;;
"-q") q=".string { color: blue; }" ;;
"-e") gete=YES ;;
"-c") sedprint='/[^[:space:]]\+/!d' ;;
*)
if [ $gete == YES ]; then
 e=$arg
 gete=NO
 q=".string { color: blue; }" 
else
 f=$arg
fi
esac
done

if [ "${f: -3}" == ".sh" ]; then opt="--src-lang=sh"
elif [ "${f: -4}" == ".ecf" ]; then opt="--src-lang=ksh"
elif [ "${f: -3}" == ".pl" ]; then opt="--src-lang=perl"
elif [ "$(file -b $f | awk '{print $1}')" == "FORTRAN" ]; then opt="--src-lang=fixed-fortran"
else opt="--failsafe"
fi

if [ "$plainhighlight" == YES ]; then
 source-highlight $opt -i $f -f esc -o STDOUT
 exit
fi

function hl(){ source-highlight $2 -i $1 --style-css-file <(echo ".comment { color: red; } $3") -f esc -o STDOUT ; }
function red(){  perl -pe 's|[[:cntrl:]]\[31m.*?[[:cntrl:]]\[m||g' ; }
function blue(){ perl -pe 's|[[:cntrl:]]\[34m.*?[[:cntrl:]]\[m||g if /'$1'/' ; }

if [ $perl == YES ]; then
hl $f "$opt" "$q" | red | blue "$e" | sed $sedprint
else
hl $f "$opt" "$q" | sed $sedprint
echo $f
echo $opt
echo $q
echo $sedprint
fi
