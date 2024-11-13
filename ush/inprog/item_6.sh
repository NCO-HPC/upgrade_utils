#!/bin/bash
#####
# Purpose:
# This script is run in the root directory of a WCOSS code package. It
# identifies symlinks that point outside of the code package directory
# structure.
#####
# Usage:
# $ cd /path/to/mycode.v1.2.3 ; application_12.sh
# >  Link './ush/somelink' points to '/some/outside/path', which is not contained within the current directory (/path/to/mycode.v1.2.3)
######
# Written by Alex Richert (alexander.richert@noaa.gov)
#

allgood=YES
for link in $(find . -type l -not -path '*.svn/*' -not -path '*.git/*'); do
linkpath=$(readlink -m $link)
wd=$(pwd -P)
shortened=$(echo $linkpath | sed "s|^$wd\/||g")
if [ $linkpath == $shortened ]; then
echo "D'OH, symlink '$link' points to '$linkpath', which is not contained within the current directory ($PWD)"
allgood=NO
fi
done

if [ $allgood == YES ]; then
echo "Yay, there are no symlinks that point outside the package directory"
fi
