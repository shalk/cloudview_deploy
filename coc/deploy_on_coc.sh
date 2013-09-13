#!/bin/bash
# ip  手动
#
# 无密码访问
# 将介质和部署包copy上来
# 时间同步
# hosts
#-------------------- 


time_server_ip=`grep "hvn1 " ../hosts | awk '{print $1}' `
#########################################  
# step 1  time sync
#  sync time with master 
######################################### 

echo "server $time_server_ip" >> /etc/ntp.conf
sntp -P no -r $time_server_ip

cp -rf ../hosts  /etc/hosts
echo coc > /etc/HOSTNAME
hostname coc 

tmppath=`pwd`
cd  ../cloudview/Supports/third-party_tools/installer_of_mysql/
sh install_mysql_linux.sh
cd $tmppath

cd ../cloudview/MSP
ls | grep x64 | xargs sh 
ls | grep sp5 | xargs sh 
cd $tmppath

cd ../cloudview/COC/
ls | grep coc | xargs sh 
cd $tmppath


