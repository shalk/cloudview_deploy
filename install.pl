#!/usr/bin/env perl

use strict;
use warnings;
use lib "./lib";
#use Smart::Comments;
BEGIN{
    unshift @INC,"local/lib/perl5/x86_64-linux-thread-multi";
    unshift @INC,"local/lib/perl5/";
}

use File::Path qw(make_path remove_tree);
use Carp;
use Getopt::Long;


use MyAnalyzer;
use MyCheck;
use MyCluster;
use MyCmd;


my $config_filename='ip_map';
my $password = '111111';
my @iplist  ;
my $help = 0;

GetOptions (
    "pass=s" => \$password,
    "file=s" => \$config_filename,
    "help|h" => \$help,
);

if($help){
print <<"EOF";
Usage: perl $0  --pass  <password>  --file  <ip_map>

    Options:
        --pass  give the pass of Operation System ,
                defualt the value is 111111
        
        --file  the file contains network plan
                defualt the value is ip_map
                 
    eg:
         perl install.pl --pass 123456  -file ip_map
    
EOF
}

# ######################################## 
#        analyze part
# ########################################
my $master = MyAnalyzer->new($config_filename);
$master->generate_hosts();

&mylog("analyze finish");


# #########################################
#          check part
# #########################################
foreach my $host ( keys %$master)
{
    my $ip = $master->manage_ip($host);
    push @iplist,$ip;
#    MyCheck::check_ip_connect($ip);
}
MyCheck::check_cloudview_exsit();
MyCheck::check_cloudview_software();
&mylog("check finish");
#   ########################################
#           cluster part
#   ########################################
my $cluster=MyCluster->new( \@iplist );

&mylog("setup a cluster");

#no password
&mylog("setup no pass");
#$cluster->no_pass($password );
&mylog("set up time sysnc");


#set local time server
my $ntp_serverip =  $master->manage_ip('hvn1');
my $master_network = $master->manage_network('hvn1');
my $master_netmask = $master->manage_netmask('hvn1');
my $cmd = MyCmd::ntp_server_cmd($master_network,$master_netmask); 
#system($cmd);

#client sync time
$cmd  = MyCmd::ntp_client_cmd($ntp_serverip);
$cluster->batch_exec($cmd);

#change hostname 
&mylog("setup hostname");
foreach my $host (  keys %$master )
{   
    my $ip = $master->{$host}{'manage'}{'ip'};   
    my $cmd = MyCmd::set_hostname_cmd($host);
    MyCluster::remote_exec($ip,$cmd);
}
# make up network 
&mylog("setup network");
foreach my $host (  keys %$master )
{   
    foreach my $network_hash ( @{$master->{$host}{'other'}}, $master->{$host}{'busi'}, $master->{$host}{'manage'} ) 
    {
### $network_hash
        my $network_hash = $master->{$host}{'manage'};
        my $ip = $master->manage_ip($host);
        my $cmd = MyCmd::network_cmd($network_hash);
        print "-------------------\n";
        MyCluster::remote_exec($ip,$cmd);
        print "-------------------\n";
    }
}
&mylog("restart all network");
$cluster->batch_exec("nohup service network restart 2>&1 >/tmp/1.log &  ");

print "Finish\n";


sub mylog{
    my $msg = shift;
    print "[INFO] $msg  #####################\n";
}
