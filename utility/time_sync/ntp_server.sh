#!/bin/bash

#egg: $0  \"2007-08-03 14:15:00\"
date -s  "$1"
hwclock -w
/etc/init.d/ntp start
chkconfig ntp on
if grep "restrict 10.10.10.0 mask 255.255.255.0" /etc/ntp.conf >&/dev/null
then
    echo 
else
    echo "restrict 10.10.10.0 mask 255.255.255.0">> /etc/ntp.conf
fi
