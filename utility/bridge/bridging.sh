#!/bin/bash
######################################
#  config bridging network 
########################################
#  
# usage  $0    ip_connect    ethx   brx
#  eg   $0 10.0.23.11   ethx brx
#          then   192.168.0.1 bridging to  br1 (eth1)
#             
##########################################

ip=$1
eth_num=${2:-eth0}
br_num=${3:-br0}
DIRNAME=`dir $0`
cd $DIRNAME
TMPDIR=`pwd`
echo "[$ip] config business network  bridging "
echo "[$ip]  $eth_num  will connect to $br_num"

mkdir -p bak
cp -rf  /etc/sysconfig/network/ifcfg-$eth_num  ./bak/ifcfg-${eth_num}.bak 
cp -rf ifcfg-br0   /etc/sysconfig/network/ifcfg-$br_num 
cp -rf ifcfg-eth0   /etc/sysconfig/network/ifcfg-$eth_num  

perl -p -i -e "s/eth./${eth_num}/" /etc/sysconfig/network/ifcfg-$br_num
perl -p -i -e "s/^IPADDR.*$/IPADDR=\'${ip}\/24\'/"  /etc/sysconfig/network/ifcfg-$br_num

chkconfig NetworkManage off
service NetworkManage stop
service network restart 

unset ip
unset eth_num
unset br_num
cd $TMPDIR

