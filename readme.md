#Deploy_CloudView#

The project can relief the deployment of CloudView which is a virtualization management software.


安装准备
=============

1.下载本项目相应分支[代码](https://github.com/shalk/cloudview_deploy/archive/1.5.2.zip)  并解压 
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
		|   `-- install
		`-- cvm_template.rar

4.修改ip_map文件：

		$ cat ip_map
		# 管理网    主机名  业务网
		10.0.23.61 hvn1  192.168.0.1       
		10.0.23.62 hvn2  192.168.0.2
		10.0.23.63 hvn3  192.168.0.3
		10.0.23.64 cvm   192.168.0.4
		10.0.23.65 coc   192.168.0.5

按照ip_map， 配置各节点管理网，使得网络通畅。

请确认： 

- 节点名称为hvn1，hvn2，hvn3….,(若要修改，请在全部安装完成之后修改) 
- 管理网：为eth1，且掩码为255.255.0.0, 
- ping通hvn2、hvn3….. 


执行步骤
===========

		
**步骤1**. 在主节点，执行install.sh
		
		$ cd cloudview_deploy/
		$ sh install  "2013-12-12 12:48:32"
        #等待2分钟，执行成功。

若用vcell安装的系统，执行完步骤1之后，进入步骤4 

	步骤2. 重启所有节点
			
			$ reboot
	
	步骤3. 在主节点，执行after_reboot.sh,等待2分钟。
		
			$ sh after_reboot.sh 
		
**步骤4**. 在主节点，创建cvm
		
		$ cd master
		$ sh create_cvm.sh
若需要指定安装目录：
		
		$ sh create_cvm.sh  /dsx01/img/
		
**步骤5**.(可选) 在主节点，创建coc
		
		$ cd master
		$ sh create_coc.sh
若需要指定安装目录：
		
		$ sh create_coc.sh  /dsx01/img/



END
=====
