#!/usr/bin/env python3
# This script gets called by items_7_8_9_10.sh

import datetime, os, re, subprocess, sys

v = {}
n = ["COMROOT","NET","NET_ver_2D","envir","RUN","PDY","NWGES"]
for name in n: v[name] = os.getenv(name)

predicted = {}
try: predicted["COMIN"] = [os.path.realpath("/".join([v["COMROOT"],v["NET"],v["NET_ver_2D"],v["RUN"]+"."+v["PDY"]]))]
except: print("Unable to predict COMIN")
try: predicted["COMOUT"] = [os.path.realpath("/".join([v["COMROOT"],v["NET"],v["NET_ver_2D"],v["RUN"]+"."+v["PDY"]]))]
except: print("Unable to predict COMOUT")
try: predicted["GEMPAK"] = [os.path.realpath("/".join([v["COMROOT"],v["NET"],v["NET_ver_2D"],v["RUN"]+"."+v["PDY"],"gempak"]))]
except: print("Unable to predict GEMPAK")
try: predicted["WMO"] = [os.path.realpath("/".join([v["COMROOT"],v["NET"],v["NET_ver_2D"],v["RUN"]+"."+v["PDY"],"wmo"]))]
except: print("Unable to predict WMO")

allgood = True
actual = {}
#check = ["COMIN","COMOUT","WMO","GEMPAK","NWGES"]
check = ["COMIN","COMOUT","NWGES"]
presentandgood = []
for c in check:
 actual[c] = os.getenv(c)
 if (c not in actual.keys()) or (actual[c] is None):
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
