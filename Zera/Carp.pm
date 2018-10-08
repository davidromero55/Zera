package Zera::Carp;

require 5.000;
use Exporter;
#use Carp;
BEGIN {
    *CORE::GLOBAL::die   = \&Zera::Carp::die;
    $main::SIG{__WARN__} = \&Zera::Carp::die;
    $main::SIG{__DIE__}  = \&Zera::Carp::die;
}

sub die {
    my $mess = shift;
    my @call_details = caller(1);
    $mess = "$call_details[1] Line $call_details[2]. Function ".$call_details[3] . "<br>\n" . $mess;

    my $bytes_written = eval{tell STDOUT};
    if (defined $bytes_written && $bytes_written > 0) {
        $mess = error_template($mess);
        print STDOUT $mess;
    }
    else {
        print STDOUT "Status: 500\n";
        print STDOUT "Content-type: text/html\n\n";
        $mess = full_error_template($mess);
        print STDOUT $mess;
    }
}

sub full_error_template {
    my $msg = shift;
    return qq|
<!DOCTYPE HTML PUBLIC "-//IETF//DTD HTML 2.0//EN">
<html><head>
<title>500 Internal Server Error</title>
</head><body>
<h1>Internal Server Error</h1>
<p>The server encountered an internal error or misconfiguration and was unable to complete your request.</p>
<p style="color: #721c24; background-color: #f8d7da; border-color: #f5c6cb; padding: .75rem 1.25rem; margin-bottom: 1rem; border: 1px solid transparent; border-radius: .25rem;">$msg</p>
</body></html>|;
}

sub error_template {
    my $msg = shift;
    return qq|<p style="color: #721c24; background-color: #f8d7da; border-color: #f5c6cb; padding: .75rem 1.25rem; margin-bottom: 1rem; border: 1px solid transparent; border-radius: .25rem;">$msg</p>|;
}
