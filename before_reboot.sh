#!/bin/bash
Usage(){
#before 
 echo "Usage:
     $0   time
 egg: $0  \"2007-08-03 14:15:00\"
" 
    exit 1
}
checkfinish(){

    echo 

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

mkdir log

########################################
#   handle hosts file 
######################################
if [[ -f  ip_map    ]]
then 
   sed -i 's/
//g' ip_map 
   echo "127.0.0.1 localhost" > hosts  
   awk  '{printf("%s   %s\n", $1,$2)}' ip_map >> hosts
else
    echo please check ip_map  is exist
    exit 1
fi


########################################
# no_passwd 
########################################
cp -rf hosts  /etc/  
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

egrep  -v '^\s*#' ip_map | grep hvn | while  read ip  name business_ip
do
     
	if [[ "X$name" == "Xhvn1" ]];then
        # bridging manage ip
	    cd utility/
	    touch ../log/bridging.log
        nohup sh   bridging.sh $business_ip  > ../log/bridging.log    2>&1 &  
        cd ..
        	
        #excute A1
        cd master
	    touch ../log/master_before.log
	    nohup sh master_hyper_before_reboot.sh  $manage_eth $ip  > ../log/master_before.log   2>&1  &
	    cd ..
		continue
	fi            

	#copy file	
        cd ..  
        scp  -r   cloudview_deploy/     ${ip}:/root/  
        cd cloudview_deploy

    tmp_cmd="cd /root/cloudview_deploy/utility/;touch ../log/bridging; nohup sh   bridging.sh $business_ip  >../log/bridging.log    2>&1 & " 
    ssh $ip $tmp_cmd 
    unset tmp_cmd 
    
  	#excute B1
    tmp_cmd="cd /root/cloudview_deploy/hvn ;touch ../log/${name}_before.log ;nohup  sh  hvn_before_reboot.sh  $manage_eth  $ip  > ../log/${name}_before.log  2>&1 & "

    ssh $ip  $tmp_cmd 
	unset tmp_cmd
#	echo $ip
done 
unset ip
unset name 
unset business_ip
unset manage_eth

checkfinish 


