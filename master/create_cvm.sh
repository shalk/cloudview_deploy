#!/bin/bash
cvmcocpath=/cloudview

# create cvm
CVM_IP=`grep cvm ../ip_map  | awk '{print $1 }'`
TEMP_GATEWAY=`echo $CVM_IP | perl -p -e 's/\.\d+\s*$/.254/' ` 
TEMP_NETMASK='255.255.255.0'

mkdir -p $cvmcocpath 
cd ../utility/
sh create_vm_from_template.sh cvm  $CVM_IP $TEMP_NETMASK  $TEMP_GATEWAY  



