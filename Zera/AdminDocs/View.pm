package Zera::AdminDocs::View;

use base 'Zera::BaseAdmin::View';

# Module Functions
sub display_home {
    my $self = shift;

    $self->set_title('Documents');
    $self->add_search_box();

    my $parent_id   = $self->param('parent_id');
    my $category_id = $self->param('category_id');

    my $list;

    if($category_id){
        $self->set_add_btn('/AdminDocs/Edit/New?category_id='.$category_id);
        my $category = $self->selectrow_hashref("SELECT category_id, parent_id, category FROM categories WHERE category_id=?",{},
            $self->param('category_id'));
        $self->add_btn('/AdminDocs?parent_id='.$category->{parent_id},'Back');
        $list = $self->_get_entries();
    }elsif($parent_id){
        $self->set_add_btn('/AdminDocs/EditCategory/New?parent_id='.$parent_id);
        $self->add_btn('/AdminDocs','Back');
        $list = $self->_get_categories();
    }else{
        $self->set_add_btn('/AdminDocs/EditCategory/New');
        $list = $self->_get_parent_categories();
    }
    my $vars = {
        list => $list,
    };

    return $self->render_template($vars);
}

sub display_edit {
    my $self = shift;
    my $values = {};
    my @submit = ("Save");
    $self->param('entry_id',$self->param('SubView')) if(!($self->param('entry_id')));
    my $entry_id = $self->param('entry_id') || 0;
    $entry_id =~ s/\D//g;
    $self->param('entry_id',$entry_id);

    # Title
    ($self->param('SubView') eq 'New') ? $self->set_title('Add Doc') : $self->set_title('Edit Doc');

    $self->add_btn('/AdminDocs?category_id='.$self->param('category_id'),'Back');

    # JS
    $self->add_jsfile('admin_pages');

    # Values
    if($self->param('entry_id')){
        $values = $self->selectrow_hashref("SELECT * FROM entries WHERE entry_id=? AND module='Docs'",{},$self->param('entry_id'));
        $values->{category_id} = $self->selectrow_array("SELECT category_id FROM entries_categories WHERE entry_id=?",{},$self->param('entry_id'));
        push(@submit, 'Delete');
    }else{
        $values = {
            category_id => $category_id,
            date => $self->selectrow_array('SELECT DATE(NOW())'),
        };
    }

    # Form
    my $form = $self->form({
        method   => 'POST',
        fields   => [qw/entry_id category_id title url keywords date active description content /],
        submits  => \@submit,
        values   => $values,
    });

    $form->field('entry_id',{type=>'hidden'});
    $form->field('category_id',{type=>'hidden'});
    $form->field('title',{span=>'col-md-12', required=>1});
    $form->field('url',{span=>'col-md-6', required=>1, readonly=>1});
    $form->field('keywords',{span=>'col-md-6'});
    $form->field('date',{class=>'form-control form-control-sm datepicker', required=>1});
    $form->field('description',{span=>'col-md-12', required=>1});
    $form->field('content',{span=>'col-md-12', required=>1, type=>'textarea', rows=>10, class=>"wysiwyg form-control form-control-sm"});
    $form->field('active',{label=>"Publish", check_label=>'Yes / No', class=>"filled-in", type=>"checkbox"});

    $form->submit('Delete',{class=>'btn btn-danger'});

    return $form->render();
}

sub _get_entries {
    my $self = shift;
    my $where = "e.module='Docs' AND ec.category_id=?";
    my @params = $self->param('category_id');
    if($self->param('zl_q')){
        $where .= " AND title LIKE ? ";
        push(@params,'%' . $self->param('zl_q') .'%');
    }
    $list = Zera::List->new($self->{Zera},{
        sql => {
            select => "entry_id, title, Date(date) as date, active, '' AS edit",
            from =>"entries e NATURAL JOIN entries_categories ec",
            order_by => "",
            where => $where,
            params => \@params,
            limit => "30",
        },
        link => {
            key => "entry_id",
            hidde_key_col => 1,
            transit_params => {
                category_id => $self->param('category_id')
            },
        },
        debug => 1,
    });

    $list->get_data();
    $list->on_off('active');
    $list->columns_align(['left','left','center','center','center']);

    foreach my $row (@{$list->{rs}}){
        $row->{edit}       = '<a href="/AdminDocs/Edit/' . $row->{entry_id} . '?category_id='.$self->param('category_id').'"><i class="fas fa-edit"></i></a>';
    }
    return $list->print();
}

sub _get_parent_categories {
    my $self = shift;

    my $where = "c.module='Docs' AND c.parent_id=0";
    my @params;
    if($self->param('zl_q')){
        $where .= " AND c.category LIKE ? ";
        push(@params,'%' . $self->param('zl_q') .'%');
    }
    $list = Zera::List->new($self->{Zera},{
        sql => {
            select => "c.category_id, c.category, c.active, '' AS edit, '' AS categories",
            from =>"categories c",
            order_by => "c.sort_order, c.category",
            where => $where,
            params => \@params,
            limit => "30",
        },
        link => {
            key => "category_id",
            hidde_key_col => 1,
            transit_params => {},
        },
        debug => 1,
    });

    $list->get_data();
    $list->columns_align(['left','center','center','center']);
    $list->on_off('active');

    foreach my $row (@{$list->{rs}}){
        $row->{edit}       = '<a href="/AdminDocs/EditCategory/' . $row->{category_id} . '"><i class="fas fa-edit"></i></a>';
        $row->{categories} = '<a href="/AdminDocs?parent_id=' . $row->{category_id} . '"><i class="fas fa-chevron-circle-right"></i>

        </i></a>';
    }
    return $list->print();
}

sub display_edit_category {
    my $self = shift;
    my $values = {};
    my @submit = ("Save");
    $self->param('category_id',$self->param('SubView')) if(!($self->param('category_id')));
    my $entry_id = $self->param('category_id') || 0;
    $entry_id =~ s/\D//g;
    $self->param('category_id',$entry_id);

    # Title
    ($self->param('SubView') eq 'New') ? $self->set_title('Add Category') : $self->set_title('Edit Category');

    # JS
    $self->add_jsfile('docs_categories');

    # Values
    if($self->param('category_id')){
        $values = $self->selectrow_hashref("SELECT * FROM categories WHERE category_id=? AND module='Docs'",{},$self->param('category_id'));
        push(@submit, 'Delete');
    }else{
        $values = {
            parent_id => $self->param('parent_id') ,
        };
    }
    $self->add_btn('/AdminDocs?parent_id='.($values->{parent_id} || 0),'Back');

    # Form
    my $form = $self->form({
        method   => 'POST',
        fields   => [qw/category_id parent_id category url active description/],
        submits  => \@submit,
        values   => $values,
    });

    $form->field('category_id',{type=>'hidden'});
    $form->field('parent_id',{type=>'hidden'});
    $form->field('category',{span=>'col-md-12', required=>1});
    $form->field('url',{span=>'col-md-6', required=>1, readonly=>1});
    $form->field('active',{label=>"Active", check_label=>'Yes / No', class=>"filled-in", type=>"checkbox"});
    $form->field('description',{span=>'col-md-12', required=>1});

    $form->submit('Delete',{class=>'btn btn-danger'}) if($values->{category_id});

    return $form->render();
}

sub _get_categories {
    my $self = shift;
    my @params;

    my $where = "c.module='Docs' AND c.parent_id=?";
    push(@params,$self->param('parent_id'));
    if($self->param('zl_q')){
        $where .= " AND c.category LIKE ? ";
        push(@params,'%' . $self->param('zl_q') .'%');
    }
    $list = Zera::List->new($self->{Zera},{
        sql => {
            select => "c.category_id, c.category, c.active, '' AS edit, '' AS documents",
            from =>"categories c",
            order_by => "c.sort_order, c.category",
            where => $where,
            params => \@params,
            limit => "30",
        },
        link => {
            key => "category_id",
            hidde_key_col => 1,
            transit_params => {
                parent_id => $self->param('parent_id')
            },
        },
        debug => 1,
    });

    $list->get_data();
    $list->columns_align(['left','center','center','center']);
    $list->on_off('active');

    foreach my $row (@{$list->{rs}}){
        $row->{edit}       = '<a href="/AdminDocs/EditCategory/' . $row->{category_id} . '"><i class="fas fa-edit"></i></a>';
        $row->{documents} = '<a href="/AdminDocs?category_id=' . $row->{category_id} . '"><i class="fas fa-chevron-circle-right"></i>

        </i></a>';
    }
    return $list->print();
}

1;
