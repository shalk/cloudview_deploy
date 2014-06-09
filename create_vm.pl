#!/usr/bin/env perl

use strict;
use warnings;
use lib "./lib";
use Smart::Comments;
BEGIN{
    unshift @INC,"local/lib/perl5/x86_64-linux-thread-multi";
    unshift @INC,"local/lib/perl5/";
}

use Carp;
use Getopt::Long;
use File::Path;

use MyAnalyzer;
use MyCheck;
use MyCluster;
use MyCmd;
use MyVm;

my $config_filename = 'ip_map';
my $vm_name = 'cvm';
my $vm_path_prefix = '/cv';
my $vm_origin_img = '../cvm_template.zip';
my $help = 0;

GetOptions(
    "name=s"    => \$vm_name,
    "network=s" => \$config_filename,
    "orig=s"    => \$vm_origin_img,
    "dest=s"    => \$vm_path_prefix,
    "help|h"    => \$help,
);

if ($help) {
    print <<"EOF";
Usage: perl create_vm.pl  --name  <vm_name>  [ --network  <ip_map> ] --orig <origin vm img >  --dest  <dir storage vm >

    Options:
       
        --name  virtual machine name 
                default value is cvm               

        --orig  origal vm img file path
                the parameter is needed 
                 
        --dest  directory storage vm 
                default the value is /cv

        --file  the file contains network plan
                defualt the value is ip_map
                 
    eg:
        
         perl create_vm.pl --name cvm  --orig  /root/cvm_template.zip   --dest  /cv/  --file ip_map 
        
          
         this will create   a vm named cvm in /cv/cvm  directory and config network with ip_map
        

    
EOF
    exit 0;
}


my $master = MyAnalyzer->new($config_filename);


my $vm_xml_filename = $vm_path_prefix.'/'.$vm_name.'/'.$vm_name.'.xml';
my $vm_img_filename = $vm_path_prefix.'/'.$vm_name.'/'.$vm_name.'.img';
mkpath($vm_path_prefix.'/'.$vm_name);
croak "$vm_name is not in ip_map " unless defined $master->{$vm_name};

my $vm_ip1 = $master->{$vm_name}{'manage'}{'ip'};
my $vm_ip2 = $master->{$vm_name}{'busi'}{'ip'};

my $vm = MyVm->new( {
    name => $vm_name,
    xml  => $vm_xml_filename,
    disk => $vm_img_filename, 
    ip1  => $vm_ip1,
    ip2  => $vm_ip2,
    orig => $vm_origin_img,
    }
    );
$vm->generate_xml();
$vm->generate_raw();
$vm->vm_define();
$vm->vm_startup();
 #wait vm boot into system;
#=======================================================================
my $n = 120;
for(my $i=1;$i<=$n;$i++){
        &proc_bar($i,$n);
        select(undef, undef, undef, 1);
}

my $cmd = "ifconfig eth0 ".$vm->{'ip1'}." netmask ".$master->{$vm_name}{'manage'}{'netmask'};

my $vm_username = 'root';
my $vm_password = '111111';

$vm->virsh_console_exec("$cmd",$vm_username,$vm_password);


#  setup on password

MyCluster::remote_scp_with_password('/root/.ssh/',$vm->{'ip1'},'/root/',$vm_password );


MyCluster::exe("scp -r ../cloudview_deploy ".$vm->{'ip1'}.":/root/ ");


#client sync time
my $ntp_serverip   = $master->manage_ip('hvn1');
$cmd = MyCmd::ntp_client_cmd($ntp_serverip);
MyCluster::remote_exec($vm->{'ip1'},$cmd);

#change hostname

$cmd = MyCmd::set_hostname_cmd($vm->{'name'});
MyCluster::remote_exec( $vm->{'ip1'}, $cmd );

# make up network
foreach my $network_hash (
    @{ $master->{$vm_name}{'other'} },
    $master->{$vm_name}{'busi'},
    $master->{$vm_name}{'manage'}
  )
{
    my $cmd = MyCmd::network_cmd($network_hash);
    MyCluster::remote_exec( $vm->{'ip1'}, $cmd );
}

$cmd = "nohup /etc/init.d/network restart 2>&1 >/tmp/1.log &  ";
MyCluster::remote_exec($vm->{'ip1'},$cmd );

sub proc_bar{
        local $| = 1;
        my $i = $_[0] || return 0;
        my $n = $_[1] || return 0;
        print "\r [ ".("\032" x int(($i/$n)*50)).(" " x (50 - int(($i/$n)*50)))." ] ";
        printf("%2.1f %%",$i/$n*100);
        local $| = 0;
}



