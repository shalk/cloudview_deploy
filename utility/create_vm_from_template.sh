usage(){
  echo "
	$PROGRAM  cvm_test  10.0.50.231  255.255.255.0 10.0.50.254  
"
  exit 1
}
PROGRAM=`basename $0`
DIRNAME=`dirname $0`
cd $DIRNAME
echo "paranumber   $#"
if [[  $# -ne  4 ]]
then
    usage
fi

TEMPLATE_NAME=${1:-cvm_test}

# prepare   xml  and  img  of   virtual machine 
XML_NAME="/cloudview/${TEMPLATE_NAME}/${TEMPLATE_NAME}.xml"
mkdir -p /cloudview/$TEMPLATE_NAME
cp ../utility/conf/cvm_template.xml $XML_NAME 
IMG_PATH="/cloudview/${TEMPLATE_NAME}/${TEMPLATE_NAME}.raw"
qemu-img convert -f qcow2  ../../cvm_template.qcow2  -O raw  $IMG_PATH

echo  'img convert finish '

TEMPIP=${2:-10.0.50.231}
sed -i "/$TEMPIP/d"  /root/.ssh/known_hosts
TEMPNETMASK=${3:-255.255.255.0}
GATEWAY=${4:-10.0.50.254}


MAC_NAME=`echo 00:16$(hexdump -n4 -e '/1 ":%02X"' /dev/random)`
UUID_NAME=`uuidgen`
echo $TEMPLATE_NAME
echo $IMG_PATH
echo $MAC_NAME
echo $UUID_NAME
perl -p -i -e   "s!TEMPLATE_NAME!$TEMPLATE_NAME!" $XML_NAME 
perl -p -i -e   "s!IMG_PATH!$IMG_PATH!"    $XML_NAME
perl -p -i -e   "s!MAC_NAME!$MAC_NAME!" $XML_NAME 
perl -p -i -e   "s!UUID_NAME!$UUID_NAME!" $XML_NAME 


virsh define  $XML_NAME
sleep 5
xm start $TEMPLATE_NAME
sleep 60

echo  "$TEMPLATE_NAME  start  finish "

########echo finish
#TEMPIP="10.0.50.231"
#GATEWAY="10.0.50.254"
TEMPGW="default $GATEWAY - -"
expect -c "
    set timeout 10
    spawn virsh console $TEMPLATE_NAME 
    expect {
	\"Escape character\" {send \"\r\r\" ; exp_continue} 
	\"Escape character\" {send \"\r\r\" ; exp_continue} 
	\"login:\" {send \"root\r\"; exp_continue}
	\"Password:\" {send \"111111\r\";} 
	} 
	expect \"~ #\"
	send \"echo  123\r\" 
	expect \"~ #\"
	send \"ifconfig eth0 $TEMPIP  netmask  $TEMPNETMASK \r\"
	expect \"~ #\"
	send \"echo  $TEMPGW  >> /etc/sysconfig/network/routes \r \"
	expect \"~ #\"
	send \"exit\r\"
	expect \"logout\"
	send \"\r\r\"
	send \"\"
	send \"\"
	send \"\"
"
sleep 5
expect -c "
 	spawn scp -r /root/.ssh/  $TEMPIP:/root
	expect {
	\"not know\" {send_user \"[exec echo \"not know\"]\";exit}
	\"(yes/no)?\" {send \"yes\r\";exp_continue}
	\"password:\" {send  \"111111\r\";exp_continue}
	\"Password:\" {send  \"111111\r\";exp_continue}
	\"Permission denied, please try again.\" {send_user \"[exec echo \"Error:Password is wrong\"]\" exit  }
	}
"
scp  -r ../../cloudview_deploy/  $TEMPIP:/root/

ssh $TEMPIP  'cd /root/cloudview_deploy/cvm; sh deploy_on_cvm.sh'
########################################
#  set permanent  ip 
###################################
cp ../utility/conf/ifcfg-eth0  /tmp/ifcfg-eth0 
perl -p -i -e  "s/^.*$/IPADDR='${TEMPIP}\/24'/  if /^IPADDR/" /tmp/ifcfg-eth0 
scp /tmp/ifcfg-eth0 $TEMPIP:/etc/sysconfig/network
ssh $TEMPIP  "service network restart "
ssh $TEMPIP "service cloudview start "
ssh $TEMPIP "service tomcat start "

echo "VM  $TEMPLATE_NAME  FINISH "
