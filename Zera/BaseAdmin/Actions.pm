package Zera::BaseAdmin::Actions;

use strict;
use JSON;

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
    my $var = shift;
    my $val = shift;
    if(defined $val){
        $self->{Zera}->{_SESS}->{_sess}{$var} = "$val";
    }else{
        return $self->{Zera}->{_SESS}->{_sess}{$var};
    }
}

# Request Functions
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
    my $arg = $self->param('View') || "";
    $arg =~ s/([A-Z])/_$1/g;
    $arg =~ s/\W//g;
    if($self->param('_Action')){
        $arg = $self->param('_Action');
        $arg =~ s/([A-Z])/_$1/g;
        $arg =~ s/\W//g;
        #$arg = '_' . $arg;
    }
    my $sub_name = "do" . lc($arg);
    $self->{Zera}->{sub_name} = $sub_name;
    if ($self->can($sub_name) ) {
        return $self->$sub_name();
    } else {
        $self->add_msg('danger','Action ' . $sub_name . ' not implemented.');
        return {error => 1};
    }
}

sub upload_file {
    my $self = shift;
    my $cgi_param = shift || "";
    my $dir = shift || "";
    my $save_as = shift || "";
    my $filename = $self->{Zera}->{_REQUEST}->param_filename($cgi_param);
    my $mime = '';

    if(!(-e "data")){
        mkdir ("data") or die $!;
    }

    my @subdirs = split(/\//,$dir);
    my $subdirsSrt = '';
    foreach my $subdir (@subdirs){
        $subdirsSrt .= '/' if($subdirsSrt);
        $subdirsSrt .= $subdir;
        if(!(-e "data/$subdirsSrt")){
            mkdir ("data/$subdirsSrt") or die $!
        }
    }

    if($filename){
        my $type = $self->{Zera}->{_REQUEST}->param_mime($cgi_param);
        my ($name, $extension) = split(/\./, $filename);
        $name =~s/\W+/-/g;
        my $file = $name . '.' . $extension;
        if($type eq "image/jpeg" or $type eq "image/x-jpeg"  or $type eq "image/pjpeg"){
            $extension = "jpg";
        }elsif($type eq "image/png" or $type eq "image/x-png"){
            $extension = "png";
        }elsif($type eq "image/gif" or $type eq "image/x-gif"){
            $extension = "gif";
        }elsif($filename =~ /\.pdf$/i){
            $extension = 'pdf';
        }elsif($filename =~ /\.doc$/i){
            $extension = 'doc';
        }elsif($filename =~ /\.xls$/i){
            $extension = 'xls';
        }elsif($filename =~ /\.csv$/i){
            $extension = 'csv';
        }elsif($filename =~ /\.ppt$/i){
            $extension = 'ppt';
        }elsif($filename =~ /\.docx$/i){
            $extension = 'docx';
        }elsif($filename =~ /\.xlsx$/i){
            $extension = 'xlsx';
        }elsif($filename =~ /\.pptx$/i){
            $extension = 'pptx';
        }elsif($filename =~ /\.swf$/i){
            $extension = 'swf';
        }elsif($filename =~ /\.mp4$/i){
            $extension = 'mp4';
        }elsif($filename =~ /\.zip$/i){
            $extension = 'zip';
        }elsif($filename =~ /\.txt$/i){
            $extension = 'txt';
        }else{
            msg_add("danger","File type not supported.");
            return "";
        }
        $file = $name . '.' . $extension;
        if (-e "data/$dir/$file") {
             foreach my $it (1 .. 1000000) {
                 $file = $name.'_'.$it . '.' . $extension;
                 if(!(-e "data/$dir/$file")){
                     last;
                 }
             }
         }

        open (OUTFILE,">data/$dir/" . $file) or die "$!";
        binmode(OUTFILE);
        print OUTFILE $self->param($cgi_param);
        close(OUTFILE);
        return $file;
    }
    return "";
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
  return $self->{Zera}->{_DBH}->{_dbh}->selectall_arrayref(shift, {slice=>{}}, @_);
}

sub dbh_do {
    my $self = shift;
    return $self->{Zera}->{_DBH}->{_dbh}->do(shift, shift, @_);
}

# Email Functions
sub send_html_email {
    my $self = shift;
    my $vars = shift;

    $self->{Zera}->{_EMAIL}->send_html_email($vars);
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
