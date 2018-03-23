#!/usr/bin/perl

use lib 'lib/';
use strict;
use Zera;
use Zera::Carp;
#use FCGI;

#use Zera::Conf;
#use Zera::Com;
#use Zera::LayoutAdmin;

#print "Content-Type: text/html\n\n";
#foreach my $key (keys %ENV){
#    print "$key = $ENV{$key}  <br>\n";
#}

my $Zera = Zera->new();
$Zera->run();
exit 0;
