package Zera::Form;

use strict;
use Switch;
use Template;

use Zera::Conf;
use Zera::Com;

# Base functions
sub new {
    my $class = shift;
    my $self = {
        version  => '0.1',
    };
    bless $self, $class;

    # Main Zera object
    $self->{Zera} = shift;
    $self->{params} = shift;

    # Init app ENV
    $self->_init();

    return $self;
}

sub _init {
    my $self = shift;

    # Default ID
    $self->{id} = $self->{Zera}->{sub_name}.'_form';
    $self->{id} =~s/^display_//;

    # Default name
    $self->{params}->{name} = $self->{id} if(!$self->{params}->{name});

    # Fields
    $self->{fields} = {};
    foreach my $field_name (@{$self->{params}->{fields}}){
        $self->{fields}->{$field_name} = {name=>$field_name, class=>'form-control form-control-sm'};
    }

    # Submits
    $self->{submits} = {};
    my @btn_class = ('btn-primary','btn-secondary','btn-danger','btn-secondary','btn-secondary','btn-secondary');
    foreach my $submit_name (@{$self->{params}->{submits}}){
        $self->{submits}->{$submit_name} = {type => 'submit', name=>$submit_name, class=>'btn ' . shift(@btn_class)};
    }

    # Default Action
    if(!$self->{params}->{action}){
        $self->{params}->{action} = $ENV{SCRIPT_URL} || $ENV{REQUEST_URI};
        if($self->{params}->{action} =~ /\?/){
            $self->{params}->{action} =~ s/(\?.*)//;
        }
    }

    # Default class
    $self->{params}->{class} .= 'form-horizontal needs-validation' if(!$self->{params}->{class});

    # Control fields
    $self->field('_submit',{type=>'hidden', value=>''});
    $self->field('_submitted',{type=>'hidden', value=>$self->{id}});
}

sub param {
    my $self = shift;
    my $var = shift;
    return $self->{Zera}->{_REQUEST}->param($var);
}

sub render {
    my $self = shift;
    my $content = shift || "";
    my $vars    = shift || {};

    $self->_prepare_fields();

    my $template_file = $self->{params}->{template};
    if (!$template_file) {
        my $dir = __PACKAGE__;
        $dir =~s/::/\//g;
        if(-e ("$dir/$self->{Zera}->{sub_name}.html")){
            $template_file = "$dir/$self->{Zera}->{sub_name}.html";
        }else{
            if($self->{Zera}->{_Layout} eq 'Public'){
                $template_file = 'templates/' . $conf->{Template}->{TemplateID} . '/zera_form.html';
            }elsif($self->{Zera}->{_Layout} eq 'User'){
                $template_file = 'templates/' . $conf->{Template}->{UserTemplateID} . '/zera_form.html';
            }elsif($self->{Zera}->{_Layout} eq 'Admin'){
                $template_file = 'templates/' . $conf->{Template}->{AdminTemplateID} . '/zera_form.html';
            }
        }
    }

    my $tt = Zera::Com::template();
    $vars = {
        vars    => $self->{vars},
        conf    => $conf,
        msg     => $self->{Zera}->get_msg(),
        page    => $self->{Zera}->{_PAGE}
    };
    my $HTML = '';
    $tt->process($template_file, $vars, \$HTML) || die $tt->error(), "\n";
    return $HTML;
}

sub field {
    my $self = shift;
    my $field_name = shift;
    my $attrs = shift;

    # Prevent null
    if(!(defined $self->{fields}->{$field_name} )){
        $self->{fields}->{$field_name} = {name => $field_name, class=>'form-control'};
    }

    # Fill attributes
    foreach my $key (keys %$attrs){
        $self->{fields}->{$field_name}->{$key} = $attrs->{$key};
    }

    # Push field to fields
    push(@{$self->{params}->{fields}},$field_name) unless grep{$_ eq $field_name} @{$self->{params}->{fields}};
}

sub submit {
    my $self = shift;
    my $name = shift;
    my $attrs = shift;

    # Prevent null
    if(!(defined $self->{submits}->{$name} )){
        $self->{submits}->{$name} = {name => $name};
    }

    # Fill attributes
    foreach my $key (keys %$attrs){
        $self->{submits}->{$name}->{$key} = $attrs->{$key};
    }

}

sub _prepare_fields {
    my $self = shift;

    # Fields
    $self->{vars}->{fields} = [];
    foreach my $field_name (@{$self->{params}->{fields}}){
        push (@{$self->{vars}->{fields}},$self->_prepare_field($field_name));
    }

    # Submits
    $self->{vars}->{submits} = [];
    foreach my $submit_name (@{$self->{params}->{submits}}){
        push (@{$self->{vars}->{submits}},$self->_prepare_submit($submit_name));
    }

    # Form enclosing
    $self->{vars}->{form_start} = $self->_get_form_start();
    $self->{vars}->{form_end}   = '</form>';

}

sub _prepare_field {
    my $self = shift;
    my $field_name = shift;

    # Process the attributes
    $self->{fields}->{$field_name}->{label} = $self->_create_label($field_name) if(!$self->{fields}->{$field_name}->{label});
    $self->{fields}->{$field_name}->{placeholder} = $self->_create_label($field_name) if(!$self->{fields}->{$field_name}->{label});

    if((defined $self->param($field_name))){
        $self->{fields}->{$field_name}->{value} = $self->param($field_name);
    }

    # create te html
    $self->{fields}->{$field_name}->{field} = $self->_get_field($field_name);
    return $self->{fields}->{$field_name};
}

sub _prepare_submit {
    my $self = shift;
    my $name = shift;

    $self->{submits}->{$name}->{label} = $self->_create_label($name) if(!$self->{submits}->{$name}->{label});

    # create te html
    $self->{submits}->{$name}->{submit} = $self->_get_submit($name);
    return $self->{submits}->{$name};
}

sub _get_submit {
    my $self = shift;
    my $submit_name = shift;
    my $submit_html = '';

    if(!($self->{submits}->{$submit_name}->{type})){
        $self->{submits}->{$submit_name}->{type} = 'submit';
    }

    # Control action
    $self->{submits}->{$submit_name}->{onclick} = 'this.form._submit.value = this.name;';
#    $self->{submits}->{$submit_name}->{onclick} = 'alert(this.name);';

    switch ($self->{submits}->{$submit_name}->{type}) {
        case 'submit' {
            $self->{submits}->{$submit_name}->{class} = 'btn btn-secondary' if(!($self->{submits}->{$submit_name}->{class}));
            foreach my $key (keys %{$self->{submits}->{$submit_name}}) {
                next if($key eq 'id');
                next if($key eq 'name');
                next if($key eq 'type');
                $submit_html .= $key . '="' . $self->{submits}->{$submit_name}->{$key} . '" ';
            }
            $submit_html  = '<button name="' . $submit_name . '" id="' . $submit_name . '" type="' . $self->{submits}->{$submit_name}->{type} . '" ' . $submit_html .'>' . $self->{submits}->{$submit_name}->{label} . '</button>';
        }
        case 'btn' {
            $self->{submits}->{$submit_name}->{class} = 'btn btn-secondary' if(!($self->{submits}->{$submit_name}->{class}));
            foreach my $key (keys %{$self->{submits}->{$submit_name}}) {
                next if($key eq 'id');
                next if($key eq 'name');
                next if($key eq 'type');
                $submit_html .= $key . '="' . $self->{submits}->{$submit_name}->{$key} . '" ';
            }
            $submit_html  = '<button name="' . $submit_name . '" id="' . $submit_name . '" type="' . $self->{submits}->{$submit_name}->{type} . '" ' . $submit_html .'>' . $self->{submits}->{$submit_name}->{label} . '</button>';
        }
    }
    return $submit_html;
}

sub _create_label {
    my $self = shift;
    my $field_label = shift;
    $field_label =~s/_/ /;
    return ucfirst($field_label);
}

sub _get_field {
    my $self = shift;
    my $field_name = shift;
    my $field_html = '';

    if(!($self->{fields}->{$field_name}->{type})){
        $self->{fields}->{$field_name}->{type} = 'text';
    }

    if(defined $self->{params}->{values}->{$field_name}){
        $self->{fields}->{$field_name}->{value} = $self->{params}->{values}->{$field_name};
    }

    switch ($self->{fields}->{$field_name}->{type}) {
        case 'select' {
            my $field_options = '';
            
            foreach my $key(keys %{$self->{fields}->{$field_name}}){
                next if($key eq 'id');
                next if($key eq 'name');
                next if($key eq 'type');
                next if($key eq 'invalid_msg');
                next if($key eq 'help');
                next if($key eq 'override');
                next if($key eq 'label');
                if($key eq 'options'){
                    foreach my $option(@{$self->{fields}->{$field_name}->{$key}}){
                        $field_options .= '<option>'.$option.'</option>';
                    }
                }else{
                    $field_html .= $key . '="' . $self->{fields}->{$field_name}->{$key} . '" ';
                }    
                
            }

            $field_html = '<select name='.$field_name.'  '.$field_html.'><option disabled>Select an option</options>'.$field_options.'</select>';
        }
        case 'checkbox' {
            $self->{fields}->{$field_name}->{class} = 'form-check-input' if(!($self->{fields}->{$field_name}->{class}));
            foreach my $key (keys %{$self->{fields}->{$field_name}}) {
                next if($key eq 'id');
                next if($key eq 'name');
                next if($key eq 'type');
                next if($key eq 'invalid_msg');
                next if($key eq 'help');
                next if($key eq 'override');
                next if($key eq 'label');
                if($key eq 'value'){
                    if($self->{fields}->{$field_name}->{$key}){
                        $field_html .= ' checked="1" ';
                    }
                }else{
                    $field_html .= $key . '="' . $self->{fields}->{$field_name}->{$key} . '" ';
                }
            }
            $field_html  = '<input name="' . $field_name . '" id="' . $field_name . '" type="' . $self->{fields}->{$field_name}->{type} . '" value="1" ' . $field_html .'/>';
            if($self->{fields}->{$field_name}->{check_label}){
                $field_html .= "\n".'<label class="form-check-label" for="' . $field_name . '">' . $self->{fields}->{$field_name}->{check_label} . '</label>';
            }else{
                $field_html .= "\n".'<label class="form-check-label" for="' . $field_name . '">' . $self->{fields}->{$field_name}->{label} . '</label>' if($self->{fields}->{$field_name}->{label});
            }
        }
        case 'password' {
            foreach my $key (keys %{$self->{fields}->{$field_name}}) {
                next if($key eq 'id');
                next if($key eq 'name');
                next if($key eq 'type');
                next if($key eq 'invalid_msg');
                next if($key eq 'help');
                next if($key eq 'override');
                next if($key eq 'label');
                next if($key eq 'value');
                $field_html .= $key . '="' . $self->{fields}->{$field_name}->{$key} . '" ';
            }
            $field_html = '<input name="' . $field_name . '" id="' . $field_name . '" type="' . $self->{fields}->{$field_name}->{type} . '" ' . $field_html .'/>'
        }
        case 'textarea' {
            foreach my $key (keys %{$self->{fields}->{$field_name}}) {
                next if($key eq 'id');
                next if($key eq 'name');
                next if($key eq 'type');
                next if($key eq 'invalid_msg');
                next if($key eq 'help');
                next if($key eq 'override');
                next if($key eq 'label');
                next if($key eq 'value');
                $field_html .= $key . '="' . $self->{fields}->{$field_name}->{$key} . '" ';
            }
            $self->{fields}->{$field_name}->{value} = '' if(!$self->{fields}->{$field_name}->{value});
            $field_html = '<textarea name="' . $field_name . '" id="' . $field_name . '" ' . $field_html .'>'.$self->{fields}->{$field_name}->{value}.'</textarea>';
        }
        case 'file' {
            $self->{fields}->{$field_name}->{class} = 'custom-file-input' if(($self->{fields}->{$field_name}->{class} eq 'form-control form-control-sm'));
            foreach my $key (keys %{$self->{fields}->{$field_name}}) {
                next if($key eq 'id');
                next if($key eq 'name');
                next if($key eq 'type');
                next if($key eq 'invalid_msg');
                next if($key eq 'help');
                next if($key eq 'override');
                next if($key eq 'label');
                next if($key eq 'value');
                $field_html .= $key . '="' . $self->{fields}->{$field_name}->{$key} . '" ';
            }
            $field_html = '<input name="' . $field_name . '" id="' . $field_name . '" type="' . $self->{fields}->{$field_name}->{type} . '" ' . $field_html .'/>' .
                '<label class="custom-file-label" for="' . $field_name . '"></label>';

            $self->{params}->{enctype} ="multipart/form-data";
        }
        else {
            foreach my $key (keys %{$self->{fields}->{$field_name}}) {
                next if($key eq 'id');
                next if($key eq 'name');
                next if($key eq 'type');
                next if($key eq 'invalid_msg');
                next if($key eq 'help');
                next if($key eq 'override');
                next if($key eq 'label');
                $field_html .= $key . '="' . $self->{fields}->{$field_name}->{$key} . '" ';
            }
            $field_html = '<input name="' . $field_name . '" id="' . $field_name . '" type="' . $self->{fields}->{$field_name}->{type} . '" ' . $field_html .'/>'
        }
    }
    return $field_html;
}

sub _get_form_start {
    my $self = shift;
    my $form_start_html = '';

    foreach my $key (keys %{$self->{params}}) {
        next if($key eq 'id');
        next if($key eq 'name');
        next if($key eq 'fields');
        next if($key eq 'submits');
        next if($key eq 'submit');
        next if($key eq 'template');
        next if($key eq 'values');
        next if($key eq 'help');
        next if($key eq 'override');
        next if($key eq 'type');
        $form_start_html .= $key . '="' . $self->{params}->{$key} . '" ';
    }
    $form_start_html = '<form name="' . $self->{params}->{name} . '" id="' . $self->{id} . '" ' . $form_start_html .' novalidate />';
    return $form_start_html;
}


1;
