package Zera::Blog::Cron;

use Zera::Conf;
use base 'Zera::Base::Cron';

# Module Functions
sub exec_test {
    my $self = shift;

    print "\nExecuting Test\n\n" if($self->debug());
}

1;
