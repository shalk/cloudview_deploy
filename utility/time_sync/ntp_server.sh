#!/bin/bash

#egg: $0  \"2007-08-03 14:15:00\"
date -s  "$1"
hwclock -w
/etc/init.d/ntp start
chkconfig ntp on

