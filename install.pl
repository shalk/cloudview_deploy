#!/usr/bin/env perl

use strict;
use warnings;
#use Smart::Comments;
use lib "./lib";
use MyCheck ;
use File::Path qw(make_path remove_tree);
use Carp;
use Master;
use MyCheck;
my $config_filename='ip_map';


my $password = '111111'
# struct 
#
#  hostname => {  master => { ip
#                             br   
#                             }
#
#
#
 
#analyze part
my $master = Master->new($config_filename);

#check part
foreach my $host (  keys %$master)
{
  MyCheck::check_ip_connect($master->{$host}{'master'}{'ip'});
}
MyCheck::check_cloudview_exist();
MyCheck::check_cloudview_software();

#

&no_password($no_passwd);



# prepare
$master->generate_hosts();

# batch cluster



### $network_info


sub check_cloudview_software{
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

