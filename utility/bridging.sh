#!/bin/bash
######################################
#  config bridging network 
########################################
#  
# usage  $0       ip_bridging ethx  brx
#  eg   $0  192.168.0.1  eth1 br1
#          then   192.168.0.1 bridging to  br1 (eth1)
#             
##########################################

ip=$1
eth_num=${2:-eth1}
br_num=${3:-br1}
netmask=${4:-24}
cd `dirname $0`

echo  config  network  bridging 
echo on $ip  $eth_num  will connect to $br_num 
cp -rf  /etc/sysconfig/network/ifcfg-$eth_num  ../utility/bridge/ifcfg-${eth_num}.bak 
cp -rf ../utility/bridge/ifcfg-br0   /etc/sysconfig/network/ifcfg-$br_num 
cp -rf ../utility/bridge/ifcfg-eth0   /etc/sysconfig/network/ifcfg-$eth_num  
perl -p -i -e "s/eth./${eth_num}/" /etc/sysconfig/network/ifcfg-$br_num
perl -p -i -e "s/^IPADDR.*$/IPADDR=\'${ip}\/${netmask}\'/"  /etc/sysconfig/network/ifcfg-$br_num
chkconfig NetworkManage off
service NetworkManage stop
service network restart 


unset ip
unset eth_num
unset br_num
