#!/bin/bash

install(){
tmppath=`pwd`
cd  ../cloudview/Supports/third-party_tools/installer*/
chmod a+x *
./uninstall*
sleep 10
./install*
cd $tmppath

cd ../cloudview/msp
cd ../cloudview/MSP
chmod a+x *
mspsh=`ls | grep x64`

expect -c "
    set timeout 60;
    spawn ./${mspsh} -c ;
    expect {
       \"Please select a language:\" {send \"2\r\"; exp_continue}
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


cd $tmppath


cd ../cloudview/csp/
cd ../cloudview/CSP/
chmod a+x *

cspsh=`ls | grep csp` 

expect -c "
   set timeout 60;
   spawn ./$cspsh -c;
       expect {
        \"Please select a language:\" {send \"2\r\"; exp_continue}
        \"This will install CloudviewOperationCenter on your computer\" {send \"\r\"; exp_continue}
        \"InitData\" {send \"\r\"; exp_continue}
        \"StorageManagementConfiguration\" {send \"\r\"; exp_continue}
        \"Please input Storage's Port\" {send \"\r\"; exp_continue}
        \"VirtualDirectoryConfiguration\" {send \"\r\"; exp_continue}
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


}
uninstall(){
cd /opt/msp/ 2>/dev/null || exit 1  
expect -c "
    set timeout 60;
    spawn ./uninstall -c;
    expect {
        \"Are you sure you want to completely remove\" {send \"\r\"; exp_continue}
        \"Drop Database:\" {send \"\r\"; exp_continue}
   }
"
sleep 10
rm  -rf /opt/msp

}

install
