#!/bin/bash
# IT Checklist, Application/Coordination #25: "If the application is syncing data to a remote site using rsync, is a timeout and retry included in the script?"

re="^[^\"|\'|#]*((\"[^\"]*?\")|(\'[^']*?\')|[^\"|\'|#])*\Krsync"
for f in $(find . -type f); do
if [ $(file $f | grep ASCII | grep -v 'with very long lines' | wc -l) -gt 0 ]; then
count=$(grep -cP "$re" $f)
gpstat=$?
if [ $gpstat -ne 0 ]; then count=$(grep rsync -c $f); fi
if [ $count -gt 0 ]; then
escf=$(echo $f | sed 's|\.|\\\.|g')
less -R --pattern=rsync --prompt "$escf\: 'q' to close file; 'n'/'p' to go to next/previous rsync" $f
echo "$f appears to have rsync calls"
fi
fi
done
