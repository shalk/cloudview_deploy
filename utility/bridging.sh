######################################
#  config bridging network 
########################################
#  
# usage  $0    ip_connect   ip_bridging ethx
#  eg   $0 10.0.23.11  192.168.0.1  eth1 
#          then   192.168.0.1 bridging to  br1 (eth1)
#             
##########################################

connectip=$1
ip=$2
eth_num=${3:-eth1}
echo  config business network  bridging 
ssh   $connectip "
cp -rf  /etc/sysconfig/network/ifcfg-$eth_num  ifcfg-${eth_num}.bak 
cp -rf ../utility/bridge/ifcfg-br1   /etc/sysconfig/network/ 
cp -rf ../utility/bridge/ifcfg-eth0   /etc/sysconfig/network/ifcfg-$eth_num  
perl -p -i -e \"s/eth./${eth_num}/\" /etc/sysconfig/network/ifcfg-br1
perl -p -i -e \"s/^IPADDR.*$/IPADDR=\'${ip}\/24\'/\"  /etc/sysconfig/network/ifcfg-br1
chkconfig NetworkManage off
service NetworkManage stop
service network restart 
"
unset ip
unset connectip
unset eth_num

