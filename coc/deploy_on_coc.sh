#!/bin/bash

time_server_ip=`grep "hvn1 " ../hosts | awk '{print $1}' `
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

echo "server $time_server_ip" >> /etc/ntp.conf
sntp -P no -r $time_server_ip

cp -rf ../hosts  /etc/hosts
echo coc > /etc/HOSTNAME
hostname coc

tmppath=`pwd`
cd  ../cloudview/Supports/third-party_tools/installer_of_mysql/
chmod a+x *
./uninstall_mysql_linux.sh
sleep 10
./install_mysql_linux.sh
cd $tmppath

cd ../cloudview/MSP

chmod a+x *
mspsh=`ls | grep x64`

expect -c "
    set timeout 60;
    spawn ./${mspsh} -c ;
    expect {
       \"Please select a language:\" {send \"\r\"; exp_continue}
       \"This will install Sugon Management Software Core Platform on your computer\" {send \"\r\"; exp_continue}
       \"Where should Sugon Management Software Core Platform be installed?\" {send \"\r\"; exp_continue}
       \"Which components should be installed?\" {send \"\r\"; exp_continue}
       \"Remote Server: Yes?\" {send \"n\r\"; exp_continue}
       \"MySQL Home\" {send \"\r\"; exp_continue}
       \"MySQL Port\" {send \"\r\"; exp_continue}
       \"MySQL Root's Password\" {send \"root123\r\"; exp_continue}
       \"Please input Server's Manage IP\" {send \"\r\"; exp_continue}
    }
"


mspsp=`ls | grep sp5`

expect -c "
    set timeout 60;
    spawn  ./$mspsp -c;
    expect {
        \"Please select a language:\" {send \"\r\"; exp_continue}
        \"This will install MSP Service Pack on your computer\" {send \"\r\"; exp_continue}
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

/etc/init.d/cloudview start
