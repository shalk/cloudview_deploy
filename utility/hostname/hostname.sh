#!/bin/bash

currenthostname=$1
echo $currenthostname > /etc/HOSTNAME
hostname $currenthostname 

