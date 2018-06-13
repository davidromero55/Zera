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
# my $html .= qq| <select> |;
# $html .= qq|
# <option value=1>1</option>
# |;
# $html .= qq| </select> |;

# my $self = shift;
# my $values = {};
# my @submit = ("Save");
# my $form = $self->form({
#         method   => 'POST',
#         fields   => [qw/business_id /],
#         submits  => \@submit,
#         values   => $values,});
# my $buss = $self->selectbox_data("SELECT business_id FROM business_admins WHERE user_id=?",{},$self->sess('user_id'));
# $form->field('business_id',{placeholder=> 'Empresa', span=>'col-md-3', label=> 'Empresa', type=>'select', selectname => 'Elija su empresa', options => $buss{values}});

exit 0;
