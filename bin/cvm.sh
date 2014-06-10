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

cd ../cloudview/cvm/
cd ../cloudview/CVM
chmod a+x *

cvmsh=`ls | grep cvm`

expect -c "
   set timeout 60;
   spawn ./$cvmsh -c;
   expect {
       \"Please select a language:\" {send \"2\r\"; exp_continue}
       \"This will install Sugon\" {send \"\r\"; exp_continue}
       \"InitData\" {send \"\r\"; exp_continue}
       \"VirtualDirectoryConfiguration\" {send \"\r\"; exp_continue}
       \"Please select hypervisor type\" {send \"1\r\"; exp_continue}
   }
   "
cd $tmppath


sleep 30
cd /opt/msp/collect_agent
rm node_list
perl -lane "print @F[0] if /hvn/ "  /etc/hosts > /opt/msp/collect_agent/node_list
sh batch_install_collect_node.sh 
cd $tmppath

sleep 30

/etc/init.d/cloudview status
/etc/init.d/cloudview start
/etc/init.d/tomcat status
/etc/init.d/tomcat start
sleep 10
/etc/init.d/tomcat start
}


install_collect(){


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


