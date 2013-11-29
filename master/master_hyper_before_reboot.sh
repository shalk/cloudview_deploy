#!/bin/bash
#########################################
# Description:
# deploy on master hypervisor
# 
#          by xiaokun 2013-09-13
#########################################

####### variable init ############
Usage(){
 echo "
Usage:
 ${0} eth[x] ip 
 egg: $0 eth0  10.0.23.61
"
}
if [   $# -ne 2  ] 
then 
    Usage 
    exit 1
fi

eth_num=$1  # active network interface
ip=$2     # current machine ip
rm success_a1
########################################
# copy hosts file
#########################################
echo change host
cp -rf ../hosts  /etc/hosts
currenthostname=`grep $ip /etc/hosts | awk '{print $2}'`
echo $currenthostname > /etc/HOSTNAME
hostname $currenthostname 
echo change host finish
########################################
# step1 change menulist
########################################
echo change grub
perl -p -i -e  's/^default .*$/default 2/' /boot/grub/menu.lst
perl -p -i -e  " s/$/dom0_mem=4096M/ if /xen.gz/ && ! /dom0_mem/" /boot/grub/menu.lst
echo change grub finish
############################################
# step 3 replace libvirt conf and xen conf 
########################################
#echo libvirt and xen conf
#cp -rf  ../utility/conf/libvirtd.conf   /etc/libvirt/  
#cp -rf  ../utility/conf/xend-config.sxp  /etc/xen/

chkconfig libvirtd on
chkconfig  xend on
service libvirtd restart
service xend restart 
echo libvirt and xen conf finish
########################################
# step 4 time sync
########################################
chkconfig ntp on 
service ntp start 

########################################
# step 2   bridging 
########################################
echo "service network start" >> /etc/init.d/after.local
echo change bridging
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
touch success_a1
