package MyAnalyzer;
use strict;
use Carp;
use Exporter;
our @ISA = qw/Exporter/;

sub new {
    my $class    = shift;
    my $filename = shift || 'ip_map';
    my $self     = {};
    $self = &analyze_ip_map($filename);
    bless $self, $class;
    return $self;
}

sub analyze_ip_map {
    my $node_info = {};
    my $filename  = shift;
    open my $fh, "< $filename " or die "Cann't open file $filename ";
    while ( my $line = <$fh> ) {
        chomp($line);

        # delete redundant blank
        $line =~ s/^\s*//;
        $line =~ s/\s*$//;
        $line =~ s/  / /g;
        $line =~ s/ ,/,/g;
        $line =~ s/, /,/g;

        # blank line
        next if $line =~ /^\s*$/;

        # comment line
        next if $line =~ /^#/;

        my @piece = split ' ', $line;

        my $hostname = shift @piece;

        # 主机名不能重复
        croak $hostname, " have exists in ip_map ,Please modify ip_map
            line $. :  ($line) 
          " if ( exists $node_info->{$hostname} );

        if ( $hostname =~ m/^hvn\d+$/ ) {
            croak "shoud have more than 3 colum  " if scalar @piece < 2;
            $node_info->{$hostname}{'manage'} = &get_eth_hash( shift @piece );
            $node_info->{$hostname}{'busi'}   = &get_eth_hash( shift @piece );
            foreach (@piece) {
                push @{ $node_info->{$hostname}{'other'} }, &get_eth_hash($_);
            }
        }
        elsif ( $hostname =~ m/^(cvm|coc|csp)\d*$/ ) {
            croak " shoud have 3 colum " if scalar @piece != 2;
            $node_info->{$hostname}{'manage'} = &get_eth_hash( shift @piece );
            $node_info->{$hostname}{'busi'}   = &get_eth_hash( shift @piece );
        }
        else {
            croak " line $. :  ($line)
         $hostname is not match hvn|cvm|csp|coc  ";
        }
    }
    return $node_info;
}

sub get_eth_hash {
    my $info = shift;
    croak 'can not make a hash ' unless defined $info;
    my @tmp = split ',', $info;
    if ( scalar @tmp == 4 ) {
        &check_ip( $tmp[2] );
        &check_netmask( $tmp[3] );
        return {
            'eth'     => $tmp[0],
            'br'      => $tmp[1],
            'ip'      => $tmp[2],
            'netmask' => $tmp[3],
        };
    }
    elsif ( scalar @tmp == 3 ) {
        &check_ip( $tmp[1] );
        &check_netmask( $tmp[2] );
        return {
            'eth'     => $tmp[0],
            'ip'      => $tmp[1],
            'netmask' => $tmp[2],
        };
    }
    elsif ( scalar @tmp == 2 ) {
        &check_ip( $tmp[0] );
        &check_netmask( $tmp[1] );
        return {
            'ip'      => $tmp[0],
            'netmask' => $tmp[1],
        };
    }
    else {
        croak "shoudn't be here !";
    }
}

sub check_ip {
    my $ip = shift;
    if ( $ip =~
/^(\d{1,2}|1\d\d|2[0-4]\d|25[0-5])\.(\d{1,2}|1\d\d|2[0-4]\d|25[0-5])\.(\d{1,2}|1\d\d|2[0-4]\d|25[0-5])\.(\d{1,2}|1\d\d|2[0-4]\d|25[0-5])$/
      )
    {
        return 1;
    }
    else {
        croak "$ip is not a ip format";
        return 0;
    }
}

sub check_netmask {
    my $ip = shift;
    if ( $ip =~
/(255|254|252|248|240|224|192|128|0+)\.(255|254|252|248|240|224|192|128|0+)\.(255|254|252|248|240|224|192|128|0+)\.(255|254|252|248|240|224|192|128|0+)/
      )
    {
        return 1;
    }
    else {
        croak "$ip is not a netmask format";
        return 0;
    }
}

sub generate_hosts {

    my $self = shift;
    my $filename = shift || 'hosts';
    open my $fh, "> $filename" or die "can not open hosts";
    print $fh "127.0.0.1 localhost\n";
    foreach my $host ( keys %$self ) {
        my $ip = $self->{$host}{'manage'}{'ip'};
        print $fh "$ip $host\n";
    }
    close $fh;
}
sub get_all_manage_ip{
    my $self = shift;
    my @all_manage_ip;
    foreach my $host (keys %$self){
       push @all_manage_ip , $self->{$host}{'manage'}{'ip'};
    }
    return @all_manage_ip;
}
sub get_host_from_manage_ip{
    my $self = shift;
    my $ip = shift;
    my $ret;
    foreach my $host (keys %$self){
       if( $self->{$host}{'manage'}{'ip'} eq $ip ){
          $ret = $host;
          last;
	}
    }
    return $ret;
}
sub manage_ip {
    my $self     = shift;
    my $hostname = shift;
    croak "$hostname is not exists " unless exists $self->{$hostname};
    return $self->{$hostname}{'manage'}{'ip'};
}

sub manage_netmask {
    my $self     = shift;
    my $hostname = shift;
    croak "$hostname is not exists " unless exists $self->{$hostname};
    return $self->{$hostname}{'manage'}{'netmask'};
}

sub manage_network {
    my $self     = shift;
    my $hostname = shift;
    croak "$hostname is not exists " unless exists $self->{$hostname};
    my $ip      = $self->{$hostname}{'manage'}{'ip'};
    my $netmask = $self->{$hostname}{'manage'}{'netmask'};
    return &calc_network_by_netmask( $ip, $netmask );
}

# 类函数
sub calc_network_by_netmask {
    use Socket;
    my $ip      = shift;
    my $netmask = shift;
    return inet_ntoa( inet_aton($ip) & inet_aton($netmask) );
}
