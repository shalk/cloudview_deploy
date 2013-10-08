#Deploy_CloudView#

The project can relief the deloyment of CloudView which is a virtualization management software.

安装准备
=============

下载本项目[代码](https://github.com/shalk/cloudview_deploy/archive/master.zip) 

		unzip  master.zip
		mv   cloudview_deploy-master  cloudview_deploy

将cloudview 安装包放入cloudview_deploy 文件夹内,删除末尾的版本号

		cp  -rf  cloudview1.5.1.20130717    cloudview_deploy/cloudview

将[cvm.zip](http://pan.baidu.com/s/1pBAso) 解压到cloudview_deploy 同一级目录：

		[root@bogon test]# ls -lt
		total 12
		drwxr-xr-x. 10 root root 4096 Oct  8 09:14 cloudview_deploy
		-rw-r--r--.  1 root root    0 Sep 17 11:04 cvm.qcow2

修改ip_map文件：
	
		# 管理网    主机名  业务网
		10.0.23.61 hvn1  192.168.0.1       
		10.0.23.62 hvn2  192.168.0.2
		10.0.23.63 hvn3  192.168.0.3
		10.0.23.64 cvm   192.168.0.4
		10.0.23.65 coc   192.168.0.5

按照ip_map， 各节点完成管理网配置，使得网络通畅。


执行步骤
===========

步骤1. 确保cvm.qcow2 和cloudview_deploy 存放在主节点（hvn1） 同一级目录。

    	hvn1:~/test # ls -lt
		total 12
		drwxr-xr-x. 10 root root 4096 Oct  8 09:14 cloudview_deploy
		-rw-r--r--.  1 root root    0 Sep 17 11:04 cvm.qcow2
步骤2. 执行before_reboot.sh
		
		$ cd cloudview_deploy/
		$ sh  before_reboot.sh  "2007-03-01 14:48:32"
        #等待2分钟，执行成功。

步骤3. 重启所有节点
		
		$ reboot

步骤4. 执行after_reboot.sh,等待2分钟。
	
		
		$ sh after_reboot.sh 
步骤5. 创建coc 和cvm
		
		cd master
		sh create_cvm_and_coc.sh

步骤6. 在图形化界面下配置cvm和coc的IP，使得网络通畅。


步骤7. 将cloudview_deploy 文件夹拷贝到cvm和coc的/root目录下。

步骤8. 在cvm上执行：
	   
		cd cvm
		sh deploy_on_cvm.sh
	  
同时，  在coc上执行：

		cd coc
		sh deploy_on_coc.sh
      

END
=====
