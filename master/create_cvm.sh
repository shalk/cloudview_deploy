#!/bin/bash
cvmcocpath=/cloudview

mkdir -p $cvmcocpath 
cd ../utility/create_vm/
echo "########################################"
echo "create cvm     "
echo "########################################"
sh prepare_vm.sh cvm  



