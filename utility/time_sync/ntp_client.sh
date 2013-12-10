#!/bin/bash

server_ip=$1
task="*/5 * * * * root /usr/sbin/sntp -P no -r $1; /sbin/hwclock -w >& /dev/null"
/usr/sbin/sntp -P no -r $1

sed -i '/hwclock/ d' /etc/crontab
echo $task >> /etc/crontab
