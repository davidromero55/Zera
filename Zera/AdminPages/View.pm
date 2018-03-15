package Zera::AdminPages::View;

use base 'Zera::BaseAdmin::View';

# Module Functions
sub display_home {
    my $self = shift;
    
    $self->set_title('Pages');
    $self->add_search_box();
    $self->set_add_btn('/AdminPages/Edit/New');
    
    
    my $where = "e.module='Pages'";
    my @params;
    if($self->param('zl_q')){
        $where .= " AND title LIKE ? ";
        push(@params,'%' . $self->param('zl_q') .'%');
    }
    my $list = Zera::List->new($self->{Zera},{
        sql => {
            select => "entry_id, title, Date(date) as date, active",
            from =>"entries e",
            order_by => "",
            where => $where,
            params => \@params,
            limit => "30",
        },
        link => {
            key => "entry_id",
            hidde_key_col => 1,
            location => '/AdminPages/Edit',
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
    
    $self->param('entry_id',$self->param('SubView')) if(!(defined $self->param('entry_id')));
    
    # Title
    ($self->param('SubView') eq 'New') ? $self->set_title('Add Page') : $self->set_title('Edit Page');

    # Helper buttons
    $self->add_btn('/AdminPages','Back');

    # JS
    $self->add_jsfile('admin-pages');

    # Values
    if($self->param('entry_id')){
        $values = $self->selectrow_hashref("SELECT * FROM entries WHERE entry_id=? AND module='Pages'",{},$self->param('entry_id'));
        push(@submit, 'Delete');
    }else{
        $values = {
            date => $self->selectrow_array('SELECT DATE(NOW())'),
        };
    }
    
    # Form
    my $form = $self->form({
        method   => 'POST',
        fields   => [qw/entry_id title url keywords date active description content /],
        submits  => \@submit,
        values   => $values,
    });
    
    $form->field('entry_id',{type=>'hidden'});
    $form->field('title',{span=>'col-md-12', required=>1});
    $form->field('url',{span=>'col-md-6', required=>1, readonly=>1});
    $form->field('keywords',{span=>'col-md-6', required=>1});
    $form->field('date',{class=>'form-control form-control-sm datepicker', required=>1});
    $form->field('description',{span=>'col-md-12', required=>1});
    $form->field('content',{span=>'col-md-12', required=>1, type=>'textarea', rows=>10, class=>"wysiwyg form-control form-control-sm"});
    $form->field('active',{label=>"Publish", check_label=>'Yes / No', class=>"filled-in", type=>"checkbox"});

    $form->submit('Delete',{class=>'btn btn-danger'});
    
    return $form->render();
}

1;