package Zera::Static::View;

use JSON;
use base 'Zera::Base::View';
use Zera::Conf;

sub display_item {
    my $self = shift;
    my $file_name = $self->_get_file_name();
    my $vars = {

    };

    return $self->render_template($vars,$file_name);
}

sub _get_file_name {
    my $self = shift;
    my $file_name = $self->param('SubView');
    $file_name =~ s/\W!-//g;
    $file_name = lc($file_name);
    if (-e ('templates/'.$conf->{Template}->{TemplateID}.'/static/'.$file_name . '.html')) {
        return 'templates/'.$conf->{Template}->{TemplateID}.'/static/'.$file_name . '.html'
    }elsif (-e ('static/'.$file_name . '.html')) {
        return 'static/'.$file_name . '.html';
    }
}

1;
