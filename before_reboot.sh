#!/bin/bash
time=$1

########################################
# no_passwd 
########################################
nodenum=`grep hvn ./hosts | wc -l  | awk '{print $1}'` # 
tmppath=`pwd`
nodelist=`seq -f 'hvn%g' -s ','  1 $nodenum`
tmppasswd='111111'
cd ./utility/nopasswd/
chmod a+x * 
echo ./xmakessh  --pass  $tmppasswd  --nodes  $nodelist 
cd $tmppath
unset tmppath
unset nodenum
unset tmppasswd
#######################################
#  scp file 
######################################

#########################################
#  config  before reboot 
######################################
egrep  -v '^\s*#' hosts |while  read ip name    
do
	if [[ "X$name" == "Xlocalhost" ]];then
		continue 
	fi
	
	if [[ "X$name" == "Xhvn1" ]];then
		cd master;
		echo ./master_hyper_before_reboot.sh  eth0  $time 
		cd ..
		continue
	fi            
	cd ..  
	#copy file	
      	echo scp  -r   cloudview_deploy/     ${ip}:/root/  
  	tmp_cmd="cd /root/cloudview_deploy/hvn; sh  hvn_before_reboot.sh  eth0 $ip  "
	echo ssh $ip \" $tmp_cmd \"
	unset tmp_cmd
#	echo $ip
done 

