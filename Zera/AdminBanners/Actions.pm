package Zera::AdminBanners::Actions;

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
        my $image = $self->upload_file('media', 'img');
        if($image){
            $display_options->{image} = '/data/img/'.$image;
        }

        eval {
            if(int($self->param('banner_id'))){
                # Update
                $self->dbh_do("UPDATE banners SET name=?, url=?, code=?, active=?, publish_from=?, publish_to=?, sort_order=? " .
                                 "WHERE banner_id=?",{},
                                 $self->param('name'), $self->param('url'), $self->param('code'), ($self->param('active') || 0), $self->param('publish_from'), $self->param('publish_to'), $self->param('sort_order'), $self->param('banner_id'));
               if($image){
                 my $oldimage = $self->selectrow_hashref("SELECT media FROM banners WHERE banner_id = ?", {}, $self->param('banner_id'));
                 $self->add_msg("info", $oldimage->{media});
                 unlink "data/img/$oldimage->{media}" if($oldimage->{media});
                 $self->dbh_do("UPDATE banners SET media=? " .
                                  "WHERE banner_id=?",{},
                                  $image, $self->param('banner_id'));
               }
            }else{
                # Insert
                $self->dbh_do("INSERT INTO banners (group_id, name, url, media, code, active, publish_from, publish_to, sort_order) " .
                                 "VALUES (?,?,?,?,?,?,?,?,?)",{},
                                 $self->param('group_id'), $self->param('name'), $self->param('url'), $image, $self->param('code'), ($self->param('active') || 0), $self->param('publish_from'), $self->param('publish_to'), $self->param('sort_order'));
            }
        };
        if($@){
            $self->add_msg('warning','Error '.$@);
            $results->{error} = 1;
            return $results;
        }else{
            $results->{redirect} = '/AdminBanners';
            $results->{success} = 1;
            return $results;
        }
    }elsif($self->param('_submit') eq 'Delete'){
        eval {
            my $oldimage = $self->selectrow_hashref("SELECT media FROM banners WHERE banner_id = ?", {}, $self->param('banner_id'));
            $self->add_msg("info", $oldimage->{media});
            unlink "data/img/$oldimage->{media}" if($oldimage->{media});
            $self->dbh_do("DELETE FROM banners WHERE banner_id=?",{},
                             $self->param('banner_id'));
        };
        if($@){
            $self->add_msg('warning','Error '.$@);
            $results->{error} = 1;
            return $results;
        }else{
            $results->{redirect} = '/AdminBanners';
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
                $self->dbh_do("UPDATE banners_groups SET name=?, group_type=? " .
                                 "WHERE group_id=?",{},
                                 $self->param('name'), $self->param('group_type'));
            }else{
                # Insert
                $self->dbh_do("INSERT INTO banners_groups (name, group_type) " .
                                 "VALUES (?,?)",{},
                                 $self->param('name'), $self->param('group_type'));
            }
        };
        if($@){
            $self->add_msg('warning','Error '.$@);
            $results->{error} = 1;
            return $results;
        }else{
            $results->{redirect} = '/AdminBanners';
            $results->{success} = 1;
            return $results;
        }
    }elsif($self->param('_submit') eq 'Delete'){
        eval {
            $self->dbh_do("DELETE FROM banners_groups WHERE group_id=?",{},
                             $self->param('group_id'));
        };
        if($@){
            $self->add_msg('warning','Error '.$@);
            $results->{error} = 1;
            return $results;
        }else{
            $results->{redirect} = '/AdminBanners';
            $results->{success} = 1;
            return $results;
        }

    }

}

1;
