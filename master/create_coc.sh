#!/bin/bash
cvmcocpath=${1:-/cloudview}

mkdir -p $cvmcocpath 
cd ../utility/create_vm/
echo "########################################"
echo "create coc     "
echo "########################################"
sh prepare_vm.sh coc  $cvmcocpath



