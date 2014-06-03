package MyCmd;


sub set_hostname_cmd{
    my $hostname = shift;
    my $cmd  = <<"EOF";
hostname $hostname
export HOSTNAME=$hostname
echo $hostname > /etc/HOSTNAME 
EOF
    return $cmd;
}

sub vitual_service_up{

    my $cmd = <<'EOF';
chkconfig libvirtd on
chkconfig  xend on
service libvirtd start
service xend start
EOF
    return $cmd;
}

sub ntp_server_cmd{ 
    my $master_network = shift;
    my $master_netmask = shift;    
    my $cmd = <<"EOF";
echo restrict $master_network mask  $master_netmask >> /etc/ntp.conf 
chkconfig ntp on 
service ntp start 
EOF
    return $cmd;
}
sub ntp_client_cmd{
    my $serverip = shift;
    my $cmd =  <<"EOF";
sntp -P no -r $serverip ; 
echo server $serverip prefer >> /etc/ntp.conf ;
hwclock -w;
chkconfig ntp on;
service ntp start; 
EOF
    return $cmd;
}
sub network_cmd{
    my $net = shift;
    my $cmd ;
    my ($eth,$br,$ip,$netmask) = ($net->{'eth'},$net->{'br'},$net->{'ip'},$net->{'netmask'} );
    if(defined $br){
    my $file_eth= <<"EOF";
IPADDR=0.0.0.0/32
STARTMODE=auto
EOF
    my $file_br= <<"EOF";
BRIDGE='yes'
BRIDGE_FORWARDDELAY='0'
BRIDGE_PORTS='${eth}'
BRIDGE_STP='off'
IPADDR=$ip
NETMASK=$netmask
STARTMODE='auto'
EOF
    # for suse 
    $cmd .= "echo '$file_eth' > /etc/sysconfig/network/ifcfg-$eth  \n";
    $cmd .= "echo '$file_br' > /etc/sysconfig/network/ifcfg-$br \n";
    }else{
    my $file_eth= <<"EOF";
IPADDR=0.0.0.0/32
STARTMODE=auto
EOF
    # for suse
    $cmd .= "echo '$file_eth' > /etc/sysconfig/network/ifcfg-$eth  \n";
    }
    
   return $cmd; 
}

1;
