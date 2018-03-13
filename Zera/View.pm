package Zera::View;

use strict;

#use Marketero::Conf;
#use Marketero::Com;
#use Marketero::Layout;

sub default {
    return Marketero::Layout::print(msg_print());
}

1;