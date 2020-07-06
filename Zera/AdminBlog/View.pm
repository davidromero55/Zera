package Zera::AdminBlog::View;

use JSON;
use base 'Zera::BaseAdmin::View';

# Module Functions
sub display_home {
    my $self = shift;

    $self->set_title('Blog');
    $self->add_search_box();
    $self->set_add_btn('/AdminBlog/Edit/New');

    my $where = "e.module='Blog'";
    my @params;
    if($self->param('zl_q')){
        $where .= " AND title LIKE ? ";
        push(@params,'%' . $self->param('zl_q') .'%');
    }
    my $list = Zera::List->new($self->{Zera},{
        sql => {
            select => "entry_id, title, Date(date) as date, active",
            from =>"entries e",
            order_by => "entry_id DESC",
            where => $where,
            params => \@params,
            limit => "30",
        },
        link => {
            key => "entry_id",
            hidde_key_col => 1,
            location => '/AdminBlog/Edit',
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

    $self->param('entry_id',$self->param('SubView')) if(!($self->param('entry_id')));

    # Title
    ($self->param('SubView') eq 'New') ? $self->set_title('Add Blog') : $self->set_title('Edit Blog');

    # Helper buttons
    $self->add_btn('/AdminBlog','Back');

    # JS
    $self->add_jsfile('admin-blog');

    # Values
    if($self->param('entry_id') ne 'New'){
        $values = $self->selectrow_hashref("SELECT * FROM entries WHERE entry_id=? AND module='Blog'",{},$self->param('entry_id'));
        $values->{display_options} = decode_json($values->{display_options});
        $values->{category_id} = $self->selectrow_array("SELECT category_id FROM entries_categories WHERE entry_id=?", {},$self->param('entry_id')) || 0;
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
        fields   => [qw/entry_id title url keywords date active description image content category_id/],
        submits  => \@submit,
        values   => $values,
    });
    my %categories = $self->selectbox_data("SELECT category_id, category FROM categories WHERE module = 'Blog'");

    $form->field('entry_id',{type=>'hidden'});
    $form->field('title',{span=>'col-md-12', required=>1});
    $form->field('url',{span=>'col-md-6', required=>1, readonly=>1});
    $form->field('keywords',{span=>'col-md-6', required=>1});
    $form->field('date',{class=>'form-control form-control-sm datepicker', required=>1});
    $form->field('description',{required=>1, type=>'textarea', rows=>9, class=>"form-control form-control-sm"});
    $form->field('image', {type=>'file', accept=>"image/x-png,image/gif,image/jpeg"});
    $form->field('content',{span=>'col-md-12', required=>1, type=>'textarea', rows=>10, class=>"wysiwyg form-control form-control-sm"});
    $form->field('active',{label=>"Publish", check_label=>'Yes / No', class=>"filled-in", type=>"checkbox"});
    $form->field('category_id',{placeholder=> 'Category', span=>'col-md-3', label=> 'Category', type=>'select', selectname => 'Select a category', options => $categories{values}, labels => $categories{labels}});

    if($values->{display_options}->{image}){
        $form->field('image', {help=>$self->get_image_options($values->{display_options}->{image})});
    }

    $form->submit('Delete',{class=>'btn btn-danger'});

    return $form->render();
}

1;
