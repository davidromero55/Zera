package Zera::AdminDeveloper::View;

use Zera::Conf;

use base 'Zera::BaseAdmin::View';

# Module Functions
sub display_home {
    my $self = shift;
    my @options = ('Admin', 'User', 'Public');
    my @submit = ("Save");
    
    $self->set_title('Developer Options');
    my $user = $self->selectrow_hashref("SELECT user_id, name, email FROM users WHERE user_id=?",{},$self->sess('user_id'));

    my $form = $self->form({
        method   => 'POST',
        fields   => [qw/type name on_menu/],
        submits  => \@submit,
        values   => $values,
    });
    
    $form->field('_Action',{type => 'hidden', value => 'home'});
    $form->field('type',{type => 'select', label => 'Module Type', span => 'col-12', options=> \@options, required => 1});
    $form->field('name',{span => 'col-12', label => 'Module Name', required => 1});
    $form->field('on_menu',{label=>"Add to Menu", check_label=>'Yes / No', class=>"filled-in", type=>"checkbox"});
    
    
    my $vars = {
        user => $user,
        add_module_form => $form->render()
    };

    return $self->render_template($vars);
}

1;