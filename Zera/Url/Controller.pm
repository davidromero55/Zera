package Zera::Url::Controller;

use base 'Zera::Base::Controller';
use Zera::Conf;

sub rewrite_request {
    my $self = shift;

    my $entry = $self->{Zera}->{_DBH}->{_dbh}->selectrow_hashref("SELECT module, url FROM entries e WHERE e.url=? AND e.active=1",{}, $self->{Zera}->{_REQUEST}->param('View'));
    if($entry->{module}){
        return ($entry->{module},'Item', $entry->{url})
    }else{
        my $file_name = $self->{Zera}->{_REQUEST}->param('View');
        $file_name =~ s/\W!-//g;
        $file_name = lc($file_name);
        if($file_name){
            if (-e ('templates/'.$conf->{Template}->{TemplateID}.'/static/'.$file_name . '.html')) {
                return ('Static','Item',$file_name);
            }elsif (-e ('static/'.$file_name . '.html')) {
                return ('Static','Item',$file_name);
            }
        }
    }
    return ('','','');
}

1;
