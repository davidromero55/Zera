package Zera::Base::Components;

use Zera::Conf;
use Zera::Com;
use Zera::Form;
use Zera::List;

# Base functions
sub new {
    my $class = shift;
    my $self = {
        version  => '0.1',
    };
    bless $self, $class;

    # Main Zera object
    $self->{Zera} = shift;

    # Init app ENV
    $self->_init();
    return $self;
}

sub _init {
    my $self = shift;
    $self->{Zera}->{component_name} = '';
}

# Session functions
sub sess {
    my $self = shift;
    my $name = shift;
    my $value = shift;

    if(defined $value){
        $self->{Zera}->{_SESS}->{_sess}{$name} = "$value";
    }else{
        return $self->{Zera}->{_SESS}->{_sess}{$name};
    }
}

# Request functions
sub param {
    my $self = shift;
    my $var = shift;
    my $val = shift;
    if(defined $val){
        $self->{Zera}->{_REQUEST}->param($var,$val);
    }else{
        return $self->{Zera}->{_REQUEST}->param($var);
    }
}

sub get_component {
    my $self = shift;
    my $component = shift;
    my @params    = @_;
    $component =~ s/\W//g;

    my $sub_name = $component;
    $sub_name = "component_" . $sub_name;
    if ($self->can($sub_name) ) {
        $self->{Zera}->{component_name} = $sub_name;
        return $self->$sub_name(@params);
    } else {
        $self->add_msg('danger',"Component '$sub_name' not defined.\n");
        return $self->{Zera}->get_msg();
    }
}

# User messages
sub add_msg {
    my $self = shift;
    $self->{Zera}->add_msg(shift, shift);
}

sub display_msg {
    my $self = shift;

    my $vars = {
    };
    return $self->render_template($vars,'msg-admin');
}

# Database functions
sub selectrow_hashref {
    my $self = shift;
    return $self->{Zera}->{_DBH}->{_dbh}->selectrow_hashref(shift, shift,@_);
}

sub last_insert_id {
    my $self = shift;
    return $self->{Zera}->{_DBH}->{_dbh}->last_insert_id('','',shift,shift);
}

sub selectrow_array {
    my $self = shift;
    return $self->{Zera}->{_DBH}->{_dbh}->selectrow_array(shift, shift,@_);
}

sub selectall_arrayref {
    my $self = shift;
    return $self->{Zera}->{_DBH}->{_dbh}->selectall_arrayref(shift, shift,@_);
}

sub dbh_do {
    my $self = shift;
    return $self->{Zera}->{_DBH}->{_dbh}->do(shift, shift,@_);
}

# Template functions
sub render_template {
    my $self = shift;
    my $vars = shift;
    my $template = shift || $self->{Zera}->{component_name};
    my $HTML = '';

    my $dir =caller();
    $dir =~ s/::/\//g;
    $dir =~s/\/Components$//;

    if(-e ($dir . '/tmpl/' . $template . '.html')){
        $template = $dir . '/tmpl/' . $template . '.html';
    }elsif(-e ('templates/' . $conf->{Template}->{TemplateID} . '/' . $template . '.html')){
        $template = 'templates/' . $conf->{Template}->{TemplateID} . '/' . $template . '.html';
    }elsif(-e ($template)){

    }else{
        $self->add_msg('danger','Template ' . $template . ' not found.');
        return $self->{Zera}->get_msg();
    }

    $vars->{conf} = $conf;
    $vars->{msg}  = $self->{Zera}->get_msg();
    $vars->{page} = $self->{Zera}->{_PAGE};
    $vars->{Zera} = $self->{Zera};

    my $tt = Zera::Com::template();
    $tt->process($template, $vars, \$HTML) || die "$Template::ERROR \n";
    return $HTML;
}

sub form {
    my $self = shift;
    my $params = shift;
    return Zera::Form->new($self->{Zera}, $params);
}

sub set_page_attr {
    my $self = shift;
    my $attr = shift;
    my $val  = shift;
    $self->{Zera}->{_PAGE}->{$attr} = $val;
}

sub add_jsfile {
    my $self = shift;
    my $js_file = shift;
    if(-e ('Zera/' . $self->{Zera}->{ControllerName} . '/js/' . $js_file . '.js')){
        $self->{Zera}->{_PAGE}->{js_files} .= '<script src="' . '/Zera/' . $self->{Zera}->{ControllerName} . '/js/' . $js_file . '.js' . '"></script>';
    }else{
        $self->add_msg('danger',"JS file $js_file does not exist.");
    }
}

sub add_btn {
    my $self  = shift;
    my $url   = shift;
    my $label = shift || 'Add';
    my $class = shift || 'btn btn-secondary text-white';
    my $icon  = shift || '';

    $label = '<i class="material-icons md-18">' . $icon . '</i> ' . $label if($icon);
    $self->{Zera}->{_PAGE}->{buttons} .= $self->_tag('a',{class=>$class, href=>$url},$label);
}

# HTML functions
sub _tag {
    my $self     = shift;
    my $tag_type = shift;
    my $attrs    = shift;
    my $content  = shift;

    my $tag = '';
    foreach my $key (keys %{$attrs}){
        $tag .= ' ' . $key .'="'. $attrs->{$key}.'"';
    }
    if($content){
        return '<' . $tag_type . $tag . '>' . $content . '</' . $tag_type . '>';
    }else{
        return '<' . $tag_type . $tag . ' />';
    }
}

1;
