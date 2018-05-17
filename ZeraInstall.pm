package ZeraInstall;

use CGI::Minimal;
use JSON::XS;

use Zera::Com;
use Zera::Layout;
use Zera::DBI;
use Zera::Email;
$CGI::Minimal::_allow_hybrid_post_get = 1;

sub new {
    my $class    = shift;
    my $self     = {};
    bless $self,$class;
    $self->{mode} = 'CGI';
    $self->{_REQUEST} = CGI::Minimal->new();
    $self->_init();
    return $self;
}

sub _init {
    my $self = shift;
    $self->{_DBH}  = Zera::DBI->new() if($conf->{DBI});
    $self->{_CONF} = $self->get_installation_settings();
    $self->{_PAGE} = {title => $conf->{App}->{Name}, buttons=>'', type=>'website'};
    $self->{_REQUEST}->param('Controller','Install');
}

sub run {
    my $self = shift;

    my $module = $self->{_REQUEST}->param('Controller');
    my $view = $self->{_REQUEST}->param('View') || "";
    $module =~s/\W//g;
    $self->{ControllerName} = $module;

    require "Zera/".$module ."/Controller.pm";
    my $controller_name ='Zera::'.$module.'::Controller';
    my $Controller = $controller_name->new($self);

    my $controller_results = $Controller->after_init();
    $self->process_results($controller_results);

    # Load module
    my $Module;
    if( $view eq 'API'){
        print Zera::Com::header($self, 'application/json');
        require "Zera/".$module ."/API.pm";
        my $module_name ='Zera::'.$module.'::API';
        $Module = $module_name->new($self);
        print $Module->process_api();
    }else{
        if($ENV{REQUEST_METHOD} eq 'POST' or $self->{_REQUEST}->param('_Action')) {
            eval {
                require "Zera/".$module ."/Actions.pm";
                my $module_name ='Zera::'.$module.'::Actions';
                $Module = $module_name->new($self);
                my $results = $Module->process_action();
                $self->process_results($results);
            };
            if($@){
                #                add_msg('danger', $@);
                ##                Zera::Controller::display_error();
                ##                $self->{DBH}->disconnect();
                ##                return '';
            }
        }

        eval {
            require "Zera/".$module ."/View.pm";
            my $module_name ='Zera::'.$module.'::View';
            my $View = $module_name->new($self);
            print Zera::Com::header($self);
            if($view =~ /^[\w|-]+$/){
                my $Layout = Zera::Layout->new($self);
                print $Layout->print( $View->get_view() );
            }else{
                my $Layout = Zera::Layout->new($self);
                print $Layout->print( $View->get_default_view() );
            }
        };
        if($@){
            print Zera::Com::header($self);
            $self->add_msg('danger', $@);
            print $self->get_msg();
        }
    }
    $self->clear();
}

sub clear {
    my $self = shift;
    $self->set_installation_settings();
    exit;
}

sub process_results {
    my $self = shift;
    my $results = shift;

    if($results->{redirect}){
        $self->set_installation_settings();
        $self->http_redirect($results->{redirect});
        exit;
    }
}

sub http_redirect {
    my $self = shift;
    my $dest = shift;
    print $self->redirect($dest);
}

sub redirect {
    my $self = shift;
    my $url  = shift;
    my $status = '302 Found';

    my @header;
    push(@header,"Location: $url");
    push(@header,"Status: $status");

    my $header = join("\n",@header)."${CRLF}${CRLF}";
    return $header . "\n\n";
}

sub add_msg {
    my $self = shift;
    my $type = shift;
    my $msg = shift;
    push(@{$self->{_CONF}->{msg}},{type=>$type, msg=> $msg});
}

sub get_msg {
    my $self = shift;
    my $HTML = "";
    foreach my $msg (@{$self->{_CONF}->{msg}}){
     	my $class = '';
     	$HTML .= '<div class="alert alert-'.$msg->{type}.'" role="alert">' . $msg->{msg} . '<button type="button" class="close" data-dismiss="alert" aria-label="Close"><span aria-hidden="true">&times;</span></button></div>';
    }
    $self->{_CONF}->{msg} = [];
    return $HTML;
}

sub get_installation_settings {
    my $self = shift;
    my $file = '';
    my $conf = {
        msg=>[],
        Template=>{
            TemplateID      => 'ZeraInstall',
            UserTemplateID  => 'ZeraUser',
            AdminTemplateID => 'ZeraAdmin',
        }
    };

    if(-e ('Zera/INSTALL.json')){
        open(FILE,'Zera/INSTALL.json');
        while (<FILE>) {
            $file .= $_;
        }
        close FILE;
        if($file){
            $conf = decode_json($file);
        }
    }

    return $conf;
}

sub set_installation_settings {
    my $self = shift;
    open(FILE,'>Zera/INSTALL.json');
    my $json = encode_json($self->{_CONF});
    print FILE $json;
    close FILE;
}


1;
