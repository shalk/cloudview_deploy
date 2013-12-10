#!/bin/bash

#修改/boot/grub/menu.lst
# 
#echo change grub memu.lst
perl -p -i -e  's/^default .*$/default 2/' /boot/grub/menu.lst
perl -p -i -e  " s/$/dom0_mem=${1}M/ if /xen.gz/ && ! /dom0_mem/" /boot/grub/menu.lst
#echo change grub finish
