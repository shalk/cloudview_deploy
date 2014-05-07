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
 egg: $0 eth1  10.0.23.61
"
}
if [   $# -ne 2  ] 
then 
    Usage 
    exit 1
fi

eth_num=$1  # active network interface
ip=$2     # current machine ip
manage_br='br1'
manage_netmask='16'
rm success_a1
########################################
# step1 copy hosts file
#########################################
echo change host
cp -rf ../hosts  /etc/hosts
currenthostname=`grep $ip /etc/hosts | awk '{print $2}'`
echo $currenthostname > /etc/HOSTNAME
hostname $currenthostname 
echo change host finish
########################################
# step2  change menulist
########################################
echo change grub
#perl -p -i -e  's/^default .*$/default 2/' /boot/grub/menu.lst
perl -p -i -e  " s/$/dom0_mem=4096M/ if /xen.gz/ && ! /dom0_mem/" /boot/grub/menu.lst
echo change grub finish
#######################################
#  config ssh
###################################
perl -p -i -e "s/^.*PasswordAuthentication.*$/PasswordAuthentication yes/" /etc/ssh/sshd_config
perl -p -i -e "s/^.*PermitRootLogin.*$/PermitRootLogin yes/" /etc/ssh/sshd_config
perl -p -i -e "s/^.*StrictHostKeyChecking.*$/StrictHostKeyChecking no/" /etc/ssh/ssh_config
service sshd restart 
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
# step 4 time server start
########################################
echo "restrict 10.10.10.0 mask 255.255.255.0">> /etc/ntp.conf
chkconfig ntp on 
service ntp start 
echo  ntp server finish 
########################################
# step 5   bridging 
########################################
echo "service network start" >> /etc/init.d/after.local
echo bridging manage network  for cvm


sh ../utility/bridging.sh  $eth_num  $manage_br $ip $manage_netmask

unset ip
unset eth_num
echo bridging manage network finish

########################################
touch success_a1
