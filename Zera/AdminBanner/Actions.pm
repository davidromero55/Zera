package Zera::AdminBanner::Actions;

use strict;
use JSON;
use base 'Zera::BaseAdmin::Actions';

sub do_edit {
    my $self = shift;
    my $results = {};

    $self->param('banner_id',0) if($self->param('banner_id') eq 'New');

    if($self->param('_submit') eq 'Save'){
        # Prevent URL duplicates
        my $exist = $self->selectrow_array(
            "SELECT COUNT(*) FROM banners WHERE name=? AND banner_id<>?",{},$self->param('name'), int($self->param('banner_id'))) || 0;
        if($exist){
            my $base_name = $self->param('name');
            for (my $i = 1; $i < 1000; $i++){
                $self->param('name',$base_name . '-'.$i);
                $exist = $self->selectrow_array(
                    "SELECT COUNT(*) FROM banners WHERE name=? AND banner_id<>?",{},$self->param('name'), int($self->param('banner_id'))) || 0;
                last if ($exist == 0);
            }
        }

        my $display_options = {};
        my $image = $self->upload_file('image', 'img');
        if($image){
            $display_options->{image} = '/data/img/'.$image;
        }

        eval {
            if(int($self->param('banner_id'))){
                # Update
                $self->dbh_do("UPDATE banners SET name=?, media=?, code=?, active=?, publish_from=?, publish_to=? " .
                                 "WHERE banner_id=? AND module='Banner'",{},
                                 $self->param('name'), $self->param('media'), $self->param('code'), ($self->param('active') || 0), $self->param('publish_from'), $self->param('publish_to'));
            }else{
                # Insert
                $self->dbh_do("INSERT INTO banners (group_id, name, media, code, active, publish_from, publish_to) " .
                                 "VALUES (?,?,?,?,?,?,?)",{},
                                 $self->param('group_id'), $self->param('name'), $self->param('media'), $self->param('code'), ($self->param('active') || 0), $self->param('publish_from'), $self->param('publish_to'));
            }
        };
        if($@){
            $self->add_msg('warning','Error '.$@);
            $results->{error} = 1;
            return $results;
        }else{
            $results->{redirect} = '/AdminBanner';
            $results->{success} = 1;
            return $results;
        }
    }elsif($self->param('_submit') eq 'Delete'){
        eval {
            $self->dbh_do("DELETE FROM banners WHERE banner_id=? AND module='Banner'",{},
                             $self->param('banner_id'));
        };
        if($@){
            $self->add_msg('warning','Error '.$@);
            $results->{error} = 1;
            return $results;
        }else{
            $results->{redirect} = '/AdminBanner';
            $results->{success} = 1;
            return $results;
        }

    }

}

sub do_group_edit {
    my $self = shift;
    my $results = {};

    $self->param('group_id',0) if($self->param('group_id') eq 'New');

    if($self->param('_submit') eq 'Save'){
        # Prevent URL duplicates
        my $exist = $self->selectrow_array(
            "SELECT COUNT(*) FROM banners_groups WHERE name=? AND group_id<>?",{},$self->param('name'), int($self->param('group_id'))) || 0;
        if($exist){
            my $base_name = $self->param('name');
            for (my $i = 1; $i < 1000; $i++){
                $self->param('name',$base_name . '-'.$i);
                $exist = $self->selectrow_array(
                    "SELECT COUNT(*) FROM banners_groups WHERE name=? AND group_id<>?",{},$self->param('name'), int($self->param('group_id'))) || 0;
                last if ($exist == 0);
            }
        }

        my $display_options = {};

        eval {
            if(int($self->param('group_id'))){
                # Update
                $self->dbh_do("UPDATE banners_groups SET name=?, type=? " .
                                 "WHERE group_id=? AND module='Banner'",{},
                                 $self->param('name'), $self->param('type'));
            }else{
                # Insert
                $self->dbh_do("INSERT INTO banners_groups (name, group_type) " .
                                 "VALUES (?,?)",{},
                                 $self->param('name'), $self->param('type'));
            }
        };
        if($@){
            $self->add_msg('warning','Error '.$@);
            $results->{error} = 1;
            return $results;
        }else{
            $results->{redirect} = '/AdminBanner';
            $results->{success} = 1;
            return $results;
        }
    }elsif($self->param('_submit') eq 'Delete'){
        eval {
            $self->dbh_do("DELETE FROM banners_groups WHERE group_id=? AND module='Banner'",{},
                             $self->param('group_id'));
        };
        if($@){
            $self->add_msg('warning','Error '.$@);
            $results->{error} = 1;
            return $results;
        }else{
            $results->{redirect} = '/AdminBanner';
            $results->{success} = 1;
            return $results;
        }

    }

}

1;
