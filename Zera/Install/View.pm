package Zera::Install::View;

use Zera::Conf;
use base 'Zera::Install::BaseView';

# Module Functions
sub display_home {
   my $self = shift;
   $self->set_title("Hello World");

   my $vars = {};
   return $self->render_template($vars);
}

sub display_user {
    my $self = shift;
    my $values = $self->{Zera}->{_CONF}->{User};
    my @submit = ("Next");

    # Title
    $self->set_title('User settings');
    $self->add_btn('/Zera/Install/install.pl','Back');

    # Form
    my $form = $self->form({
        action   => 'install.pl?View=User',
        method   => 'POST',
        fields   => [qw/Name Email/],
        submits  => \@submit,
        values   => $values,
    });

    $form->field('Name',{span=>'col-md-12', required=>1, required=>1});
    $form->field('Email',{span=>'col-md-12', required=>1, type=>'EMAIL', required=>1});
    $form->submit('Next',{class=>'btn btn-primary'});

    return $form->render();
}

sub display_database {
    my $self = shift;
    my $values = $self->{Zera}->{_CONF}->{Database};
    my @submit = ("Next");

    # Title
    $self->set_title('Mysql database settings');
    $self->add_btn('/Zera/Install/install.pl?View=User','Back');

    # Form
    my $form = $self->form({
        action   => 'install.pl?View=Database',
        method   => 'POST',
        fields   => [qw/Host Port Database Username Password Timezone/],
        submits  => \@submit,
        values   => $values,
    });


    $form->field('Host',{span=>'col-md-6', label=>'Server host',placeholder=>'localhost'});
    $form->field('Port',{span=>'col-md-6', label=>'Port number',placeholder=>'3306'});
    $form->field('Database',{span=>'col-md-12', required=>1, label=>'Database name'});
    $form->field('Username',{span=>'col-md-6', required=>1, label=>'Username'});
    $form->field('Password',{span=>'col-md-6', required=>1, label=>'Password', type=>'password'});
    $form->field('Timezone',{span=>'col-md-6', required=>1, type=>'select',
        options=>['-11:00','-10:00','-09:00','-08:00','-07:00','-06:00','-05:00','-04:00','-03:00','-02:00','-01:00','00:00',
            '01:00','02:00','03:00','04:00','05:00','06:00','07:00','08:00','09:00','10:00','11:00','12:00']});
    $form->field('Language', {span=>'col-md-6', required=>1, type=>'select',  options=>['en_US', 'es_MX'], labels=>{'en_US'=>'English', 'es_MX'=>'Español'}});
    $form->submit('Next',{class=>'btn btn-primary'});

    return $form->render();
}

sub display_website {
    my $self = shift;
    my $values = $self->{Zera}->{_CONF}->{Website};
    my @submit = ("Next");

    if(!$values->{URL}){
        $values->{URL} = $ENV{HTTP_HOST};
    }

    # Title
    $self->set_title('Website settings');
    $self->add_btn('/Zera/Install/install.pl?View=Database','Back');

    # Form
    my $form = $self->form({
        action   => 'install.pl?View=Website',
        method   => 'POST',
        fields   => [qw/Name URL/],
        submits  => \@submit,
        values   => $values,
    });

    $form->field('Name',{span=>'col-md-12', required=>1, label=>'Website name'});
    $form->field('URL',{span=>'col-md-12', required=>1, label=>'Domain name'});
    $form->submit('Next',{class=>'btn btn-primary'});

    return $form->render();
}

sub display_confirm {
    my $self = shift;
    my $values = $self->{Zera}->{_CONF}->{Website};
    my @submit = ("Confirm");

    # Title
    $self->set_title('Confirm your settings');
    $self->add_btn('/Zera/Install/install.pl?View=Website','Back');

    # Form
    my $form = $self->form({
        action   => 'install.pl?View=Confirm',
        method   => 'POST',
        fields   => [qw//],
        submits  => \@submit,
        values   => $values,
        template => 'zera_confirm_installation_form'
    });

    return $form->render({install => $self->{Zera}->{_CONF}});
}

sub display_clean {
    my $self = shift;
    my $values = $self->{Zera}->{_CONF}->{Website};
    my @submit = ("Clean");

    # Title
    $self->set_title('Your installation is ready');

    # Form
    my $form = $self->form({
        action   => 'install.pl?View=Clean',
        method   => 'POST',
        fields   => [qw//],
        submits  => \@submit,
        values   => $values,
        template => 'zera_clean_installation_form'
    });

    return $form->render({install => $self->{Zera}->{_CONF}});
}

1;
