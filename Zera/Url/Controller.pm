package Zera::Url::Controller;

use base 'Zera::Base::Controller';

sub rewrite_request {
    my $self = shift;
    
    my $entry = $self->{Zera}->{_DBH}->{_dbh}->selectrow_hashref("SELECT module, url FROM entries e WHERE e.url=? AND e.active=1",{}, $self->{Zera}->{_REQUEST}->param('View'));
    if($entry->{module}){
        return ($entry->{module},'Item', $entry->{url})
    }else{
        return ('','','');
    }
}
1;
