#!/bin/bash
#####
# Purpose:
# This script is run in the root directory of a WCOSS code package. It looks at
# all scripts and identifies unused standard variables (as per WCOSS
# implementation standards), as well as used non-standard variables.
#####
# Usage:
# $ cd /path/to/mycode.v1.2.3 ; application_5.sh
# >  ==========
# >  Non-standard variables in ./ush/ncomycodephp.pl:
# >  mycodelog: line 76
# >  ==========
# >  Non-standard variables in ./sorc/mycode.fd/makefile:
# >  BINDIR: line 44
# >  BUFR_LIB8: line 18
# >  =============================================
# >  Standard variable 'subcycle' does not appear to be used anywhere in this package.
# >  Standard variable 'DCOM' does not appear to be used anywhere in this package.
# or
# $ cd /path/to/mycode.v1.2.3 ; application_5.sh NWROOTp1 NWROOTxc40
# or
# $ cd /path/to/mycode.v1.2.3 ; application_5.sh -m codename
# or, to list unique non-standard variables:
# cd /path/to/mycode.v1.2.3 ; application_5.sh | awk '{print $1}' | grep -E "^[^[:space:]]+:" | sort | uniq | sed 's|:$||'
#
# The first argument is the name of the model; remaining optional arguments are
# variable names to ignore. The '-m' option can be used to manually override
# the model name.
#####
# Written by Alex Richert (alexander.richert@noaa.gov)
#

stdvarlist=( 'RUN_ENVIR' envir NWROOT NWROOTp1 NWROOTp3 NWROOTxc40 job jobid NET RUN PDY cyc cycle subcycle DATAROOT DATA 'HOME{model}' 'USH{model}' 'EXEC{model}' 'PARM{model}' 'FIX{model}' DCOMROOT DCOM COMIN COMOUT 'COMOUT{model}' GESIN GESOUT DBNROOT SENDECF SENDDBN SENDDBN_NTC SENDCOM SENDWEB '{model}_ver' KEEPDATA )

if [ "$1" == "-m" ]; then
modelname=$2; shift 2;
else
modelname=$(echo $PWD | perl -pe "s|.+\/||g;s|\..*||g");
fi

declare -A used
for i in $(seq 0 $((${#stdvarlist[@]}-1))); do
 stdvar=$(echo ${stdvarlist[$i]} | sed "s/{model}/$modelname/")
 used[$stdvar]=NO
 stdvarlist[$i]=$stdvar
done

for f in $(find -type f -not -path '*.svn/*' -not -path '*.git/*');
do
 filetype=$(file --brief $f)
 isshellscript=$(grep 'script' <(echo "$filetype"))
 if [ ! "$isshellscript" ] ; then continue; fi
 declare -A uniqnonstd
 while IFS= read -r scriptline; do
  if [ $(echo $filetype | awk '{print $1}') == "Perl" ];
  then
   varnames=$(echo $scriptline | grep -oP '\$ENV{.\K\w+(?=.})')
  else varnames=$(echo $scriptline | grep -oP '\$\{?\K\w*(?=\}?)');
  fi
  for varname in $varnames; do
   if [[ " $@ " =~ " $varname " ]]; then continue; fi
   if [ -z ${used[$varname]} ]; then
    if [ ! $(echo $varname | grep -E "^PDY(m|p)[[:digit:]]+") ]; then
     linenum=$(echo $scriptline | grep -oE "^[0-9]*:")
     uniqnonstd[$varname]+="$linenum"
    fi
   else
    used[$varname]=YES
   fi
  done
 done < <(nocomment.sh $f | grep -E --line-number '\$\{?\w+\}?')
 echo -e "==========\nNon-standard variables in $f":
 for key in $(echo "${!uniqnonstd[@]}" | sed 's|[[:space:]]\+|\n|g' | sort); do echo $key: $(echo lines ${uniqnonstd[$key]} | sed 's|:|,|g;s|,$||;s|lines \([0-9]\+\)$|line \1|'); done
done
echo "============================================="
for stdvar in "${stdvarlist[@]}"; do
 if [ ${used[$stdvar]} == NO ]; then
  echo "Standard variable '$stdvar' does not appear to be used anywhere in this package."
 fi
done
