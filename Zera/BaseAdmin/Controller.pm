package Zera::BaseAdmin::Controller;

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
    
    # Views where authentication is nos required
    $self->{public_views} = ['Login','Msg'];
    my $is_public_view = 0;
    
    # no user_id in session.
    if(!($self->{Zera}->{_SESS}->{_sess}{user_id})){
        # Check public Views
        foreach my $view (@{$self->{public_views}}) {
            if($self->{Zera}->{_REQUEST}->param('View') eq $view){
                $is_public_view = 1;
                last;
            }
        }
        
        if(!$is_public_view){
            $self->{Zera}->add_msg('warning','Log into your account.');
            $results->{error} = 1;
            $results->{redirect} = '/Admin/Login?_next=';
            $self->{Zera}->process_results($results);
        }
    }
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
