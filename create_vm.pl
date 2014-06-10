#!/usr/bin/env perl

use strict;
use warnings;
use lib "./lib";
#use Smart::Comments;
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
use Cwd qw(abs_path);


$MyVm::debug = 0;
$MyCluster::debug = 0;

my $config_filename = 'ip_map';
my $vm_name = 'cvm';
my $vm_path_prefix = '/cv';
my $vm_origin_img = '../cvm_template.zip';
my $vm_on_host = 'hvn1';
my $help = 0;
my $cmd ;

GetOptions(
    "name=s"    => \$vm_name,
    "network=s" => \$config_filename,
    "orig=s"    => \$vm_origin_img,
    "dest=s"    => \$vm_path_prefix,
    "host=s"    => \$vm_on_host,
    "help|h"    => \$help,
);

if ($help) {
    print <<"EOF";
Usage: perl create_vm.pl  --name  <vm_name>  [ --network  <ip_map> ] --orig <origin vm img >  --dest  <dir storage vm >  --host < vm on which host>

    Options:
          
        --name  virtual machine name 
                default the  value is cvm               

        --orig  origal vm img file path
                defualt the value is ../cvm_template.zip
                 
        --dest  directory storage vm 
                default the value is /cv

        --file  the file contains network plan
                defualt the value is ip_map
        
        --host  vm running on the host
                default  the value is hvn1
                 
    eg:
        
         perl create_vm.pl --name cvm  --orig  /root/cvm_template.zip   --dest  /cv/  --file ip_map  --host  hvn1
        
          
         this will create   a vm named cvm in /cv/cvm  directory and config network with ip_map
        

    
EOF
    exit 0;
}


my $master = MyAnalyzer->new($config_filename);


my $vm_xml_filename = $vm_path_prefix.'/'.$vm_name.'/'.$vm_name.'.xml';
$vm_xml_filename = abs_path($vm_xml_filename);
my $vm_img_filename = $vm_path_prefix.'/'.$vm_name.'/'.$vm_name.'.img';
$vm_img_filename = abs_path($vm_img_filename);

mkpath($vm_path_prefix.'/'.$vm_name);
croak "$vm_name is not in ip_map " unless defined $master->{$vm_name};

my $vm_ip1 = $master->{$vm_name}{'manage'}{'ip'};
my $vm_ip2 = $master->{$vm_name}{'busi'}{'ip'};

my $vm = MyVm->new( {
    name => $vm_name,
    xml  => $vm_xml_filename,
    disk => $vm_img_filename, 
    manage_ip  => $vm_ip1,
    busi_ip  => $vm_ip2,
    orig => $vm_origin_img,
    }
    );


print "generate_xml\n";
$vm->generate_xml();

print "convert vm img:\n";
$vm->generate_raw();

print "vm define";
$vm->vm_define();
print "vm start";
$vm->vm_startup();
print "wait 120s\n";
 #wait vm boot into system;
#=======================================================================
my $n = 120;
for(my $i=1;$i<=$n;$i++){
        &proc_bar($i,$n);
        select(undef, undef, undef, 1);
}
#set temporate manage ip
print "VM's OS  boot up  \n";

my $cmd1 = "ifconfig -a | grep ".uc($vm->{'manage_mac'})." | cut -b 1-4 > /tmp/mac1" ;
my $cmd2 = 'ifconfig $( cat /tmp/mac1 ) '.$vm->{'manage_ip'}." netmask ".$master->{$vm_name}{'manage'}{'netmask'};
my $cmd3 = 'exit';

$cmd  = [$cmd1,$cmd2,$cmd3];

my $vm_username = 'root';
my $vm_password = '111111';
$vm->virsh_console_exec($cmd,$vm_username,$vm_password);


print "confiure temp ip finish\n";
#  setup on password
MyCluster::remote_scp_with_password('/root/.ssh/',$vm->{'manage_ip'},'/root/',$vm_password );


MyCluster::exe("scp -r ../cloudview_deploy ".$vm->{'manage_ip'}.":/root/ ");


#client sync time
my $ntp_serverip   = $master->manage_ip('hvn1');
$cmd = MyCmd::ntp_client_cmd($ntp_serverip);
MyCluster::remote_exec($vm->{'manage_ip'},$cmd);

#change hostname

$cmd = MyCmd::set_hostname_cmd($vm->{'name'});
MyCluster::remote_exec( $vm->{'manage_ip'}, $cmd );

# make up network
foreach my $network_hash (
    @{ $master->{$vm_name}{'other'} },
    $master->{$vm_name}{'busi'},
    $master->{$vm_name}{'manage'}
  )
{
    my $cmd = MyCmd::network_cmd($network_hash);
    MyCluster::remote_exec( $vm->{'manage_ip'}, $cmd );
}

$cmd = "nohup /etc/init.d/network restart 2>&1 >/tmp/1.log &  ";
MyCluster::remote_exec($vm->{'manage_ip'},$cmd );
print  "cvm network restart";
sleep 10;
# install cvm or coc or csp;
$cmd = "cd cloudview_deploy; cd bin; bash ".$vm->{'name'}.".sh";
MyCluster::remote_exec($vm->{'manage_ip'},$cmd);


sub proc_bar{
        local $| = 1;
        my $i = $_[0] || return 0;
        my $n = $_[1] || return 0;
        print "\r [ ".("\032" x int(($i/$n)*50)).(" " x (50 - int(($i/$n)*50)))." ] ";
        printf("%2.1f %%",$i/$n*100);
        local $| = 0;
}


