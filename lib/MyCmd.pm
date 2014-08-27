package MyCmd;

sub set_hostname_cmd {
    my $hostname = shift;
    my $cmd      = <<"EOF";
hostname $hostname
export HOSTNAME=$hostname
echo $hostname > /etc/HOSTNAME 
EOF
    return $cmd;
}

sub vitual_service_up {

    my $cmd = <<'EOF';
chkconfig libvirtd on
chkconfig  xend on
service libvirtd start
service xend start
EOF
    return $cmd;
}

sub ntp_server_cmd {
    my $master_network = shift;
    my $master_netmask = shift;
    my $cmd            = <<"EOF";
cp -rf /etc/ntp.cof.bak /etc/ntp.conf
 [ -f /etc/ntp.conf.bak ] ||  cp -rf /etc/ntp.conf /etc/ntp.cof.bak
echo restrict $master_network mask  $master_netmask >> /etc/ntp.conf 
chkconfig ntp on 
service ntp start 
EOF
    return $cmd;
}

sub ntp_client_cmd {
    my $serverip = shift;
    my $cmd      = <<"EOF";
cp -rf /etc/ntp.cof.bak /etc/ntp.conf
 [ -f /etc/ntp.conf.bak ] ||  cp -rf /etc/ntp.conf /etc/ntp.cof.bak
sntp -P no -r $serverip ; 
sed -i '/^server /d' /etc/ntp.conf;
echo server $serverip prefer >> /etc/ntp.conf ;
hwclock -w;
chkconfig ntp on;
service ntp start; 
EOF
    return $cmd;
}

sub network_cmd {
    my $net = shift;
    my $cmd;
    my ( $eth, $br, $ip, $netmask ) =
      ( $net->{'eth'}, $net->{'br'}, $net->{'ip'}, $net->{'netmask'} );
    if ( defined $br ) {
        my $file_eth = <<"EOF";
IPADDR=0.0.0.0/32
STARTMODE=auto
EOF
        my $file_br = <<"EOF";
BRIDGE='yes'
BRIDGE_FORWARDDELAY='0'
BRIDGE_PORTS='${eth}'
BRIDGE_STP='off'
IPADDR=$ip
NETMASK=$netmask
STARTMODE='auto'
EOF

        # for suse
        $cmd .= "touch  /etc/sysconfig/network/ifcfg-$eth ;";
        $cmd .= "touch  /etc/sysconfig/network/ifcfg-$br ;";
        $cmd .= "echo '$file_eth' > /etc/sysconfig/network/ifcfg-$eth  \n";
        $cmd .= "echo '$file_br' > /etc/sysconfig/network/ifcfg-$br \n";
    }
    else {
        my $file_eth = <<"EOF";
IPADDR=$ip
NETMASK=$netmask
STARTMODE=auto
EOF

        # for suse
        $cmd .= "touch  /etc/sysconfig/network/ifcfg-$eth ;";
        $cmd .= "echo '$file_eth' > /etc/sysconfig/network/ifcfg-$eth  \n";
    }

    return $cmd;
}
sub vm_manage_network_cmd{
    # description:
    #   need ip and netmask  
    #   excute after generate /tmp/mac1
    my $net  = shift;
    my $cmd;
    my ( $ip, $netmask ) =
      (   $net->{'ip'}, $net->{'netmask'} );
        my $file_eth = <<"EOF";
IPADDR=$ip
NETMASK=$netmask
STARTMODE=auto
EOF

        # for suse
        $cmd = q{a=\`cat /tmp/mac1 \`;};
        $cmd .= q{touch  /etc/sysconfig/network/ifcfg-\$a ;};
        $cmd .= "echo '$file_eth' > /etc/sysconfig/network/ifcfg-\\\$a  \n";
}
sub vm_busi_network_cmd{
    # description:
    #   need ip and netmask  
    #   excute after generate /tmp/mac2
    my $net  = shift;
    my $cmd;
    my ( $ip, $netmask ) =
      (   $net->{'ip'}, $net->{'netmask'} );
        my $file_eth = <<"EOF";
IPADDR=$ip
NETMASK=$netmask
STARTMODE=auto
EOF

        # for suse
        $cmd = q{a=\`cat /tmp/mac2 \`;};
        $cmd .= q{touch  /etc/sysconfig/network/ifcfg-\$a ;};
        $cmd .= "echo '$file_eth' > /etc/sysconfig/network/ifcfg-\\\$a  \n";
}
sub vm_start_in_after_local{
    my $vm_name = shift;
    my $file = "/etc/init.d/after.local";
    my $cmd = "echo 'xm start $vm_name' >> $file;";
    $cmd .= "cp $file /tmp/afterlocal; ";
    $cmd .=  "uniq /tmp/afterlocal > $file";
    return $cmd;
}
1;
