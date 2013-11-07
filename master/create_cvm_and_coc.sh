#!/bin/bash
cvmcocpath=/root/.cvmcoc

# create cvm

mkdir -p $cvmcocpath 
qemu-img convert -f qcow2  ../../cvm.qcow2  -O raw  ${cvmcocpath}/cvm.raw 

virt-install    --hvm   --name cvm  --ram 4096  --vcpus 4 \
 --disk  path=${cvmcocpath}/cvm.raw   --os-type "linux"  --network bridge=br0 --boot hd
 
# create coc
qemu-img convert -f qcow2  ../../cvm.qcow2  -O raw  ${cvmcocpath}/coc.raw 

virt-install    --hvm   --name coc --ram 4096  --vcpus 4 \
 --disk  path=${cvmcocpath}/coc.raw   --os-type "linux"  --network bridge=br0 --boot hd



