package Zera::AdminDashboard::View;

use base 'Zera::BaseAdmin::View';

# Module Functions
sub display_home {
    my $self = shift;

    my $vars = {
        foo => 'bar'
    };
    return $self->render_template($vars);
}

1;