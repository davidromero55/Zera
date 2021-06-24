package Zera::AdminBlog::Actions;

use strict;
use JSON;
use base 'Zera::BaseAdmin::Actions';

sub do_edit {
    my $self = shift;
    my $results = {};

    $self->param('entry_id',0) if($self->param('entry_id') eq 'New');

    if($self->param('_submit') eq 'Save'){
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

        my $display_options = {};
        my $image = $self->upload_file('image', 'img');
        if($image){
            $display_options->{image} = '/data/img/'.$image;
        }
        my $file = $self->upload_file('file', 'files');
        if($file){
            $self->param('content',$self->param('content') . '<p><a href="/data/files/' . $file . '" class="btn btn-primary" target="_blank">' . $file . '</a></p>');
        }

        eval {
            if(int($self->param('entry_id'))){
                # Update
                $self->dbh_do("UPDATE entries SET title=?, keywords=?, date=?, updated_by=?, updated_on=NOW(), active=?, description=?, content=?" .
                "WHERE entry_id=? AND module='Blog'",{},
                $self->param('title'), $self->param('keywords'), $self->param('date'), $self->{sess}{user_id},
                ($self->param('active') || 0), $self->param('description'), $self->param('content'),
                $self->param('entry_id'));
                if($image){
                    my $oldmedia = $self->selectrow_array("SELECT display_options FROM entries WHERE entry_id = ?", {}, $self->param('entry_id'));
                    $oldmedia = decode_json $oldmedia;
                    unlink $oldmedia->{image} if($oldmedia->{image});
                    $display_options->{image} = '/data/img/'.$image;
                    $self->dbh_do("UPDATE entries SET display_options=? WHERE entry_id = ?", {}, encode_json($display_options), $self->param('entry_id'));
                }
                $self->dbh_do("DELETE FROM entries_categories WHERE entry_id=?", {}, $self->param('entry_id'));
                $self->dbh_do("INSERT INTO entries_categories (category_id, entry_id, sort_order) VALUES (?, ?, 1)", {}, $self->param('category_id'), $self->param('entry_id'));
            }else{
                # INSERT
                if($image){
                    $display_options->{image} = '/data/img/'.$image;
                }
                $self->dbh_do("INSERT INTO entries (module, title, keywords, date, added_by, added_on, views, user_id, active, url, description, content, display_options) " .
                "VALUES ('Blog', ?,?,?,?,NOW(),?,?,?,?,?,?,?)",{},
                $self->param('title'), $self->param('keywords'), $self->param('date'), $self->{sess}{user_id}, 0, $self->{sess}{user_id},
                ($self->param('active') || 0), $self->param('url'), $self->param('description'), $self->param('content'), encode_json($display_options));
                $self->dbh_do("INSERT INTO entries_categories (category_id, entry_id, sort_order) VALUES (?, ?, 1)", {}, $self->param('category_id'), $self->last_insert_id("entries","entry_id"));
            }
        };
        if($@){
            $self->add_msg('warning','Error '.$@);
            $results->{error} = 1;
            return $results;
        }else{
            $results->{redirect} = '/AdminBlog';
            $results->{success} = 1;
            return $results;
        }
    }elsif($self->param('_submit') eq 'Delete'){
        eval {
            my $display_options_json = $self->selectrow_array("SELECT display_options FROM entries WHERE entry_id = ?",{},$self->param('entry_id'));
            my $display_options = decode_json($display_options_json);
            my $oldmedia = $display_options->{image} || '';
            unlink $oldmedia if($oldmedia);
            $self->dbh_do("DELETE FROM entries WHERE entry_id=? AND module='Blog'",{}, $self->param('entry_id'));
            $self->dbh_do("DELETE FROM entries_categories WHERE entry_id=?", {}, $self->param('entry_id'));
        };
        if($@){
            $self->add_msg('warning','Error '.$@);
            $results->{error} = 1;
            return $results;
        }else{
            $results->{redirect} = '/AdminBlog';
            $results->{success} = 1;
            return $results;
        }
    }
}

1;
