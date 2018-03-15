package Zera::Admin::View;

use Zera::Conf;
use base 'Zera::BaseAdmin::View';

# Module Functions
sub display_home {
    my $self = shift;
    
    $self->set_title('My account');
    my $user = $self->selectrow_hashref("SELECT user_id, name, email FROM users WHERE user_id=?",{},$self->sess('user_id'));

    my $vars = {
        user => $user,
    };
    return $self->render_template($vars);
}

sub display_login {
    my $self = shift;
    
    my @submit = (("Login"));
    my $form = $self->form({
        method   => 'POST',
        fields   => [qw/email password keep_me_in/],
        submit   => \@submit,
        template => 'templates/' . $conf->{Template}->{AdminTemplateID} . '/zera-login-form.html',
    });
    
    $form->field('email',{placeholder=> 'Correo Electrónico', type=>'email', maxlength=>"100", required=>"1", invalid_msg => 'Introduce un correo válido', validate=>'EMAIL'});
    $form->field('password',{placeholder=> 'Contraseña', maxlength=>"100", required=>"1",value=>"", override=>1, invalid_msg => 'Introduce una contraseña válida.', type=>"password"});
    $form->field('keep_me_in',{label=>"Keep me signed in", class=>"filled-in", override=>1, type=>"checkbox", value=>'1', checked=>'1'});

    return $form->render();
}

sub display_edit {
    my $self = shift;
    my $values = {};
    my @submit = ("Save");
    
    $self->set_title('Edit my account');

    # Helper buttons
    $self->add_btn('/Admin','Back');

    # Values
    $values = $self->selectrow_hashref("SELECT name, email FROM users WHERE user_id=?",{},$self->sess('user_id'));
    
    # Form
    my $form = $self->form({
        method   => 'POST',
        fields   => [qw/name email/],
        submits  => \@submit,
        values   => $values,
    });
    
    $form->field('name',{span=>'col-md-6', required=>1});
    $form->field('email',{span=>'col-md-6', readonly=>1});
    
    return $form->render();
}

sub display_password_update {
    my $self = shift;
    my $values = {};
    my @submit = ("Save");
    
    $self->set_title('Update my password');

    # Helper buttons
    $self->add_btn('/Admin','Back');
    
    # Form
    my $form = $self->form({
        method   => 'POST',
        fields   => [qw/current_password new_password new_password_confirm/],
        submits  => \@submit,
        values   => $values,
    });
    
    $form->field('current_password',{type=>'password',span=>'col-md-12', required=>1});
    $form->field('new_password',{type=>'password',span=>'col-md-6', required=>1});
    $form->field('new_password_confirm',{type=>'password',span=>'col-md-6', required=>1, label=>'Confirm the new password'});
    
    return $form->render();
}

1;
