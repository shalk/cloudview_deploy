#Deploy_CloudView#
----
##Description##
The project can relief the deloyment  of CloudView which is a virtualization management software.

##Tree View ##
.
├── cloudview -> /root/cloudview1.5.1.20130717/
├── coc
│   └── deploy_on_coc.sh
├── cvm
│   ├── after_coc_cvm.sh
│   └── deploy_on_cvm.sh
├── deploy.conf
├── hosts
├── hvn
│   ├── hvn_after_reboot.sh
│   └── hvn_before_reboot.sh
├── master
│   ├── create_cvm_and_coc.sh
│   ├── master_hyper_after_reboot.sh
│   └── master_hyper_before_reboot.sh
├── reame.md
├── storage
│   └── config_nfs.sh
└── utility
    ├── bridge
    │   ├── ifcfg-br0
    │   └── ifcfg-eth0
    ├── conf
    │   ├── libvirtd.conf
    │   └── xend-config.sxp
    ├── cvm-hypervisor-install-2.1 -> ../cloudview/Supports/third-party_tools/cvm-hypervisor-install/cvm-hypervisor-install-2.1/
    └── nopasswd
        ├── cmd.exp
        ├── ecmd.sh
        ├── ssh.exp
        └── xmakessh

11 directories, 20 files

## test version ##
init 
