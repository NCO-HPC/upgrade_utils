#! /usr/bin/env bash
#### 
# Purpose:
# check package dependency on external sources in fortran,C,bash and python scripts
# Usage  
# this_code.sh path/to/new/package
####
# Written by A.Bigdeli Aug-2024 (arash.bigdeli@noaa.gov)
#

while [ -n "$1" ]; do
case "$1" in 
 -h|--h|--help|help) echo ""
    echo "this script  check package dependency on external sources"
    echo "in fortran,C,bash and python scripts"
    echo "--------------------------------------------------------"
    echo "--------------------------------------------------------"
    echo "Usage: "
    echo " $(basename "$0") path_to_new_package"
    echo "Outputs: "  
    echo "Success message incase of no dependcy"
    echo "Failed message with list of dependencies"
    exit
;;
 *) dirin="$1" 
    shift 1
;;
esac
shift 1
done

if [[ -d "$dirin" ]]; then echo ""; else echo "This script takes atleast one argument: path to package directory, can't find it, please use -h for info, exiting"; exit; fi


allgood=YES

extdep=$(find "$dirin" -type f \
    \( -name "*.sh" -o -name "*.py" -o -name "*.c" -o -name "*.cpp" \
    -o -name "*.f" -o -name "*.f90" -o -name "*.f95" -o -name "*.bash" \) \
    -exec sh -c \
    'nocomment.sh "$1" | grep -H --label="The file $1 has external  dependency via " \
    -e "\blftp\b" -e "\bscp\b" -e "\brsync\b" -e "\bwget\b"' _ {} \;)

if [ -n "$extdep" ]; then
    echo "ERROR! EXTERNAL DEP FOUND"
    echo "$extdep"
else
    echo "Yay, no external dep found"
fi
