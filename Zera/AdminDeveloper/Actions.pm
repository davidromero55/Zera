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
            _create_home_content($module_folder_prefix.$self->param('name'));

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
    my $path = 'Zera/'.$module_name.'/Controller.pm';

    unless(open FILE, '>'.$path) {
                    # Die with error message 
                    # if we can't open it.
                    die "\nUnable to create $path\n";
    }

    print FILE "package Zera::".$module_name."::Controller;\n\n";
    print FILE "use base 'Zera::Base".$base."::Controller';\n";
    print FILE "1;";

    # close the file.
    close FILE;
} 

sub _create_actions_content{
    my $module_name = shift || '';
    my $module_type = shift || '';

    my $base = $module_type eq 'Public' ? '' : $module_type;
    my $path = 'Zera/'.$module_name.'/Actions.pm';

    unless(open FILE, '>'.$path) {
                    # Die with error message 
                    # if we can't open it.
                    die "\nUnable to create $path\n";
    }

    print FILE "package Zera::".$module_name."::Actions;\n\n";
    print FILE "use strict;\n"; 
    print FILE "use JSON;\n\n";
    print FILE "use Zera::Conf;\n\n";
    print FILE "use base 'Zera::Base".$base."::Actions';\n";
    print FILE "1;";

    # close the file.
    close FILE;
}

sub _create_view_content{
    my $module_name = shift || '';
    my $module_type = shift || '';

    my $base = $module_type eq 'Public' ? '' : $module_type;
    my $path = 'Zera/'.$module_name.'/View.pm';


    unless(open FILE, '>'.$path) {
        # Die with error message 
        # if we can't open it.
        die "\nUnable to create $path\n";
    }

    print FILE "package Zera::".$module_name."::View;\n\n";
    print FILE "use Zera::Conf;\n";
    print FILE "use base 'Zera::Base".$base."::View';\n\n";
    print FILE "# Module Functions\n";
    print FILE "sub display_home {\n";
    print FILE '   my $self = shift;'."\n";        
    print FILE '   $self->set_title("Hello World");'."\n\n";     
    print FILE '   my $vars = {'."\n";
    print FILE "   };\n";
    print FILE '   return $self->render_template($vars);'."\n";
    print FILE "}\n\n";
    print FILE "1;";

    # close the file.
    close FILE;
}

sub _create_home_content{
    my $module_name = shift || '';
    my $path = 'Zera/'.$module_name.'/tmpl/display_home.html';

    unless(open FILE, '>'.$path) {
        # Die with error message 
        # if we can't open it.
        die "\nUnable to create $path\n";
    }

    print FILE "<h2><% page.title %></h2>\n";
    print FILE "<p>This is the module created by the developer tools.</p>\n";

    print FILE "<div class='row justify-content-center'>\n";
    print FILE "    <div class='col-4'>\n";
    print FILE "        Template.\n";

    print FILE "    </div>\n";
    print FILE "    <div class='col-4'>\n";
    print FILE "        List.\n";
    print FILE "    </div>\n";
    print FILE "    <div class='col-4'>\n";
    print FILE "        Form.\n";
    print FILE "    </div>\n";
    print FILE "</div>\n";


    # close the file.
    close FILE;
}

1;