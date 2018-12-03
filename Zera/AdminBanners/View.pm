package Zera::AdminBanners::View;

use JSON;
use base 'Zera::BaseAdmin::View';

# Module Functions
sub display_home {
    my $self = shift;

    $self->set_title('Banners');
    $self->add_search_box();
    $self->set_add_btn('/AdminBanners/Edit/New', 'Add');
    $self->add_btn('/AdminBanners/Groups', 'Groups');

    my $where;
    my @params;
    if($self->param('zl_q')){
        $where .= " name LIKE ? ";
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
            location => '/AdminBanners/Edit',
            transit_params => {},
        },
        debug => 1,
    });

    $list->get_data();
    $list->on_off('active');
    $list->columns_align(['left','left','center']);

    return $list->render();
}

sub display_edit {
    my $self = shift;
    my $values = {};
    my @submit = ("Save");

    $self->param('banner_id',$self->param('SubView')) if(!($self->param('banner_id')));

    # Title
    ($self->param('SubView') eq 'New') ? $self->set_title('Add Banner') : $self->set_title('Edit Banner');

    # Helper buttons
    $self->add_btn('/AdminBanners','Back');

    # Values
    if($self->param('banner_id') ne 'New'){
        $values = $self->selectrow_hashref("SELECT * FROM banners WHERE banner_id=?",{},$self->param('banner_id'));
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
        fields   => [qw/banner_id group_id name url media code publish_from publish_to active sort_order/],
        submits  => \@submit,
        values   => $values,
    });

    my %groups = $self->selectbox_data("SELECT group_id, name FROM banners_groups");
    $form->field('banner_id',{type=>'hidden'});
    $form->field('group_id',{placeholder=> 'Group', span=>'col-md-3', label=> 'Group', type=>'select', selectname => 'Select a group', options => $groups{values}, labels => $groups{labels}, required=>1});
    $form->field('name',{span=>'col-md-9', required=>1});
    $form->field('url',{span=>'col-6'});
    $form->field('media', {type=>'file', accept=>"image/x-png,image/gif,image/jpeg", span=>'col-6'});
    $form->field('code',{span=>'col-md-12', type=>'textarea', rows=>10, class=>"form-control form-control-sm"});
    $form->field('publish_from',{class=>'form-control form-control-sm datepicker'});
    $form->field('publish_to',{class=>'form-control form-control-sm datepicker'});
    $form->field('active',{label=>"Publish", span=>'col-md-1', check_label=>'Yes / No', class=>"filled-in", type=>"checkbox"});
    $form->field('sort_order', {label=>'Orden', span=>'col-md-5'});

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
    $self->set_add_btn('/AdminBanners/GroupEdit/New');
    $self->add_btn('/AdminBanners','Back to banners');

    my $where;
    my @params;
    if($self->param('zl_q')){
        $where .= " name LIKE ? ";
        push(@params,'%' . $self->param('zl_q') .'%');
    }
    my $list = Zera::List->new($self->{Zera},{
        sql => {
            select => "group_id, name, group_type ",
            from =>"banners_groups e",
            order_by => "",
            where => $where,
            params => \@params,
            limit => "30",
        },
        link => {
            key => "group_id",
            hidde_key_col => 0,
            location => '/AdminBanners/GroupEdit',
            transit_params => {},
        },
        debug => 1,
    });

    $list->get_data();
    $list->on_off('active');
    $list->columns_align(['left','left','center']);

    return $list->render();
}

sub display_group_edit {
    my $self = shift;
    my $values = {};
    my @submit = ("Save");

    $self->param('group_id',$self->param('SubView')) if(!($self->param('group_id')));

    # Title
    ($self->param('SubView') eq 'New') ? $self->set_title('Add Banner Group') : $self->set_title('Edit Banner Group');

    # Helper buttons
    $self->add_btn('/AdminBanners/Groups','Back');

    # JS
    $self->add_jsfile('admin-blog');

    # Values
    if($self->param('group_id') ne 'New'){
        $values = $self->selectrow_hashref("SELECT * FROM banners_groups WHERE group_id=?",{},$self->param('group_id'));
        #$values->{display_options} = decode_json($values->{display_options});
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
        fields   => [qw/name group_type /],
        submits  => \@submit,
        values   => $values,
    });

    $form->field('group_id',{type=>'hidden'});
    $form->field('name',{span=>'col-md-8', required=>1});
    $form->field('group_type',{span=>'col-md-4', required=>1});

    $form->submit('Delete',{class=>'btn btn-danger'});

    return $form->render();
}

1;
