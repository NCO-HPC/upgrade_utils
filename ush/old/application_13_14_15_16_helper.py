#!/usr/bin/env python
# This script gets called by application_13_14_15_16.sh

import datetime, os, re, subprocess, sys

v = {}
n = ["COMROOT","NET","envir","RUN","PDY","PCOMROOT","GESROOT"]
for name in n: v[name] = os.getenv(name)

predicted = {}
try: predicted["COMIN"] = [os.path.realpath("/".join([v["COMROOT"],v["NET"],v["envir"],v["RUN"]+"."+v["PDY"]]))]
except: print("Unable to predict COMIN")
try: predicted["COMOUT"] = [os.path.realpath("/".join([v["COMROOT"],v["NET"],v["envir"],v["RUN"]+"."+v["PDY"]]))]
except: print("Unable to predict COMOUT")
try: predicted["PCOM"] = [os.path.realpath("/".join([v["PCOMROOT"],v["envir"],v["RUN"]]))]
except: print("Unable to predict PCOM")
try: predicted["GESIN"] = [os.path.realpath("/".join([v["GESROOT"],v["envir"],v["RUN"]+"."+v["PDY"]])), os.path.realpath("/".join([v["GESROOT"],v["envir"],v["RUN"]]))]
except: print("Unable to predict GESIN")
try: predicted["GESOUT"] = [os.path.realpath("/".join([v["GESROOT"],v["envir"],v["RUN"]+"."+v["PDY"]])), os.path.realpath("/".join([v["GESROOT"],v["envir"],v["RUN"]]))]
except: print("Unable to predict GESOUT")

allgood = True
actual = {}
check = ["COMIN","COMOUT","PCOM","GESIN","GESOUT"]
presentandgood = []
for c in check:
 actual[c] = os.getenv(c)
# try:
 if c not in actual.keys():
  print("%s not defined"%c)
  continue
 if c not in predicted.keys(): continue
 if os.path.realpath(actual[c]) not in predicted[c]:
  print("$%s is not properly formatted!"%c)
  print("predicted: %s"%" OR ".join(predicted[c]))
  print("actual: %s"%actual[c])
  allgood = False
 else: presentandgood += [c]
 if c=="COMOUT":
  if actual[c][:len(predicted[c][0])]==predicted[c][0]:
   PDYstr = predicted[c][0][-8:]
   try:
    PDYdtobj = datetime.datetime.strptime(PDYstr,"%Y%m%d")
    print("Yay, COMOUT contains a valid PDY in the right directory structure so that it will get automatically cleaned up")
   except ValueError:
    print("D'OH! COMOUT does not appear to end in a valid PDY, and therefore will not get automatically cleaned up (%s)"%actual[c])
 if c!=check[-1]: print("")

if len(presentandgood)>0: print("Yay, variable%s %s %s properly formatted"%("s"[:len(presentandgood)>1],", ".join(presentandgood),["is","are"][len(presentandgood)>1]))
