package Zera::Banner::View;

use JSON;
use base 'Zera::Base::View';

# Overwrite get_view
sub get_view {
    my $self = shift;
    my $sub_name = $self->param('View');
    return $self->display_doc();
}

sub display_home {
    my $self = shift;

    return $self->display_doc();;
}

sub display_doc {
    my $self = shift;
    my $parent_url   = $self->param('View') || '';
    my $category_url = $self->param('SubView') || '';
    my $entry_url    = $self->param('UrlId') || '';

    my $entry;
    my $childs;
    my $current_category = {};

    if($entry_url){
        $entry = $self->selectrow_hashref(
            "SELECT entry_id, url, title, description, keywords, display_options, DATE(e.date) AS date, content " .
            "FROM entries e WHERE url=? AND module='Docs' AND active=1 ORDER BY e.date DESC",{Slice=>{}}, $entry_url);
        eval {
            $entry->{display_options} = decode_json($entry->{display_options});
        };
    }elsif($category_url){
        $current_category = $self->selectrow_hashref("SELECT category_id, category, url, parent_id, description FROM categories WHERE url=? AND module='Docs'",{},$category_url);
        $childs = $self->selectall_arrayref(
            "SELECT e.entry_id, e.url, e.title, e.description " .
            "FROM entries e " .
            "INNER JOIN entries_categories ec ON e.entry_id=ec.entry_id " .
            "WHERE ec.category_id=? AND e.module='Docs' AND e.active=1 ORDER BY ec.sort_order",{Slice=>{}}, $current_category->{category_id});
    }elsif($parent_url){
        $current_category = $self->selectrow_hashref("SELECT category_id, category, url, parent_id, description FROM categories WHERE url=? AND module='Docs'",{},$parent_url);
        $childs = $self->selectall_arrayref("SELECT category_id, category, url, description FROM categories WHERE parent_id=? AND module='Docs'",{Slice=>{}},$current_category->{category_id});
    }else{
        $childs = $self->selectall_arrayref("SELECT category_id, category, url, description FROM categories WHERE parent_id=0 AND module='Docs'",{Slice=>{}});
    }

    my $categories = $self->_get_categories_tree($entry->{entry_id});
    $self->set_title($entry->{title});

    my $vars = {
        entry      => $entry,
        categories => $categories,
        childs     => $childs,
        current_category => $current_category,
        parent_url       => $parent_url,
        category_url     => $category_url,

    };

    return $self->render_template($vars,'display_doc');
}

sub _get_categories_tree {
    my $self = shift;
    my $entry_id = shift;
    my $parent_url   = $self->param('View') || '';
    my $category_url = $self->param('SubView') || '';
    my $entry_url    = $self->param('UrlId') || '';

    my $categories = $self->selectall_arrayref("SELECT category_id, category, url, 0 AS active FROM categories WHERE parent_id=0 AND module='Docs'",{Slice=>{}});
    foreach my $category (@$categories){
        if($category->{url} eq $parent_url){
            $category->{active} = 1;
            $category->{childs} = $self->selectall_arrayref("SELECT category_id, category, url, 0 AS active FROM categories WHERE parent_id=? AND module='Docs'",{Slice=>{}},$category->{category_id});
            foreach my $sub_category (@{$category->{childs}}){
                if($sub_category->{url} eq $category_url){
                    $sub_category->{active} = 1;
                    if($entry_url){
                        $sub_category->{childs} = $self->selectall_arrayref(
                            "SELECT e.entry_id, e.url, e.title " .
                            "FROM entries e " .
                            "INNER JOIN entries_categories ec ON e.entry_id=ec.entry_id " .
                            "WHERE ec.category_id=? AND e.module='Docs' AND e.active=1 ORDER BY ec.sort_order",{Slice=>{}}, $sub_category->{category_id});
                        foreach my $entry (@{$sub_category->{childs}}){
                            if($entry->{url} eq $entry_url){
                                $entry->{active} = 1;
                            }
                        }
                    }
                }
            }
        }
    }
    return $categories;
}

1;
