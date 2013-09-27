#!/bin/bash
######################################
#  config bridging network 
########################################
#  
# usage  $0    ip_connect   ip_bridging ethx
#  eg   $0 10.0.23.11  192.168.0.1  eth1 
#          then   192.168.0.1 bridging to  br1 (eth1)
#             
##########################################

ip=$1
eth_num=${2:-eth1}
br_num="br1"

echo  config business network  bridging 
echo on $ip  $eth_num  will connect to $br1 
cp -rf  /etc/sysconfig/network/ifcfg-$eth_num  ../utility/bridge/ifcfg-${eth_num}.bak 
cp -rf ../utility/bridge/ifcfg-br0   /etc/sysconfig/network/ifcfg-$br_num 
cp -rf ../utility/bridge/ifcfg-eth0   /etc/sysconfig/network/ifcfg-$eth_num  
perl -p -i -e "s/eth./${eth_num}/" /etc/sysconfig/network/ifcfg-$br_num
perl -p -i -e "s/^IPADDR.*$/IPADDR=\'${ip}\/24\'/"  /etc/sysconfig/network/ifcfg-$br_num
chkconfig NetworkManage off
service NetworkManage stop
service network restart 

unset ip
unset eth_num
unset br_num

