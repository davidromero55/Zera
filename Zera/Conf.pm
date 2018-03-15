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
    conection     => "dbi:mysql:zera_dev",
    user_name     => "zera_dev",
    password      => "Zng4k4*4",
    charset       => 'utf8',
    time_zone     => '-6:00'
};

$conf->{App} = {
    Name      => 'Zera CMS',
    Version   => '0.1',
    URL       => '127.0.0.1',
    Copyright => 'Xaandia Tecnologías Digitales SA de CV',
    Language  => 'en_US',
    TimeZone  => 'US/Central',
    Resources => '/var/www/vhosts/zera.tech/httpdocs/',
};

$conf->{Cookie} = {
    Name      => "ZERA",
    'Max-Age' => "31536000", # Cookie life time in secconds
    Domain    => $conf->{App}->{URL},
    SameSite  => 'Strict',
    Path      => '/',
};

$conf->{Template} = {
    TemplateID => 'zera-website',
    AdminTemplateID => 'zera',
};

$conf->{Security} = {
    Key => 'sdsd',
};

1;