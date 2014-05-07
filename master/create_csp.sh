#!/bin/bash
cvmcocpath=${1:-/cv}

mkdir -p $cvmcocpath 
cd ../utility/create_vm/
echo "########################################"
echo "create csp     "
echo "########################################"
sh prepare_vm.sh csp  $cvmcocpath



