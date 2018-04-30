package Zera::DBI;

use DBI;
use Zera::Conf;

sub new {
    my $class    = shift;
    my $self     = {};
    bless $self,$class;

    # DataBase
    $self->{_dbh} = DBI->connect( $conf->{DBI}->{Conection}, $conf->{DBI}->{Username}, $conf->{DBI}->{Password},{RaiseError => 1,AutoCommit=>1}) or die "Can't Connect to database.";
    $self->{_dbh}->do("SET CHARACTER SET 'utf8'");
    $self->{_dbh}->do("SET time_zone=?",{},$conf->{DBI}->{Timezone});

    return $self;
}

sub disconnect {
    my $self = shift;
    $self->{_dbh}->disconnect();
}

sub get_dbh {
    my $self = shift;
    return $self->{_dbh};
}

1;
