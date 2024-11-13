#!/bin/bash
# Interactively shows rsync calls in all scripts in all subdirectories

for f in $(find ./ush ./scripts ./jobs -type f); do
if [ $(file $f | grep ASCII | grep -v 'with very long lines' | wc -l) -gt 0 ]; then
count=$(nocomment.sh $f | grep -c rsync)
if [ $count -gt 0 ]; then
escf=$(echo $f | sed 's|\.|\\\.|g')
less -R --pattern='^[^#]*rsync.*' --prompt "$escf\: 'q' to close file; 'n'/'p' to go to next/previous rsync" $f
echo "$f appears to have rsync calls"
fi
fi
done
