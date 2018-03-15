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

# Request functions
sub param {
    my $self = shift;
    my $var = shift;
    return $self->{Zera}->{_VARS}->{$var};
}

1;
