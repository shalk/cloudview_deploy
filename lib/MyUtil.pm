package MyUtil;
use strict;
use warnings;
use Carp;
use Socket;
use List::Util qw/first/;
require 'sys/ioctl.ph';


sub get_ip_address($) {
    my $pack = pack("a*", shift);
    my $socket;
    socket($socket, AF_INET, SOCK_DGRAM, 0);
    ioctl($socket, SIOCGIFADDR(), $pack);
    return inet_ntoa(substr($pack,20,4));
};
sub get_netmask_from_eth {
    my $eth = shift;
    my $mask;
    open my $fh ,"ifconfig  $eth |" or die "can not open ifconfig";
    while(<$fh>){
     chomp;
     $mask = $1 if / Mask:(\S+)/;
    }
    close($fh);
     return $mask;
}

sub get_local_ip_list {
    my @local_ip;
    open my $fh ,' ifconfig | ' or die "can not open ifconfig" ;
    while(<$fh>){
        chomp;
        if(/inet addr:(\S+)/){
            push @local_ip,$1 if $1 ne '127.0.0.1';
        }
    }
    return @local_ip;
}
sub local_manage_ip {
    my @all_manage_ip = @_;
    my @local_ip = &get_local_ip_list;
    my @local_manage_ip =  grep {  my $c = $_ ; first{ $_ eq $c }@all_manage_ip  } @local_ip; 
    warn "local machine have many ip match  manage ip ( @local_manage_ip )
            modify ip_map  or modify local network cfg
        "  if scalar @local_manage_ip > 1;
    warn "current machine ip is not in ip_map " if scalar @local_manage_ip == 0;
    return $local_manage_ip[0];
}
1;
