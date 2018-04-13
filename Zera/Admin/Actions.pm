package Zera::Admin::Actions;

use strict;
use Zera::Conf;
use Digest::SHA qw(sha384_hex);

use base 'Zera::BaseAdmin::Actions';

sub do_login {
    my $self = shift;
    my $results = {};
    my $user = $self->selectrow_hashref(
        "SELECT u.user_id, u.email, u.name " .
        "FROM users u " .
        "WHERE u.email=? AND password = ? AND is_admin=1",{},
        $self->param('email'), sha384_hex($conf->{Security}->{Key} . $self->param('password')));

    if($user->{user_id}){
        # Write session data and redirect to dashboard
        $self->sess('user_id',"$user->{user_id}");
        $self->sess('user_name',"$user->{name}");
        $self->sess('user_email',"$user->{email}");
        $self->sess('is_admin',"1");
        $self->sess('user_keep_me_in',"".$self->param('keep_me_in'));

        $self->dbh_do("UPDATE users SET last_login_on=NOW() WHERE user_id=?",{},$user->{user_id});

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

    $self->sess('user_id','');
    $self->sess('user_name','');
    $self->sess('user_email','');
    $self->sess('user_keep_me_in','');

    $self->add_msg('success','Your session is now closed');

    $results->{error} = 1;
    $results->{redirect} = '/Admin/Msg';
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
        $results->{redirect} = '/Admin';
        $results->{success} = 1;
        return $results;
    }
}

sub do_forgot_password {
    my $self = shift;
    my $results = {};
    my $sub_view = $self->param('SubView') || "";

    # Generate recovery keys
    if(length($sub_view) < 10){
        my $user = $self->selectrow_hashref(
            "SELECT u.user_id, u.email, u.name " .
            "FROM users u " .
            "WHERE u.email=? AND is_admin = 1",{},
            $self->param('email'));

        if($user->{user_id}){
            # Wrike recovery data and send by email
            my $key = $self->selectrow_array("SELECT SUBSTRING(SHA2(CONCAT(RAND(1000),NOW(),?),384),1,64)",{}, $conf->{Security}->{Key});

            $self->dbh_do("UPDATE users SET password_recovery_expires=DATE_ADD(NOW(),INTERVAL 1 HOUR), " .
                "password_recovery_key=? WHERE user_id=?",{},
                $key, $user->{user_id});

            my $sent = $self->send_html_email({
                to => "$user->{name} <$user->{email}>",
                subject => 'password-reset',
                vars => {
                    name => $user->{name},
                    password_reset_link => $conf->{App}->{URLLink} . '/Admin/ForgotPassword/'.$key.$user->{user_id}
                }
            });

            if(!$sent){
                $results->{success} = 0;
                $results->{redirect} = '/User/Msg';
                return $results;
            }
        }

        $self->add_msg('success','Check your email address inbox for instructions.');
        $results->{redirect} = '/Admin/
        Msg';
        $results->{success} = 1;
        return $results;

    }


    # Reset password
    if(length($sub_view) > 10){
        # If there are a key check if is valid.
        my $key = substr($sub_view,0,64);
        my $user_id = substr($sub_view,64,65);
        my $user = $self->selectrow_hashref(
            "SELECT user_id, name, email FROM users WHERE user_id=? AND password_recovery_key=? AND password_recovery_expires > NOW()",
            {}, $user_id, $key);

        # Validate new password complexity
        my $new_password = $self->param('new_password');
        if(length($new_password) < 8){
            $self->add_msg('warning','Enter a longer new password.');
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

        if($user->{user_id}){
            $self->dbh_do("UPDATE users SET password = ?, password_recovery_key='' " .
                "WHERE user_id=?",{},
                sha384_hex($conf->{Security}->{Key} . $new_password), $user->{user_id});
                $self->add_msg('success','Your new password is ready. now you can login into your account.');
                $results->{success} = 0;
                $results->{redirect} = '/User/Msg';
                return $results;

        }else{
            $self->add_msg('danger','Your key is not valid, please try again.');
            $results->{success} = 0;
            $results->{redirect} = '/User/Msg';
            return $results;
        }
    }
}

sub do_password_update {
    my $self = shift;
    my $results = {};

    # Validate current password
    my $is_current_password_ok = $self->selectrow_array(
        "SELECT user_id FROM users WHERE user_id=? AND password = ? ",{},
        $self->sess('user_id'), sha384_hex($conf->{Security}->{Key} . $self->param('current_password')));

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
        $self->dbh_do("UPDATE users SET password = ? WHERE user_id=?",{}, sha384_hex($conf->{Security}->{Key} . $new_password), $self->sess('user_id'));

    };
    if($@){
        $self->add_msg('warning','Error '.$@);
        $results->{error} = 1;
        return $results;
    }else{
        $results->{redirect} = '/Admin';
        $results->{success} = 1;
        $self->add_msg('success','Your new password is ready.');
        return $results;
    }
}

1;
