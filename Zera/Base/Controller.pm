package Zera::Base::Controller;

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

# Initialize ENV
sub _init {
    my $self = shift;

    # Define layout mode
    $self->{Zera}->{_Layout} = 'Public';
}

sub after_init {
    my $self = shift;
}

sub before_actions {
    my $self = shift;
}

sub after_actions {
    my $self = shift;

}

sub before_views {
    my $self = shift;

}

sub after_views {
    my $self = shift;

}

sub before_api {
    my $self = shift;

}

sub after_api {
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
    my $val = shift;
    if(defined $val){
        $self->{Zera}->{_REQUEST}->param($var,$val);
    }else{
        my $val = $self->{Zera}->{_REQUEST}->param($var);
        if(defined $val){
            return $self->{Zera}->{_REQUEST}->param($var);
        }else{
            return '';
        }
    }
}

# User messages
sub add_msg {
    my $self = shift;
    $self->{Zera}->add_msg(shift, shift);
}

sub get_msg {
  my $self = shift;
  $self->{Zera}->get_msg();
}

sub display_msg {
    my $self = shift;

    my $vars = {
    };
    return $self->render_template($vars,'msg-admin');
}

#Call conf values
sub conf {
    my $self = shift;
    my $name = shift;
    my $module = shift;
    my $value = shift;
    if (defined $value){
        $self->dbh_do("UPDATE value = ? WHERE name = ? AND module = ?", {}, $value, $name, $module);
    }else{
        $value = $self -> selectrow_array(
            "SELECT value FROM conf WHERE name = ?", {}, $name);
        return $value;
    }
}

1;
