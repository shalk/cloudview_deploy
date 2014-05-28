package Hello;
use  Exporter;

our @ISA = qw(Exporter);
our @EXPORT =  qw(hello);
our $version = 1.0;

sub hello{
 
 print "hello world\n";

}

1;
__END__
