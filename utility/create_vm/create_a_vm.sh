#!/bin/bash

cd `dirname $0`
ifconfig br0  >& /dev/null
if [[ $? != 0 ]]
then
    echo "need br0 for bridge!"
    exit
fi

ifconfig br1  >& /dev/null
if [[ $? != 0 ]]
then
    echo "also need br1 for bridge!"
    exit
fi

PROGRAM=`basename $0`
DIRNAME=`dirname $0`
cd $DIRNAME

# prepare   xml  and  img  of   virtual machine 
TEMPLATE_NAME=${1:-cvm}
MOUNT_PATH='/cloudview'
XML_NAME="${MOUNT_PATH}/${TEMPLATE_NAME}/${TEMPLATE_NAME}.xml"
IMG_PATH="${MOUNT_PATH}/${TEMPLATE_NAME}/${TEMPLATE_NAME}.raw"


mkdir -p ${MOUNT_PATH}/${TEMPLATE_NAME}
cp -rf cvm_template.xml $XML_NAME 
tmppath=`pwd`

cd ../../../
if [[ ! -f cvm_template.qcow2 ]]
then 
    unrar x cvm_template.rar
fi
qemu-img convert -f qcow2  cvm_template.qcow2  -O raw  $IMG_PATH
echo  'img convert finish '
cd $tmppath


MAC_NAMEA=`echo 00:16$(hexdump -n4 -e '/1 ":%02X"' /dev/urandom)`
MAC_NAMEB=`echo 00:16$(hexdump -n4 -e '/1 ":%02X"' /dev/urandom)`
MAC_FILE="${TEMPLATE_NAME}_mac"

cd ../../
rm -rf $MAC_FILE
echo $MAC_NAMEA >> $MAC_FILE
echo $MAC_NAMEB >> $MAC_FILE
cd $tmppath 

UUID_NAME=`uuidgen`
echo $TEMPLATE_NAME
echo $IMG_PATH
echo $MAC_NAMEA 
echo $MAC_NAMEB
echo $UUID_NAME
perl -p -i -e   "s!TEMPLATE_NAME!$TEMPLATE_NAME!" $XML_NAME 
perl -p -i -e   "s!IMG_PATH!$IMG_PATH!"    $XML_NAME
perl -p -i -e   "s!MAC_NAMEA!$MAC_NAMEA!" $XML_NAME
perl -p -i -e   "s!MAC_NAMEB!$MAC_NAMEB!" $XML_NAME
perl -p -i -e   "s!UUID_NAME!$UUID_NAME!" $XML_NAME 


virsh define  $XML_NAME
sleep 5
xm start $TEMPLATE_NAME
echo  "$TEMPLATE_NAME  start  finish "
