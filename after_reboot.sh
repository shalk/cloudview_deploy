#!/bin/bash
#########################################
#  config  before reboot 
######################################
egrep  -v '^\s*#' hosts |while  read ip name    
do
	if [[ "X$name" == "Xlocalhost" ]];then
		continue 
	fi
	
	if [[ "X$name" == "Xhvn1" ]];then
		cd master
		nohup sh master_hyper_after_reboot.sh   >../log/master_after.log   1<&2  &
		cd ..
		continue
	fi            

  	#excute B1
    tmp_cmd="cd /root/cloudview_deploy/hvn; nohup  sh  hvn_after_reboot.sh   > ../log/hvn_after.log  1<&2 & "
    ssh $ip  $tmp_cmd 
	unset tmp_cmd
#	echo $ip
done 



