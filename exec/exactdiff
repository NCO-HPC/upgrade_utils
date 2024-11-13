#!/usr/bin/env python
#
# Diff two files, but if two lines are not exactly identical then they are
# considered different. Useful for diffing file lists. Only considers unique
# lines.
#
# Provide two files as arguments; optional third argument sets padding between
# the two columns
#

import os, re, sys

args = sys.argv[1:]
if args[0]=="--hidefilenames":
 hidefilenames = True
 args = args[1:]
else: hidefilenames = False

assert len(args) in [2,3], "Wrong number of arguments"
if len(args)==3: assert re.match("^\d+$", args[2]), "Extra argument must be an integer (pad size)"
assert all([os.path.exists(f) for f in args[:2]]), "Make sure your files exist!"

pad = 5 if len(args)==2 else int(args[2])

def niceprint(arr, maxlen0):
 sys.stdout.write(arr[0].ljust(maxlen0))
 sys.stdout.write(pad*" ")
 sys.stdout.write(arr[1])
 sys.stdout.write("\n")

files = [sorted([l.strip() for l in open(args[i],"r").readlines()]) for i in [0,1]]
uniques = sorted(list(set(files[0]+files[1])))

maxlen0 = max([len(l) for l in files[0]+[args[0]]])

if not hidefilenames:
 niceprint(args, maxlen0)
 niceprint(["="*max([len(a) for a in args])]*2, maxlen0)

for unique in uniques:
 niceprint([[">","<"][i] if unique not in files[i] else unique for i in [0,1]], maxlen0)

sys.stdout.flush()
