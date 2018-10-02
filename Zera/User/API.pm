package Zera::User::API;

use strict;
use JSON;
use Zera::Conf;
use Digest::SHA qw(sha384_hex);

use base 'Zera::BaseUser::API';

sub do_signup {
    my $self = shift;
    my $response = $self->{response};

    if(!$self->conf('User','SignupAllowed')){
      $results->{msg} = 'Signup not allowed.';
      return $results;
    }

    # email validation
    my $email = lc($self->param('email'));
    if($email !~ /^[\w\-\+\._]+\@[a-zA-Z0-9][-a-zA-Z0-9\.]*\.[a-zA-Z]+$/){
        $response->{msg} = 'Introduce un correo válido';
        $response->{status} = 'error';
        return $response;
    }

    my $exist = $self->selectrow_hashref("SELECT u.user_id, u.email, u.name, password FROM users u WHERE u.email=?",{},$email);
    if($exist->{user_id}){
        if($exist->{password} ne ""){
            $response->{msg} = "El correo electrónico ya esta registrado.";
            $response->{status} = 'error';
            return $response;
        }
    }

    # User creation
    eval {
     	if($exist->{user_id}){
            $self->dbh_do("UPDATE users SET name=?, password = ? WHERE user_id = ?",{},
                          $self->param('name'),sha384_hex($conf->{Security}->{Key} . $self->param('password')),$exist->{user_id});

            my $request_token = sha1_hex($conf->{Security}->{Key} . time() . rand(999) . $self->param('device_id'));
            my $exist_device = int($self->dbh_do("UPDATE devices SET last_request_on=NOW(), request_token=?, push_token=? WHERE device_id=? AND user_id=?",{},
                                            $request_token, $self->param('token'), $self->param('device_id'), $exist->{user_id}));
            if(!$exist_device){
                $self->dbh_do("INSERT INTO devices(device_id, user_id, added_on, last_request_on, platform, request_token, push_token) VALUES(?,?,NOW(),NOW(),?,?,?)",{},
                         $self->param('device_id'), $exist->{user_id}, $self->param('platform'), $request_token, $self->param('token'));
            }
            my $user = $self->selectrow_hashref("SELECT user_id, name, email, time_zone, language FROM users WHERE user_id=?",{},$exist->{user_id});
            $response->{data} = $user;
            $response->{data}->{token} = $request_token;
            $response->{status} = 'success';
        }else{
            $self->dbh_do("INSERT INTO users (name, email, time_zone, language, password, last_login_on, signup_date) VALUES(?,?,?,?,?,NOW(),NOW())",{},
                          $self->param('name'), $self->param('email'), $conf->{App}->{TimeZone}, $conf->{App}->{Language}, sha384_hex($conf->{Security}->{Key} . $self->param('password')) );
            my $user_id = $self->last_insert_id("users",'user_id');

            my $request_token = sha384_hex($conf->{Security}->{Key} . time() . rand(999) . $self->param('device_id'));
            my $exist_device = int($self->dbh_do("UPDATE devices SET last_request_on=NOW(), request_token=?, push_token=? WHERE device_id=? AND user_id=?",{},
                                                 $request_token, $self->param('token'), $self->param('device_id'), $user_id));
            if(!$exist_device){
                $self->dbh_do("INSERT INTO devices(device_id, user_id, added_on, last_request_on, platform, request_token, push_token) VALUES(?,?,NOW(),NOW(),?,?,?)",{},
                              $self->param('device_id'), $user_id, $self->param('platform'), $request_token, $self->param('token'));
            }
            my $user = $self->selectrow_hashref("SELECT user_id, name, email, time_zone, language FROM users WHERE user_id=?",{},$user_id);
            $response->{data} = $user;
            $response->{data}->{token} = $request_token;
            $response->{status} = 'success';
        }
    };
    if ($@) {
        $response->{status} = 'error';
        $response->{msg} = $@.$exist->{user_id};
        return $response;
    }

    # Send Welcome Email
    my $sent = $self->send_html_email(
        {
            to       => $self->param('email'),
            subject  => $conf->{App}->{Name} . ': '. 'Tu cuenta esta lista',
            vars => {
                name     => $self->param('name'),
                email    => $self->param('email'),
                password => $self->param('password'),
            },
        });

    # Welcome msg
    $response->{msg} = 'Tu cuenta fue creada con éxito. ' .
        'Recibirás un correo electrónico de confirmación.';

    return $response;
}

sub do_logout {
    my $self = shift;
    my $response = $self->{response};
    my $email = lc($self->param('email'));
    eval {
        $self->dbh_do("DELETE FROM devices WHERE device_id=? AND user_id=?",{},
                      $self->header('APPDEVICEID'), $self->header('APPUSERID'));
    };
    if ($@) {
        $response->{status} = 'error';
        $response->{msg} = $@;
    }else{
        $response->{status} = 'success';
        $response->{msg} = $self->get_msg();
    }
    return $response;
}

sub do_login {
    my $self = shift;
    my $response = $self->{response};

    my $email = lc($self->param('email'));
    my $user;
    if(($self->param('email')) and ($self->param('password'))){
        #$negocio = $self->selectrow_hashref("SELECT business_id, name FROM business WHERE business_id=? ",{},$self->param('business_id'));
        $user = $self->selectrow_hashref("SELECT user_id, name, email FROM users WHERE email=? AND password=? AND active=1",{},
                                         $self->param('email'), sha384_hex($conf->{Security}->{Key}.$self->param('password')));
    }

    if(!$user){
        $response->{status} = 'error';
        $response->{msg}    = 'Nombre de usuario o contraseña incorrectos.';
        return $response;
    }

    eval {
        $self->dbh_do("UPDATE users SET last_login_on=DATE(NOW()) WHERE user_id=?",{}, $user->{user_id});
        my $request_token = sha384_hex($conf->{Security}->{Key} . time() . rand(999999) . $self->param('device_id'));
        my $exist = int($self->dbh_do("UPDATE devices SET last_request_on=NOW(), request_token=?, push_token=? WHERE device_id=? AND user_id=?",{},
                                      $request_token, $self->param('token'), $self->param('device_id'), $user->{user_id}));
        if(!$exist){
            $self->dbh_do("INSERT INTO devices(device_id, user_id, added_on, last_request_on, platform, request_token, push_token) VALUES(?,?,NOW(),NOW(),?,?,?)",{},
                          $self->param('device_id'), $user->{user_id}, $self->param('platform'), $request_token, $self->param('token'));
        }
        $response->{data} = $user;
        $response->{data}->{token} = $request_token;
    };
    if ($@) {
        $response->{status} = 'error';
        $response->{msg}   = $@;
        $response->{jets}    = $user;
    }else{
        $response->{status} = 'success';
        $response->{msg} = $self->get_msg();
    }

    return $response;
}

sub do_password_reset {
    my $self = shift;
    my $response = $self->{response};

    my $email = lc($self->param('email'));
    eval {
        my $user = $self->selectrow_hashref("SELECT user_id, name, email FROM users WHERE email=?",{},$email);

        if($user and $email){
            # Actualizar DB.
            my $key = $self->selectrow_array("SELECT SUBSTRING(SHA2(CONCAT(RAND(1000),NOW(),?),384),1,64)",{}, $conf->{Security}->{Key});
            $self->dbh_do("UPDATE users SET password_recovery_expires=DATE_ADD(NOW(), INTERVAL 1 HOUR), password_recovery_key=? WHERE user_id=?",{},$key, $user->{user_id});

            # Enviar correo.
            my $sent = $self->send_html_email({
                to       => $self->param('email'),
                subject  => $conf->{App}->{Name} . ' - ' . 'Recuperar contraseña',
                vars => {
                    name     => $self->param('name'),
                    email    => $self->param('email'),
                    password_reset_link => $conf->{App}->{URLLink} . '/User/ForgotPassword/'.$key.$user->{user_id}
                }
                                              });
        }else{
            $response->{msg} = 'El correo no existe.';
            $response->{status} = 'error';
            return $response;
        }
    };
    if ($@) {
        $response->{status} = 'error';
        $response->{msg} = $@;
    }else{
        $response->{status} = 'success';
        $response->{msg} = $self->get_msg();
    }
    return $response;
}

1;
