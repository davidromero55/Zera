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
        template => 'zera_login_form',
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

sub display_forgot_password {
    my $self = shift;
    my $sub_view = $self->param('SubView') || "";

    if(length($sub_view) > 10){
        # If there are a key check if is valid.
        my $key = substr($sub_view,0,64);
        my $user_id = substr($sub_view,64,65);

        my $user = $self->selectrow_hashref(
            "SELECT user_id, name, email FROM users WHERE user_id=? AND password_recovery_key=? AND password_recovery_expires > NOW() AND is_admin = 1",
            {}, $user_id, $key);
        if($user->{user_id}){
            return $self->_display_password_recovery($user);
        }else{
            $self->add_msg('danger','Your key is not valid, please try again.');
        }
    }

    $self->set_title('Password recovery');

    my @submit = ("Next");
    my $form = $self->form({
        method   => 'POST',
        fields   => [qw/email/],
        submits  => \@submit,
        template => '/zera_form_out',
    });

    $form->field('email',{placeholder=> 'Email', type=>'email', maxlength=>"100", required=>"1", invalid_msg => 'Enter a valid email address.', validate=>'EMAIL'});

    $form->submit('Next',{});
    return $form->render();
}

sub _display_password_recovery {
    my $self = shift;
    my $user = shift;

    $self->set_title('Password recovery');

    my @submit = ("Save");
    my $form = $self->form({
        method   => 'POST',
        fields   => [qw/email new_password new_password_confirm/],
        submits  => \@submit,
        template => 'zera_form_out',
    });

    $form->field('email',{placeholder=> 'Email', readonly=>1, value=>$user->{email}, type=>'email', maxlength=>"100", required=>"1", invalid_msg => 'Enter a valid email address.', validate=>'EMAIL'});
    $form->field('new_password',{placeholder=> 'New password', type=>'password', maxlength=>"15", required=>"1", invalid_msg => 'Enter a password.',
        help => 'Enter your new password.'});
    $form->field('new_password_confirm',{placeholder=> 'Confirm the new password', type=>'password', maxlength=>"15", required=>"1", invalid_msg => 'Enter a password.',
        help => ''});

    $form->submit('Save',{});
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
