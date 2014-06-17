#!/usr/bin/env perl

use strict;
use warnings;
use lib "./lib";

#use Smart::Comments;
BEGIN {
    unshift @INC, "local/lib/perl5/x86_64-linux-thread-multi";
    unshift @INC, "local/lib/perl5/";
}

use Carp;
#use Getopt::Long;
use File::Path;
use List::Util;
use Config::General qw(ParseConfig SaveConfig SaveConfigString);

use MyAnalyzer;
use MyCheck;
use MyCluster;
use MyCmd;
use MyUtil;
use MyVm;
use MyVm::Install;
use Cwd qw(abs_path);

$MyVm::debug      = 0;
$MyCluster::debug = 0;

#step 1 get conf
my $vm_conf_filename = "vm.conf";
my %vm_conf_hash = ParseConfig( $vm_conf_filename);
my $vm_conf = \%vm_conf_hash;

#step 2 define vm and boot up
my $vm = MyVm::Install->new($vm_conf);

$vm->build_up_vm_from_img();

#wait vm boot into system;

print "VM OS is starting up , wait 120s \n";
my $n = 120;
for ( my $i = 1 ; $i <= $n ; $i++ ) {
    &proc_bar( $i, $n );
    select( undef, undef, undef, 1 );
}
print "\n";

&mylog("config temp ip start ");
$vm->config_temp_ip();
&mylog("\nconfig temp ip finish");

sleep 10;
&mylog("config vm env start");
$vm->set_env();
&mylog("config vm env finish ");
sleep 10;
&mylog("install cloudview start");
$vm->install_cloudview();
&mylog("install cloudview finish");
$vm->net
sub proc_bar {
    local $| = 1;
    my $i = $_[0] || return 0;
    my $n = $_[1] || return 0;
    print "\r [ "
      . ( "\032" x int( ( $i / $n ) * 50 ) )
      . ( " " x ( 50 - int( ( $i / $n ) * 50 ) ) ) . " ] ";
    printf( "%2.1f %%", $i / $n * 100 );
    local $| = 0;
}
sub usage {

    print <<"EOF";
Usage: perl create_vm_conf.pl  
   
        please modify vm.conf:
         
EOF
}
sub mylog {
    my $msg = shift;
    print "[INFO] $msg  \n";

}
