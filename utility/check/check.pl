#!/usr/bin/env perl
use strict;
use Cwd;
use Net::Ping;
use File::Basename;

my $cwd =  getcwd();
print $cwd,"\n";
open my $fh, "< ip_map" or die "can not open ip_map";

while(<$fh>)
{
    chomp;
    next if /^\s*#/;
    s/^\s*//;
    s/\s*$//;
    s/  / /g;
    my ($ip,$host) = split ' ';
    if( &check_ip($ip)){
        my  $p = Net::Ping->new();
        if (!$p->ping($ip)){
         print "\033[31m[Line:$.] $ip\033[0m is not alive ,can not ping !\n";
        }

        $p->close();
    }else {
     print  "\033[31m[Line:$.]$ip\033[0m is not a ip,please modify your ip_map\n  ";
    }
    next if  $host =~ /cvm/;
    next if  $host =~ /coc/;
    next if  $host =~ /csp/;
    print "host:",$host ,"\n";
    if( ! $host =~ /hvn/ )
    {
     print "\033[31m[Line:$.]$host\033[0m need be  named as  hvn1 , hvn2 ... or hvn100 \n";
    }
}

sub check_ip{
    my $ip = shift;
    if($ip =~ /^(\d{1,2}|1\d\d|2[0-4]\d|25[0-5])\.(\d{1,2}|1\d\d|2[0-4]\d|25[0-5])\.(\d{1,2}|1\d\d|2[0-4]\d|25[0-5])\.(\d{1,2}|1\d\d|2[0-4]\d|25[0-5])$/)
    {
        return 1;
    }else {
        return 0;
    }
}
# check ip
# check hostname
# 参数检查


