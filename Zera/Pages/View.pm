package Zera::Pages::View;

use JSON;
use base 'Zera::Base::View';

sub display_item {
    my $self = shift;
       
    # Entry
    my $entry = $self->{dbh}->selectrow_hashref(
        "SELECT entry_id, url, title, description, keywords, display_options, DATE(e.date) AS date, content " .
        "FROM entries e WHERE url=? AND module='Pages' AND active=1 ORDER BY e.date DESC",{Slice=>{}}, $self->param('SubView'));
    $entry->{display_options} = decode_json($entry->{display_options});
    
    $self->set_title($entry->{title});
    
    my $vars = {
        entry => $entry,
    };
    
    return $self->render_template($vars);
}

1;