package Zera::Base::Actions;

use strict;

use Zera::Conf;
use Zera::LayoutAdmin;

sub new {
    my $class = shift;
    my $self = {
        version  => '0.1',
    };
    bless $self, $class;
    
    # Main Zera object
    $self->{Zera} = shift;

    # Init app ENV
    $self->_init();

    return $self;
}

sub _init {
    my $self = shift;
}

sub param {
    my $self = shift;
    my $var = shift;
    return $self->{Zera}->{_REQUEST}->param($var);
}

sub process_action {
    my $self = shift;
    my $arg = shift;
    $arg =~ s/\W//g;
    my $sub_name = "do_" . lc($arg);
    if ($self->can($sub_name) ) {
        $self->$sub_name();
    } else {
        return "sub '$sub_name' not defined.\n";
    }
}

sub add_msg {
    my $self = shift;
    $self->{Zera}->add_msg(shift, shift);
}

1;