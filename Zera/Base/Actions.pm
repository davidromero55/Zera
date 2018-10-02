package Zera::Base::Actions;

use strict;

use Zera::Conf;

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

sub process_action {
    my $self = shift;
    my $arg = shift || $self->param('View');
    $arg =~ s/([A-Z])/_$1/g;
    $arg =~ s/\W//g;
    if(!($arg)){
        $arg = $self->param('_Action');
        $arg =~ s/([A-Z])/_$1/g;
        $arg =~ s/\W//g;
        $arg = '_' . $arg;
    }
    my $sub_name = "do" . lc($arg);
    if ($self->can($sub_name) ) {
        $self->$sub_name();
    } else {
        $self->add_msg('danger',"sub '$sub_name' not defined.\n");
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
  return $self->{Zera}->{_DBH}->{_dbh}->selectall_arrayref(shift, {Slice=>{}}, @_);
}

sub dbh_do {
    my $self = shift;
    return $self->{Zera}->{_DBH}->{_dbh}->do(shift, shift,@_);
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
