package Zera::Com;

use strict;
use Zera::Conf;

BEGIN {
    use Exporter();
    use vars qw( @ISA @EXPORT @EXPORT_OK );
    @ISA = qw( Exporter );
    @EXPORT = qw(
        $CRLF
    );
}

use vars @EXPORT;

##################################################################################
## App Init
##################################################################################

$CRLF = "\n";
#################################################################################
# Common Functions
#################################################################################

# Print the httpheader including cookie and characterset
sub header {
    my $Zera = shift;
    my $type = shift || 'text/html';
    my $charset = shift || 'utf-8';
    my @header;
    $type .= "; charset=$charset";
    push(@header,"Set-Cookie: " . $Zera->{_SESS}->{cookie}) if($Zera->{_SESS});
    # push(@header,"Expires: " . expires($expires,'http')) if $expires;
    push(@header,"Pragma: no-cache");
    # push(@header,"Content-Disposition: attachment; filename=\"$attachment\"") if $attachment;
    push(@header,"Content-Type: $type");
    my $header = join($CRLF,@header)."${CRLF}${CRLF}";
    return $header;
}

sub template {
    return Template->new({
        TAG_STYLE => 'asp',
    }) || die "$Template::ERROR\n";
}

1;
