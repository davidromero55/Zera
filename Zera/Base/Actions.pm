package Zera::Base::Actions;

use strict;

use Zera::Conf;

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

# Session functions
sub sess {
    my $self = shift;
    my $name = shift;
    my $value = shift;

    if(defined $value){
        $self->{Zera}->{_SESS}->{_sess}{$name} = "$value";
    }else{
        return $self->{Zera}->{_SESS}->{_sess}{$name};
    }
}

# Request functions
sub param {
    my $self = shift;
    my $var = shift;
    return $self->{Zera}->{_REQUEST}->param($var);
}

sub process_action {
    my $self = shift;
    my $arg = shift || $self->param('View');
    $arg =~ s/([A-Z])/_$1/g;
    $arg =~ s/\W//g;
    if(!($arg)){
        $arg = $self->param('_Action');
        $arg =~ s/([A-Z])/_$1/g;
        $arg =~ s/\W//g;
        $arg = '_' . $arg;
    }
    my $sub_name = "do" . lc($arg);
    if ($self->can($sub_name) ) {
        $self->$sub_name();
    } else {
        $self->add_msg('danger',"sub '$sub_name' not defined.\n");
    }
}

# User messages
sub add_msg {
    my $self = shift;
    $self->{Zera}->add_msg(shift, shift);
}

# Database functions
sub selectrow_hashref {
    my $self = shift;
    return $self->{Zera}->{_DBH}->{_dbh}->selectrow_hashref(shift, shift,@_);
}

sub last_insert_id {
    my $self = shift;
    return $self->{Zera}->{_DBH}->{_dbh}->last_insert_id('','',shift,shift);
}

sub selectrow_array {
    my $self = shift;
    return $self->{Zera}->{_DBH}->{_dbh}->selectrow_array(shift, shift,@_);
}

sub selectall_arrayref {
    my $self = shift;
    return $self->{Zera}->{_DBH}->{_dbh}->selectall_arrayref(shift, shift,@_);
}

sub dbh_do {
    my $self = shift;
    return $self->{Zera}->{_DBH}->{_dbh}->do(shift, shift,@_);
}

1;
