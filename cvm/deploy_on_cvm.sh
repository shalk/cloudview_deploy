#!/bin/bash
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

echo "server $time_server_ip" >> /etc/ntp.conf
sntp -P no -r $time_server_ip

cp -rf ../hosts  /etc/hosts
echo cvm > /etc/HOSTNAME
hostname cvm 
########################################
# change vm xml 
########################################
 
#perl -p -i -e 's/br0/br1/g' ../cloudview/Supports/cvm_config/xen_create_template_xml_file/* 
#perl -p -i -e 's/br0/br1/g' ../cloudview/Supports/cvm_config/xen_template_xml_file/* 
mkdir -p /dsx01/iso
mkdir -p /dsx01/img
mkdir -p /dsx01/cfg
#cp -rf ../cloudview/Supports/cvm_config/xen_create_template_xml_file/* /dsx01/cfg
#cp -rf ../cloudview/Supports/cvm_config/xen_template_xml_file/* /dsx01/cfg

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


#mspsp=`ls | grep sp[0-9]`
#
#expect -c "
#    set timeout 60;
#    spawn  ./$mspsp -c;
#    expect {
#        \"Please select a language:\" {send \"\r\"; exp_continue}
#        \"This will install MSP Service Pack on your computer\" {send \"\r\"; exp_continue}
#    }
#"
cd $tmppath

cd ../cloudview/CVM/
chmod a+x *

cvmsh=`ls | grep cvm` 

expect -c "
   set timeout 60;
   spawn ./$cvmsh -c;
   expect {
       \"Please select a language:\" {send \"\r\"; exp_continue}
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
