#Deploy_CloudView#

The project can relief the deloyment of CloudView which is a virtualization management software.

Installation
=============

下载本项目[代码](https://github.com/shalk/cloudview_deploy/archive/master.zip) 

		unzip  master.zip
		mv   cloudview_deploy-master  cloudview_deploy

将cloudview 安装包放入cloudview_deploy 文件夹内,删除末尾的版本号

		cp  -rf  cloudview1.5.1.20130717    cloudview_deploy/cloudview

将cvm.zip 解压到cloudview_deploy 同一级目录：

		[root@bogon work]# ls -lt
		total 12
		drwxr-xr-x. 10 root root 4096 Oct  8 09:14 cloudview_deploy
		-rw-r--r--.  1 root root    0 Sep 17 11:04 cvm.qcow2

修改ip_map文件:
	
		# 管理网    主机名  业务网
		10.0.23.61 hvn1  192.168.0.1  
		10.0.23.62 hvn2  192.168.0.2
		10.0.23.63 hvn3  192.168.0.3
		10.0.23.64 cvm   192.168.0.4
		10.0.23.65 coc   192.168.0.5

各节点按照ip_map 完成管理网配置.




	   
