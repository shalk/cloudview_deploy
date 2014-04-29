#!/bin/bash
cd `dirname $0`
time_server_ip=`perl -lane  "print if /hvn1$/ || /hvn1 / " ../hosts  | awk '{print $1}' `
###################
# check network 
##################
if cd ../cloudview > /dev/null
then
        echo
else
        echo "ln -s  ../cloudview   cloudview_fullname_and_fullpath "
        exit 1
fi
if   ping  $time_server_ip  -c 2 > /dev/null
then
     echo 
else
    echo "ping $time_server_ip is failed , Please check the network!"
    exit 1
fi

############################################
# add into cluster
############################3
expect -c "
 	spawn scp -r $time_server_ip:/root/.ssh/  /root
	expect {
	\"not know\" {send_user \"[exec echo \"not know\"]\";exit}
	\"(yes/no)?\" {send \"yes\r\";exp_continue}
	\"password:\" {send  \"111111\r\";exp_continue}
	\"Password:\" {send  \"111111\r\";exp_continue}
	\"Permission denied, please try again.\" {send_user \"[exec echo \"Error:Password is wrong\"]\" exit  }
	}
"

#########################################  
# step   time sync
#  sync time with master 
######################################### 
echo "server $time_server_ip prefer" >> /etc/ntp.conf
echo "sntp -P no -r $time_server_ip" >> /etc/rc.d/after.local
sntp -P no -r $time_server_ip
chkconfig ntp on
service ntp start 


cp -rf ../hosts  /etc/hosts
echo coc > /etc/HOSTNAME
hostname coc 
########################################
# change vm xml 
########################################
 
mkdir -p /dsx01/iso
mkdir -p /dsx01/img
mkdir -p /dsx01/cfg

########################################

tmppath=`pwd`
cd  ../cloudview/Supports/third-party_tools/installer*/
chmod a+x *
./uninstall*
sleep 10
./install*
cd $tmppath

cd ../cloudview/MSP
chmod a+x *
mspsh=`ls | grep x64`

expect -c "
    set timeout 60;
    spawn ./${mspsh} -c ;
    expect {
       \"Please select a language:\" {send \"\r\"; exp_continue}
       \"Which components should be installed?\" {send \"\r\"; exp_continue}
       \"Remote Server: Yes?\" {send \"n\r\"; exp_continue}
       \"MySQL Home\" {send \"\r\"; exp_continue}
       \"MySQL Port\" {send \"\r\"; exp_continue}
       \"MySQL Root's Password\" {send \"root123\r\"; exp_continue}
       \"Please input Server's Manage IP\" {send \"\r\"; exp_continue}
    }
"


cd $tmppath

cd ../cloudview/COC/
chmod a+x *

cocsh=`ls | grep coc` 

expect -c "
   set timeout 60;
   spawn ./$cocsh -c;
       expect {
        \"Please select a language:\" {send \"\r\"; exp_continue}
        \"This will install CloudviewOperationCenter on your computer\" {send \"\r\"; exp_continue}
        \"InitData\" {send \"\r\"; exp_continue}
        \"StorageManagementConfiguration\" {send \"\r\"; exp_continue}
        \"Please input Storage's Port\" {send \"\r\"; exp_continue}
        \"VirtualDirectoryConfiguration\" {send \"\r\"; exp_continue}
        \"Please select hypervisor type\" {send \"1\r\"; exp_continue}
    }
   "

cd $tmppath



sleep 30

/etc/init.d/cloudview status
/etc/init.d/cloudview start
/etc/init.d/tomcat status
/etc/init.d/tomcat start
sleep 10
/etc/init.d/tomcat start


MANAGE_IP=`grep coc /etc/hosts | awk '{print $1 }'`
MANAGE_MAC= `head -n 1 ../utility/create_vm/coc_mac `
MANAGE_ETH=`ifconfig -a | grep $MANAGE_MAC | awk '{print $1}'`

BUSSINESS_IP=`grep coc ip_map | awk '{print $3}'   `
BUSSINESS_MAC= `head -n 1 ../utility/create_vm/coc_mac `
BUSSINESS_ETH=`ifconfig -a | grep $BUSSINESS_MAC | awk '{print $1}'`
BUSSINESS_MASK=24

cp -rf ../utility/conf/ifcfg-eth0  /tmp/ifcfg-eth0 
cp -rf ../utility/conf/ifcfg-eth0  /tmp/ifcfg-eth1 

perl -p -i -e  "s/^.*$/IPADDR='${MANAGE_IP}\/16'/  if /^IPADDR/" /tmp/ifcfg-${MANAGE_ETH} 
perl -p -i -e  "s/^.*$/IPADDR='${BUSSINESS_IP}\/${BUSSINESS_MASK}'/  if /^IPADDR/" /tmp/ifcfg-${BUSSINESS_ETH} 

cp -rf /tmp/ifcfg-eth0 /etc/sysconfig/network/
cp -rf /tmp/ifcfg-eth1 /etc/sysconfig/network/

ssh $MANAGE_IP  "service network restart "
ssh $MANAGE_IP "service cloudview start "
ssh $MANAGE_IP "service tomcat start "
