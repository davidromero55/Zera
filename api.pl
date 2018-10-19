#!/usr/bin/perl

use lib 'lib/';
use strict;
use ZeraAPI;

#print "Content-Type: text/html\n\n";
#foreach my $key (keys %ENV){
#    print "$key = $ENV{$key}  <br>\n";
#}

my $Zera = ZeraAPI->new();
$Zera->run();
exit 0;
