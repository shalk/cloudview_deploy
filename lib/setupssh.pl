#!/usr/bin/env perl

use strict;


use Expect;
use Getopt::Long;

my $username = "root";
my $iplist;
my $password;

GetOptions(
    "nodes=s" => \$iplist,
    "pass=s"  => \$password,
) or &usage(1);
&usage(1) unless $iplist;
&usage(1) unless $password;

sub usage {
    my $ret = shift;
    print <<'EOF';
 sshsetup.pl    [ -pass  password ] [ -nodes  ip1,ip2,ip3 ];
 
 example:
 perl sshsetup.pl   -pass 123456  -nodes  10.5.1.1,10.5.2.2
 
EOF
    die if $ret == 1;
}

#step 1
my @iplist = split ',', $iplist;
my $type = 'rsa';

my $cmd =
  "echo -e 'y\\n' | ssh-keygen  -t ${type}  -f \$HOME/.ssh/id_${type} -N '' ";
system($cmd);
if ( $? != 0 ) {
    die "ssh-keygen genenrate error ($cmd)";
}

$cmd = "cat \$HOME/.ssh/id_${type}.pub >> \$HOME/.ssh/authorized_keys ";
system($cmd);
if ( $? != 0 ) {
    die "cat file  error ($cmd)";
}

$cmd = "echo 'StrictHostKeyChecking no' >> \$HOME/.ssh/config ";
system($cmd);
if ( $? != 0 ) {
    die "cat file  error ($cmd)";
}

#step 2
foreach my $ip (@iplist) {
    my $timeout = "30";

    $cmd = " scp -r \$HOME/.ssh ${ip}:\$HOME ";
    my $exp = Expect->spawn($cmd) or die "can not spawn $cmd ";

    if ($exp) {
        $exp->expect(
            $timeout,
            [
                qr/password/i => sub {
                    my $self = shift;
                    $self->send( $password . "\n" );
                    exp_continue;
                  }
            ],
            [
                qr/(yes\/no)/ =>
                  sub { my $self = shift; $self->send("yes\n"); exp_continue; }
            ],
            [
                qr/Overwrite(y\/n)/ =>
                  sub { my $self = shift; $self->send("y\n"); exp_continue; }
            ],
            [ timeout => sub { die "Timeout happened ,check network "; } ],
            '-re',
            qr'[#>:\$] $',    # wait for shell prompt,then exit expect;
        );
    }
    $exp->soft_close;
}
