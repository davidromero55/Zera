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
        
        eval {
            if(int($self->param('entry_id'))){
                # Update
                $self->dbh_do("UPDATE entries SET title=?, keywords=?, date=?, updated_by=?, updated_on=NOW(), active=?, description=?, content=?, display_options=? " .
                                 "WHERE entry_id=? AND module='Blog'",{},
                                 $self->param('title'), $self->param('keywords'), $self->param('date'), $self->{sess}{user_id},
                                 ($self->param('active') || 0), $self->param('description'), $self->param('content'), encode_json($display_options),
                                 $self->param('entry_id'));
            }else{
                # Insert
                $self->dbh_do("INSERT INTO entries (module, title, keywords, date, added_by, added_on, views, user_id, active, url, description, content, display_options) " .
                                 "VALUES ('Blog', ?,?,?,?,NOW(),?,?,?,?,?,?,?)",{},
                                 $self->param('title'), $self->param('keywords'), $self->param('date'), $self->{sess}{user_id}, 0, $self->{sess}{user_id},
                                 ($self->param('active') || 0), $self->param('url'), $self->param('description'), $self->param('content'), encode_json($display_options));
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
            $self->dbh_do("DELETE FROM entries WHERE entry_id=? AND module='Blog'",{},
                             $self->param('entry_id'));
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
