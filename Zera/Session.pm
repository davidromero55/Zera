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

    #Disable warnings
    $main::SIG{__WARN__} = sub {};
    $main::SIG{__DIE__}  = sub {};

    eval {
        tie %{$self->{_sess}}, 'Apache::Session::MySQL', $session_id, {
            Handle     => $self->{_DBH}->get_dbh(),
            LockHandle => $self->{_DBH}->get_dbh(),
            TableName  => $conf->{DBI}->{Database} . '.sessions',
        };
    };
    # Enable warnings
    $main::SIG{__WARN__} = \&Zera::Carp::die;
    $main::SIG{__DIE__}  = \&Zera::Carp::die;

    if ($@) {
        $session_id = '';
        eval {
            tie %{$self->{_sess}}, 'Apache::Session::MySQL' , $session_id,{
                Handle     => $self->{_DBH}->get_dbh(),
                LockHandle => $self->{_DBH}->get_dbh(),
                TableName  => $conf->{DBI}->{Database} . '.sessions',
            };
        };
        die "Can't create session data $@" if($@);
    }

    defined $self->{_sess}{user_id}    or $self->{_sess}{user_id} = '';
    defined $self->{_sess}{user_name}  or $self->{_sess}{user_name} = '';
    defined $self->{_sess}{user_email} or $self->{_sess}{user_email} = '';

        #foreach my $key (keys %{$self->{_sess}}){
        #    print "--22-- $key = $self->{_sess}{$key} ------<br>";
        #}
        #print "-- Prueba4 - $self->{_SESS}->{_sess} --<br>";


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
