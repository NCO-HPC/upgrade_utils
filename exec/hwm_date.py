#!/usr/bin/env python3
# first arg: # of days
# second+ args: code/system

import datetime, os, sys, time
import pandas as pd
import numpy as np

args = sys.argv[1:]
if any([h in args for h in ["-h","--help"]]):
 sys.stderr.write("Usage: hwm_model.py PDY model1/sys1 [model2/sys2 ...]\n\n")
 sys.stderr.write(" where PDY is the YYYYMMDD date,\n")
 sys.stderr.write(" modelX is a HWM model code (e.g., 'BLEND', 'RAP'),\n")
 sys.stderr.write(" and systemX is one of 'p3', 'p35', and 'to4'.\n")
 sys.stderr.write(" Use -i/--interactive to plot interactively (default is PDF file).\n")
 sys.exit()
interactive = False
for i in ["-i","--interactive"]:
 if i in args:
  interactive = True
  args.remove(i)

import matplotlib
if not interactive: matplotlib.use("pdf")
import matplotlib.pyplot as plt

date = args[0]
hwmcodes = [a.split("/")[0] for a in args[1:]]
systems = [a.split("/")[1] for a in args[1:]]
assert not set(systems)-set(["p3","p35","to4"])

today_ymd = datetime.date.today().strftime("%Y%m%d")

data = {}

dates = [date]

for icode in range(len(hwmcodes)):
 hwmcode = hwmcodes[icode]
 system = systems[icode]
 if system.startswith("p3"):
  fs = "dell1"
 elif system=="to4":
  fs = "hps"
 else:
  sys.stderr.write("FATAL ERROR: System '%s' not valid, must be 'dell' or 'cray'!\n"%system)
  sys.exit(1)
 data[hwmcode] = {"OPS":[[],[]],"T2O":[[],[]]}
 for date in dates:
  for ver in list(data[hwmcode].keys()):
   d = pd.read_json("/gpfs/%s/nco/ops/com/hwm/para/hwm.%s/%s/%s-%s.json"%(fs,date,system,hwmcode,ver))
   data[hwmcode][ver][0] += [datetime.datetime.utcfromtimestamp(a[0]/1000) for a in d["data"][0]]
   data[hwmcode][ver][1] += [a[1] for a in d["data"][0]]

f = plt.figure(figsize=(6,4.5))
ax = f.add_subplot(111)
c = {"OPS":["red"],"T2O":["blue"]}

for ver in ["OPS","T2O"]:
 running_y = np.array([0 for i in data[hwmcodes[0]][ver][1]])
 for icode in range(len(hwmcodes)):
  hwmcode = hwmcodes[icode]
  if len(data[hwmcode][ver][0])==0: continue
  else: x, y = [np.array(z) for z in zip(*sorted(zip(data[hwmcode][ver][0],data[hwmcode][ver][1])))]
  running_y += np.array(y)
 ax.fill_between(x,running_y,step="pre",label="%s-%s"%("/".join(hwmcodes),ver),alpha=0.5,color=c[ver][icode%1],lw=0)

plt.xticks(rotation=90)
mtxt = []
if "to4" in systems: mtxt += ["Cray max: 2016"]
if "p3" in systems: mtxt += ["p3 max: 1212"]
if "p35" in systems: mtxt += ["p35 max: 630"]
plt.ylabel("# of nodes (%s)"%";".join(mtxt))
ax.legend()
ax.xaxis.set_major_locator(matplotlib.dates.HourLocator(interval=1))
gridweight = 0.5 if interactive else 0.25
plt.grid(lw=gridweight,linestyle="-")
plt.xlim(x[0],x[-1])
plt.ylim(0,plt.ylim()[1])
f.set_tight_layout(True)
if interactive:
 plt.show()
else:
 uniq = "%s_%s"%(time.time(),os.getpid())
 outname = "%s.%sdays.%s.pdf"%("_".join(hwmcodes),date,uniq)
 f.savefig(outname)
 sys.stderr.write(outname+"\n"); sys.stderr.flush()
