package Zera::Session;

use Apache::Session::MySQL;
use Zera::Conf;

sub new {
    my $class    = shift;
    my $self     = {};
    bless $self,$class;
    
    $self->{_DBH} = shift;
    $self->_init();
    
    return $self;
}

sub _init {
    my $self = shift;
    my $session_id;
    if (defined $ENV{'HTTP_COOKIE'}){
        my %cookies = map {$_ =~ /\s*(.+)=(.+)/g} ( split( /;/, $ENV{'HTTP_COOKIE'} ) );
        $session_id = $cookies{$conf->{Cookie}->{Name}};
    }

    eval {
        tie %{$self->{_sess}}, 'Apache::Session::MySQL', $session_id, {
            Handle     => $self->{_DBH}->get_dbh(),
            LockHandle => $self->{_DBH}->get_dbh(),
            TableName  => 'sessions',
        };
    };

    if ($@) {
        eval {
            $session_id = '';
            tie %{$self->{_sess}}, 'Apache::Session::MySQL' , $session_id,{
                Handle     => $self->{_DBH}->get_dbh(),
                LockHandle => $self->{_DBH}->get_dbh(),
                TableName  => 'sessions',
            };
        };
        die "Can't create session data $@" if($@);
    }

    defined $self->{_sess}{account_id}    or $self->{_sess}{account_id} = '';
    defined $self->{_sess}{account_name}  or $self->{_sess}{account_name} = '';
    defined $self->{_sess}{account_email} or $self->{_sess}{saccount_email} = '';

    $self->{cookie} = $self->_get_cookie_str();
}

sub close {
    my $self = shift;
    untie %{$self->{_sess}}
}

sub _get_cookie_str {
    my $self  = shift;
    my $cookie_str = '';
    foreach my $key (keys %{$conf->{Cookie}}) {
        next if($key eq 'Name');
        $cookie_str .= '; ' . $key . '=' . $conf->{Cookie}->{$key};
    }
    $cookie_str = $conf->{Cookie}->{Name} . "=" . $self->{_sess}{_session_id} . $cookie_str;
    return $cookie_str;
}

1;
