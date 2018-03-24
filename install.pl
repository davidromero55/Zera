#!/usr/bin/perl -w

use strict;

# Main vars
my $required_modules = [
    'CGI::Minimal',
    'Template',
    'DBI',
    'DBD::mysql',
    'Apache::Session',
    'Apache::Session::MySQL',
    'JSON::XS',
    'JSON',
    'Switch',
    'Number::Format'];

print "Content-Type: text/html\n\n";
if(!$ENV{QUERY_STRING}){
    # If no query string is present check if the required modules are installed
    # and send a welcome page.
    print welcome_template();
    exit 0;
}else{
    # Load required modules
    require CGI::Minimal;
    require DBI;
    require Template;

    my $_REQUEST = CGI::Minimal->new();

    if($_REQUEST->param('step') eq '2'){
        print database_check_template();
    }
    exit 0;
}

sub welcome_template {
    my $HTML = '';
    my $errors = 0;
    my $errors_html = '';
    $HTML = get_html_file('header');

    # Test required modules
    foreach my $module (@$required_modules  ){
        eval "require $module;";
        if($@){
            $errors_html .= '<div class="alert alert-danger" role="alert">The ' .$module .' module is not available, please install it to continue.</div>';
            $errors = 1;
        }
    }
    my $welcome .= get_html_file('welcome');
    if($errors){
        $welcome =~ s/<% content %>/$errors_html/;
    }else{
        my $next_html = q|
        <div class="alert alert-success" role="alert">Looks like you have all the stuff we need.!!!</div>
        <div style="margin-top:40px" class="form-group">
            <div class="col-sm-12 controls">
                <a href="install.pl?step=2" class="btn btn-primary col">Continue</a>
            </div>
        </div>
        |;
        $welcome =~ s/<% content %>/$next_html/;
    }
    $HTML .= $welcome;
    $HTML .= get_html_file('footer');

    return $HTML;
}


# Step 2
sub database_check_template {
    my $HTML = '';
    my $tt = template();
    my $tt_vars = {
    	#sess    => \%sess,
    };

    $tt->process('templates/ZeraInstall/database_form.html', $tt_vars, \$HTML) or $HTML = $tt->error();
    return $HTML;
}

# Common functions
sub get_html_file {
    my $file = shift;
    my $HTML = '';
    open (FILE,'templates/ZeraInstall/' . $file . '.html') or return 'Check the file permisions and owner.';
    while (<FILE>){
        $HTML .= $_;
    }
    close HEADER;
    return $HTML;
}

sub template {
    return Template->new({
        TAG_STYLE => 'asp',
    }) || die "$Template::ERROR\n";
}
