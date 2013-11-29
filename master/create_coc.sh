#!/bin/bash
cvmcocpath=/cloudview

# create coc
COC_IP=`grep coc ../ip_map  | awk '{print $1 }'`
TEMP_GATEWAY=`echo $COC_IP | perl -p -e 's/\.\d+\s*$/.254/' ` 
TEMP_NETMASK='255.255.255.0'
mkdir -p $cvmcocpath 
cd ../utility/
sh create_vm_from_template.sh  coc $COC_IP $TEMP_NETMASK  $TEMP_GATEWAY  



