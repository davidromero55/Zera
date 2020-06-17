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
    my $layout_file = $conf->{Template}->{Layout} || 'layout.html';

    my $Controller = $self->{Zera}->{_REQUEST}->param('Controller');
    if($self->{Zera}->{_Layout} eq 'Public'){
        if (!$template_file) {
            $template_file = 'templates/' . $conf->{Template}->{TemplateID} . '/' . $layout_file;
        }
    }elsif($self->{Zera}->{_Layout} eq 'User'){
        if (!$template_file) {
            if(!($self->{Zera}->{_SESS}->{_sess}{user_id})){
                if($layout_file eq 'layout.html'){
                    $layout_file = 'layout_out.html';
                }
            }
            $template_file = 'templates/' . $conf->{Template}->{UserTemplateID} . '/' . $layout_file;
        }
    }elsif($self->{Zera}->{_Layout} eq 'Admin'){
        if (!$template_file) {
            if($self->{Zera}->{_SESS}->{_sess}{user_id} and $self->{Zera}->{_SESS}->{_sess}{is_admin}){
                $template_file = 'templates/' . $conf->{Template}->{AdminTemplateID} . '/' . $layout_file;
            }else{
                $template_file = 'templates/' . $conf->{Template}->{AdminTemplateID} . '/' . $layout_file;
            }
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
        page    => $self->{Zera}->{_PAGE},
        msg     => $self->{Zera}->get_msg(),
        Zera    => $self->{Zera},
    };

    $tt->process($template_file, $tt_vars, \$HTML) or $HTML = $tt->error();
    return $HTML;
}
1;
