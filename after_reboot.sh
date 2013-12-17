#!/bin/bash
#########################################
#  config  before reboot 
######################################
ip=''
name=''
business_ip=''

for  line  in `egrep  -v '^\s*#' ip_map | grep hvn | sed  -e 's/  / /g'  -e 's/ /:/g'`
do
     ip=`echo $line | awk -F: '{print $1}'`
     name=`echo $line | awk -F: '{print $2}'`
     business_ip=`echo $line | awk -F: '{print $3}'`
    
	if [[ "X$name" == "Xhvn1" ]];then
        #excute A2
		continue
	fi            
     echo "########################################"
     echo "# $ip  $name  $business_ip   install hypervisor"
  	#excute B2
    tmp_cmd="cd /root/cloudview_deploy/hvn;touch ../log/${name}_after.log; nohup  sh  hvn_after_reboot.sh   > ../log/${name}_after.log  2>&1 & "
    ssh $ip  $tmp_cmd 
	unset tmp_cmd
#	echo $ip
     echo "########################################"
done 

     echo "########################################"
     echo "# master  install hypervisor "
cd master
touch ../log/master_after.log
sh master_hyper_after_reboot.sh    
cd ..
     echo "########################################"

unset ip
unset name
unset business_ip



