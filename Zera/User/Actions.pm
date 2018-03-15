package Zera::User::Actions;

use strict;
use Zera::Conf;

use base 'Zera::BaseUser::Actions';

sub do_login {
    my $self = shift;
    my $results = {};

    my $user = $self->selectrow_hashref(
        "SELECT u.user_id, u.email, u.name " .
        "FROM users u " .
        "WHERE u.email=? AND password=SHA2(?,256) AND is_admin=1",{},
        $self->param('email'), $conf->{Security}->{Key} . $self->param('password'));
        
    if($user->{user_id}){
        # Write session data and redirect to dashboard
        $self->sess('user_id',"$user->{user_id}");
        $self->sess('user_name',"$user->{name}");
        $self->sess('user_email',"$user->{email}");
        $self->sess('is_admin',"0");
        $self->sess('user_keep_me_in',"".$self->param('keep_me_in'));
        
        $self->dbh_do("UPDATE users SET last_login_on=NOW() WHERE user_id=?",{},$user->{user_id});

        $results->{redirect} = '/UserDashboard';
        $results->{success} = 1;
        return $results;
    }else{
        $self->add_msg('warning','Username or password incorrect.');
    	$results->{error} = 1;
    	$results->{redirect} = '/User/Login?email='.$self->param('email');
        return $results;
    }
}

sub do_logout {
    my $self = shift;
    my $results = {};

    $self->sess('user_id','');
    $self->sess('user_name','');
    $self->sess('user_email','');
    $self->sess('user_keep_me_in','');

    $self->add_msg('success','Your session is now closed');
    
    $results->{error} = 1;
    $results->{redirect} = '/User/Msg';
    return $results;
}

sub do_edit {
    my $self = shift;
    my $results = {};

    eval {
        $self->dbh_do("UPDATE users SET name=? WHERE user_id=?",{},$self->param('name'),$self->sess('user_id'));
    };
    if($@){
        $self->add_msg('warning','Error '.$@);
        $results->{error} = 1;
        return $results;
    }else{
        $results->{redirect} = '/User';
        $results->{success} = 1;
        return $results;
    }
}

sub do_password_update {
    my $self = shift;
    my $results = {};

    # Validate current password
    my $is_current_password_ok = $self->selectrow_array(
        "SELECT user_id FROM users WHERE user_id=? AND password=SHA2(?,256)",{},
        $self->sess('user_id'), $conf->{Security}->{Key} . $self->param('current_password'));
    if(!$is_current_password_ok){
        $self->add_msg('warning','Please enter your correct current password and try again.');
        $results->{error} = 1;
        return $results;
    }
    
    # Validate new password complexity
    my $new_password = $self->param('new_password');
    if(length($new_password) < 8){
        $self->add_msg('warning','Enter a longer password.');
        $results->{error} = 1;
    }
    if(!($new_password =~ /[A-Z]/)){
        $self->add_msg('warning','Use upper case.');
        $results->{error} = 1;
    }
    if(!($new_password =~ /[a-z]/)){
        $self->add_msg('warning','Use lowercase.');
        $results->{error} = 1;
    }
    if(!($new_password =~ /[0-9]/)){
        $self->add_msg('warning','Use numbers.');
        $results->{error} = 1;
    }
    if(!($new_password =~ /\W/)){
        $self->add_msg('warning','Use a special character or simbol (# - % & / ! $  ?).');
        $results->{error} = 1;
    }

    if($new_password ne $self->param('new_password_confirm')){
        $self->add_msg('warning','Your new passsword and the confirmation are not equal.');
        $results->{error} = 1;
    }
    
    if($results->{error}){
        return $results;
    }
    
    eval {
        $self->dbh_do("UPDATE users SET password=SHA2(?,256) WHERE user_id=?",{}, $conf->{Security}->{Key} . $new_password, $self->sess('user_id'));
    };
    if($@){
        $self->add_msg('warning','Error '.$@);
        $results->{error} = 1;
        return $results;
    }else{
        $results->{redirect} = '/User';
        $results->{success} = 1;
        $self->add_msg('success','Your new password is ready.');
        return $results;
    }
}

1;