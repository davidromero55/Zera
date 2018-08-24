package Zera::BaseUser::View;

use JSON;

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
        my $val = $self->{Zera}->{_REQUEST}->param($var);
        if(defined $val){
            return $self->{Zera}->{_REQUEST}->param($var);
        }else{
            return '';
        }
    }
}

sub get_view {
    my $self = shift;
    my $sub_name = $self->param('View');
    $sub_name =~ s/([A-Z])/_$1/g;
    $sub_name =~ s/\W//g;
    $sub_name = "display" . lc($sub_name);
    if ($self->can($sub_name) ) {
        $self->{Zera}->{sub_name} = $sub_name;
        return $self->$sub_name();
    } else {
        $self->add_msg('danger',"sub '$sub_name' not defined.\n");
        return $self->get_msg();
    }
}

sub get_default_view {
    my $self = shift;
    my $sub_name = 'display_home';
    if ($self->can($sub_name) ) {
        $self->{Zera}->{sub_name} = $sub_name;
        return $self->$sub_name();
    } else {
        $self->add_msg('danger',"sub '$sub_name' not defined.\n");
        return $self->get_msg();
    }
}

#Delete files from /Data
sub remove_data{
  my $self = shift;
  my $file = shift;
  if ($file =~ /[ \\\*;]/){
    $self->add_msg('danger', "$file Is not a valid file path.");
  }else{
    unlink "data/$file" or $self->add_msg('danger', 'File $file not found');
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
    return $self->render_template($vars,'msg');
}

sub get_msg {
  my $self = shift;
  $self->{Zera}->get_msg();
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

sub selectall {
  my $self = shift;
  return $self->{Zera}->{_DBH}->{_dbh}->selectall_arrayref(shift, {slice=>{}}, @_);
}

sub dbh_do {
    my $self = shift;
    return $self->{Zera}->{_DBH}->{_dbh}->do(shift, shift,@_);
}

sub form {
    my $self = shift;
    my $params = shift;
    return Zera::Form->new($self->{Zera}, $params);
}

# Template functions
sub render_template {
    my $self = shift;
    my $vars = shift;
    my $template = shift || $self->{Zera}->{sub_name};
    my $HTML = '';

    if(-e ($template)){

    }elsif(-e ('templates/' . $conf->{Template}->{TemplateID} . '/' . $self->{Zera}->{_REQUEST}->param('Controller') . '/' . $template . '.html')){
        $template = 'templates/' . $conf->{Template}->{TemplateID} . '/' . $self->{Zera}->{_REQUEST}->param('Controller') . '/' . $template . '.html';
    }elsif(-e ('Zera/' . $self->{Zera}->{_REQUEST}->param('Controller') . '/tmpl/' . $template . '.html')){
        $template = 'Zera/' . $self->{Zera}->{_REQUEST}->param('Controller') . '/tmpl/' . $template . '.html';
    }else{
        $self->add_msg('danger','Template ' . $template . ' not found.');
        return $self->get_msg();
    }

    $vars->{conf} = $conf;
    $vars->{msg}  = $self->get_msg();
    $vars->{page} = $self->{Zera}->{_PAGE};

    my $tt = Zera::Com::template();
    $tt->process($template, $vars, \$HTML) || die "$Template::ERROR\n";
    return $HTML;
}

sub set_title {
    my $self = shift;
    my $title = shift;
    $self->{Zera}->{_PAGE}->{title} = $title;
}

sub set_keywords {
    my $self = shift;
    my $keywords = shift;
    $self->{Zera}->{_PAGE}->{keywords} = $keywords;
}

sub set_description {
    my $self = shift;
    my $description = shift;
    $self->{Zera}->{_PAGE}->{description} = $description;
}

sub set_page_attr {
    my $self = shift;
    my $attr = shift;
    my $val  = shift;
    $self->{Zera}->{_PAGE}->{$attr} = $val;
}

sub set_add_btn {
    my $self = shift;
    my $url   = shift;
    my $label = shift || 'Add';
    $self->add_btn($url, $label,'btn btn-primary text-white','plus-circle');
}

sub add_search_box {
    my $self = shift;
    my $placeholder = shift || 'Search';
    my $url = shift || $ENV{SCRIPT_URL}  || $ENV{REQUEST_URI};
    if($url =~ /\?/){
        $url =~ s/(\?.*)//;
    }

    my $value = $self->param('zl_q');
    $value = '' if(!(defined $self->param('zl_q')));
    $self->{Zera}->{_PAGE}->{search_url} = $url;
    $self->{Zera}->{_PAGE}->{search_box} = $self->_tag('input', {type=>"text", class=>"form-control", value=>$value, name=>"zl_q", id=>"zl_q", placeholder=>$placeholder});
    $self->{Zera}->{_PAGE}->{buttons} .= $self->_tag('button',{type=>"submit", class=>"btn btn-secondary"},'<i class="fas fa-search"></i>');
}

sub add_btn {
    my $self  = shift;
    my $url   = shift;
    my $label = shift || 'Add';
    my $class = shift || 'btn btn-secondary text-white';
    my $icon  = shift || '';

    $label = '<i class="fas fa-' . $icon . '"></i> ' . $label if($icon);
    $self->{Zera}->{_PAGE}->{buttons} .= $self->_tag('a',{class=>$class, href=>$url},$label);
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

sub get_image_options {
    my $self = shift;
    my $file = shift;

    my $image_html =  $self->_tag('img',{src=>$file, class=>'img-thumbnail mx-auto d-block img-fluid', style=>'max-height: 150px;'});
    return $image_html;
}

#Call conf values
sub conf {
    my $self = shift;
    my $module = shift;
    my $name = shift;
    my $value = shift;
    if (defined $value){
      $self->dbh_do("UPDATE value = ? WHERE name = ? AND module = ?", {}, $value, $name, $module);
    }else{
      $value = $self -> selectrow_array("SELECT value FROM conf WHERE name = ? AND module = ?", {}, $name, $module);
      return $value;
    }
}

1;
