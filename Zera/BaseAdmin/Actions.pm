package Zera::BaseAdmin::Actions;

use strict;
use JSON;

use Zera::Conf;
use Zera::LayoutAdmin;

sub new {
    my $class = shift;
    my $self = {
        version  => '0.1',
    };
    bless $self, $class;
    
    # Main Zera object
    $self->{Zera} = shift;

    $self->{dbh} = $self->{Zera}->{_DBH}->{_dbh};
    
    # Init app ENV
    $self->_init();

    return $self;
}

sub _init {
    my $self = shift;
}

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

sub process_action {
    my $self = shift;
    my $arg = $self->param('View');
    $arg =~ s/\W//g;
    if(!($arg)){
        $arg = $self->param('_Action');
        $arg =~ s/\W//g;
    }
    my $sub_name = "do_" . lc($arg);
    if ($self->can($sub_name) ) {
        return $self->$sub_name();
    } else {
        $self->add_msg('danger','Action ' . $sub_name . ' not implemented.');
        return {error => 1};
    }
}

sub add_msg {
    my $self = shift;
    $self->{Zera}->add_msg(shift, shift);
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
    
    if(!(-e "data/img")){
        mkdir ("data/img") or die $!
    }
    
    if(!(-e "data/$dir")){
        mkdir ("data/$dir") or die $!
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

1;