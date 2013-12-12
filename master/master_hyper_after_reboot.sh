#########################################
#    configuration hypervisor
########################################
rm  success_a2
tmppath=`pwd`
echo 'configure each hypervisor '

cd ../cloudview/Supports/third-party_tools/cvm-hypervisor-install/cvm-hypervisor-install*/
chmod a+x install 
./install 
cd $tmppath
########################################
bussiness_br="br1"
perl -p -i -e "s/^BRIDGE=.*/BRIDGE=${bussiness_br}/" /etc/cvm/conf/bridge.conf
unset bussiness_br

unset tmppath
touch success_a2

#########################################3
