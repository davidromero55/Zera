package Zera::Template::Plugin::ZeraInclude;

use Zera::Conf;
use Zera::Com;
use base qw( Template::Plugin );

sub new {
	my ($self, $context) = @_;
	return bless {_context => $context},$self;
}

sub block{
	my $self = shift;
	my $block_name = shift || '';
    my $template = shift || 'templates/Blocks/'.$block_name.'html';
    my $HTML = '';

    if(!$template || !$block_name || !(-e $template)){
    	$template = 'templates/Blocks/not_found.html';

    }
    
    $vars->{conf} = $conf;
    $vars->{name} = $block_name;
    
    my $tt = Zera::Com::template();
    $tt->process($template, $vars, \$HTML) || die "$Template::ERROR \n";
    return $HTML;
}

sub partial_view{
    my $self = shift;
    my $parital_view shift || '';

    
}

1;