#!/usr/bin/env perl

use strict;
use Carp;
use Smart::Comments;
use File::Basename qw(dirname basename);
use Archive::Rar;
use Archive::Extract;
use Cwd ;

sub generate_raw {
    my $file    = shift;
    my $dir     = dirname($file);
    my $name    = basename($file);
    my $cwd     = getcwd(); 
    croak "$file is not exsit!" unless -f $file;
    if($name =~ /\.rar$/){
        chdir $dir or croak "$dir is not exsist!";
        my $rar = Archive::Rar->new(-archive => $name );
        $rar->List();
        my $res = $rar->Extract();
        croak "Error $res in extracting from $archive\n" if ( $res );
    }elsif ($name =~ /\.zip$/){
        chdir $dir or croak "$dir is not exsist!";
        my $ae = Archive::Extract->NEW( archive => $name);
        my $ok = $ae=>extract() or croak $ae->error;
    }elsif($name =~ /\.qcow2$/){
        
    }else{
        croak "$name is unkown file!"; 
    }
    chdir $cwd;
}



