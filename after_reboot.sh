#!/bin/bash
#########################################
#  config  before reboot 
######################################
ip=''
name=''
business_ip=''

egrep  -v '^\s*#' ip_map| grep hvn |while  read ip name  business_ip 
do
	if [[ "X$name" == "Xhvn1" ]];then
        #excute A2
		cd master
		touch ../log/master_after.log
		nohup sh master_hyper_after_reboot.sh   > ../log/master_after.log   2>&1  &
		cd ..
		continue
	fi            

  	#excute B2
    tmp_cmd="cd /root/cloudview_deploy/hvn;touch ../log/${name}_after.log; nohup  sh  hvn_after_reboot.sh   > ../log/${name}_after.log  2>&1 & "
    ssh $ip  $tmp_cmd 
	unset tmp_cmd
#	echo $ip
done 

unset ip
unset name
unset business_ip



