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
    Database  => '<% Database.Database %>',
    Language  => '<% Database.Language %>'
};

$conf->{App} = {
   Name      => '<% Website.Name %>',
   Version   => '0.1',
   URL       => '<% Website.URL %>',
   Language  => '<% Database.Language %>',
   URLLink   => 'http://<% Website.URL %>',
   Copyright => '<% Website.Name %>',
   Language  => 'en_US',
   TimeZone  => 'US/Central',
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
    Port     => '587',
    Auth     => 'LOGIN',
    User     => '',
    Password => '',
    From     => '<% User.Email %>',
    SSL      => 'starttls',
    Debug    => '0',
};

1;
