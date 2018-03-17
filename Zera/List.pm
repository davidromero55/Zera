package Zera::List;

################################################################################
#
# This is the evolution of the CGI::List CPAN module
#
################################################################################

use strict;
use Zera::Conf;
use Zera::Carp;

require 5.004;
use Math::Round(qw/nearest nhimult/);

our $VERSION = '0.2.0';

sub new {
    my $class    = shift;
    my $self     = {};
    bless $self,$class;

    $self->{Zera} = shift;
    my $params    = shift;

    # Init params
    defined $self->param("zl_list")  or $self->param("zl_list", "");
    defined $self->param("zl_order") or $self->param("zl_order", "");
    defined $self->param("zl_side")  or $self->param("zl_side", "");
    defined $self->param("zl_page")  or $self->param("zl_page", "1");

    #Prevent attacks
    $self->param("zl_order",int($self->param("zl_order") || 0));
    $self->param("zl_page",int($self->param("zl_page") || 0));

    #Predefined values
    $self->{name} = "zera_list";
    $self->{debug} = 0;
    $self->{on_errors} = "print";
    $self->{auto_order} = 1;
    $self->{pagination} = 1;
    $self->{nav_pages}  = 5;
    $self->{custom_labels} = {};
    $self->{hidde_column} = '';
    ($self->{script},$self->{p}) = split(/\?/,$ENV{REQUEST_URI});

    $self->{table} = {
		      width       => "100%",
		      class       => "table table-hover table-striped table-bordered table-sm",
		      align       => "center",
		      cellspacing => "0",
		     };

    $self->{columns}= {params => {}};
    $self->{th} = {params => {scope=>"col", class=>"text-center"}};
    $self->{detail_th} = {params => {}};
    $self->{group_th} = {params => {align=>"left",class=>"zl_group_th"}};
    $self->{group_td} = {params => {align=>"left",class=>"zl_group_td"}};

    $self->{group_item_totals} = {td=>{params=>{class=>"zl_group_item_totals"}}};


    $self->{detail}{td}{params} = {};
    $self->{detail}{Tr}{params_a} = {class=> "zl_row_a"};
    $self->{detail}{Tr}{params_b} = {class=> "zl_row_b"};

    $self->{no_data}{params} = {class=>"zl_no_data", align=>"center"};

    $self->{totals}{td}{params} = {align=>"right",class=>"zl_cell_total"};
    $self->{totals}{Tr}{params} = {class=>"zl_row_total"};

    $self->{foother}{params} = {class=>"zl_foother"};

    $self->{nw_params}="width=600,height=500,toolbar=no,scrollbars=yes,top='+((screen.height/2)-250)+',left='+((screen.width/2)-300)+'";

    $self->{orders} = {};

    $self->{labels} = {
        page_of => '',
        no_data   => 'No hay datos',
        link_up   => '&uarr;',
        link_down => '&darr;',
        next_page => '&raquo;',
        previous_page => '&laquo;',
        number_of_rows => "_NUMBER_ registros",
    };
    $self->{display_rows_total} = 0;

    $self->{Number_Format}={THOUSANDS_SEP=>",",DECIMAL_POINT=>".",MON_THOUSANDS_SEP=>",","MON_DECIMAL_POINT"=>".","INT_CURR_SYMBOL"=>''};

    #Put all Parameters on the object
    foreach my $init_param(keys %{$params}){
        $self->{$init_param} = $params->{$init_param};
    }

    $self->{name} =~ s/\W/_/g;
    
    #Order params and Query
    if ($self->{auto_order} and $self->param('zl_order') and $self->param('zl_list') eq $self->{name}){
		if($self->param("zl_order") =~ /\w+/){
			$self->{sql}{order_by}  = $self->param("zl_order");
			$self->{sql}{order_by} .= " DESC  " if ($self->param("zl_side"));
			$self->{sql}{order_by} .= " ASC  " if (!$self->param("zl_side"));
		}
    }

    $self->{transit_params} = "";
    $self->{cgi_zl_params} = "";

    if($self->{link} and !$self->{link}{event}){
        $self->{link}{event} = "onClick";
        $self->{detail}{Tr}{params_a} = {class=> "pointer zl_row_a"};
        $self->{detail}{Tr}{params_b} = {class=> "pointer zl_row_b"};
    }
    return $self;
}

sub param {
    my $self  = shift;
    my $name  = shift;
    my $value = shift;
    
    if(defined $value){
        $self->{Zera}->{_REQUEST}->param($name, $value);    
    }else{
        return $self->{Zera}->{_REQUEST}->param($name);
    }
}

sub render_template {
    my $self = shift;
    my $vars = shift;
    my $template = shift || $self->{Zera}->{sub_name};
    my $HTML = '';
    
    if(-e ('Zera/' . $self->{Zera}->{ControllerName} . '/tmpl/' . $template . '.html')){
        $template = 'Zera/' . $self->{Zera}->{ControllerName} . '/tmpl/' . $template . '.html';
    }elsif(-e ('templates/' . $conf->{Template}->{AdminTemplateID} . '/' . $template . '.html')){
        $template = 'templates/' . $conf->{Template}->{AdminTemplateID} . '/' . $template . '.html';
    }
    
    $vars->{conf} = $conf;
    
    my $tt = Zera::Com::template();
    $tt->process($template, $vars, \$HTML) || die "$Template::ERROR\n";
    return $HTML;
}

sub print {
    my $self = shift;
    my $vars = {};
    
    $self->transit_params();
    if(!defined $self->{rs}){
#		$grid .= $self->get_data();
    }
    if(defined $self->{sn}){
        my $sn_counter = $self->{sn}->{start_on} || 0;
        foreach my $rec (@{$self->{rs}}){
            $sn_counter ++;
            $rec->{$self->{sn}->{field}} = $sn_counter;
        }
    }

    $self->{table}{id} = 'zl_table_' . $self->{name};
    if($self->{opener} or $self->{link}{location}){
        $self->{table}->{class} .= ' highlight';
    }

    $vars->{table_attrs} = $self->{table};
    $vars->{caption}     = $self->{caption};

    if(defined $self->{groups}){
        # ToDo
    #	$grid .= $self->print_group_columns();
    #	$grid .= $self->print_group_detail();
    #	if(!$self->{rows}){
    #	    $self->{no_data}{params}{colspan} = $self->{colspan};
    #	    $grid .= "    " . $self->_tag('tr',{},$self->_tag('td',$self->{no_data}{params},$self->{labels}{no_data})) . "\n";
    #	}else{
    #	    $grid .= $self->print_group_totals;
    #	    $grid .= $self->print_pagination();
    #	}
    }else{
        $vars->{columns} = $self->print_columns();
    	$vars->{details} = $self->print_detail();
    
    	if(!$self->{rows}){
    	    $self->{no_data}{params}{colspan} = $self->{colspan};
    	    $vars->{details} = $self->_tag('tr',{},$self->_tag('td',$self->{no_data}{params},$self->{labels}{no_data}));
    	}else{
            $vars->{totals} = $self->print_totals();
    	    $vars->{pagination} = $self->print_pagination();
    	}
    }
    
    $self->{total_records} = $self->{rows} if(!$self->{total_records} and $self->{rows});
    
    return $self->render_template($vars, 'zera-list-render');
}

sub get_data {
    my $self = shift;

    $self->build_query();

    $self->{sth} = $self->{Zera}->{_DBH}->{_dbh}->prepare($self->{sql}{query});
    eval {
		if($self->{sql}{params}){
			$self->{sth}->execute(@{$self->{sql}{params}});
		}else{
			$self->{sth}->execute();
		}
    };
    #if sql errors
    if($@){
    	if($self->{on_errors} eq "die"){
    	    if($self->{debug}){
    			die "Chapix::List Error code: ".$self->{Zera}->{_DBH}->{_dbh}->err.". Error message: ".$self->{Zera}->{_DBH}->{_dbh}->errstr . " SQL: " . $self->{sql}{query};
    	    }else{
    			die "Chapix::List Error code: " . $self->{Zera}->{_DBH}->{_dbh}->err . ". Error message: " . $self->{Zera}->{_DBH}->{_dbh}->errstr;
    	    }
    	    return "";
    	}elsif($self->{on_errors} eq "warn"){
    	    if($self->{debug}){
    			die "Chapix::List Error code: ".$self->{Zera}->{_DBH}->{_dbh}->err.". Error message: ".$self->{Zera}->{_DBH}->{_dbh}->errstr . " SQL: " . $self->{sql}{query};
    	    }else{
    			die "Chapix::List Error code: " . $self->{Zera}->{_DBH}->{_dbh}->err . ". Error message: " . $self->{Zera}->{_DBH}->{_dbh}->errstr;
    	    }
    	    return "";
    	}elsif($self->{on_errors} eq "print"){
    	    if($self->{debug}){
    			return "Chapix::List Error code: " . $self->{Zera}->{_DBH}->{_dbh}->err .". Error message: ".$self->{Zera}->{_DBH}->{_dbh}->errstr." SQL: ".$self->{sql}{query};
    	    }else{
    			return "Chapix::List Error code: " . $self->{Zera}->{_DBH}->{_dbh}->err .". Error message: ".$self->{Zera}->{_DBH}->{_dbh}->errstr;
    	    }
    	}
#    }
#
#    if ( defined $self->{Zera}->{_DBH}->{_dbh}->errstr ) {
#
    }else{
	while ( my $rec = $self->{sth}->fetchrow_hashref() ) {
	    push (@{$self->{rs}},$rec);
	}
    }
    return "";
}

sub build_query {
    my $self = shift;
    if (ref \$self->{sql} eq "SCALAR"){
		my $query = $self->{sql};
		$self->{sql} = {
			query => $query,
		};
		$self->{auto_order} = 0;
		$self->{pagination} = 0;
    }else{
    	defined $self->{sql}{select}   or $self->{sql}{select}   = "";
    	defined $self->{sql}{from}     or $self->{sql}{from}     = "";
    	defined $self->{sql}{where}    or $self->{sql}{where}    = "";
    	defined $self->{sql}{order_by} or $self->{sql}{order_by} = "";
    	defined $self->{sql}{limit}    or $self->{sql}{limit}    = "";
    	defined $self->{sql}{offset}   or $self->{sql}{offset}   = "";
	if($self->{Zera}->{_DBH}->{_dbh}->{Driver}->{Name} eq 'Sybase'){
	    if ($self->{sql}{limit}){
		$self->{sql}{query}  = " SELECT TOP ".$self->{sql}{limit}."  " . $self->{sql}{select};
	    }else{
		$self->{sql}{query}  = " SELECT   " . $self->{sql}{select};
	    }
	    $self->{sql}{query} .= " FROM     " . $self->{sql}{from}     if $self->{sql}{from};
	    $self->{sql}{query} .= " WHERE    " . $self->{sql}{where}    if $self->{sql}{where};
	    $self->{sql}{query} .= " GROUP BY " . $self->{sql}{group_by} if $self->{sql}{group_by};
	    $self->{sql}{query} .= " ORDER BY " . $self->{sql}{order_by} if $self->{sql}{order_by};
	    #$self->{sql}{query} .= " LIMIT    " . $self->{sql}{limit}    if $self->{sql}{limit};
	    #if($self->{pagination}){
	    #$self->{sql}{query} .= " OFFSET   " . ($self->{sql}{limit} * ($self->param("zl_page") - 1) );
	    #}else{
	    #$self->{sql}{query} .= " OFFSET   " .  $self->{sql}{offset}   if $self->{sql}{offset};
	    #}

	}else{
	    $self->{sql}{query}  = " SELECT   " . $self->{sql}{select};
	    $self->{sql}{query} .= " FROM     " . $self->{sql}{from}     if $self->{sql}{from};
	    $self->{sql}{query} .= " WHERE    " . $self->{sql}{where}    if $self->{sql}{where};
	    $self->{sql}{query} .= " GROUP BY " . $self->{sql}{group_by} if $self->{sql}{group_by};
	    $self->{sql}{query} .= " ORDER BY " . $self->{sql}{order_by} if $self->{sql}{order_by};
	    $self->{sql}{query} .= " LIMIT    " . $self->{sql}{limit}    if $self->{sql}{limit};
	    if($self->{pagination}){
		$self->{sql}{query} .= " OFFSET   " . ($self->{sql}{limit} * ($self->param("zl_page") - 1) );
	    }else{
		$self->{sql}{query} .= " OFFSET   " .  $self->{sql}{offset}   if $self->{sql}{offset};
	    }
	}
    }
}

sub print_columns {
    my $self = shift;
    $self->get_columns();
    if(defined $self->{headers_groups}){
    	my $HTML = "";
    	$self->{th}{params}{align} = "center";
    	foreach my $hgroup (@{$self->{headers_groups}}){
    	    if(ref $hgroup eq "HASH" ){
        		$self->{th}{params}{colspan} = $hgroup->{colspan};
        		$HTML .= th($self->{th}{params},$hgroup->{label}) . "\n";
        		undef $self->{th}{params}{colspan};
    	    }else{
    		$HTML .= th($self->{th}{params},"") . "\n";
    	    }
    	}
    	my $line1 = $self->_tag('tr',$self->{columns}{params},$HTML);
    	$HTML = "";
    	undef 	$self->{th}{params}{align};
    	my $it = 0;
    	foreach my $label (@{$self->{columns}{labels}}){
    	    $self->{th}{params}{width} = $self->{columns_width}[$it] if(defined $self->{columns_width}[$it]);
    	    $self->{th}{params}{align} = $self->{columns_headers_align}[$it] if(defined $self->{columns_headers_align}[$it]);
    	    $HTML .= th($self->{th}{params},$label) . "\n";
    	    $it++;
    	}
    	return $line1 . "\n   " . $self->_tag('tr',$self->{columns}{params},$HTML);
    }else{
        if (defined $self->{columns_width} or defined $self->{columns_headers_align}){
            my $HTML = "";
            my $it = 0;
            foreach my $label (@{$self->{columns}{labels}}){
            	$self->{th}{params}{width} = $self->{columns_width}[$it] if(defined $self->{columns_width}[$it]);
            	$self->{th}{params}{align} = $self->{columns_headers_align}[$it] if(defined $self->{columns_headers_align}[$it]);
            	$HTML .= th($self->{th}{params},$label) . "\n" if($self->{hidde_column} ne $label);
            	$it++;
    	    }
    	    return "   " . $self->_tag('tr',$self->{columns}{params},$HTML);
    	};
    	my $HTML = "";
    	my $it = 0;
    	foreach my $label (@{$self->{columns}{labels}}){
    	    $HTML .= $self->_tag('th',$self->{th}{params},$label) . "\n" if($self->{hidde_column} ne $label);
    	    $it++;
    	}
    	return "   " . $self->_tag('tr',$self->{columns}{params},$HTML);


	#$HTML .= $self->_tag('tr',$self->{columns}{params},[$self->_tag('th',$self->{th}{params},$self->{columns}{labels})]);

	#return $HTML;
    }
}

sub social_buttons {
    my $self = shift;
    my $fb = shift || 0;
    my $tw = shift || 0;
    my $module = shift || 'Blog';
    if($fb or $tw){
        $self->{sql}->{select} .= ", '' AS social";
        $self->{social} = {fb=>$fb, tw=>$tw, module=>$module};
    }
}

sub on_off {
    my $self = shift;
    $self->{on_off_column} = shift;
}

sub actions {
    my $self = shift;
    my @actions = @_;
    $self->{sql}->{select} .= ", '' AS actions";
    $self->{actions} = \@actions;
}

sub get_columns {
    my $self = shift;
    $self->{columns}{names} = ();
    $self->{columns}{labels} = ();
    $self->{colspan} = ($self->{sth}->{NUM_OF_FIELDS}) || 0;
    foreach my $i(0 .. ($self->{colspan} - 1)) {
    	defined $self->{sth}->{NAME}->[$i] or $self->{sth}->{NAME}->[$i] = "";
    	if ($self->{sth}->{NAME}->[$i] and !($self->{link}{hidde_key_col} and $self->{sth}->{NAME}->[$i] eq $self->{link}{key})){
    	    next if(defined $self->{second_row} and $self->{second_row}->{colspan}->{$self->{sth}->{NAME}->[$i]});
    	    push(@{$self->{columns}{names}},$self->{sth}->{NAME}->[$i]);
    	    my $col_label = $self->{sth}->{NAME}->[$i];
    	    if($col_label ne $self->{hidde_column}){
        		if($self->{custom_labels}->{$self->{sth}->{NAME}->[$i]}){
        		    $col_label = $self->{custom_labels}->{$self->{sth}->{NAME}->[$i]};
        		}else{
        		    $col_label =~ s/_/ /g;
        		    $col_label = ucfirst($col_label);
        		}
        		#Auto order Links
        		my $side = 0;
        		$side = 1 if (!$self->param("zl_side"));
        		if($self->{auto_order}){
        		    if(defined $self->{auto_order_switch}){
            			if(defined $self->{auto_order_switch}[$i] and $self->{auto_order_switch}[$i]){
            			    if(($i+1) eq $self->param("zl_order")){
                				if($self->param("zl_side") eq "0"){
                				    $col_label =       $self->a({href=>$self->{script} . "?zl_order=".($i+1)."&zl_side=1&zl_page=" . $self->param("zl_page") . "&zl_list=" . $self->{name} . $self->{transit_params}},$col_label);
                				}elsif($self->param("zl_side") eq "1"){
                				    $col_label =  $self->a({href=>$self->{script} . "?zl_order=".($i+1)."&zl_side=0&zl_page=" . $self->param("zl_page") . "&zl_list=" . $self->{name} . $self->{transit_params}},$col_label);
                				}
            			    }else{
                				$col_label = $self->a({href=>$self->{script} . "?zl_order=".($i+1)."&zl_side=0&zl_page=" . $self->param("zl_page") . "&zl_list=" . $self->{name} . $self->{transit_params}},$col_label);
            			    }
            			}
        		    }else{
            			if(($i+1) eq $self->param("zl_order")){
            			    if($self->param("zl_side") eq "0"){
                				$col_label =       $self->a({href=>$self->{script} . "?zl_order=".($i+1)."&zl_side=1&zl_page=" . $self->param("zl_page") . "&zl_list=" . $self->{name} . $self->{transit_params}},
                                                            $col_label . '<i class="material-icons md-18">arrow_downward</i>');
            			    }elsif($self->param("zl_side") eq "1"){
                				$col_label =  $self->a({href=>$self->{script} . "?zl_order=".($i+1)."&zl_side=0&zl_page=" . $self->param("zl_page") . "&zl_list=" . $self->{name} . $self->{transit_params}},
                                                       $col_label . '<i class="material-icons md-18">arrow_upward</i>');
            			    }
            			}else{
            			    $col_label = $self->a({href=>$self->{script} . "?zl_order=".($i+1)."&zl_side=0&zl_page=" . $self->param("zl_page") . "&zl_list=" . $self->{name} . $self->{transit_params}},$col_label);
            			}
        		    }
        		}
    	    }
    	    push(@{$self->{columns}{labels}},$col_label);
       	}
    }
    $self->{colspan} -= 1 if($self->{link}{hidde_key_col});
}

sub print_detail {
    my $self = shift;
    my $HTML = "";

    $self->{link}{event} = 'ondblclick' if($self->{actions});
    $self->{rows} = 0;
	foreach my $rec(@{$self->{rs}}) {
	    $self->{rows} ++;
	    my @fields;
	    my $row_cells = "";
	    my $row_params = "params_b";
	    my $row_html_params = 0;
	    $row_params = "params_a" if (($self->{rows}/2) - int($self->{rows}/2));
	    foreach my $i(0 .. (($self->{colspan}-1))) {
		if(defined $self->{columns_align}){
		    $self->{detail}{td}{params}{align} = $self->{columns_align}[$i];
		}
		if($self->{columns}{names}[$i] ne $self->{hidde_column}){
		    if(defined $self->{cell_format}{$self->{columns}{names}[$i]}){
			#Cell Formats
			my $cell_params = $self->{detail}{td}{params};
			foreach my $cell_format(@{$self->{cell_format}{$self->{columns}{names}[$i]}}){
			    my $check = 0;
			    my $condition = $cell_format->{condition};
			    $condition =~ s/%%/$rec->{$self->{columns}{names}[$i]}/g;
			    $condition =~/([\S\s]+)\s(\S+)\s([\S\s]+)/;
			    my $untained_condition = " $1 $2 $3" || "";
			    eval '$check = 1 if(' . $untained_condition . ');';
			    if( $check ){
				$cell_params = $cell_format->{params};
			    }
			}
			$row_cells .= $self->_tag('td',$cell_params,$rec->{$self->{columns}{names}[$i]});
                    }elsif($self->{actions} and $self->{columns}{names}[$i] eq 'actions'){
                        my $cell = '<div class="btn-group">';
			my $it = 0;
                        foreach my $action (@{$self->{actions}}){
                            #$cell .= $action;
			    if($it == 1){
				$cell .= '<button class="btn btn-small btn-inverse dropdown-toggle" data-toggle="dropdown">'.
                                    '<span class="caret"></span></button><ul class="dropdown-menu">';
			    }

                            if($action->{onclick} eq 'default'){
                                $cell .= $self->a({-class=> 'btn btn-small btn-inverse',-href=> $self->{link}{location} . "?" . $self->{link}{key} . "=" .
                                                     $rec->{$self->{link}{key}} . $self->{transit_params}},
                                                '<i class="icon-edit"></i>'.$action->{name});
                            }elsif($action->{onclick} eq 'youtube'){
                                $cell .= '<li>'.$self->a({
            				    -href=>"javascript:wsModal('youtube_share.pl?_ws_l_mode=overlay&module=Youtube&action=edit&module_id=".$rec->{$self->{link}{key}}."');"},
						       '<i class="icon-share"></i>'.$action->{name}).'<li>';
                            }elsif($action->{onclick} eq 'delete'){
                                $cell .= '<li>'.$self->a({-href=>$self->{link}{location} . "?_zl_action=delete&" . $self->{link}{key} . "=" .
                                                 $rec->{$self->{link}{key}} . $self->{transit_params}},
                                                '<i class="icon-trash"></i>'.$action->{name}).'<li>';
                            }else{
                                $cell .= '<li>';
                                my $ID = $rec->{$self->{link}{key}};
                                my $name = $action->{name};
                                my $href = $action->{href};
                                $href    =~ s/_ID_/$ID/g;
                                $name  = '<i class="icon-' . $action->{icon} . '"></i> ' . $name if($action->{icon});
                                $cell .= $self->a({-href => $href . $self->{transit_params}},$name);
                                $cell .= '<li>';
                            }
			    $it ++;
                        }
			if($it > 2){
			    $cell .= '</ul>';
			}
                        $cell .= '</div>';
                        $row_cells .= $self->_tag('td',$self->{detail}{td}{params},$cell);
                    }elsif($self->{on_off_column} and $self->{columns}{names}[$i] eq $self->{on_off_column}){
                        my $cell = '';
                        if($rec->{$self->{columns}{names}[$i]}){
                            $cell .= '<i class="material-icons">check_box</i>';
                            #$cell .= CGI::button(
                            #    -class=> 'cg-on',
                            #    -value=> ' ',
                            #    -onclick=>"document.location.href='" . $self->{link}{location} . "?_zl_action=off&" . $self->{link}{key} . "=" .
                            #        $rec->{$self->{link}{key}} . "$self->{transit_params}';");
                        }else{
                            $cell .= '<i class="material-icons">check_box_outline_blank</i>';
                            #$cell .= CGI::button(
                            #    -class=> 'cg-off',
                            #    -value=> '',
                            #    -onclick=>"document.location.href='" . $self->{link}{location} . "?_zl_action=on&" . $self->{link}{key} . "=" .
                            #        $rec->{$self->{link}{key}} . "$self->{transit_params}';");
                        }
                        $row_cells .= $self->_tag('td',$self->{detail}{td}{params},$cell);
                    }elsif($self->{social} and $self->{columns}{names}[$i] eq 'social'){
                        my $cell = '';
                        if($self->{social}->{fb}){
                            $cell .= ' ' .
                                $self->a({-href=>"javascript:wsModal('facebook_share.pl?_ws_l_mode=overlay&module=".$self->{social}->{module}."&action=edit&module_id=".$rec->{$self->{link}{key}}."');",
                                        -rel=>"#overlay",
                                        -style=>"text-decoration:none"},
				       '<i class="icon-facebook-sign" data-rel="tooltip" title="Publicar en facebook"></i>');
                        }
                        if($self->{social}->{tw}){
                            $cell .= ' ' .
                                $self->a({-href=>"javascript:wsModal('twitter_share.pl?_ws_l_mode=overlay&module=".$self->{social}->{module}."&action=edit&module_id=".$rec->{$self->{link}{key}}."');",
                                        -style=>"text-decoration:none"},
				'<i class="icon-twitter-sign" data-rel="tooltip" title="Publicar en twitter"></i>');
                        }
			$row_cells .= $self->_tag('td',$self->{detail}{td}{params},$cell);
		    }else{
			#Normal cell ---------------------------------------------------------------------------
			defined $rec->{$self->{columns}{names}[$i]} or $rec->{$self->{columns}{names}[$i]} = "";

			if($self->{link}->{exclude_rows} and $self->{link}){
			    if($self->{link}->{exclude_rows}->{$self->{columns}{names}[$i]}){
				$self->{detail}{td}{params}->{$self->{link}{event}} = '';
			    }else{
				if($self->{link}{target}){
				    $self->{detail}{td}{params}->{$self->{link}{event}} = "window.open('" . $self->{link}{location} . "?" . $self->{link}{key} . "=" . $rec->{$self->{link}{key}} . "$self->{transit_params}','" . $self->{key}{target} . "','" . $self->{nw_params} . "');";
				}elsif($self->{opener}){
				    my $opener_transit_params = $self->{transit_params};
				    $opener_transit_params =~ s/opener=[\w]*//g;
				    $self->{detail}{td}{params}->{$self->{link}{event}} = "opener.location.href='" . $self->{opener} . "?" . $self->{link}{key} . "=" . $rec->{$self->{link}{key}} . "$opener_transit_params'; window.close();";
				}elsif($self->{link}{location}){
				    $self->{detail}{td}{params}->{$self->{link}{event}} = "document.location.href='" . $self->{link}{location} . "/" . $rec->{$self->{link}{key}} . "?$self->{transit_params}';";
				}
			    }
			}
			$row_cells .= $self->_tag('td',$self->{detail}{td}{params},$rec->{$self->{columns}{names}[$i]});
		    }
		}
		if(defined $self->{row_format}{$self->{columns}{names}[$i]}){
		    #Row Format
		    foreach my $row_format(@{$self->{row_format}{$self->{columns}{names}[$i]}}){
			my $check = 0;
			my $condition = $row_format->{condition};
			$condition =~ s/%%/$rec->{$self->{columns}{names}[$i]}/g;
			$condition =~/([\S\s]+)\s(\S+)\s([\S\s]+)/;
			my $untained_condition = " $1 $2 $3" || "";
			eval '$check = 1 if(' . $untained_condition . ');';
			if( $check ){
			    $row_params = $self->{columns}{names}[$i];
			    $self->{detail}{Tr}{$row_params} = $row_format->{params};
			    $row_html_params = 1;
			}
		    }
		}
	    }

	    #Links
	    if(defined $self->{second_row}){
		$row_params = "params_a" if($row_params eq "params_b");
	    }
	    if($self->{link}){
		if(!$self->{link}->{exclude_rows}){
		    if($self->{link}{target}){
			$self->{detail}{Tr}{$row_params}{$self->{link}{event}} = "window.open('" . $self->{link}{location} . "?" . $self->{link}{key} . "=" . $rec->{$self->{link}{key}} . "$self->{transit_params}','" . $self->{key}{target} . "','" . $self->{nw_params} . "');";
		    }elsif($self->{opener}){
			my $opener_transit_params = $self->{transit_params};
			$opener_transit_params =~ s/opener=[\w]*//g;
			$self->{detail}{Tr}{$row_params}{$self->{link}{event}} = "opener.location.href='" . $self->{opener} . "?" . $self->{link}{key} . "=" . $rec->{$self->{link}{key}} . "$opener_transit_params'; window.close();";
		    }elsif($self->{link}{location}){
			$self->{detail}{Tr}{$row_params}{$self->{link}{event}} = "document.location.href='" . $self->{link}{location} . "/" . $rec->{$self->{link}{key}} . "?$self->{transit_params}';";
		    }
		}
	    }

	    if($rec->{_list_separator}){
		$HTML .= "   " . $self->_tag('tr',{class=>"zl_row_separator", height=>'4'},$self->_tag('td',{colspan=>$self->{colspan}},'')) . "\n";
	    }
	    $HTML .= "   " . $self->_tag('tr',$self->{detail}{Tr}{$row_params},$row_cells) . "\n";
	    if(defined $self->{second_row}){
		my $colspan = 0;
		my %second_row_params = %{$self->{detail}{td}{params}};
		my $row_cells = "";
		foreach my $field(@{$self->{second_row}->{fields}}){
		    $second_row_params{colspan} = $self->{second_row}->{colspan}->{$field};
		    $colspan +=  $second_row_params{colspan} = $self->{second_row}->{colspan}->{$field};
		    if($field eq "_VOID"){
			$row_cells .= $self->_tag('td',\%second_row_params,"");
		    }else{
			$row_cells .= $self->_tag('td',\%second_row_params,$rec->{$field});
		    }
		}
		$HTML .= "   " . $self->_tag('tr',{class=>"zl_second_row"},$row_cells) ."\n";
		$HTML .= "   " . $self->_tag('tr',{class=>"zl_separator"},$self->_tag('td',{colspan=>$colspan},'')) ."\n";
	    }
	}

    return $HTML;
}

sub transit_params {
    my $self = shift;
    #Transit Params
    $self->{cgi_zl_params} =  "zl_order=" . $self->param("zl_order") .
		"&zl_side=" . $self->param("zl_side") .
			"&zl_page=" . $self->param("zl_page") .
				"&zl_list=" . $self->{name};
    if (defined $self->{link}{transit_params}){
		foreach my $k (sort keys %{$self->{link}{transit_params}}){
		    $self->{transit_params} .= "&" . $k . "=" . $self->{link}{transit_params}{$k};
		}
    }
    if($self->{opener}){
		$self->{transit_params} .= "&opener=" . $self->{opener};
    }
}

sub print_pagination {
    my $self = shift;
    my $HTML = "";
    $self->{foother}{params}{colspan} = $self->{colspan}+1;
    if($self->{pagination}){
	#Get total rows
	my $sSQL = "SELECT count(*) AS total FROM " . $self->{sql}{from};
	$sSQL .= " WHERE    " . $self->{sql}{where}    if $self->{sql}{where};
	my $total = $self->{Zera}->{_DBH}->{_dbh}->selectrow_hashref($sSQL,{},@{$self->{sql}{params}});
	$self->{total_records} = $total->{total} || 0;
	my $pages = ($total->{total} / $self->{sql}{limit});
	my $pages_int = int($pages);
	$pages = $pages_int + 1 if($pages > $pages_int);
	my $pagination = $self->{labels}{page_of};
	my $page = $self->param("zl_page") || 1;
	$pagination =~ s/_PAGE_/$page/;
	$pagination =~ s/_OF_/$pages/;
	$pagination .= "";
	if($self->param("zl_page") > 1){
	    $pagination .= "<li>" .$self->a({-href => $self->{script} . "?zl_page=" . ($self->param("zl_page")-1) . "&zl_order=" . $self->param("zl_order") . "&zl_side=" . $self->param("zl_side") . "&zl_list=" . $self->{name} . $self->{transit_params}, -alt=>'Previous'},
				     $self->{labels}{previous_page}) . "</li>";
	    foreach(my $ii = $self->{nav_pages} -1;$ii > 0;$ii--){
		$pagination .= "<li>" .$self->a({-href => $self->{script} . "?zl_page=" . ($self->param("zl_page") - $ii) . "&zl_order=" . $self->param("zl_order") . "&zl_side=" . $self->param("zl_side") . "&zl_list=" . $self->{name} . $self->{transit_params}},
					 ($self->param("zl_page") - $ii)).'</li>' if(($self->param("zl_page") - $ii) > 0);
	    }
	}
	$pagination .= '<li class="active"><a href="#">'.$self->param('zl_page').'</a></li>' if($pages > 1);
	if($self->param("zl_page") < $pages){
	    foreach(my $ii = 1;$ii < $self->{nav_pages};$ii++){
		last if($ii >= $pages);
		$pagination .= "<li>" .$self->a({-href => $self->{script} . "?zl_page=" . ($self->param("zl_page") + $ii) . "&zl_order=" . $self->param("zl_order") . "&zl_side=" . $self->param("zl_side") . "&zl_list=" . $self->{name} . $self->{transit_params}},
					 ($self->param("zl_page") + $ii)) if(($self->param("zl_page") + $ii) <= $pages).'</li>';
	    }
	    $pagination .= "<li>" .$self->a({-href => $self->{script} . "?zl_page=" . ($self->param("zl_page") +1) . "&zl_order=" . $self->param("zl_order") . "&zl_side=" . $self->param("zl_side") . "&zl_list=" . $self->{name} . $self->{transit_params},-alt=>"Next"},$self->{labels}{next_page}).'</li>';
	}

	if($self->{display_rows_total}){
	    my $rows = $self->{labels}{number_of_rows};
	    $rows =~ s/_NUMBER_/$self->{rows}/g;

	    $HTML .= "    " . $self->_tag('tr',{},$self->_tag('td',$self->{foother}{params},
					'<div class="badge pull-left">' . $rows . '</div>' .
					'<div class="pagination pull-right"><ul>' . $pagination . '</ul></div>'
					)) . "\n";
	}
    }else{
	$self->{total_records} = $self->{rows};
		if($self->{display_rows_total}){
			my $rows = $self->{labels}{number_of_rows};
			$rows =~ s/_NUMBER_/$self->{rows}/g;

			$HTML .= "    " . $self->_tag('tr',{},$self->_tag('td',$self->{foother}{params},
						    '<span class="zl_number_rows">' . $rows . '</span>'
					      )) . "\n";
		}
    }
    return $HTML;
}

sub row_format {
    my $self = shift;
    my %params = @_;
    push(@{$self->{row_format}{$params{name}}},{'params' => $params{params},condition => $params{condition}});
}

sub cell_format {
    my $self = shift;
    my %params = @_;
    push(@{$self->{cell_format}{$params{name}}},{'params' => $params{params},condition => $params{condition}});
}

sub group {
    my $self = shift;
    my %params = @_;
    push(@{$self->{groups}},{'key' => $params{key},fields => $params{fields}});
    foreach my $field(@{$params{fields}}){
		push(@{$self->{group_fields_array}},$field);
		$self->{group_fields_hash}{$field} = 1;
    }

    if($self->{sql}{order_by}){
		$self->{sql}{order_by} = ($params{order_by} || $params{key}) . ", $self->{sql}{order_by}";
    }else{
		$self->{sql}{order_by} = "$params{order_by}" || $params{key};
    }
}

sub columns_width {
    my $self = shift;
    $self->{columns_width} = shift;
}

sub columns_align {
    my $self = shift;
    $self->{columns_align} = shift;
}

sub columns_headers_align {
    my $self = shift;
    $self->{columns_headers_align} = shift;
}

sub print_group_columns {
    my $self = shift;
    my @labels;
    foreach my $field(@{$self->{group_fields_array}}){
	my $col_label = $field;
	if($self->{custom_labels}->{$field}){
	    $col_label = $self->{custom_labels}->{$field};
	}else{
	    $col_label =~ s/_/ /g;
	    $col_label = ucfirst($col_label);
	}
	push(@labels,$col_label);
    }
    return "   " . $self->_tag('tr',$self->{columns}{params},[$self->_tag('th',$self->{group_th}{params},\@labels)]) . "\n";
}

sub print_group_item {
    my $self = shift;
    my $rec = shift;
    my @data;
    foreach my $key (@{$self->{group_fields_array}}){
	push(@data,$rec->{$key});
    }
    return "   " . $self->_tag('tr',$self->{columns}{params},[$self->_tag('td',$self->{group_td}{params},\@data)]) . "\n";
}

sub print_group_detail {
    my $self = shift;
    my $HTML = "";

    $self->{rows} = 0;
    my $group = undef;
    $self->get_detail_columns();
    foreach my $rec(@{$self->{rs}}) {
		#Group items
		if($group ne $rec->{$self->{groups}[0]{key}}){
			if($group ne undef){
				$HTML .= $self->print_group_item_totals($self->{groups}[0]{key},$group);
				$HTML .= "</table>\n";
				$HTML .= "    </td>\n  </tr>\n";
			}
			$group = $rec->{$self->{groups}[0]{key}};
			$HTML .= $self->print_group_item($rec);
			$HTML .= "  <tr>\n    <td colspan=" . scalar(@{$self->{group_fields_array}}) . ">\n";
			$self->{table}{class} = "zl_detail_table";
			$HTML .= start_table($self->{table}) . "\n";
			$HTML .= $self->print_detail_columns();
		}

		$self->{rows} ++;
		my @fields;
		my $row_cells = "";
		my $row_params = "params_b";
		my $row_html_params = 0;
		$row_params = "params_a" if (($self->{rows}/2) - int($self->{rows}/2));
		foreach my $i(0 .. (($self->{colspan})- scalar(@{$self->{group_fields_array}}))) {
			if(defined $self->{columns_align}){
				$self->{detail}{td}{params}{align} = $self->{columns_align}[$i];
			}
			if(defined $self->{cell_format}{$self->{columns}{names}[$i]}){
				#Cell Formats
				my $cell_params = $self->{detail}{td}{params};
				foreach my $cell_format(@{$self->{cell_format}{$self->{columns}{names}[$i]}}){
					my $check = 0;
					my $condition = $cell_format->{condition};
					$condition =~ s/%%/$rec->{$self->{columns}{names}[$i]}/g;
					$condition =~/([\S\s]+)\s(\S+)\s([\S\s]+)/;
					my $untained_condition = " $1 $2 $3" || "";
					eval '$check = 1 if(' . $untained_condition . ');';
					if( $check ){
						$cell_params = $cell_format->{params};
					}
				}
				$row_cells .= $self->_tag('td',$cell_params,$rec->{$self->{columns}{names}[$i]});
			}else{
				#Normal cell
				$row_cells .= $self->_tag('td',$self->{detail}{td}{params},$rec->{$self->{columns}{names}[$i]});
			}
			if(defined $self->{row_format}{$self->{columns}{names}[$i]}){
				# 		#Row Format
				foreach my $row_format(@{$self->{row_format}{$self->{columns}{names}[$i]}}){
					my $check = 0;
					my $condition = $row_format->{condition};
					$condition =~ s/%%/$rec->{$self->{columns}{names}[$i]}/g;
					$condition =~/([\S\s]+)\s(\S+)\s([\S\s]+)/;
					my $untained_condition = " $1 $2 $3" || "";
					eval '$check = 1 if(' . $untained_condition . ');';
					if( $check ){
						$row_params = $self->{columns}{names}[$i];
						$self->{detail}{Tr}{$row_params} = $row_format->{params};
						$row_html_params = 1;
					}
				}
			}
		}


		# #Links
		if($self->{link}){
			if($self->{link}{target}){
				$self->{detail}{Tr}{$row_params}{$self->{link}{event}} = "window.open('" . $self->{link}{location} . "?" . $self->{link}{key} . "=" . $rec->{$self->{link}{key}} . "$self->{transit_params}','" . $self->{key}{target} . "','" . $self->{nw_params} . "');";
			}elsif($self->{opener}){
				my $opener_transit_params = $self->{transit_params};
				$opener_transit_params =~ s/opener=[\w]*//g;
				$self->{detail}{Tr}{$row_params}{$self->{link}{event}} = "opener.location.href='" . $self->{opener} . "?" . $self->{link}{key} . "=" . $rec->{$self->{link}{key}} . "$opener_transit_params'; window.close();";
			}elsif($self->{link}{location}){
				$self->{detail}{Tr}{$row_params}{$self->{link}{event}} = "document.location.href='" . $self->{link}{location} . "/" . $rec->{$self->{link}{key}} . "?$self->{transit_params}';";
			}
		}
		$HTML .= "   " . $self->_tag('tr',$self->{detail}{Tr}{$row_params},$row_cells) . "\n";
	}
    if($HTML){
		$HTML .= $self->print_group_item_totals($self->{groups}[0]{key},$group);
		$HTML .= "</table>\n";
		$HTML .= "    </td>\n  </tr>\n";
    }
    return $HTML;
}

sub print_detail_columns {
    my $self = shift;
    if (defined $self->{columns_width} or defined $self->{columns_headers_align}){
	my $HTML = "";
	my $it = 0;
	foreach my $label (@{$self->{columns}{labels}}){
	    $self->{detail_th}{params}{width} = $self->{columns_width}[$it] if(defined $self->{columns_width}[$it]);
	    $self->{detail_th}{params}{align} = $self->{columns_headers_align}[$it] if(defined $self->{columns_headers_align}[$it]);
	    $HTML .= $self->_tag('th',$self->{detail_th}{params},$label) . "\n";
	    $it++;
	}
	return "   " . $self->_tag('tr',$self->{columns}{params},$HTML);
    };
    return "   " . $self->_tag('tr',$self->{columns}{params},[$self->_tag('th',$self->{detail_th}{params},$self->{columns}{labels})]) . "\n";
}

sub get_detail_columns {
    my $self = shift;
    $self->{columns}{names} = ();
    $self->{columns}{labels} = ();
    $self->{colspan} = ($self->{sth}->{NUM_OF_FIELDS});
    foreach my $i(0 .. ($self->{colspan} - 1)) {
		defined $self->{sth}->{NAME}->[$i] or $self->{sth}->{NAME}->[$i] = "";
		if ($self->{sth}->{NAME}->[$i] and !($self->{link}{hidde_key_col} and $self->{sth}->{NAME}->[$i] eq $self->{link}{key}) and !$self->{group_fields_hash}{$self->{sth}->{NAME}->[$i]}){

			push(@{$self->{columns}{names}},$self->{sth}->{NAME}->[$i]);
			my $col_label = $self->{sth}->{NAME}->[$i];
			$col_label =~ s/_/ /g;
			$col_label = ucfirst($col_label);

			#Auto order Links
			my $side = 0;
			$side = 1 if (!$self->param("zl_side"));
			if($self->{auto_order}){
				if(($i+1) eq $self->param("zl_order")){
					if($self->param("zl_side") eq "0"){
						$col_label = $self->a({href=>$self->{script} . "?zl_order=".($i+1)."&zl_side=1&zl_page=" . $self->param("zl_page") . "&zl_list=" . $self->{name} . $self->{transit_params}},$col_label);
					}elsif($self->param("zl_side") eq "1"){
						$col_label = $self->a({href=>$self->{script} . "?zl_order=".($i+1)."&zl_side=0&zl_page=" . $self->param("zl_page") . "&zl_list=" . $self->{name} . $self->{transit_params}},$col_label);
					}
				}else{
					$col_label = $self->a({href=>$self->{script} . "?zl_order=".($i+1)."&zl_side=1&zl_page=" . $self->param("zl_page") . "&zl_list=" . $self->{name} . $self->{transit_params}},$col_label);
#					$col_label .= $self->a({href=>$self->{script} . "?zl_order=".($i+1)."&zl_side=0&zl_page=" . $self->param("zl_page") . "&zl_list=" . $self->{name} . $self->{transit_params}},$self->{labels}{link_down});
				}
			}
			push(@{$self->{columns}{labels}},$col_label);
		}
    }
    $self->{colspan} -= 1 if($self->{link}{hidde_key_col});
}

sub total {
    my $self = shift;
    my %params = @_;
    $self->{totals}{$params{key}} = {type => $params{type},operation=>$params{operation},label=>$params{label},format=>$params{format},nearest=>$params{nearest}};
}

sub group_total {
    my $self = shift;
    my %params = @_;
    $self->{group_totals}{$params{key}} = {type => $params{type},operation=>$params{operation},label=>$params{label},format=>$params{format}};
}

sub print_totals {
    my $self = shift;
    my $HTML = "";
    my @totals;

    foreach my $i(0 .. (($self->{colspan} - 1))) {
	if(!(defined $self->{totals}{$self->{columns}{names}[$i]})){
	    push(@totals,"");
	    next;
	}
	#Operaciones
	my $total = "";
	if(defined $self->{totals}{$self->{columns}{names}[$i]}{operation}){
	    if($self->{totals}{$self->{columns}{names}[$i]}{operation} eq "SUM"){
			$total = $self->SUM($self->{columns}{names}[$i]);
	    }elsif($self->{totals}{$self->{columns}{names}[$i]}{operation} eq "AVG"){
			$total = $self->AVG($self->{columns}{names}[$i], ($self->{totals}{$self->{columns}{names}[$i]}{nearest} || ""));
	    }elsif($self->{totals}{$self->{columns}{names}[$i]}{operation} eq "COUNT"){
			$total = $self->COUNT($self->{columns}{names}[$i]);
	    }
	}

	#Formatos
	if(defined $self->{totals}{$self->{columns}{names}[$i]}{format} and $self->{totals}{$self->{columns}{names}[$i]}{format} eq "price"){
	    use Number::Format;
	    my $NF = Number::Format->new(%{$self->{Number_Format}});
	    $total = $NF->format_price($total);
	}

	if($self->{totals}{$self->{columns}{names}[$i]}{label}){
	    my $total_label = $total;
	    $total = $self->{totals}{$self->{columns}{names}[$i]}{label};
	    $total =~ s/%%/$total_label/g;
	}
	push(@totals,$total);
    }

    return "   " . $self->_tag('tr',$self->{totals}{Tr}{params},[$self->_tag('td',$self->{totals}{td}{params},\@totals)]) . "\n" if($totals[0]);
}

sub print_group_totals {
    my $self = shift;
    my $HTML = "";
    my @totals;

    foreach my $i(0 .. (($self->{colspan} - 1))) {
	if(!(defined $self->{totals}{$self->{columns}{names}[$i]})){
	    next;
	}
	#Operaciones
	my $total = "";
	if(defined $self->{totals}{$self->{columns}{names}[$i]}{operation}){
	    if($self->{totals}{$self->{columns}{names}[$i]}{operation} eq "SUM"){
			$total = $self->SUM($self->{columns}{names}[$i]);
	    }elsif($self->{totals}{$self->{columns}{names}[$i]}{operation} eq "AVG"){
			$total = $self->AVG($self->{columns}{names}[$i], ($self->{totals}{$self->{columns}{names}[$i]}{nearest} || ""));
	    }elsif($self->{totals}{$self->{columns}{names}[$i]}{operation} eq "COUNT"){
			$total = $self->COUNT($self->{columns}{names}[$i]);
	    }
	}

	#Formatos
	if($self->{totals}{$self->{columns}{names}[$i]}{format} eq "price"){
	    use Number::Format;
	    my $NF = Number::Format->new(%{$self->{Number_Format}});
	    $total = $NF->format_price($total);
	}

	if($self->{totals}{$self->{columns}{names}[$i]}{label}){
	    my $total_label = $total;
	    $total = $self->{totals}{$self->{columns}{names}[$i]}{label};
	    $total =~ s/%%/$total_label/g;
	}
	push(@totals,$total);
    }

    return "   " . $self->_tag('tr',{},$self->_tag('td',{colspan=>scalar(@{$self->{group_fields_array}})},
			     '<table width="100%">' .
			     $self->_tag('tr',$self->{totals}{Tr}{params},[$self->_tag('td',$self->{totals}{td}{params},\@totals)]) . "\n" .
			     '</table>'
			    )) . "\n";
}

sub print_group_item_totals {
    my $self = shift;
    my $field = shift;
    my $field_value = shift;
    my $totals = "";
    foreach my $i(0 .. (($self->{colspan})- scalar(@{$self->{group_fields_array}}))) {
#	if(!(defined $self->{group_totals}{$self->{columns}{names}[$i]})){
#	    $totals .= '<td></td>';
#	    next;
#	}
	#Operaciones
	my $total = "";
	if(defined $self->{group_totals}{$self->{columns}{names}[$i]}{operation}){
	    if($self->{group_totals}{$self->{columns}{names}[$i]}{operation} eq "SUM"){
		$total = $self->group_SUM($self->{columns}{names}[$i],$field,$field_value);
	    }elsif($self->{group_totals}{$self->{columns}{names}[$i]}{operation} eq "AVG"){
		$total = $self->group_AVG($self->{columns}{names}[$i],$field,$field_value);
	    }elsif($self->{group_totals}{$self->{columns}{names}[$i]}{operation} eq "COUNT"){
		$total = $self->group_COUNT($self->{columns}{names}[$i],$field,$field_value);
	    }
	}

	#Formatos
	if($self->{group_totals}{$self->{columns}{names}[$i]}{format} eq "price"){
	    use Number::Format;
	    my $NF = Number::Format->new(%{$self->{Number_Format}});
	    $total = $NF->format_price($total);
	}

	if($self->{group_totals}{$self->{columns}{names}[$i]}{label}){
	    my $total_label = $total;
	    $total = $self->{group_totals}{$self->{columns}{names}[$i]}{label};
	    $total =~ s/%%/$total_label/g;
	}
	if(defined $self->{columns_align}){
	    $self->{group_item_totals}{td}{params}{align} = $self->{columns_align}[$i];
	    $totals .= $self->_tag('td',$self->{group_item_totals}{td}{params},$total);
	}else{
	    $totals .= $self->_tag('td',$self->{group_item_totals}{td}{params},$total);
	}
    }
    return "   " . $self->_tag('tr',$self->{group_item_totals}{Tr}{params},$totals) . "\n";
}

sub SUM {
    my $self = shift;
    my $field = shift || "";
    return 0 if(!$field);
    my $total = 0;
    foreach my $rec(@{$self->{rs}}) {
		$rec->{$field} = 0 if($rec->{$field} eq "-");
		$total += $rec->{$field};
    }
    return $total;
}

sub group_SUM {
    my $self = shift;
    my $field = shift || "";
    my $filter = shift;
    my $filter_value = shift;
    return 0 if(!$field);
    my $total = 0;
    foreach my $rec(@{$self->{rs}}) {
		next if($rec->{$filter} ne $filter_value);
		$total += $rec->{$field};
    }
    return $total;
}

sub COUNT {
    my $self = shift;
    my $field = shift || "";
    return 0 if(!$field);
    return scalar( @{$self->{rs}});
}

sub group_COUNT {
    my $self = shift;
    my $field = shift || "";
    my $filter = shift;
    my $filter_value = shift;
    return 0 if(!$field);
    my $total = 0;
    foreach my $rec(@{$self->{rs}}) {
		next if($rec->{$filter} ne $filter_value);
		$total += 1;
    }
    return $total;
}

sub AVG {
    my $self = shift;
    my $field = shift || "";
	my $nearest = shift || '.01';
    return 0 if(!$field);
    my $avg = 0;
    my $it = 0;

    foreach my $rec(@{$self->{rs}}) {
		$it++;
		$avg += $rec->{$field};
    }

    eval {
		$avg = $avg / $it;
    };

    if($@){
		$avg = "";
    }

    $avg = nearest($nearest,$avg);
    return $avg;
}

sub group_AVG {
    my $self = shift;
    my $field = shift || "";
    my $filter = shift;
    my $filter_value = shift;
    return 0 if(!$field);
    my $avg = 0;
    my $it = 0;

    foreach my $rec(@{$self->{rs}}) {
		next if($rec->{$filter} ne $filter_value);
		$it++;
		$avg += $rec->{$field};
    }

    eval {
		$avg = $avg / $it;
    };

    if($@){
		$avg = "";
    }

    $avg = nearest(.01,$avg);
    return $avg;
}

sub headers_groups {
    my $self = shift;
    $self->{headers_groups} = shift;
}

sub orders {
    my $self = shift;
    $self->{orders} = shift;
    if($self->{orders}->{$self->param("zl_order")}){
	$self->{sql}{order_by} = $self->{orders}->{$self->param("zl_order")};
	$self->{sql}{order_by} .= " DESC  " if ($self->param("zl_side"));
	$self->{sql}{order_by} .= " ASC  " if (!$self->param("zl_side"));
    }
}

sub auto_order_switch {
    my $self = shift;
    $self->{auto_order_switch} = shift;
	if(int($self->{sql}{order_by}) > 0){
		if($self->param('zl_order') > scalar(@{$self->{auto_order_switch}})){
			$self->param('zl_order', '');
			$self->{sql}->{order_by} = '';
		}
	}
}

sub second_row {
    my $self = shift;
    $self->{second_row} = shift;
}

sub set_label {
    my $self = shift;
    my $field = shift;
    my $label = shift;
    $self->{custom_labels}->{$field} = $label;
}

sub hidde_column {
    my $self = shift;
    my $field = shift;
    $self->{hidde_column} = $field;
}

sub sn {
    my $self = shift;
    my $field = shift;
    my $start_on = shift;
    if(!$start_on){
	$start_on = ($self->param('zl_page') - 1) * $self->{sql}->{limit}
    }
    $self->{sn} = {field=>$field,start_on=>$start_on};
}

sub a {
    my $self = shift;
    my $attrs = shift;
    my $content = shift;
    return $self->_tag('a',$attrs, $content);    
}

sub _tag {
    my $self     = shift;
    my $tag_type = shift;
    my $attrs    = shift;
    my $content  = shift;

    my $tag = '';
    foreach my $key (keys %{$attrs}){
        $tag .= ' ' . $key .'="'. $attrs->{$key}.'"';
    }
    if($content){
        return '<' . $tag_type . $tag . '>' . $content . '</' . $tag_type . '>';
    }else{
        return '<' . $tag_type . $tag . ' />';
    }
}

1;
