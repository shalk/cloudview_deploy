#!/bin/bash
cd `dirname $0`
nbdname='nbd1'
filename=$1
if [ $# < 1 ] ; then
    echo "need a parameter
         eg: $0 rhel6u3.qcow2
        "
fi
nbd_qcow2(){
modinfo  nbd
if [ $? != 0 ] ; then
    echo "nbd module is not exists ,please install qemu-nbd"
    exit 1
fi
lsmod | grep nbd
if [ $? != 0 ] ; then
    echo "nbd module is not exists ,please install qemu-nbd"
    exit 1
fi
modprobe nbd max_part=16

qemu-nbd -c /dev/$nbdname $filename
fdisk -lu /dev/$nbdname 
}
mount_qcow2(){
mount /dev/${nbdname}p3  /mnt/
}
umount_qcow2(){
umount /mnt/ 
}

unlink_qcow2(){
qemu-nbd -d /dev/$nbdname
}
