#Deploy_CloudView#
----
##Description##
The project can relief the deloyment  of CloudView which is a virtualization management software.

##Tree View ##
```
.
├── cloudview -> /root/cloudview1.5.1.20130717/
├── coc
│   └── deploy_on_coc.sh
├── cvm
│   ├── deploy_on_cvm.sh
│   └── prepare
├── hosts
├── hvn
│   ├── hvn_after_reboot.sh
│   └── hvn_before_reboot.sh
├── master
│   ├── create_cvm_and_coc.sh
│   ├── master_hyper_after_reboot.sh
│   └── master_hyper_before_reboot.sh
├── readme.md
├── storage
│   └── config_nfs.sh
└── utility
    ├── bridge
    │   ├── ifcfg-br0
    │   └── ifcfg-eth0
    ├── conf
    │   ├── libvirtd.conf
    │   └── xend-config.sxp
    └── nopasswd
        ├── cmd.exp
        ├── ecmd.sh
        ├── ssh.exp
        └── xmakessh
11 directories, 20 files
```
## test version ##
init  
