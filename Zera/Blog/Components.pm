package Zera::Blog::Components;

use base 'Zera::Base::Components';
use JSON;

sub component_latest {
    my $self = shift;
    my $limit = shift;
    my $latest = $self->selectall_arrayref("SELECT SQL_CACHE entry_id, title, date, url, description, display_options ".
    "FROM entries e WHERE e.module='Blog' ORDER BY e.date DESC limit ?",{Slice=>{}}, $limit);
    foreach my $entry (@$latest){
        $entry->{display_options} = decode_json($entry->{display_options});
    }
    my $vars = {
        latest  => $latest,
    };

    return $self->render_template($vars);
}

sub component_footer {
    my $self = shift;
    my $limit = shift;
    my $latest = $self->selectall_arrayref("SELECT SQL_CACHE entry_id, title, date, url FROM entries NATURAL JOIN entries_categories WHERE active=1 AND category_id=1 ORDER BY date DESC limit ?",{Slice=>{}}, $limit);
    my $vars = {
        latest  => $latest,
    };

    return $self->render_template($vars);
}
1;
