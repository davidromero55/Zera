#!/usr/bin/perl

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

if(!$ENV{QUERY_STRING}){
    print "Content-Type: text/html\n\n";
    # If no query string is present check if the required modules are installed
    # and send a welcome page.
    print welcome_template();

    create_conf_pm();

    exit 0;
}else{
    # Load required modules
    require ZeraInstall;
    #print "Content-Type: text/html\n\n";
    #foreach my $key (keys %ENV){
    #    print "$key = $ENV{$key}  <br>\n";
    #}
    my $Zera = ZeraInstall->new();
    $Zera->run();
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

    # Test write permissions
    open(CONF,'>>install.pid') or $errors_html = '<div class="alert alert-danger" role="alert">Write permissions are required on home folder and Zera folder.</div>' .$!;
    unlink 'install.pid';

    my $welcome .= get_html_file('welcome');
    if($errors or $errors_html){
        $welcome =~ s/<% content %>/$errors_html/;
    }else{
        my $next_html = q|
        <div class="alert alert-success" role="alert">Looks like you have all the stuff we need.!!!</div>
        <div style="margin-top:40px" class="form-group">
            <div class="col-sm-12 controls">
                <a href="install.pl?View=User" class="btn btn-primary col">Continue</a>
            </div>
        </div>
        |;
        $welcome =~ s/<% content %>/$next_html/;
    }
    $HTML .= $welcome;
    $HTML .= get_html_file('footer');

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

sub create_conf_pm {
    # if not exist, create a new Conf.pm file
    if(!(-e ('Zera/Conf.pm'))){
        my $conf = '';
        open SOURCE , 'Zera/Install/tmpl/Conf.pm.Base';
        while (<SOURCE>){
            $conf .= $_;
        }
        close SOURCE;

        open (CONF, '>Zera/Conf.pm');
        print CONF $conf;
        close CONF;
    }
}
