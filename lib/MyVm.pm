package MyVm;
use strict;
use Carp;
use File::Basename qw(dirname basename);
use Archive::Extract;
use Data::UUID;
use Cwd;
use Expect;

our $debug = 0;

sub new {

    # arg need a hash ref
    #    name =>         (needed)
    #    disk =>         (needed)
    #    xml  =>         (needed)
    #    cpu  =>
    #    mem  =>
    #    manage_br  =>
    #    busi_br  =>
    #    manage_mac =>
    #    busi_mac =>

    my $class = shift;
    my $arg   = shift;
    my $self  = {};
    $self = $arg if defined $arg;
    bless $self, $class;
    return $self;
}

sub generate_raw {

    # description :
    #    convert qcow2 img to raw img
    # param :
    #    origin img file
    # return :
    #    void

    my $self = shift;
    my $file = $self->{'orig'};
    croak "need a origin img as parameter" unless $file;
    my $target_file = $self->{'disk'};

    my $dir         = dirname($file);
    my $name        = basename($file);
    my $target_dir  = dirname($target_file);
    my $target_name = basename($target_file);
    my $cwd         = getcwd();
    croak "$file is not exsit!" unless -f $file;

    #extract

# because rar is not open source software,i should not to support it for copyright
#    if($name =~ /\.rar$/){
#        chdir $dir or croak "$dir is not exsist!";
#        my $rar = Archive::Rar->new(-archive => $name );
#        $rar->List();
#        my $res = $rar->Extract();
#        croak "Error $res in extracting from $archive\n" if ( $res );
#    }
    if ( $name =~ /(\.zip|\.tar\.gz|\.tgz|\.gz|\.bz2|\.tar\.gz2|\.tbz)$/ ) {
        chdir $dir or croak "$dir is not exsist!";
        my $ae = Archive::Extract->NEW( archive => $name );
        my $ok = $ae => extract() or croak $ae->error;
    }
    else {

    }

    chdir $cwd;
    if ( $name =~ /\.qcow2$/ ) {
        &exe("qemu-img convert -f qcow2 $file  -O raw  $target_file -p ");
    }
    else {
        &exe("qemu-img check $target_file");
        croak "Please use qcow2 format";
    }
}

sub generate_xml {

    # description:
    #   generate a xml string for vm
    # param:
    #   $self
    # return:
    #   vold 

    my $self    = shift;
    my $vm_name = $self->{'name'};
    my $ug      = new Data::UUID;
    my $vm_uuid = lc $ug->create_str();

    my $vm_mem = $self->{'mem'} || 4194304;
    my $vm_cpu = $self->{'cpu'} || 2;
    my $vm_img = $self->{'disk'};
    croak "vm img disk undefined " unless defined $vm_img;

    my $vm_br1 = $self->{'manage_br'} || 'br1';
    my $vm_br2 = $self->{'busi_br'} || 'br0';

    my $vm_mac1 = &generate_mac;
    my $vm_mac2 = &generate_mac;

    $self->{'cpu'}  = $vm_cpu;
    $self->{'mem'}  = $vm_mem;
    $self->{'manage_br'}  = $vm_br1;
    $self->{'busi_br'}  = $vm_br2;
    $self->{'manage_mac'} = $vm_mac1;
    $self->{'busi_mac'} = $vm_mac2;

    my $xml_file = <<"EOF";
<domain type='xen' >
  <name>$vm_name</name>
  <uuid>$vm_uuid</uuid>
  <memory>$vm_mem</memory>
  <currentMemory>$vm_mem</currentMemory>
  <vcpu >$vm_cpu</vcpu>
  <os>
    <type>hvm</type>
    <loader>/usr/lib/xen/boot/hvmloader</loader>
    <boot dev='hd'/>
  </os>
  <features>
    <acpi/>
    <apic/>
    <pae/>
  </features>
  <clock offset='utc'>
    <timer name='hpet' present='no'/>
  </clock>
  <on_poweroff>destroy</on_poweroff>
  <on_reboot>restart</on_reboot>
  <on_crash>restart</on_crash>
  <devices>
    <emulator>/usr/lib64/xen/bin/qemu-dm</emulator>
    <disk type='file' device='disk'>
      <driver name='file'/>
      <source file='$vm_img'/>
      <target dev='hda' bus='ide'/>
    </disk>
    <interface type='bridge'>
      <mac address='$vm_mac1'/>
      <source bridge='$vm_br1'/>
      <script path='/etc/xen/scripts/vif-bridge'/>
    </interface>
	<interface type='bridge'>
      <mac address='$vm_mac2'/>
      <source bridge='$vm_br2'/>
      <script path='/etc/xen/scripts/vif-bridge'/>
    </interface>
    <serial type='pty'>
      <target port='0'/>
    </serial>
    <console type='pty' >
      <target type='serial' port='0'/>
    </console>
    <input type='mouse' bus='ps2'/>
    <graphics type='vnc' port='-1' autoport='yes' keymap='en-us'/>
  </devices>
</domain>
EOF
    &exe( "touch " . $self->{'xml'} );
    open my $fh, "> " . $self->{'xml'} or die "can not open " . $self->{'xml'};
    print $fh $xml_file;
    close $fh;
}

sub virsh_console_exec {

    my $self       = shift;
    my $remote_cmd = shift;
    my $username   = shift || 'root';
    my $password   = shift || '111111';
    my $cmd        = "virsh console ".$self->{'name'};

    my $timeout = 30;
    my $exp     = new Expect;
    $exp->raw_pty(1);
    $exp->spawn($cmd) or die "can not exec $cmd";
    if ($exp) {
        $exp->expect(
            $timeout,
            [
                qr/Escape character/ =>
                  sub { my $self = shift; $self->send("\n"); exp_continue; }
            ],
            [
                qr/login: $/ => sub {
                    my $self = shift;
                    $self->send("${username}\r");
                    exp_continue;
                  }
            ],
            [
                qr/Password:/i => sub {
                    my $self = shift;
                    $self->send("${password}\r");
                    exp_continue;
                  }
            ],
            [
                qr/sugon:~ #/,
                sub {
                    my $self = shift;
                    sleep 1;
                    foreach my $singlecmd  (@$remote_cmd){
                    $self->send_slow(0.1,"\n");
                    $self->send("$singlecmd");
                    $self->send_slow(0.5,"\n");
                    }
                  }
            ],
            [
                timeout => sub {
                    my $self = shift;
                    $self->send("exit\n");
                    $self->send("^]\n");
                  }
            ],
        );
    }
    $exp->soft_close();
}

sub vm_define {
    my $self = shift;
    my $xml_name = $self->{'xml'};
    my $cmd      = "virsh define $xml_name";
    &exe($cmd);
}

sub vm_startup {
    my $self = shift;
    my $vm_name = $self->{'name'};
    my $cmd     = "virsh start $vm_name";
    &exe($cmd);
}

sub exe {
    my $cmd = shift;
    if ( $debug == 0 ) {
        system($cmd);
        if( $?>>8 != 0 ){
          croak "command( $cmd ) failed !";
        }
    }
    else {
        print $cmd, "\n";
    }
}

sub generate_mac {
    my $mac = '00:16';
    for ( 1 .. 4 ) {
        $mac .= ':';
        $mac .= ( "A" .. "F", 0 .. 9 )[ rand(16) ];
        $mac .= ( "A" .. "F", 0 .. 9 )[ rand(16) ];
    }
    return $mac;
}
1;
