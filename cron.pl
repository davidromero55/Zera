#!/usr/bin/perl

use lib '.';
use strict;
use ZeraCron;

my $num_args = $#ARGV + 1;
if ($num_args != 2) {
    print "Zera Usage: cron.pl Module action\n";
    exit;
}

my $Zera = ZeraCron->new($ARGV[0], $ARGV[1]);
$Zera->run();
exit 0;
