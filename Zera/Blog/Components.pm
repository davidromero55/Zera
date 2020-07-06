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

sub component_entries_by_category {
    my $self = shift;
    my $category_id = shift;
    my $limit = shift;
    my $entries = $self->selectall_arrayref("SELECT SQL_CACHE e.entry_id, e.title, e.date, e.url, e.description, e.display_options ".
    "FROM entries e " .
    "INNER JOIN entries_categories ec ON e.entry_id=ec.entry_id " .
    "WHERE e.module='Blog' AND ec.category_id=? ORDER BY e.date DESC limit ?",{Slice=>{}}, $category_id, $limit);
    foreach my $entry (@$entries){
        $entry->{display_options} = decode_json($entry->{display_options});
    }
    my $vars = {
        entries  => $entries,
    };

    return $self->render_template($vars);
}

sub component_categories {
    my $self = shift;
    my $limit = shift;
    my $categories = $self->selectall_arrayref("SELECT SQL_CACHE c.category_id, c.category, c.url ".
        "FROM categories c WHERE c.module='Blog' AND c.parent_id=0 ORDER BY c.sort_order LIMIT 15",{Slice=>{}});
    my $vars = {
        categories  => $categories,
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
