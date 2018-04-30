package Zera::Conf;

use strict;
BEGIN {
    use Exporter();
    use vars qw( @ISA @EXPORT @EXPORT_OK );
    @ISA = qw( Exporter );
    @EXPORT = qw(
                $conf
                );
}
use vars @EXPORT;

$conf->{DBI} = {
    Conection => 'dbi:mysql:<% Database.Database %>',
    Username  => '<% Database.Username %>',
    Password  => '<% Database.Password %>',
    Charset   => 'utf8',
    Timezone  => '<% Database.Timezone %>',
    Database  => '<% Database.Database %>'
};

$conf->{App} = {
    Name      => '<% Website.Name %>',
    Version   => '0.1',
    URL       => '<% Website.URL %>',
    Language  => 'en_US',
};

$conf->{Cookie} = {
    Name      => 'ZERA',
    'Max-Age' => '31536000',
    Domain    => $conf->{App}->{URL},
    SameSite  => 'Strict',
    Path      => '/',
};

$conf->{Template} = {
    TemplateID      => 'ZeraWebsite',
    UserTemplateID  => 'ZeraUser',
    AdminTemplateID => 'ZeraAdmin',
};

$conf->{Security} = {
    Key => '<% SecurityKey %>',
};

$conf->{Email} = {
    Server   => 'localhost',
    Port     => '',
    Auth     => '',
    User     => '',
    Password => '',
    From     => '<% User.Email %>',
    SSL      => '',
    Debug    => '0',
};

1;
