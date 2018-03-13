package Zera::Admin::Actions;

use strict;

use base 'Zera::BaseAdmin::Actions';

#use Digest::SHA qw(sha384_hex);

sub do_login {
    my $self = shift;
    my $results = {};

    my $user = $self->{dbh}->selectrow_hashref(
        "SELECT u.user_id, u.email, u.name " .
        "FROM users u " .
        "WHERE u.email=? AND is_admin=1",{},
        $self->param('email'));

        #"WHERE u.email=? AND u.password=? AND is_admin=1",{},
        #$_REQUEST->{email}, sha384_hex($conf->{Security}->{key} . $_REQUEST->{password}));
        
    if($user->{user_id}){
        # Write session data and redirect to dashboard
        $self->{sess}{user_id}    = "$user->{user_id}";
        $self->{sess}{user_name}  = "$user->{name}";
        $self->{sess}{user_email} = "$user->{email}";
        $self->{sess}{user_keep_me_in} = "".$self->param('keep_me_in');
        
        $self->{dbh}->do("UPDATE users SET last_login_on=NOW() WHERE user_id=?",{},$user->{user_id});

        $results->{redirect} = '/AdminDashboard';
        $results->{success} = 1;
        return $results;
    }else{
        $self->add_msg('warning','Username or password incorrect.');
    	$results->{error} = 1;
    	$results->{redirect} = '/Admin/Login?email='.$self->param('email');
        return $results;
    }
}

sub do_logout {
    my $self = shift;
    my $results = {};

    $self->{sess}{user_id}         = "";
    $self->{sess}{user_name}       = "";
    $self->{sess}{user_email}      = "";
    $self->{sess}{user_keep_me_in} = "";

    $self->add_msg('success','Your sessión is now closed');
    
    $results->{error} = 1;
    $results->{redirect} = '/Admin/Msg';
    return $results;
}

sub do_imageupload {
    my $self = shift;
    my $results = {};
    
    return $results;
}

1;