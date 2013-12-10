#!/usr/bin/env perl
use strict;
#use lib './lib';
#use ShellRun ;
####################
#
our $debug= 0;

sub no_passwd {
    my $passwd = shift || "111111";
    my @nodelist=  @_;
    my $node= join ',';
    my $cmd = "cd utility/nopasswd/; ./xmakessh --pass 111111 -nodes  $node ";
    &exe( $cmd); 
}

sub menu_lst{
    my $mem =  shift || 4096; 
    my $cmd =  "utility/menu_lst/menu_list.sh $mem ";
    &exe($cmd);
}    
sub time_sync_server{
    my $date = shift || "2013-07-01 12:00:00";
    my $cmd = "utility/time_sync/ntp_server.sh $date";
    &exe($cmd);
} 
sub time_sync_client{
    my $server_ip = shift;
    my $cmd = "utility/time_sync/ntp_client.sh $server_ip"   ;
    &exe($cmd);
}
sub hostname{
    my $name = shift;
    my $cmd = "utility/hostname/hostname.sh  $name";
    &exe($cmd);
} 
sub bridge{
    my $ip  = shift;
    my $eth = shift;
    my $br = shift;
    my $cmd="utility/bridge/bridging.sh $ip  $eth $br  ";
    &exe($cmd);
}
sub exe {
    my $cmd = shift;
    if($debug){
      print "$cmd \n";
    }else{
      system($cmd);
 #   my $res = ShellRun::excute($cmd,undef, "&<STDIN",">&STDOUT");
 #   return $res;
    }
}

