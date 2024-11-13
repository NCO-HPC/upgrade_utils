#!/usr/bin/env python3
#####
# Purpose:
# This script can be run anywhere. All it does is take in a Bugzilla project
# name and Bugzilla API key and check for non-closed/resolved tickets.
#
# All modules used are in the Python standard library.
#####
# Usage:
# $ application_4.py gefs $(cat alexbugzillaapikey.txt)
# >  {'summary': 'jgefs_gempak_meta needs input files defined differently', 'status': 'NEW', 'id': 20, 'product': 'GEFS'}
# >  {'summary': 'exgefs_prdgen.sh.sms: gefs_$member_prdgen restart capability will not work in certain cases', 'status': 'ASSIGNED', 'id': 26, 'product': 'GEFS'}
# >  {'summary': 'gefs_init_separate job does not fail when missing input data, causes downstream failures', 'status': 'NEW', 'id': 30, 'product': 'GEFS'}
# >  {'summary': 'gefs_p17_post_06 job report parm file not found error', 'status': 'NEW', 'id': 61, 'product': 'GEFS'}
# >  {'summary': 'gefs_global_fcst crash', 'status': 'NEW', 'id': 192, 'product': 'GEFS'}
#####
# Written by Alex Richert (alexander.richert@noaa.gov)
#

import json, sys
import urllib.request

if len(sys.argv)!=3:
 sys.stderr.write("This script takes two arguments: the name of your project as it appears in Bugzilla, and your Bugzilla API key\n")
 sys.stderr.flush()
 sys.exit()
product = sys.argv[1]

api_key=sys.argv[2]
address = "http://www2.spa.ncep.noaa.gov/bugzilla/\
rest/bug?api_key=%s&include_fields=id,product,status,summary"%api_key

data = urllib.request.urlopen(address).read()

buglist = json.loads(data)["bugs"]

matchlist = [bug for bug in buglist\
 if bug["product"].lower()==product.lower()\
 and bug["status"] not in ["CLOSED","RESOLVED"]]

#for match in matchlist:
# print(match)

counter=0
print("Status      :(id   ) Summary")
for match in matchlist:
    print(f"{match['status']:<10}  :({match['id']} ) {match['summary']}")
    counter += 1

print("------------------------------------")
print(f"THERE ARE >> {counter} << bugs open")
print("------------------------------------")
