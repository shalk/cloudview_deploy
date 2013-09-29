#!/bin/bash
Usage(){
#before 
 echo "Usage:
     $0   time
 egg: $0  \"2007-08-03 14:15:00\"
" 
    exit 1
}
if [[ $# != 1 ]]
then
    Usage
fi 

curtime=$1
# change time in the front 
echo change time
date -s  "$curtime"
hwclock -w
echo change time finish 
unset curtime

########################################
#   handle hosts file 
######################################
if [[ -f  ip_map    ]]
then 
   sed -i 's/
   echo "127.0.0.1 localhost" > hosts  
   awk  '{printf("%s   %s", $1,$2)}' ip_map >> hosts
else
    echo please check ip_map  is exist
    exit 1
fi


########################################
# no_passwd 
########################################
nodenum=`grep hvn ./hosts | wc -l  | awk '{print $1}'` # 
tmppath=`pwd`
nodelist=`seq -f 'hvn%g' -s ','  1 $nodenum`
tmppasswd='111111'
cd ./utility/nopasswd/
chmod a+x * 
./xmakessh  --pass  $tmppasswd  --nodes  $nodelist 
cd $tmppath
unset tmppath
unset nodenum
unset tmppasswd
unset tmppasswd

#########################################
#  config  before reboot 
######################################
ip=''
name=''
manage_eth="eth0"
business_ip=''

egrep  -v '^\s*#' ip_map |while  read ip  name business_ip
do
	if [[ "X$name" == "Xlocalhost" ]];then
		continue 
	fi
     
	
	if [[ "X$name" == "Xhvn1" ]];then
        # bridging manage ip
	    cd utility/
        nohup sh   bridging.sh $business_ip  >../log/brdging.log    1<&2 & 
        cd ..
        	
        #excute A1
        cd master
		nohup sh master_hyper_before_reboot.sh  $manage_eth $ip  >../log/master_before.log   1<&2  &
		cd ..
		continue
	fi            

	#copy file	
   	cd ..  
    scp  -r   cloudview_deploy/     ${ip}:/root/  
    cd cloudview_deploy

    tmp_cmd="cd /root/cloudview_deploy/utility/; nohup sh   bridging.sh $business_ip  >../log/brdging.log    1<&2 & " 
    ssh $ip $tmp_cmd 
    unset tmp_cmd 
    
  	#excute B1
    tmp_cmd="cd /root/cloudview_deploy/hvn ; nohup  sh  hvn_before_reboot.sh  $manage_eth  $ip  > ../log/hvn_before.log  1<&2 & "
    ssh $ip  $tmp_cmd 
	unset tmp_cmd
#	echo $ip
done 
unset ip
unset name 
unset business_ip
unset manage_eth

checkfinish 


checkfinish(){



}