#!/bin/bash


perl -p -i -e "s/^.*PasswordAuthentication.*$/PasswordAuthentication yes/" /etc/ssh/sshd_config
perl -p -i -e "s/^.*PermitRootLogin.*$/PermitRootLogin yes/" /etc/ssh/sshd_config
service sshd restart
