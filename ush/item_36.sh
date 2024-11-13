#!/bin/bash
#####
# Purpose:
# This script is run in the root directory of a WCOSS code package before
# any compilation/testing has been done (i.e., on a clean repo checkout).
# It looks for binary executables throughout the package and lists them to
# stdout.

#####
# Written by Alex Richert (alexander.richert@noaa.gov)
# Modified by A.Bigdeli Aug-2022 (arash.bigdeli@noaa.gov)
#
target_add=$1
pushd $target_add > /dev/null
types=(makefile FORTRAN C C++ Python POSIX Bourne-Again Korn ELF)

mapfile -t exelist < <(find ./exec ./sorc -type f -executable ! \( -path "*/fix/*" -o -path "*/parm/*" -o -path "*/.git/*" -o -path "*/.svn/*" \) | grep -Ev "(\.sh|\.pl|\.py)$" | xargs file --separator=" " | awk '{if ($2=="ELF") print $1}')

if [ ${#exelist[@]} -eq 0 ]; then
echo "Yay, no executables found!"
else
exetxt="s were"
if [ ${#exelist[@]} -eq 1 ]; then exetxt=" was"; fi
echo "ERROR, the following executable$exetxt found:"
for exe in ${exelist[@]}; do
echo $exe
done
fi
popd > /dev/null
