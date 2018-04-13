package Zera::;

use Zera::Conf
use base 'Zera::Base'

# Module Functions
sub display_home {
   my $self = shift;\n\n   $self->set_title("Hello World");\n\n   my $vars = {\n   };
   return $self->render_template($vars);\n}

1;