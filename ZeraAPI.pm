package ZeraAPI;

use JSON::XS;
use CGI::Minimal;

use Zera::Conf;
use Zera::Com;
use Zera::DBI;
use Zera::Email;
$CGI::Minimal::_allow_hybrid_post_get = 1;

sub new {
    my $class    = shift;
    my $self     = {};
    bless $self,$class;
    $self->{mode} = 'CGI';

    if('FCGI' eq  'ON'){

    }else{
        $self->{_REQUEST} = CGI::Minimal->new();
    }

    $self->_init();

    return $self;
}

sub _init {
    my $self = shift;
    $self->{_DBH}  = Zera::DBI->new();
    $self->{_MSG}  = [];
    $self->{_EMAIL} = Zera::Email->new($self);
}

sub run {
    my $self = shift;

    # Header
    print Zera::Com::header($self, 'application/json');
    
    if($self->{_REQUEST}->param('Controller')){
        my $module = $self->{_REQUEST}->param('Controller');
        my $view = $self->{_REQUEST}->param('View') || "";
        $module =~s/\W//g;

        $self->{ControllerName} = $module;

        # Load module
        my $Module;
        eval {
            require "Zera/".$module ."/API.pm";
        };
        if($@){
            $self->add_msg('dangersss', $@);
            my $response = {
                response => 'error',
                error_msg => $self->get_msg(),
            };
            print encode_json($response);
            $self->clear();
            return '';
        }

        my $module_name ='Zera::'.$module.'::API';
        $Module = $module_name->new($self);
        print JSON::XS->new->encode($Module->process_api());

    }else{
        my $response = {
            result => 'success',
            msg => 'Zera API-REST ready',
        };
        print JSON::XS->new->encode($response);
        $self->clear();
        return '';
    }
    $self->clear();
}

sub clear {
    my $self = shift;
    $self->{_DBH}->disconnect();
    exit;
}

sub add_msg {
    my $self = shift;
    my $type = shift;
    my $msg = shift;
    push(@{$self->{_MSG}}, ucfirst($type) . ": $msg");
}

sub get_msg {
    my $self = shift;
    my $str = "";
    foreach my $msg (@{$self->{_MSG}}){
        $str .= $msg . ' ';
    }
    return $str;
}

1;
