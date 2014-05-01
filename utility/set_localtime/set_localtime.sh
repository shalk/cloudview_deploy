#!/bin/bash

curtime=$1
date -s  "$curtime"
if [[ $? != 0 ]]
then
    echo "$curtime is not correct Time Format"
    exit 1
fi
hwclock -w
