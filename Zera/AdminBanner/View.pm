package Zera::AdminBanner::View;

use JSON;
use base 'Zera::BaseAdmin::View';

# Module Functions
sub display_home {
    my $self = shift;

    $self->set_title('Banner');
    $self->add_search_box();
    $self->set_add_btn('/AdminBanner/Edit/New', 'Banner');
    $self->set_add_btn('/AdminBanner/GroupEdit/New', 'Group');

    my $where = "e.module='Banner'";
    my @params;
    if($self->param('zl_q')){
        $where .= " AND name LIKE ? ";
        push(@params,'%' . $self->param('zl_q') .'%');
    }
    my $list = Zera::List->new($self->{Zera},{
        sql => {
            select => "banner_id, name, active",
            from =>"banners e",
            order_by => "",
            where => $where,
            params => \@params,
            limit => "30",
        },
        link => {
            key => "banner_id",
            hidde_key_col => 1,
            location => '/AdminBanner/Edit',
            transit_params => {},
        },
        debug => 1,
    });

    $list->get_data();
    $list->on_off('active');
    $list->columns_align(['left','left','center']);

    my $vars = {
        list => $list->print(),
    };

    return $self->render_template($vars);
}

sub display_edit {
    my $self = shift;
    my $values = {};
    my @submit = ("Save");

    $self->param('banner_id',$self->param('SubView')) if(!(defined $self->param('banner_id')));

    # Title
    ($self->param('SubView') eq 'New') ? $self->set_title('Add Banner') : $self->set_title('Edit Banner');

    # Helper buttons
    $self->add_btn('/AdminBanner','Back');

    # JS
    $self->add_jsfile('admin-blog');

    # Values
    if($self->param('banner_id') ne 'New'){
        $values = $self->selectrow_hashref("SELECT * FROM banners WHERE banner_id=? AND module='Banner'",{},$self->param('banner_id'));
        $values->{display_options} = decode_json($values->{display_options});
        push(@submit, 'Delete');
    }else{
        $values = {
            date => $self->selectrow_array('SELECT DATE(NOW())'),
            active => 1,
        };
    }

    # Form
    my $form = $self->form({
        method   => 'POST',
        fields   => [qw/group_id name media code active publish_from publish_to /],
        submits  => \@submit,
        values   => $values,
    });

    #$form->field('group_id',{type=>'hidden'});
    $form->field('group_id',{span=>'col-md-3', required=>1});
    $form->field('name',{span=>'col-md-9', required=>1});
    #$form->field('url',{span=>'col-md-6', required=>1, readonly=>1});
    #$form->field('keywords',{span=>'col-md-6', required=>1});
    $form->field('media', {type=>'file', accept=>"image/x-png,image/gif,image/jpeg"});
    $form->field('code',{span=>'col-md-12', type=>'textarea', rows=>10, class=>"form-control form-control-sm"});
    $form->field('publish_from',{class=>'form-control form-control-sm datepicker'});
    $form->field('publish_to',{class=>'form-control form-control-sm datepicker'});
    $form->field('active',{label=>"Publish", check_label=>'Yes / No', class=>"filled-in", type=>"checkbox"});

    if($values->{display_options}->{image}){
        $form->field('image', {help=>$self->get_image_options($values->{display_options}->{image})});
    }

    $form->submit('Delete',{class=>'btn btn-danger'});

    return $form->render();
}

sub display_groups {
    my $self = shift;

    $self->set_title('Banner Groups');
    $self->add_search_box();
    $self->set_add_btn('/AdminBanner/GroupEdit/New');

    my $where = "e.module='Banner'";
    my @params;
    if($self->param('zl_q')){
        $where .= " AND name LIKE ? ";
        push(@params,'%' . $self->param('zl_q') .'%');
    }
    my $list = Zera::List->new($self->{Zera},{
        sql => {
            select => "group_id, name, type",
            from =>"banners_groups e",
            order_by => "",
            where => $where,
            params => \@params,
            limit => "30",
        },
        link => {
            key => "group_id",
            hidde_key_col => 1,
            location => '/AdminBanner/GroupEdit',
            transit_params => {},
        },
        debug => 1,
    });

    $list->get_data();
    $list->on_off('active');
    $list->columns_align(['left','left','center']);

    my $vars = {
        list => $list->print(),
    };

    return $self->render_template($vars);
}

sub display_group_edit {
    my $self = shift;
    my $values = {};
    my @submit = ("Save");

    $self->param('group_id',$self->param('SubView')) if(!(defined $self->param('group_id')));

    # Title
    ($self->param('SubView') eq 'New') ? $self->set_title('Add Banner Group') : $self->set_title('Edit Banner Group');

    # Helper buttons
    $self->add_btn('/AdminBanner','Back');

    # JS
    $self->add_jsfile('admin-blog');

    # Values
    if($self->param('group_id') ne 'New'){
        $values = $self->selectrow_hashref("SELECT * FROM banners_groups WHERE group_id=? AND module='Banner'",{},$self->param('group_id'));
        $values->{display_options} = decode_json($values->{display_options});
        push(@submit, 'Delete');
    }else{
        $values = {
            date => $self->selectrow_array('SELECT DATE(NOW())'),
            active => 1,
        };
    }

    # Form
    my $form = $self->form({
        method   => 'POST',
        fields   => [qw/name type /],
        submits  => \@submit,
        values   => $values,
    });

    #$form->field('group_id',{span=>'col-md-3', required=>1});
    $form->field('name',{span=>'col-md-8', required=>1});
    $form->field('type',{span=>'col-md-4', required=>1});

    $form->submit('Delete',{class=>'btn btn-danger'});

    return $form->render();
}

1;
