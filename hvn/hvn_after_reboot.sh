
time_server_ip=`grep "hvn1 " ../hosts | awk '{print $1}' `

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
cd ../utility/cvm-hypervisor-install-2.1/ 
chmod a+x install 
./install 
cd $tmppath
unset tmppath

#########################################3
