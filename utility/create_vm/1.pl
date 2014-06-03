#!/usr/bin/env perl
#
# Description : create a virtual matchine and than depoy cloudview on it 
#
#

use Expect;
use XML::Simple;
use Carp;

croak "give a vm name parameter" if scalar @ARGV < 1;

my $vm_name = $ARGV[0];
my $vm_dir  = $ARGV[1] || '/cv';

#step 1 analyze create a xm for xml config
my $vm_xml_path = $vm_dir."/".$vm_name."/".$vm_name.".xml";


#step 2 extrat and convert img into  a directory;
my $vm_img_path = $vm_dir."/".$vm_name."/".$vm_name.".img";




#step 3 start up vm and wait boot into system

system( "virsh define  $vm_xml_path");
system( "virsh start   $vm_name");
sleep 120;


#step 4 use virsh console into system and config network as no password



#step 5 scp project and deploy cloudview
#
system("scp ../../../cloudview_deploy/  $vm_name:/root/");
system("ssh $vm_name 'bash /root/cloudview_deploy/${vm_name}.sh '");
