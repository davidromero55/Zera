package Zera::AdminDocs::Actions;

use strict;

use base 'Zera::BaseAdmin::Actions';

sub do_edit {
    my $self = shift;
    my $results = {};

    if($self->param('_submit') eq 'Save'){
        my $entry_id = $self->param('entry_id') || '0';
        $entry_id =~ s/\D//g;
        $self->param('entry_id',$entry_id);

        # Prevent URL duplicates
        my $exist = $self->selectrow_array(
            "SELECT COUNT(*) FROM entries WHERE url=? AND entry_id<>?",{},$self->param('url'), int($self->param('entry_id'))) || 0;
        if($exist){
            my $base_url = $self->param('url');
            for (my $i = 1; $i < 1000; $i++){
                $self->param('url',$base_url . '-'.$i);
                $exist = $self->selectrow_array(
                    "SELECT COUNT(*) FROM entries WHERE url=? AND entry_id<>?",{},$self->param('url'), int($self->param('entry_id'))) || 0;
                last if ($exist == 0);
            }
        }

        eval {
            if(int($self->param('entry_id'))){
                # Update
                $self->dbh_do("UPDATE entries SET title=?, keywords=?, date=?, updated_by=?, updated_on=NOW(), active=?, description=?, content=?, display_options=? " .
                                 "WHERE entry_id=? AND module='Docs'",{},
                                 $self->param('title'), $self->param('keywords'), $self->param('date'), $self->{sess}{user_id},
                                 ($self->param('active') || 0), $self->param('description'), $self->param('content'), '{}',
                                 $self->param('entry_id'));
            }else{
                # Insert
                $self->dbh_do("INSERT INTO entries (module, title, keywords, date, added_by, added_on, views, user_id, active, url, description, content, display_options) " .
                                 "VALUES ('Docs', ?,?,?,?,NOW(),?,?,?,?,?,?,?)",{},
                                 $self->param('title'), $self->param('keywords'), $self->param('date'), $self->{sess}{user_id}, 0, $self->{sess}{user_id},
                                 ($self->param('active') || 0), $self->param('url'), $self->param('description'), $self->param('content'), '{}');
                $self->param('entry_id', $self->last_insert_id("entries","entry_id"));
            }

            # category_id
            $self->dbh_do("DELETE FROM entries_categories WHERE entry_id=?",{},$self->param('entry_id'));
            $self->dbh_do("INSERT IGNORE INTO entries_categories (entry_id, category_id, sort_order) VALUES(?,?,?)",
                {},$self->param('entry_id'), $self->param('category_id'), 9999);
        };
        if($@){
            $self->add_msg('warning','Error '.$@);
            $results->{error} = 1;
            return $results;
        }else{
            $results->{redirect} = '/AdminDocs?category_id='.$self->param('category_id');
            $results->{success} = 1;
            return $results;
        }
    }elsif($self->param('_submit') eq 'Delete'){
        eval {
            $self->dbh_do("DELETE FROM entries WHERE entry_id=? AND module='Docs'",{},$self->param('entry_id'));
            $self->dbh_do("DELETE FROM entries_categories WHERE entry_id=?",{},$self->param('entry_id'));
        };
        if($@){
            $self->add_msg('warning','Error '.$@);
            $results->{error} = 1;
            return $results;
        }else{
            $results->{redirect} = '/AdminDocs?category_id='.$self->param('category_id');
            $results->{success} = 1;
            return $results;
        }

    }

}

sub do_edit_category {
    my $self = shift;
    my $results = {};


    if($self->param('_submit') eq 'Save'){
        my $category_id = $self->param('category_id') || '0';
        $category_id =~ s/\D//g;
        $self->param('category_id',$category_id);
        my $parent_id = $self->param('parent_id') || '0';
        $parent_id =~ s/\D//g;
        $self->param('parent_id',($parent_id || 0));

        # Prevent URL duplicates
        my $exist = $self->selectrow_array(
            "SELECT COUNT(*) FROM categories WHERE url=? AND parent_id<>? AND category_id<>?",{},
            $self->param('url'), int($self->param('parent_id')),int($self->param('category_id'))) || 0;
        if($exist){
            my $base_url = $self->param('url');
            for (my $i = 1; $i < 1000; $i++){
                $self->param('url',$base_url . ''.$i);
                $exist = $self->selectrow_array(
                    "SELECT COUNT(*) FROM categories WHERE url=? AND parent_id<>? AND category_id<>?",{},
                    $self->param('url'), int($self->param('parent_id')), int($self->param('category_id'))) || 0;
                last if ($exist == 0);
            }
        }

        eval {
            if(int($self->param('category_id'))){
                # Update
                $self->dbh_do("UPDATE categories SET parent_id=?, category=?, url=?, description=?, active=? " .
                                 "WHERE category_id=? AND module='Docs'",{},
                                 $self->param('parent_id'), $self->param('category'),  $self->param('url'), $self->param('description'),
                                 ($self->param('active') || 0), $self->param('category_id'));
            }else{
                # Insert
                $self->dbh_do("INSERT INTO categories (module, parent_id, category, url, description, active, sort_order) " .
                                 "VALUES ('Docs', ?,?,?,?,?,999999)",{},
                                 $self->param('parent_id'), $self->param('category'), $self->param('url'),
                                 $self->param('description'),($self->param('active') || 0));
            }
        };
        if($@){
            $self->add_msg('warning','Error '.$@);
            $results->{error} = 1;
            return $results;
        }else{
            $results->{redirect} = '/AdminDocs?parent_id='.$self->param('parent_id');
            $results->{success} = 1;
            return $results;
        }
    }elsif($self->param('_submit') eq 'Delete'){

        # Validate Childs

        eval {
            $self->dbh_do("DELETE FROM categories WHERE category_id=? AND module='Docs'",{},
                             $self->param('category_id'));
        };
        if($@){
            $self->add_msg('warning','Error '.$@);
            $results->{error} = 1;
            return $results;
        }else{
            $results->{redirect} = '/AdminDocs?parent_id='.$self->param('parent_id');
            $results->{success} = 1;
            return $results;
        }

    }

}

1;
