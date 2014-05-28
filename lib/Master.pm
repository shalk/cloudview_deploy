package Master;
use Carp;
use Exporter;
our @ISA = qw/Exporter/;

sub new {
    my $class = shift;
    my $filename = shift || 'ip_map';
    my $self = {};
    bless $self,$class;
    $self = &analyze_ip_map($filename);
    return $self;
}

sub analyze_ip_map {
  my $node_info = {};
  my $filename = shift;
  open my $fh , "< $filename " or die "Cann't open file $filename "; 
  while(my $line = <$fh>){
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
      
     my @piece = split ' ',$line;

     my $hostname =  shift @piece;
    # 主机名不能重复  
     croak $hostname," have defined in ip_map ,Please modify ip_map
            line $. :  ($line) 
          " if(defined $node_info->{$hostname} );
    
 
    if ($hostname =~ m/^hvn\d+$/){
       croak "shoud have more than 3 colum  " if scalar  @piece  < 2;    
       $node_info->{$hostname}{'master'} = &get_eth_hash( shift @piece);
       $node_info->{$hostname}{'busi'} = &get_eth_hash( shift @piece);
       foreach(@piece){
         push @{$node_info->{$hostname}{'other'}} ,&get_eth_hash($_);
       }
    }elsif ($hostname =~ m/^(cvm|coc|csp)\d*$/){
       croak " shoud have 3 colum " if scalar  @piece !=  2;    
       $node_info->{$hostname}{'master'} = &get_eth_hash( shift @piece);
       $node_info->{$hostname}{'busi'} = &get_eth_hash( shift @piece);
    }else{
     croak " line $. :  ($line)
         $hostname is not match hvn|cvm|csp|coc  " ;
    }
  }
  return $node_info; 
}
 
sub get_eth_hash{
  my $info = shift;
  croak 'can not make a hash ' unless  defined $info;
  my @tmp = split ',', $info;
  if(scalar @tmp == 4){
    &check_ip($tmp[2]);
    &check_netmask($tmp[3]);
  return { 
       'eth'  => $tmp[0],
       'br'   => $tmp[1],
       'ip'   => $tmp[2],
       'mask' => $tmp[3],
   };
  }elsif(scalar @tmp == 3){
    &check_ip($tmp[1]);
    &check_netmask($tmp[2]);
  return { 
       'eth'  => $tmp[0],
       'ip'   => $tmp[1],
       'mask' => $tmp[2],
   };
  }elsif(scalar @tmp == 2) {
    &check_ip($tmp[0]);
    &check_netmask($tmp[1]);
  return { 
       'ip'   => $tmp[0],
       'mask' => $tmp[1],
   };
  }else {
  croak "shoudn't be here !"
 }
}
sub check_ip{
    my $ip = shift;
    if($ip =~ /^(\d{1,2}|1\d\d|2[0-4]\d|25[0-5])\.(\d{1,2}|1\d\d|2[0-4]\d|25[0-5])\.(\d{1,2}|1\d\d|2[0-4]\d|25[0-5])\.(\d{1,2}|1\d\d|2[0-4]\d|25[0-5])$/)
    {
        return 1;
    }else {
        croak "$ip is not a ip format";
        return 0;
    }
}

sub check_netmask{
    my $ip = shift;
    if ( $ip =~ /(255|254|252|248|240|224|192|128|0+)\.(255|254|252|248|240|224|192|128|0+)\.(255|254|252|248|240|224|192|128|0+)\.(255|254|252|248|240|224|192|128|0+)/ )
    {
       return 1;
    }else {
       croak "$ip is not a netmask format";
       return 0; 
    }
}
sub generate_hosts {
    my $self = shift;
    open my $fh , '> hosts' or die "can not open hosts";
    print $fh  "127.0.0.1 localhost";
    foreach my $host (keys %$self) 
    {
      print $fh "$host ".$selft->{$host}{'master'}{'ip'};
    }
    close $fh;
}
