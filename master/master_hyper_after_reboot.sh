#########################################
#    configuration hypervisor
#$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$ 
rm  success_a2
tmppath=`pwd`
echo 'configure each hypervisor '
cd ../cloudview/Supports/third-party_tools/cvm-hypervisor-install/cvm-hypervisor-install-2.1/
chmod a+x install 
./install 
cd $tmppath
unset tmppath
touch success_a2

#########################################3
