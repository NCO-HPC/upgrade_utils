#!/usr/bin/env python3

import argparse, datetime, os, sys, time
import pandas as pd
import numpy as np
from collections import defaultdict, OrderedDict

parser = argparse.ArgumentParser(description='Plot HWM chart for given HWM codes',formatter_class=argparse.ArgumentDefaultsHelpFormatter)
parser.add_argument('ndays',type=int,help='Number of days ago to go back and plot')
parser.add_argument('codes',type=str,nargs='+',help='HWM code/system (e.g., BLEND/p3, HMON/to4)')
parser.add_argument('--interactive','-i',action='store_true',help='Plot interactively')
parser.add_argument('--bin','-b',type=int,default=1,help='Time bin size in minutes')
parser.add_argument('--type','-t',choices=["pdf","png"],default="pdf",help='Output file type')
parser.add_argument('--lines','-l',action='store_true',help='Plot lines instead of filled')
parser.add_argument('--save','-s',type=str,help='Save off HWM data to file')
parser.add_argument('--datestart','-d',type=str,default=datetime.date.today().strftime("%Y%m%d"),help='date to start the bin going backward, YYYYMMDD formate')
parser.add_argument('--outname','-o',type=str,help='Output file name')
args = parser.parse_args()

import matplotlib
if not args.interactive:
 if args.type!="pdf": matplotlib.use("agg")
 else: matplotlib.use("pdf")
import matplotlib.pyplot as plt

ndays = args.ndays
hwmcodes = [a.split("/")[0] for a in args.codes]
#print(args.codes)
#print(hwmcodes)
systems = [a.split("/")[1] for a in args.codes]
#systems = [a.split("/")[1] for a in args.codes]
#assert not set(systems)-set(["p3","p35","to4"]), "systems must be one of p3, p35, and to4"

mydate=datetime.datetime.strptime(args.datestart, "%Y%m%d").date() 
print (ndays)

data = {}

#dates = [(datetime.date.today()-datetime.timedelta(days=i)).strftime("%Y%m%d") for i in range(ndays)]
dates = [(mydate-datetime.timedelta(days=i)).strftime("%Y%m%d") for i in range(ndays)]

print (dates)

if args.save is not None:
  runningsavedata = ""

## AB
for icode in range(len(hwmcodes)):
 hwmcode = hwmcodes[icode]
 print (hwmcode)
#AB
for icode in range(len(hwmcodes)):
 hwmcode = hwmcodes[icode]
 system = systems[icode]
# if system.startswith("p3"):
#  fs = "dell1"
# elif system=="to4":
#  fs = "hps"
# else:
#  sys.stderr.write("FATAL ERROR: System '%s' not valid, must be 'dell' or 'cray'!\n"%system)
#  sys.exit(1)
 if hwmcode not in data.keys(): data[hwmcode] = {}
 data[hwmcode][system] = {"OPS":[[],[]],"T2O":[[],[]]}
 for date in dates:
  for ver in list(data[hwmcode][system].keys()):
   d = pd.read_json("/lfs/h1/ops/prod/com/hwm/v1.0/hwm.%s/nwges_nid_nodes/%s-%s.json"%(date,hwmcode,ver))
#AB   d = pd.read_json("/lfs/h1/ops/prod/com/hwm/v1.0/hwm.%s/nwges_nid_cores/%s-%s.json"%(date,hwmcode,ver))
   print (d)
   for a in d["data"][0]:
     datestamp = datetime.datetime.utcfromtimestamp(a[0]/1000)
     data[hwmcode][system][ver][0] += [datestamp]
     data[hwmcode][system][ver][1] += [a[1]]
     if args.save is not None:
       runningsavedata += "%s,%s,%s,%s\n"%(hwmcode,ver,datestamp.strftime("%s"),a[1])

if args.save is not None:
  savefile = os.path.abspath(args.save)
  open(savefile,"w").write(runningsavedata)
  print("Saved to '%s'"%os.path.abspath(args.save))

f = plt.figure(figsize=(6,4.5))
ax = f.add_subplot(111)
c = {"OPS":["red"],"T2O":["deepskyblue"]}
totals = {"OPS":defaultdict(int),"T2O":defaultdict(int)}

for ver in ["OPS","T2O"]:
 running_y = np.array([0 for i in data[hwmcodes[0]][systems[0]][ver][1]])
 for icode in range(len(hwmcodes)):
  hwmcode = hwmcodes[icode]
  system = systems[icode]
  if len(data[hwmcode][system][ver][0])==0: continue
  else: x, y = [np.array(z) for z in zip(*sorted(zip(data[hwmcode][system][ver][0],data[hwmcode][system][ver][1])))]
  running_y += np.array(y)
 y = np.zeros_like(running_y)
 for i in range(len(running_y)):
  lo = (i//args.bin)*args.bin ; hi = min(((i//args.bin+1)*args.bin,len(running_y)))
  y[i] = np.nanmean(running_y[lo:hi])
 if args.lines: ax.plot(x,y,label="%s-%s"%("/".join(set(hwmcodes)),ver),color=c[ver][icode%1])
 else: ax.fill_between(x,y,step="pre",label="%s-%s"%("/".join(set(hwmcodes)),ver),color=c[ver][icode%1],lw=0)
 for i in range(len(x)):
   totals[ver][x[i]] = y[i]

dtlist = set(list(totals["OPS"].keys())+list(totals["T2O"].keys()))
mindata = OrderedDict()
for dt in sorted(dtlist):
  mindata[dt] = min((totals["OPS"][dt],totals["T2O"][dt]))
ax.fill_between(list(mindata.keys()),list(mindata.values()),color="rebeccapurple")
    

plt.xticks(rotation=90)
mtxt = []
if "to4" in systems: mtxt += ["Cray max: 2016"]
if "p3" in systems: mtxt += ["p3 max: 1212"]
if "p35" in systems: mtxt += ["p35 max: 630"]
plt.ylabel("# of nodes (%s)"%";".join(mtxt))
#AB plt.ylabel("# of cores (%s)"%";".join(mtxt))
ax.legend()
if ndays <= 30:
 if ndays <= 5: tickint = 1
 elif ndays <= 15: tickint = 3
 elif ndays <= 30: tickint = 6
 ax.xaxis.set_minor_locator(matplotlib.dates.HourLocator(interval=tickint))
gridweight = 0.5 if args.interactive else 0.25
plt.grid(lw=gridweight,linestyle="-")
plt.xlim(x[0],x[-1])
plt.ylim(0,plt.ylim()[1])
f.set_tight_layout(True)
if args.interactive:
 plt.show()
else:
 uniq = "%s_%s"%(time.time(),os.getpid())
 outname = args.outname if args.outname else "%s.%sdays.%s.%s"%("_".join(hwmcodes),ndays,uniq,args.type)
 f.savefig(outname)
 sys.stderr.write(outname+"\n"); sys.stderr.flush()
