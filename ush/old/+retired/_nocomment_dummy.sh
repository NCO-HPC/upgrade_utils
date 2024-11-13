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

if [ "${f: -7}" == ".sh.ecf" ]; then opt="--src-lang=sh"
elif [ "${f: -4}" == ".ecf" ]; then opt="--src-lang=ksh"
elif [ "${f: -3}" == ".pl" ]; then opt="--src-lang=perl"
elif [ "$(file -b $f | awk '{print $1}')" == "FORTRAN" ]; then opt="--src-lang=fixed-fortran"
else opt="--failsafe"
fi

function hl(){ cat $2 -i $1 --style-css-file <(echo ".comment { color: red; } $3") -f esc256 -o STDOUT ; }
function red(){ perl -pe 's|[[:cntrl:]]\[00;38;05;196.*?[[:cntrl:]]\[m||g' ; }
function blue(){ perl -pe 's|[[:cntrl:]]\[00;38;05;75m.*?[[:cntrl:]]\[m||g if /'$1'/' ; }

if [ $perl == YES ]; then
cat $f
else
cat $f
fi
