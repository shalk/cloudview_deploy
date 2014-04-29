#!/bin/bash
cvmcocpath=/cloudview

mkdir -p $cvmcocpath 
cd ../utility/create_vm/
echo "########################################"
echo "create coc     "
echo "########################################"
sh prepare_vm.sh coc  



