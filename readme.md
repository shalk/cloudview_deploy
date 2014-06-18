#Deploy_CloudView#

The project can relief the deployment of CloudView which is a virtualization management software.


安装准备
=============

1.下载代码建立环境,安装cpanm,carton,安装本地库

		$ git clone https://github.com/shalk/cloudview_deploy.git
        $ curl -L http://cpanmin.us | perl - --sudo App::cpanminus
        $ cpanm carton
        $ carton install

2. 准备介质和模板
       
        cloudview存放在 cloudview_deploy目录下


3.修改ip_map文件：

		$ cat ip_map
		#主机名    主机名                      业务网(可不填)
        hvn1  eth1,br1,10.10.10.1,255.255.0.0 eth0,br0,0.0.0.0,255.255.255.0    eth3,br3,0.0.0.0,255.255.255.0
        hvn2  eth1,10.10.10.2,255.255.0.0     eth0,br0,0.0.0.0,255.255.255.0
        hvn3  eth1,10.10.10.3,255.255.0.0     eth0,br0,0.0.0.0,255.255.255.0
        cvm   eth1,10.10.10.11,255.255.0.0    eth0,192.168.1.11,255.255.255.0

按照ip_map， 配置各节点管理网，使得网络通畅。
4.修改vm.conf文件,创建cvm,coc,csp前,务必修改名称、IP以及相关键值：

        $ cat vm.conf
        name=cvm
        disk=/cv/cvm/cvm.img 
        xml=/cv/cvm/cvm.xml
        cpu=2
        mem=4194304
        manage_br=br0
        busi_br=br0
        orig=../cvm_template.qcow2
        manage_ip=1.1.1.111
        busi_ip=0.0.0.0 
        username=root
        password=111111



执行步骤
===========

		
**步骤1**. 在主节点，执行install
		
		$ ./install
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
