package Zera::UserDashboard::View;

use base 'Zera::BaseUser::View';

# Module Functions
sub display_home {
    my $self = shift;

    my $vars = {
        foo => 'bar'
    };
    return $self->render_template($vars);
}

1;