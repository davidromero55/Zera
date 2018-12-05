package ZeraCron;

use Zera::Conf;
use Zera::Com;
use Zera::DBI;
use Zera::Email;

sub new {
    my $class    = shift;
    my $self     = {};
    bless $self,$class;
    $self->{Controller} = shift;
    $self->{action} = shift;
    $self->{debug} = 1;
    $self->_init();
    return $self;
}

sub _init {
    my $self = shift;
    $self->{_DBH}  = Zera::DBI->new();
    $self->{_EMAIL} = Zera::Email->new($self);

    # Clear and secure user input
    $self->{Controller} =~s/\W//g;
    $self->{action} = lc($self->{action});
    $self->{action} =~s/\W//g;

}

sub debug {
    my $self = shift;
    $self->{debug} = shift;
}

sub run {
    my $self = shift;

    # Header
    print "Zera Cron Runing\n";
    print "Controller: $self->{Controller}\n" if($self->{debug});
    print "Action: $self->{action}\n" if($self->{debug});
    print "Start on " . time() . "\n" if($self->{debug});

    if($self->{Controller}){

        # Load module
        my $Module;
        eval {
            require "Zera/".$self->{Controller} ."/Cron.pm";
        };
        if($@){
            print "    Error, Can't load Zera Controller : $self->{Controller}\n";
            print "        $@\n";
            $self->clear();
            return '';
        }

        # Init module
        my $module_name ='Zera::'.$self->{Controller}.'::Cron';
        $Module = $module_name->new($self);

        # Exec function
        my $sub_name = "exec_" . $self->{action};
        if ($Module->can($sub_name) ) {
            $Module->$sub_name();
        } else {
            print "    Error, function $sub_name not found on Zera Controller $self->{Controller}\n\n";
        }
    }else{
        print "Zera Controller: $self->{Controller} not defined.\n\n";
    }
    $self->clear();

}

sub clear {
    my $self = shift;
    $self->{_DBH}->disconnect();
    print "Ends on " . time() . "\n" if($self->{debug});
    exit;
}

1;
