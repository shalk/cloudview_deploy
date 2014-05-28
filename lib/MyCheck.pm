package MyCheck;

use Net::Ping;
use Exporter;
our @ISA=qw(Exporter);
our $version = 0.1;

sub  check_ip_connect {
  my $ip = shift;
  my $ret;
  my  $p = Net::Ping->new();
  if (!$p->ping($ip)){
   print "\033[31m  $ip\033[0m is not alive ,can not ping !\n";
   $ret = 0;
  }else{
   print "\033[31m  $ip\033[0m is alive \n";
   $ret = 1;
  }
  $p->close();
  return $ret;
}

sub check_cloudview_exsit{
 if ( ! -d 'cloudview' )
 {
    my @file = < cloudview* > ;
    croak "(@file ) which is cloudview ?
         please detete other cloudview prefix file.
         preserve the softerware  
             " if scalar @file > 1;
   
    rename $file[0],'cloudview';
 }else{
    croak "Make sure cloudview software  is in ( cloudview_deploy ) directory !";
  }
}
sub check_cloudview_software
{
  my @msp =  glob './cloudview/MSP/*.sh';
  my @cvm =  glob './cloudview/CVM/*.sh';
  my @coc =  glob './cloudview/COC/*.sh';
  my @csp =  glob './cloudview/CSP/*.sh';
  my @mysql = glob './cloudview/Supports/third-party_tools/installer_of_mysql64/install*.sh';
  my @hyper = glob './cloudview/Supports/third-party_tools/cvm-hypervisor-install/cvm-hypervisor-install-*/install';
  croak "msp script miss" unless scalar  @msp;
  croak "cvm script miss" unless scalar  @cvm;
  croak "coc script miss" unless scalar  @coc;
  croak "csp script miss" unless scalar  @csp;
  croak "mysql script miss" unless scalar  @mysql;
  croak "hypervisor install  script miss" unless scalar  @hyper;
}


1;
__END__
