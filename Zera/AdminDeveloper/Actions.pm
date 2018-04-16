package Zera::AdminDeveloper::Actions;

use strict;
use Zera::Conf;
use Digest::SHA qw(sha384_hex);
use File::Basename;
use File::Path qw/make_path/;

use base 'Zera::BaseAdmin::Actions';

sub do_home{
    my $self = shift;
    my $results = {};
    my $module_type = $self->param('type');
    my $module_folder_prefix = $module_type eq 'Public' ? '' : $module_type;
    my $on_menu = 0;

    $on_menu = 1 if($self->param('on_menu'));
    
    my $root = 'Zera/'.$module_folder_prefix.$self->param('name');
    my $paths = [$root.'/Controller.pm',$root.'/Actions.pm',$root.'/View.pm',$root.'/tmpl/display_home.html'];

    if($self->param('_submit') eq 'Save'){
        if(-d $root){
            $self->add_msg('warning', 'The module name already exists');
            $results->{redirect} = '/AdminDeveloper';
            return $results;
        }

        if(!($self->param('name') =~ /[A-Z]./)){
            $self->add_msg('warning','Module name has to start with capital letter');
            $results->{redirect} = '/AdminDeveloper';
            return $results;   
        }

        eval{
            make_path($root);
            make_path($root.'/tmpl/');

            foreach my $path(@{$paths}){
                unless(open FILE, '>'.$path) {
                    # Die with error message 
                    # if we can't open it.
                    die "\nUnable to create $path\n";
                }
                # close the file.
                close FILE;
            }

            _create_controller_content($module_folder_prefix.$self->param('name'),$module_type);
            _create_actions_content($module_folder_prefix.$self->param('name'),$module_type);
            _create_view_content($module_folder_prefix.$self->param('name'),$module_type);
            _create_home_content($module_folder_prefix.$self->param('name'),$module_type);

            if($on_menu){
                my $sort_order = $self->selectrow_array("(SELECT MAX(sort_order) + 1 FROM menus)",{});
                $self->dbh_do("INSERT INTO menus (module_key,`group`,url,name,sort_order) VALUES (?,?,?,?,?)",{},
                    $self->param('name'), $module_type, '/'.$module_folder_prefix.$self->param('name'), $self->param('name'),$sort_order);
            }
        };

        if($@){
            $self->add_msg('warning','Error '.$@);
            $results->{error} = 1;
        }else{
            $results->{redirect} = '/AdminDeveloper';
            $results->{success} = 1;
            $self->add_msg('success','Module added succesfully');
        }
    }

    return $results;
}

sub _create_controller_content{
    my $module_name = shift || '';
    my $module_type = shift || '';

    my $base = $module_type eq 'Public' ? '' : $module_type;
    my $src = 'Zera/'.$module_type.'HelloWorld/Controller.pm';
    my $path = 'Zera/'.$module_name.'/Controller.pm';

    unless(open SRC, '<'.$src){

        die "\nUnable to open example $src\n";
    }

    unless(open FILE, '>'.$path) {
        # Die with error message 
        # if we can't open it.
        die "\nUnable to create $path\n";
    }

    my $replace_module = $module_name;
    my $replace_base = "Base".$module_type;
    while(my $line = <SRC>){
        if($line =~ /(AdminHelloWorld)|(UserHelloWorld)|(HelloWorld)/){
            $line =~ s/(AdminHelloWorld)|(UserHelloWorld)|(HelloWorld)/$replace_module/g;    
        }
        if($line =~ /(BaseAdmin)|(BaseUser)|(Base)/){
            $line =~ s/(BaseAdmin)|(BaseUser)|(Base)/$replace_base/g;    
        }
        
        print FILE $line;
    }

    # close the file.
    close SRC;
    close FILE;
} 

sub _create_actions_content{
    my $module_name = shift || '';
    my $module_type = shift || '';

    my $base = $module_type eq 'Public' ? '' : $module_type;
    my $path = 'Zera/'.$module_name.'/Actions.pm';
    my $src = 'Zera/'.$module_type.'HelloWorld/Actions.pm';

    unless(open SRC, '<'.$src){
        die "\nUnable to open example $src\n";
    }

    unless(open FILE, '>'.$path) {
                    # Die with error message 
                    # if we can't open it.
                    die "\nUnable to create $path\n";
    }

    my $replace_module = $module_name;
    my $replace_base = "Base".$module_type;
    while(my $line = <SRC>){
        if($line =~ /(AdminHelloWorld)|(UserHelloWorld)|(HelloWorld)/){
            $line =~ s/(AdminHelloWorld)|(UserHelloWorld)|(HelloWorld)/$replace_module/g;    
        }
        if($line =~ /(BaseAdmin)|(BaseUser)|(Base)/){
            $line =~ s/(BaseAdmin)|(BaseUser)|(Base)/$replace_base/g;    
        }
        
        print FILE $line;
    }

    # close the file.
    close SRC;
    close FILE;
}

sub _create_view_content{
    my $module_name = shift || '';
    my $module_type = shift || '';

    my $base = $module_type eq 'Public' ? '' : $module_type;
    my $path = 'Zera/'.$module_name.'/View.pm';
    my $src = 'Zera/'.$module_type.'HelloWorld/View.pm';

    unless(open SRC, '<'.$src){
        die "\nUnable to open  $src\n";
    }

    unless(open FILE, '>'.$path) {
        # Die with error message 
        # if we can't open it.
        die "\nUnable to create $path\n";
    }

    my $replace_module = $module_name;
    my $replace_base = "Base".$module_type;
    while(my $line = <SRC>){
        if($line =~ /(AdminHelloWorld)|(UserHelloWorld)|(HelloWorld)/){
            $line =~ s/(AdminHelloWorld)|(UserHelloWorld)|(HelloWorld)/$replace_module/g;    
        }
        if($line =~ /(BaseAdmin)|(BaseUser)|(Base)/){
            $line =~ s/(BaseAdmin)|(BaseUser)|(Base)/$replace_base/g;    
        }
        
        print FILE $line;
    }

    # close the file.
    close SRC;
    close FILE;
}

sub _create_home_content{
    my $module_name = shift || '';
    my $module_type = shift || '';
    my $path = 'Zera/'.$module_name.'/tmpl/display_home.html';
    my $src = 'Zera/'.$module_type.'HelloWorld/tmpl/display_home.html';

    unless(open SRC, '<'.$src){
        die "\nUnable to read $src\n";
    }

    unless(open FILE, '>'.$path) {
        # Die with error message 
        # if we can't open it.
        die "\nUnable to create $path\n";
    }


    while(my $line = <SRC>){
        print FILE $line;
    }

    # close the file.
    close SRC;
    close FILE;
}

1;