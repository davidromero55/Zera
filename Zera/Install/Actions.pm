package Zera::Install::Actions;

use strict;
use JSON;

use Zera::Conf;

use base 'Zera::Base::Actions';

sub do_user {
    my $self = shift;
    my $results = {};

    if($self->param('_submit') eq 'Next'){
        my $name  = $self->param('Name');
        my $email = $self->param('Email');

        if(length($name) < 4){
            $self->add_msg('warning','Please enter your name.');
            $results->{errors} ++;
        }

        if($email !~ /^(([^<>()\[\]\\.,;:\s@"]+(\.[^<>()\[\]\\.,;:\s@"]+)*)|(".+"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$/){
            $self->add_msg('warning','Please enter a valid email address.');
            $results->{errors} ++;
        }
        if($results->{errors}){
            return $results;
        }else{

            $self->{Zera}->{_CONF}->{User} = {
                Name => $name,
                Email => $email,
            };

            $results->{redirect} = '/install.pl?View=Database';
            $results->{success} = 1;
            return $results;
        }
    }
}

sub do_database {
    my $self = shift;
    my $results = {};

    if($self->param('_submit') eq 'Next'){
        my $database = $self->param('Database');
        my $username = $self->param('Username');
        my $password = $self->param('Password');
        my $host = $self->param('Host');

        if($host){
            if($host !~ /^(([a-zA-Z0-9]|[a-zA-Z0-9][a-zA-Z0-9\-]*[a-zA-Z0-9])\.)*([A-Za-z0-9]|[A-Za-z0-9][A-Za-z0-9\-]*[A-Za-z0-9])$/ and
                $host !~ /^(([0-9]|[1-9][0-9]|1[0-9]{2}|2[0-4][0-9]|25[0-5])\.){3}([0-9]|[1-9][0-9]|1[0-9]{2}|2[0-4][0-9]|25[0-5])$/){
                    $self->add_msg('warning','Please enter a valid Server host.');
                    $results->{errors} ++;
            }
        }


        if(length($database) < 4){
            $self->add_msg('warning','Please enter your mysql database name.');
            $results->{errors} ++;
        }
        if($database !~ /^\w+$/){
            $self->add_msg('warning','Please enter a valid database name.');
            $results->{errors} ++;
        }
        if(length($username) < 4){
            $self->add_msg('warning','Please enter your username.');
            $results->{errors} ++;
        }
        if($username !~ /^\w+$/){
            $self->add_msg('warning','Please enter a valid username.');
            $results->{errors} ++;
        }

        if(!$results->{errors}){
            # Try to connect
            my $dbi_error = '';
            my $dsn = 'dbi:mysql:' . $database;
            $dsn .= ':' . $self->param('Host') if($self->param('Host'));
            $dsn .= ':' . $self->param('Port') if($self->param('Port'));
            $dsn .= ';mysql_connect_timeout=5';
            eval {
                my $dbh = DBI->connect($dsn, $username, $password, {PrintError=>0, RaiseError => 0}) or $dbi_error = DBI->errstr;
            };
            if($dbi_error){
                $self->add_msg('warning',$dbi_error);
                $results->{errors} ++;
            }
        }

        if($results->{errors}){
            return $results;
        }else{
            $self->{Zera}->{_CONF}->{Database} = {
                Host     => $self->param('Host'),
                Port     => $self->param('Port'),
                Database => $self->param('Database'),
                Username => $self->param('Username'),
                Password => $self->param('Password'),
                Timezone => $self->param('Timezone'),
            };

            $results->{redirect} = '/install.pl?View=Website';
            $results->{success} = 1;
            return $results;
        }
    }
}

sub do_website {
    my $self = shift;
    my $results = {};

    if($self->param('_submit') eq 'Next'){
        my $name  = $self->param('Name');
        my $url   = lc($self->param('URL'));

        if(length($name) < 4){
            $self->add_msg('warning','Please enter your website name.');
            $results->{errors} ++;
        }

        if($url !~ /^(([a-zA-Z0-9]|[a-zA-Z0-9][a-zA-Z0-9\-]*[a-zA-Z0-9])\.)*([A-Za-z0-9]|[A-Za-z0-9][A-Za-z0-9\-]*[A-Za-z0-9])$/ and
            $url !~ /^(([0-9]|[1-9][0-9]|1[0-9]{2}|2[0-4][0-9]|25[0-5])\.){3}([0-9]|[1-9][0-9]|1[0-9]{2}|2[0-4][0-9]|25[0-5])$/){
            $self->add_msg('warning','Please enter a valid domain name.');
            $results->{errors} ++;
        }
        if($results->{errors}){
            return $results;
        }else{

            $self->{Zera}->{_CONF}->{Website} = {
                Name => $name,
                URL => $url,
            };

            $results->{redirect} = '/install.pl?View=Confirm';
            $results->{success} = 1;
            return $results;
        }
    }
}

sub do_confirm {
    my $self = shift;
    my $results = {};

    if($self->param('_submit') eq 'Confirm'){
        require Digest::SHA;

        my $key = Digest::SHA::sha384_hex(time . rand(999999) . $self->{Zera}->{_CONF}->{Website});
        my $user_password = substr(Digest::SHA::sha384_hex(time . rand(999999) . $self->{Zera}->{_CONF}->{User}), 1, 8);

        ############################################################################################
        # Create Conf.pm
        ############################################################################################
        my $tt = Zera::Com::template();
        my $vars = {};
        $vars->{User}        = $self->{Zera}->{_CONF}->{User};
        $vars->{Database}    = $self->{Zera}->{_CONF}->{Database};
        $vars->{Website}     = $self->{Zera}->{_CONF}->{Website};
        $vars->{SecurityKey} = $key;

        my $conf_file_contents = '';
        $tt->process('Zera/Install/tmpl/Conf.pm', $vars, \$conf_file_contents) || die $tt->error(), "\n";

        open (CONF, '>Zera/Conf.pm');
        print CONF $conf_file_contents;
        close CONF;

        ############################################################################################
        # Setup Database
        ############################################################################################
        # Database connection
        my $dbi_error = '';
        my $dbh;
        my $dsn = 'dbi:mysql:' . $vars->{Database}->{Database};
        $dsn .= ':' . $vars->{Database}->{Host} if($vars->{Database}->{Host});
        $dsn .= ':' . $vars->{Database}->{Port} if($vars->{Database}->{Port});
        $dsn .= ';mysql_connect_timeout=5';
        eval {
            $dbh = DBI->connect($dsn, $vars->{Database}->{Username}, $vars->{Database}->{Password}, {PrintError=>0, RaiseError => 0}) or $dbi_error = DBI->errstr;
        };
        if($dbi_error){
            $self->add_msg('warning',$dbi_error);
            $results->{errors} ++;
        }

        if(!$results->{errors}){
            # Database structure setup
            open (SQL,"Zera/Install/tmpl/database.sql") or die "Can't open SQL file.\n\n";
            my $SQL = '';
            while(<SQL>){
                $SQL .= $_;
            }
            close SQL;
            my @instructions = split(/;/,$SQL);
            foreach my $sql (@instructions){
                $sql =~ s/\n/ /g;
                next if($sql eq ' ' or $sql eq '  ' or $sql eq '   ' or $sql eq '     ');
                eval {
                    $dbh->do("$sql") if(length( $sql ) > 0);
                };
                if($@){
                    $self->add_msg('warning',"Error ".$@);
                }
            }
        }

        ############################################################################################
        # User
        ############################################################################################
        $dbh->do(
            "INSERT INTO `users` (`user_id`,`email`,`password`,`name`,`last_login_on`,`password_recovery_expires`,`password_recovery_key`,`created_on`,`account_validated`,`is_admin`) " .
            "VALUES (1,?,?,?,NOW(),NULL,NULL,NOW(),1,1)",{},
            $vars->{User}->{Email}, Digest::SHA::sha384_hex($vars->{SecurityKey} . $user_password), $vars->{User}->{Name});

        $self->{Zera}->{_CONF}->{User}->{Password} = $user_password;

        ############################################################################################
        if($results->{errors}){
            return $results;
        }else{

            $results->{redirect} = '/install.pl?View=Clean';
            $results->{success} = 1;

            return $results;
        }
    }
}

sub do_clean {
    my $self = shift;
    my $results = {};

    if($self->param('_submit') eq 'Clean'){
        require File::Path;

        # Delete Files
        my @files = ('install.pl','ZeraInstall.pm','INSTALL.json','LICENSE','README.md','TODO.txt');
        my @dirs = ('install','testing','Zera/Install','templates/ZeraInstall');

        foreach my $file (@files){
            unlink $file;
        }

        foreach my $dir (@dirs){
            File::Path::remove_tree($dir);
        }

        $results->{redirect} = '/Admin';
        $results->{success} = 1;
        return $results;

        # File permisions
        chmod 0755, "index.pl";
    }
}

1;
