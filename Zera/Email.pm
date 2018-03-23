package Zera::Email;

use warnings;
use strict;

use Zera::Conf;
use Zera::Com;
use Zera::Carp;

use Email::Sender::Simple qw(sendmail);
use Email::Sender;
use Encode();
use MIME::Entity();

sub new {
    my $class = shift;
    my $self = {
        version  => '0.1',
    };
    bless $self, $class;

    $self->{Zera} = shift;

    return $self;
}

sub _transport {
    my $self = shift;
    #Disable warnings
    $main::SIG{__WARN__} = sub {};
    $main::SIG{__DIE__}  = sub {};

    require Email::Sender::Transport::SMTP;

    # Enable warnings
    $main::SIG{__WARN__} = \&Zera::Carp::die;
    $main::SIG{__DIE__}  = \&Zera::Carp::die;

    if($conf->{Email}->{Auth}){
        eval {
            $self->{transport} = Email::Sender::Transport::SMTP->new({
                host => $conf->{Email}->{Server},
                port => $conf->{Email}->{Port},
                sasl_username => $conf->{Email}->{User},
                sasl_password => $conf->{Email}->{Password},
                ssl => $conf->{Email}->{SSL},
                debug => $conf->{Email}->{Debug},
                ssl_options => {Debug=>$conf->{Email}->{Debug}, SSL=>$conf->{Email}->{SSL}, SSL_verify_mode=>Net::SSLeay::VERIFY_NONE()}
            });
        };
    }else{
        $self->{transport} = Email::Sender::Transport::SMTP->new({
            host => $conf->{Email}->{Server},
            port => $conf->{Email}->{Port},
        });
    }
}

sub send_html_email {
    my $self = shift;
    my $data = shift;
    $self->{from} = $data->{from} if($data->{from});

    my $template_file = $data->{template}->{file};
    if (!$template_file) {
        my $dir = 'Zera/' . $self->{Zera}->{ControllerName} . '/tmpl/';
        if(-e ($dir . $self->{Zera}->{sub_name} .'_email.html')){
            $template_file = $dir . $self->{Zera}->{sub_name} .'_email.html';
        }else{
            $self->{Zera}->add_msg('danger', 'Email template ' . $dir . $self->{Zera}->{sub_name} .'_email.html' .' not found.');
            return '0';
        }
    }

    $data->{msg} = $self->_render_template($template_file,$data->{vars});
    return $self->_send_full_html_message($data);
}

sub _render_template {
    my $self = shift;
    my $template = shift;
    my $vars = shift;
    my $HTML = "";

    my $tt = Zera::Com::template();
    $vars->{conf} = $conf;
    $tt->process($template, $vars, \$HTML) || die $tt->error(), "\n";
    return $HTML;
}

sub _send_full_html_message {
    my $self = shift;
    my $data = shift;
    $self->{from} = $data->{from} if($data->{from});

    $self->_transport();

    my $template_file = '';
    if($self->{Zera}->{_Layout} eq 'Public'){
        $template_file = 'templates/' . $conf->{Template}->{TemplateID} . '/layout_email.html';
    }elsif($self->{Zera}->{_Layout} eq 'User'){
        $template_file = 'templates/' . $conf->{Template}->{UserTemplateID} . '/layout_email.html';
    }elsif($self->{Zera}->{_Layout} eq 'Admin'){
        $template_file = 'templates/' . $conf->{Template}->{AdminTemplateID} . '/layout_email.html';
    }

    if(-e ($template_file)){

    }else{
        $self->{Zera}->add_msg('danger', 'Email template ' . $template_file .' not found.');
        die;
    }


    my $msg = $self->_render_template($template_file,{msg => $data->{msg}});

    my $MIMEMsg = MIME::Entity->build(
        From        => Encode::encode( 'MIME-Header', $conf->{Email}->{From} ),
        To          => Encode::encode( 'MIME-Header', 'romdav@xaandia.com'),#$data->{to} ),
        Subject     => Encode::encode( 'MIME-Header', $data->{subject}),
        Type        => 'multipart/alternative',
      );
    $MIMEMsg->attach(
        Type            => 'text/html; charset=UTF-8',
        Data            => [ '<html><body>' . $msg . '</body></html>' ],
    );
    my $sent = {};
    eval {

        #Disable warnings
        $main::SIG{__WARN__} = sub {};
        $main::SIG{__DIE__}  = sub {};

        # Send message
        $sent = sendmail($MIMEMsg, { transport => $self->{transport} });

        # Enable warnings
        $main::SIG{__WARN__} = \&Zera::Carp::die;
        $main::SIG{__DIE__}  = \&Zera::Carp::die;

    };

    if($sent->{message}){
    	return $sent->{message};
    }else{
    	return 1;
    }
}

1;
