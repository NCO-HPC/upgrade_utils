#!/bin/bash
#####
# Purpose:
# This script is run in the root directory of a WCOSS code package. It spits
# out all occurrences of err_chk and err_exit.
#####
# Usage:
# $ cd /path/to/mycode.v1.2.3 ; application_7.sh
# >  ./sorc/build_thanks.sh:
# >  ./scripts/exthanks_send2web.sh.ecf:
# >  ./scripts/exthanks.sh.ecf:
# >  175:   err_exit "$pgm: $msg2"
# >  238:  export err=$?; err_chk
# >  240:  export err=$?; err_chk
# >  242:  export err=$?; err_chk
# >  244:  export err=$?; err_chk
# >  ./jobs/JTHANKS_SEND2WEB:
# >  71:export err=$?; err_chk
# >  ./jobs/JTHANKS:
# >  177:export err=$?; err_chk
#####
# Written by Alex Richert (alexander.richert@noaa.gov)
# Modified by A.Bigdeli Aug-2022 (arash.bigdeli@noaa.gov)
#

target_add=$1
pushd $target_add > /dev/null
nl=""
for file in $(find ./jobs ./scripts ./ush -type f | xargs file | grep "shell script" | awk -F ':' '{print $1}'); do
#echo -e "$nl$file:"
nl="\n"
count=$(nocomment.sh $file | grep -c -e err_chk -e err_exit)
if [ $count -eq 0 ]; then echo "$file does not appear to use err_chk or err_exit"; fi
done
popd > /dev/null
