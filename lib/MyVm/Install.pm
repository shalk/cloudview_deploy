package MyVm::Install;
use strict;
use base qw(MyVm);
use MyAnalyzer;
use Carp;
use MyCluster;
use MyCmd;
use MyUtil;

our $master;

sub new { 
    my $class = shift;
    my $arg = shift;
    my $self =  MyVm->new($arg);
    bless $self,$class;

    my $config_filename = 'ip_map';
    $master= MyAnalyzer->new($config_filename);
    $master->generate_hosts();
    croak $self->{'name'}." is not in ip_map " unless defined $master->{$self->{'name'}};
    
    $self->{'manage_ip'} = $master->{$self->{'name'}}{'manage'}{'ip'} unless defined $self->{'manage_ip'};
    $self->{'busi_ip'} = $master->{$self->{'name'}}{'busi'}{'ip'} unless defined $self->{'busi_ip'};
    
    return $self;
} 

sub config_temp_ip {
    my $self = shift; 
    my $cmd;
    
    #set temporate manage ip
    
    
    my $cmd1 =
        "ifconfig -a | grep "
      . uc( $self->{'manage_mac'} )
      . " | cut -b 1-4 > /tmp/mac1";
    my $cmd2 =
        'ifconfig $( cat /tmp/mac1 ) '
      . $self->{'manage_ip'}
      . " netmask "
      . $master->{$self->{'name'}}{'manage'}{'netmask'};
    
    my $cmd3 = 'exit';
    
    $cmd = [ $cmd1, $cmd2, $cmd3 ];
    
    
    $self->virsh_console_exec( $cmd  );


}
sub set_env{

    my $self = shift;
    my $cmd;
    #  setup on password
    MyCluster::remote_scp_with_password( '/root/.ssh/', $self->{'manage_ip'},
        '/root/', $self->{'password'} );
   
    #  scp cloudview_deploy 
    MyCluster::exe(
        "scp -r ../cloudview_deploy " . $self->{'manage_ip'} . ":/root/ " );
    
    #client sync time
    my $ntp_serverip = MyUtil::get_ip_address($self->{'manage_br'});
    my $master_netmask = MyUtil::get_netmask_from_eth($self->{'manage_br'});
    my $master_network = MyAnalyzer::calc_network_by_netmask($ntp_serverip,$master_netmask);
    $cmd = MyCmd::ntp_server_cmd( $master_network, $master_netmask );
    MyCluster::exe($cmd);
    
    
    $cmd = MyCmd::ntp_client_cmd($ntp_serverip);
    MyCluster::remote_exec( $self->{'manage_ip'}, $cmd );
    
    #change hostname
    
    $cmd = MyCmd::set_hostname_cmd( $self->{'name'} );
    MyCluster::remote_exec( $self->{'manage_ip'}, $cmd );
   

    #make up network   
    $cmd =
        "ifconfig -a | grep "
      . uc( $self->{'manage_mac'} )
      . " | cut -b 1-4 > /tmp/mac1";
     
    MyCluster::remote_exec( $self->{'manage_ip'}, $cmd );

    $cmd =
        "ifconfig -a | grep "
      . uc( $self->{'busi_mac'} )
      . " | cut -b 1-4 > /tmp/mac2";
    MyCluster::remote_exec( $self->{'manage_ip'}, $cmd );


    $cmd = MyCmd::vm_manage_network_cmd($master->{$self->{'name'}}{'manage'});
    MyCluster::remote_exec( $self->{'manage_ip'}, $cmd );
    $cmd = MyCmd::vm_busi_network_cmd($master->{$self->{'name'}}{'busi'});
    MyCluster::remote_exec( $self->{'manage_ip'}, $cmd );
   
    # reboot network 
}

sub install_cloudview(){
    my $self = shift;
    # install cvm or coc or csp;
    my $cmd = "cd cloudview_deploy; cd bin; bash " . $self->{'name'} . ".sh";
    MyCluster::remote_exec( $self->{'manage_ip'}, $cmd );
}

sub network_restart(){
    my $self = shift;  
    my $cmd = "nohup /etc/init.d/network restart 2>&1 >/tmp/1.log &  ";
    MyCluster::remote_exec( $self->{'manage_ip'}, $cmd );
}
sub xm_start_vm_in_after_local{
    my $self = shift;
    my $cmd = MyCmd::vm_start_in_after_local($self->{'name'});
    MyCluster::exe($cmd);
}

1;

