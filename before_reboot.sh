#!/bin/bash
time=$1

########################################
# no_passwd 
########################################
nodenum=`grep hvn ../hosts | wc -l  | awk '{print $1}'` # 
tmppath=`pwd`
nodelist=`seq -f 'hvn%g' -s ','  1 $nodenum`
cd ./utility/nopasswd/
chmod a+x * 
./xmakessh  --pass  111111  --nodes  $nodelist 
cd $tmppath
unset tmppath
unset nodenum
#########################################


while  read ip name    
do
	if [[ "X$name" == "Xlocalhost" ]];then
		continue 
	fi
	if [[ "X$name" == "Xhvn1" ]];then
		cd master;
		./master_hyper_before_reboot.sh  eth0  $time 
		cd ..
	fi            
  			

	echo $ip
done <  hosts
