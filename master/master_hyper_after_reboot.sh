#########################################  
# step 1  no_passwd
# assuming that  each node  have been added  in the hostfile and the network is done well .
#
#  
######################################### 


nodenum=`grep hvn ../hosts | wc -l  | awk '{print $1}'` # 
tmppath=`pwd`
nodelist=`seq -f 'hvn%g' -s ','  1 $nodenum`
cd ../utility/nopasswd/
chmod a+x * 
./makessh  --passwd  111111  --nodes  $nodelist 
cd $tmppath
unset tmppath
unset nodenum

#########################################
# step 2  configuration hypervisor
#$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$ 

tmppath=`pwd`
echo 'configure each hypervisor '
cd ../cloudview/Supports/third-party_tools/cvm-hypervisor-install/cvm-hypervisor-install-2.1/
chmod a+x install 
./install 
cd $tmppath
unset tmppath

#########################################3
