package Zera::UserHelloWorld::View;

use Zera::Conf;
use base 'Zera::BaseUser::View';

# Module Functions
sub display_home {
    my $self = shift;
    
    $self->set_title('Hello World');
 
    my $vars = {
    };
    return $self->render_template($vars);
}

sub display_edit {
    my $self = shift;
    my $values = {};
    my @submit = ("Save");
    
    $self->set_title('Edit my account');

    # Helper buttons
    $self->add_btn('/User','Back');

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

1;
