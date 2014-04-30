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
 ${0} eth[x] ip  
 egg: $0 eth1 \"10.0.23.11\"
"
}
if [   $# -ne 2  ] 
then 
    Usage 
    exit 1
fi

eth_num=$1  # active network interface
ip=$2 # current machine ip
manage_br='br1'
manage_netmask='16'

rm success_b1
###############################################3
cp -rf ../hosts  /etc/hosts
currenthostname=`grep $ip /etc/hosts | awk '{print $2}'`
echo $currenthostname > /etc/HOSTNAME
hostname $currenthostname 
unset currenthostname
########################################
# step1 change menulist
########################################
perl -p -i -e  's/^default .*$/default 2/' /boot/grub/menu.lst
perl -p -i -e  "s/$/dom0_mem=4096M/ if /xen.gz/ && ! /dom0_mem/" /boot/grub/menu.lst
perl -p -i -e  "s/dom0_mem=(\d+)M/dom0_mem=4096M/ " /boot/grub/menu.lst

########################################
# step 2 replace libvirt conf and xen conf 
########################################

#cp -rf  ../utility/conf/libvirtd.conf   /etc/libvirt/  
#cp -rf  ../utility/conf/xend-config.sxp  /etc/xen/

chkconfig libvirtd on
chkconfig  xend on
service libvirtd start
service xend start 
#######################################
#  config ssh
###################################

perl -p -i -e "s/^.*PasswordAuthentication.*$/PasswordAuthentication yes/" /etc/ssh/sshd_config
perl -p -i -e "s/^.*PermitRootLogin.*$/PermitRootLogin yes/" /etc/ssh/sshd_config
perl -p -i -e "s/^.*StrictHostKeyChecking.*$/StrictHostKeyChecking no/" /etc/ssh/ssh_config
service sshd restart 
##########################################
# time sync rely on  ntp service  and after.local 
###############################################
time_server_ip=`perl -lane  "print if /hvn1$/ || /hvn1 / " ../hosts  | awk '{print $1}' `
echo "server $time_server_ip prefer" >> /etc/ntp.conf
echo "sntp -P no -r $time_server_ip" >> /etc/rc.d/after.local
sntp -P no -r $time_server_ip
chkconfig ntp on
service ntp start 

########################################
# step 3   bridging 
########################################
echo "service network start" >>/etc/init.d/after.local

sh ../utility/bridging.sh $ip $eth_num  $manage_br  $manage_netmask

unset ip
unset eth_num


touch success_b1
