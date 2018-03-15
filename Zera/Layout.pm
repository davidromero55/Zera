package Zera::Layout;

use strict;
use utf8;
use Template;

use Zera::Conf;
use Zera::Com;


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

sub _init {
    my $self = shift;
}

sub print {
    my $self = shift;
    my $HTML = "";
    my $content = shift || "";
    my $vars    = shift || {};
    my $template_file = shift || '';
    my $menus;
    
    my $Controller = $self->{Zera}->{_REQUEST}->param('Controller');
    if($self->{Zera}->{_Layout} eq 'Public'){
        if (!$template_file) {
            $template_file = 'templates/' . $conf->{Template}->{TemplateID} . '/layout.html'
        }
    }elsif($self->{Zera}->{_Layout} eq 'User'){
        if (!$template_file) {
            if($self->{Zera}->{_SESS}->{_sess}{user_id}){
                $template_file = 'templates/' . $conf->{Template}->{UserTemplateID} . '/layout.html'
            }else{
                $template_file = 'templates/' . $conf->{Template}->{UserTemplateID} . '/layout-out.html'
            }
        }
        if($self->{Zera}->{_SESS}->{_sess}{user_id}){
            $menus = $self->{Zera}->{_DBH}->{_dbh}->selectall_arrayref("SELECT SQL_CACHE url, name, icon FROM menus m WHERE m.group='User' ORDER BY m.sort_order, m.name",{Slice=>{}});
        }        
    }elsif($self->{Zera}->{_Layout} eq 'Admin'){
        if (!$template_file) {
            if($self->{Zera}->{_SESS}->{_sess}{user_id}){
                $template_file = 'templates/' . $conf->{Template}->{AdminTemplateID} . '/layout.html'
            }else{
                $template_file = 'templates/' . $conf->{Template}->{AdminTemplateID} . '/layout-out.html'
            }
        }
        if($self->{Zera}->{_SESS}->{_sess}{user_id}){
            $menus = $self->{Zera}->{_DBH}->{_dbh}->selectall_arrayref("SELECT SQL_CACHE url, name, icon FROM menus m WHERE m.group='Admin' ORDER BY m.sort_order, m.name",{Slice=>{}});
        }
    }else{
        if (!$template_file) {
            $template_file = 'templates/' . $conf->{Template}->{TemplateID} . '/layout.html'
        }
    }
    
    my $tt = Zera::Com::template();
    my $tt_vars = {
        conf    => $conf,
        content => $content,
        vars    => $vars,
        menus   => $menus,
        page    => $self->{Zera}->{_PAGE},
        msg     => $self->{Zera}->get_msg(),
    	#sess    => \%sess,
    };
    
    $tt->process($template_file, $tt_vars, \$HTML) or $HTML = $tt->error();
    return $HTML;
}

1;