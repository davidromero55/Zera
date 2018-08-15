package Zera::User::API;

use strict;
use JSON;
use Zera::Conf;
use Digest::SHA qw(sha384_hex);

use base 'Zera::BaseUser::API';

sub do_signup {
    my $self = shift;
    my $response = $self->{response};

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
            $response->{msg} = ("El correo electrónico ya esta registrado.") . $self->get_msg();
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

1;
