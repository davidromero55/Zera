package Zera::Admin::View;

use Zera::Conf;
use base 'Zera::BaseAdmin::View';

# Module Functions
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

1;
