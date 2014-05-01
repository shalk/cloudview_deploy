#!/bin/bash

server_ip=$1

echo "server $server_ip prefer" >> /etc/ntp.conf
echo "sntp -P no -r $server_ip" >> /etc/rc.d/after.local
sntp -P no -r $server_ip
hwclock -w
chkconfig ntp on
service ntp start 
