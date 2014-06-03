package MyCluster;

use Exporter;
our @ISA = qw/Exporter/;

use Expect;
use Carp;

our $debug = 0;

sub new {
   my $class = shift;
   my $self = shift || [];
   bless $self,$class;
   return $self;
}
sub no_pass {

    my $self =shift;
    my $password = shift;
    my $iplist = $self->iplist;   

    croak "iplist is needed " unless $iplist;
    croak "passwd is needed "  unless $password;
    
    
    #step 1
    my $type = 'rsa';
    
    my $cmd =
      "echo -e 'y\\n' | ssh-keygen  -t ${type}  -f \$HOME/.ssh/id_${type} -N '' ";
    &exe($cmd);
    if ( $? != 0 ) {
        die "ssh-keygen genenrate error ($cmd)";
    }
    
    $cmd = "cat \$HOME/.ssh/id_${type}.pub >> \$HOME/.ssh/authorized_keys ";
    &exe($cmd);
    if ( $? != 0 ) {
        die "cat file  error ($cmd)";
    }
    
    $cmd = "echo 'StrictHostKeyChecking no' >> \$HOME/.ssh/config ";
    &exe($cmd);
    if ( $? != 0 ) {
        die "cat file  error ($cmd)";
    }
    
    #step 2
    foreach my $ip (@$iplist) {
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
}



sub batch_scp{
    my $self = shift;
    my $localpath = shift;
    my $remotepath = shift||$localpath;
    foreach my $remoteip ($self->iplist )
    {
        my $cmd = "scp -r  $localpath  $remoteip:$remotepath";
        &exe( $cmd );
    }
}

sub batch_exec{
    my $self = shift;
    my $remotecmd  = shift;
    foreach my $remoteip ($self->iplist )
    {
        my $cmd = "ssh $remoteip \" $remotecmd \" ";
        &exe( $cmd );
    }
}

sub iplist {
   my $self = shift;
   return wantarray?@$self:$self;
}

# 类函数
sub  remote_exec {
    my $remoteip = shift;
    my $remotecmd  = shift;
    my $cmd = "ssh $remoteip \" $remotecmd \" ";
    &exe( $cmd );
}

sub exe{
    my $cmd = shift;
    if($debug==0){
      system($cmd);
    }else{
      print $cmd,"\n";
    }
}
1;
