package ShellRun;
use strict;
use 5.010;
use IPC::Open3;
use Symbol;
our @EXPORT  = qw/excute/;

sub excute {
my $cmd = shift ;
my $arg = shift;
my ($in,$out,$err) = @_;
my $pid;
#open ERR,">  2.log" or die ;
if( ($arg eq '' ) || !defined($arg)  )
{
 $pid = open3( $in,$out ,$err,$cmd ); 
}else{
 $pid = open3( $in,$out ,$err,$cmd ,$arg); 
}
#say "child pid is ",$pid;
#say 'let\'s wait for it ';
#while(<$out>)
#{
#    print ;
#}
waitpid($pid ,0);
say $pid, ' END';
my $res=$?>>8;
#say 'return value: ',$res;

close $out if $out;
close $in if $in;
close $err if $err;
return $res;
}
1;
