#!/usr/bin/env perl

use strict;
use warnings;
use lib "./lib";
use lib "./local/lib/perl5/x86_64-linux-thread-multi";
use lib "./local/lib/perl5/";

#use Smart::Comments;

#BEGIN {
#    unshift @INC, "local/lib/perl5/x86_64-linux-thread-multi";
#    unshift @INC, "local/lib/perl5/";
#}

use Carp;
use Getopt::Long;
use Expect;
use Data::UUID; 

use MyAnalyzer;
use MyCheck;
use MyCluster;
use MyCmd;
use MyUtil;

my $debug = 0;
my $config_filename = 'ip_map';
my $password        = '111111';
my @iplist;
my $help = 0;
my $cmd ;
my $master;
my $cluster;

GetOptions(
    "pass=s" => \$password,
    "file=s" => \$config_filename,
    "help|h" => \$help,
    "debug=i" => \$debug,
);

$MyCluster::debug = $debug;

if ($help) {
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
    exit 0;
}

# ########################################
#        analyze part
# ########################################
$master = MyAnalyzer->new($config_filename);
$master->generate_hosts();

&mylog("analyze finish\t\tOK");

# #########################################
#          check part
# #########################################
foreach my $host ( keys %$master ) {
    my $ip = $master->manage_ip($host);
    next if ( $host =~ /^cvm/ );
    next if ( $host =~ /^coc/ );
    next if ( $host =~ /^csp/ );
    if ( $debug || MyCheck::check_ip_connect($ip) ) {
        push @iplist, $ip;
    }
    else {
        croak;
    }
}
&mylog("ping finish");
MyCheck::check_cloudview_exsit() unless $debug ;
MyCheck::check_cloudview_software() unless $debug;
&mylog("cloudview software check finish");

#   ########################################
#           cluster part
#   ########################################

$cluster = MyCluster->new( \@iplist );

&mylog("setup a cluster");

#no password
&mylog("setup no password ");
$cluster->no_pass($password);
&mylog("set up time sysnc");

#set local time server

if( $debug == 0){
    my $ntp_serverip = MyUtil::local_manage_ip($master->get_all_manage_ip);
    my $local_hostname = $master->get_host_from_manage_ip($ntp_serverip);
    my $master_network = $master->manage_network($local_hostname);
    my $master_netmask = $master->manage_netmask($local_hostname);
    
    $cmd = MyCmd::ntp_server_cmd( $master_network, $master_netmask );
    MyCluster::remote_exec( $ntp_serverip, $cmd );
    
    #client sync time
    $cmd = MyCmd::ntp_client_cmd($ntp_serverip);
    $cluster->batch_exec($cmd);
}

#change hostname
&mylog("setup hostname");
foreach my $host ( keys %$master ) {
    next if ( $host =~ /^cvm/ );
    next if ( $host =~ /^coc/ );
    next if ( $host =~ /^csp/ );
    my $ip  = $master->{$host}{'manage'}{'ip'};
    my $cmd = MyCmd::set_hostname_cmd($host);
    MyCluster::remote_exec( $ip, $cmd );
}

# make up network
&mylog("setup network");
&mylog("clean all bridge cfg ");
$cmd = "cd /etc/sysconfig/network/;mkdir bak/; mv -f ifcfg-br* ./bak ; ";
$cluster->batch_exec($cmd);
&mylog("clean all bridge cfg finish");

foreach my $host ( keys %$master ) {
    next if ( $host =~ /^cvm/ );
    next if ( $host =~ /^coc/ );
    next if ( $host =~ /^csp/ );
    foreach my $network_hash (
        @{ $master->{$host}{'other'} },
        $master->{$host}{'busi'},
        $master->{$host}{'manage'}
      )
    {
        my $ip  = $master->manage_ip($host);
        my $cmd = MyCmd::network_cmd($network_hash);
        MyCluster::remote_exec( $ip, $cmd );
    }
}

&mylog("restart all network");

$cmd = "echo 'sleep 1' > /tmp/netrestart.sh;";
$cmd .= "echo '/etc/init.d/network restart' >> /tmp/netrestart.sh;";
$cmd .= "echo '/sbin/ovs-init' >> /tmp/netrestart.sh;";
$cluster->batch_exec($cmd);
$cmd = "nohup bash /tmp/netrestart.sh >/tmp/ovs.log 2>&1 &" ;
$cluster->batch_exec($cmd);

&mylog("restart all network finish ");


print "Finish\n";

sub mylog {
    my $msg = shift;
    print "[INFO] $msg  \n";

}
