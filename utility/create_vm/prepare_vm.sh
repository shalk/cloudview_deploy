usage(){
  echo "
	$PROGRAM  cvm_test 
"
  exit 1
}
PROGRAM=`basename $0`
DIRNAME=`dirname $0`
cd $DIRNAME

TEMPLATE_NAME=${1:-cvm_test}

# prepare   xml  and  img  of   virtual machine 
sh create_a_vm.sh $TEMPLATE_NAME
sleep 90

MANAGE_IP=`grep $TEMPLATE_NAME /etc/hosts | awk '{print $1 }'`
MANAGE_MAC= `head -n 1 ${TEMPLATE_NAME}_mac`

echo  "$TEMPLATE_NAME  start  finish "
###################################################

ETHCMD="eth=`ifconfig -a | grep $MANAGE_MAC | awk '{print $1}'`"
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
    expecpt\"$ETHCMD\"
	expect \"~ #\"
	send \"ifconfig \$eth $MANAGE_IP  netmask  255.255.0.0 \r\"
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
 	spawn scp -r /root/.ssh/  $MANAGE_IP:/root
	expect {
	\"not know\" {send_user \"[exec echo \"not know\"]\";exit}
	\"(yes/no)?\" {send \"yes\r\";exp_continue}
	\"password:\" {send  \"111111\r\";exp_continue}
	\"Password:\" {send  \"111111\r\";exp_continue}
	\"Permission denied, please try again.\" {send_user \"[exec echo \"Error:Password is wrong\"]\" exit  }
	}
"
scp  -r ../../../cloudview_deploy/  $MANAGE_IP:/root/

ssh $MANAGE_IP  "cd /root/cloudview_deploy/${TEMPLATE_NAME}; sh deploy_on_${TEMPLATE_NAME}.sh"
########################################
#  set permanent  ip 
###################################

echo "VM  $TEMPLATE_NAME  FINISH "
