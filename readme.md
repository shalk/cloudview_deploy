#Deploy_CloudView#

The project can relief the deployment of CloudView which is a virtualization management software.


安装准备
=============

1.下载本项目相应分支[代码](https://github.com/shalk/cloudview_deploy/archive/1.5.2p.zip)  并解压 
重名名文件夹为 cloudview_deploy

		$ mv   cloudview_deploy-分支名  cloudview_deploy

2.将cloudview 安装包放入cloudview_deploy 文件夹内

		$ cp  -rf  cloudview1.5.2.20140325  cloudview_deploy/

3.将[cvm_template.rar](http://pan.baidu.com/s/1c03l64C) 放到cloudview_deploy 同一级目录：

		$ ls -lt
		total 12
		drwxr-xr-x. 10 root root 4096 Oct  8 09:14 cloudview_deploy
		-rw-r--r--.  1 root root    0 Sep 17 11:04 cvm_template.rar

最终目录结构如下：

		install/
		|-- cloudview_deploy
		|   |-- cloudview1.5.2.20140325
		|	|-- ip_map
		|   `-- install.pl
		`-- cvm_template.rar

4.修改ip_map文件：

		$ cat ip_map
		#主机名    主机名                      业务网(可不填)
        hvn1  eth1,br1,10.10.10.1,255.255.0.0 eth0,br0,0.0.0.0,255.255.255.0    eth3,br3,0.0.0.0,255.255.255.0
        hvn2  eth1,10.10.10.2,255.255.0.0     eth0,br0,0.0.0.0,255.255.255.0
        hvn3  eth1,10.10.10.3,255.255.0.0     eth0,br0,0.0.0.0,255.255.255.0
        cvm   eth1,10.10.10.11,255.255.0.0    eth0,192.168.1.11,255.255.255.0

按照ip_map， 配置各节点管理网，使得网络通畅。




执行步骤
===========

		
**步骤1**. 在主节点，执行install.sh
		
		$ cd cloudview_deploy/
		$ perl install.pl
        #等待网络重启完成		

**步骤2**. 在主节点，创建cvm
		
		$  perl create_vm.pl  --name cvm  --orig /root/shalk/cvm_template.qcow2

若需要指定安装目录：
		
		$  perl create_vm.pl  -name cvm --orig  /root/shalk/cvm_template.qcow2  --dest /dsx01/img/

		
**步骤3**.(可选) 在主节点，创建coc
		
		$ perl create_vm.pl  --name coc

若需要指定安装目录：
		
		$ sh create_coc.sh  /dsx01/img/



END
=====
