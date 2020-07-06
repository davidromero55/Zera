package Zera;

use CGI::Minimal;

use Zera::Conf;
use Zera::Com;
use Zera::Layout;
use Zera::DBI;
use Zera::Session;
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
    $self->{_SESS} = Zera::Session->new($self->{_DBH});
    $self->{_EMAIL} = Zera::Email->new($self);
    $self->{_PAGE} = {title => $conf->{App}->{Name}, buttons=>'', type=>'website'};
}

sub run {
    my $self = shift;

    if($self->{_REQUEST}->param('Controller')){
        my $module = $self->{_REQUEST}->param('Controller');
        my $view = $self->{_REQUEST}->param('View') || "";
        $module =~s/\W//g;
        $self->{ControllerName} = $module;

        if( $self->{ControllerName} eq 'Url'){
            my ($url_module, $view, $sub_view) = $self->rewrite_request();
            if($url_module){
                $module = $url_module;
                $self->{Zera}->{ControllerName} = $module;
                $self->{ControllerName} = $module;
                $self->{_REQUEST}->param('Controller',$module);
                $self->{_REQUEST}->param('View',$view);
                $self->{_REQUEST}->param('SubView',$sub_view);
            }else{
                print "Status: 404 Not Found\n";
                print "\n";
                $self->clear();
                exit 0;
            }
        }

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
                if($view =~ /^[\w\-]+$/){
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
                #Zera::display_error();
                #$self->{DBH}->disconnect();
                #return '';
            }
        }
    }
    $self->clear();
}

sub clear {
    my $self = shift;
    $self->{_SESS}->close();
    $self->{_DBH}->disconnect();
    exit;
}

sub process_results {
    my $self = shift;
    my $results = shift;

    if($results->{redirect}){
        $self->{_SESS}->close();
        $self->{_DBH}->disconnect();
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
    $self->{_DBH}->{_dbh}->do("INSERT IGNORE INTO $conf->{DBI}->{Database}.sessions_msg (session_id, type, msg) values(?,?,?)",{},$self->{_SESS}->{_sess}{_session_id},$type, $msg);
}

sub get_msg {
    my $self = shift;
    my $HTML = "";
    my $msgs = $self->{_DBH}->{_dbh}->selectall_arrayref("SELECT m.type, m.msg FROM $conf->{DBI}->{Database}.sessions_msg m WHERE m.session_id=?",{},($self->{_SESS}->{_sess}{_session_id} || ""));
    foreach my $msg (@$msgs){
    	my $class = '';
    	$HTML .= '<div class="alert alert-'.$msg->[0].'" role="alert">' . $msg->[1] . '<button type="button" class="close" data-dismiss="alert" aria-label="Close"><span aria-hidden="true">&times;</span></button></div>';
    }
    $self->{_DBH}->{_dbh}->do("DELETE FROM $conf->{DBI}->{Database}.sessions_msg WHERE session_id=?",{},$self->{_SESS}->{_sess}{_session_id}) if($msgs->[0]);
    return $HTML;
}

sub get_api_msg {
    my $self = shift;
    my $str = "";
    my $msgs = $self->{_DBH}->{_dbh}->selectall_arrayref("SELECT m.type, m.msg FROM sessions_msg m WHERE m.session_id=?",{},$self->{_SESS}->{_sess}{_session_id});
    foreach my $msg (@$msgs){
    	my $class = '';
    	$str .= $msg->[0].': ' . $msg->[1] . "\n";
    }
    $self->{_DBH}->{_dbh}->do("DELETE FROM sessions_msg WHERE session_id=?",{},$self->{_SESS}->{_sess}{_session_id}) if($msgs->[0]);
    return $str;
}

sub zera_include_block{
    my $self = shift;
    my $block_name = shift || 'not_found.html';
    my $template = shift || '';
    my $HTML = '';

    if($self->{Zera}->{_Layout} eq 'Public'){
        if (!$template) {
            $template = 'templates/' . $conf->{Template}->{TemplateID} . '/block/'.$block_name.'.html';
        }
    }elsif($self->{Zera}->{_Layout} eq 'User'){
        if (!$template) {
                $template = 'templates/' . $conf->{Template}->{UserTemplateID} . '/block/'.$block_name.'.html';
        }
    }elsif($self->{Zera}->{_Layout} eq 'Admin'){
        if (!$template_file) {
                $template_file = 'templates/' . $conf->{Template}->{AdminTemplateID} . '/block/'.$block_name.'.html';
        }
    }else{
        if (!$template_file) {
            $template_file = 'templates/' . $conf->{Template}->{TemplateID} . '/block/'.$block_name.'.html';
        }
    }

    $vars->{conf} = $conf;
    $vars->{msg}  = $self->get_msg();
    $vars->{page} = $self->{_PAGE};

    my $tt = Zera::Com::template();
    $tt->process($template, $vars, \$HTML) || die "$Template::ERROR \n";
    return $HTML;
}

sub get_component {
    my $self = shift;
    my $Controller = shift;
    my $Component = shift;
    my @params = @_;

    $Controller =~s/\W//g;
    $Component  =~s/\W//g;

    # Load module
    eval {
        require "Zera/".$Controller ."/Components.pm";
    };
    if($@){
        return $@;
    }
    my $module_name ='Zera::'.$Controller.'::Components';
    my $Module = $module_name->new($self);
    return $Module->get_component($Component, @params);
}

sub rewrite_request {
    my $self = shift;

    my $entry = $self->{_DBH}->{_dbh}->selectrow_hashref("SELECT module, url FROM entries e WHERE e.url=? AND e.active=1",{}, $self->{_REQUEST}->param('View'));
    if($entry->{module}){
        return ($entry->{module},'Item', $entry->{url})
    }else{
        my $file_name = $self->{_REQUEST}->param('View');
        $file_name =~ s/\W!-//g;
        $file_name = lc($file_name);
        if($file_name){
            if (-e ('templates/'.$conf->{Template}->{TemplateID}.'/static/'.$file_name . '.html')) {
                return ('Static','Item',$file_name);
            }elsif (-e ('static/'.$file_name . '.html')) {
                return ('Static','Item',$file_name);
            }
        }
    }
    return ('','','');
}

1;
