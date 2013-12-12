rm success_b2
time_server_ip=`perl -lane  "print if /hvn1$/ || /hvn1 / " ../hosts  | awk '{print $1}' `
#########################################  
# step 1  time sync
#  sync time with master 
######################################### 

echo "server $time_server_ip" >> /etc/ntp.conf
sntp -P no -r $time_server_ip

#########################################
# step 2  configuration hypervisor
#$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$ 

tmppath=`pwd`
echo 'configure each hypervisor '
cd ../cloudview/Supports/third-party_tools/cvm-hypervisor-install/cvm-hypervisor-install-*/
chmod a+x install 
./install 
########################################
bussiness_br="br1"
perl -p -i -e "s/^BRIDGE=.*/BRIDGE=${bussiness_br}/" /etc/cvm/conf/bridge.conf
unset bussiness_br

cd $tmppath
unset tmppath

#########################################3
touch success_b2
