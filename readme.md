#Deploy_CloudView#
----
##Description##
The project can relief the deloyment  of CloudView which is a virtualization management software.

##Tree View ##
```
cloudview_deploy/
.
├── cloudview -> /root/cloudview1.5.1.20130717/
├── after_reboot.sh
├── before_reboot.sh
├── coc
│   └── deploy_on_coc.sh
├── cvm
│   ├── deploy_on_cvm.sh
│   └── prepare
├── hosts
├── hvn
│   ├── hvn_after_reboot.sh
│   └── hvn_before_reboot.sh
├── ip_map
├── log
├── master
│   ├── busi_list
│   ├── create_cvm_and_coc.sh
│   ├── master_hyper_after_reboot.sh
│   ├── master_hyper_before_reboot.sh
│   └── test.sh
├── readme.md
├── storage
│   └── config_nfs.sh
└── utility
    ├── bridge
    │   ├── ifcfg-br0
    │   └── ifcfg-eth0
    ├── bridging.sh
    ├── conf
    │   ├── libvirtd.conf
    │   └── xend-config.sxp
    ├── hosts.example
    └── nopasswd
        ├── cmd.exp
        ├── ecmd.sh
        ├── ssh.exp
        └── xmakessh
11 directories, 20 files
```
## test version ##
init  

10 directories, 26 files
