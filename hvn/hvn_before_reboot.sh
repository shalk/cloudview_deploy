#!/bin/bash
#########################################
# Description:
# deploy on normal  hypervisor
# 
#          by xiaokun 2013-09-13
#########################################

####### variable init ############
Usage(){
 echo "
Usage:
 ./${0} eth[x] ip  
 egg: ./$0 eth0 \"10.0.23.11\"
"
}
if [   $# -ne 2  ] 
then 
    Usage 
    exit 1
fi

ip=$2 # current machine ip
eth_num=$1  # active network interface


###############################################3
cp -rf ../hosts  /etc/hosts
currenthostname=`grep $ip hosts | awk '{print $2}'`
echo $currenthostname > /etc/HOSTNAME
hostname $currenthostname 
unset currenthostname
########################################
# step1 change menulist
########################################
perl -p -i -e  's/^default .*$/default 2/' /boot/grub/menu.lst
perl -p -i -e  " s/$/dom0_mem=8192M/ if /xen.gz/ && ! /dom0_mem/" /boot/grub/menu.lst

########################################
# step 2   bridging 
########################################
cp -rf  /etc/sysconfig/network/ifcfg-$eth_num  ifcfg-${eth_num}.bak 
cp -rf ../utility/bridge/ifcfg-br0   /etc/sysconfig/network/ 
cp -rf ../utility/bridge/ifcfg-eth0   /etc/sysconfig/network/ifcfg-$eth_num  
perl -p -i -e "s/eth./${eth_num}/" /etc/sysconfig/network/ifcfg-br0
perl -p -i -e "s/^IPADDR.*$/IPADDR=\'${ip}\/24\'/"  /etc/sysconfig/network/ifcfg-br0
chkconfig NetworkManage off
service NetworkManage stop
service network restart 
unset ip
unset eth_num

########################################
# step 3 replace libvirt conf and xen conf 
########################################

cp -rf  ../utility/conf/libvirtd.conf   /etc/libvirt/  
cp -rf  ../utility/conf/xend-config.sxp  /etc/xend/

chkconfig libvirtd on
chkconfig  xend on
service libvirtd restart
service xend restart 

