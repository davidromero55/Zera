package Zera::Com;

use strict;
use Zera::Conf;

#use DBI;
#use Apache::Session::MySQL;

# use Marketero::Conf;

BEGIN {
    use Exporter();
    use vars qw( @ISA @EXPORT @EXPORT_OK );
    @ISA = qw( Exporter );
    @EXPORT = qw(
        );
}

use vars @EXPORT;

#BEGIN {
#    use Exporter();
#    use vars qw( @ISA @EXPORT @EXPORT_OK );
#    @ISA = qw( Exporter );
#    @EXPORT = qw(
#        $dbh
#        %sess
#        $cookie
#        &msg_add
#        &msg_print
#        &msg_get
#        &http_redirect
#        $_REQUEST
#        $Template
#        );
#}


##################################################################################
## App Init
##################################################################################

my $CRLF = "\n";
#
## CGI params
#my $Q = CGI->new;
#
#foreach my $key (keys %{$Q->Vars()}){
#    $_REQUEST->{$key} = $Q->param($key);
#}
#        
#my $URL = $ENV{SCRIPT_URL};
#my $BaseURL = $conf->{ENV}->{BaseURL};
#
## DataBase
#$dbh = DBI->connect( $conf->{DBI}->{conection}, $conf->{DBI}->{user_name}, $conf->{DBI}->{password},{RaiseError => 1,AutoCommit=>1}) or die "Can't Connect to database.";
#$dbh->do("SET CHARACTER SET 'utf8'");
#$dbh->do("SET time_zone=?",{},$conf->{DBI}->{time_zone});
##$dbh->do("SET lc_time_names = ?",{},$conf->{DBI}->{lc_time_names});
#
## Session
#my $session_id;
#if (defined $ENV{'HTTP_COOKIE'}){
#    my %cookies = map {$_ =~ /\s*(.+)=(.+)/g} ( split( /;/, $ENV{'HTTP_COOKIE'} ) );
#    $session_id = $cookies{$conf->{SESSION}->{name}};
#}
#my $today_date = $dbh->selectrow_array("SELECT CURDATE()");
#
#
#if ($ENV{HTTP_USER_AGENT}){
#    eval {
#    	tie %sess, 'Apache::Session::MySQL', $session_id, {
#    	    Handle     => $dbh,
#    	    LockHandle => $dbh,
#    	    TableName  => 'xaa.sessions',
#    	};
#    };
#
#    if ($@) {
#        eval {
#            $session_id = '';	
#            tie %sess, 'Apache::Session::MySQL' , $session_id,{
#                Handle     => $dbh,
#                LockHandle => $dbh,
#                TableName  => 'xaa.sessions',
#            };
#        };
#    	die "Can't create session data $@" if($@);
#    }
#
#    $cookie = cookie(-name    => $conf->{SESSION}->{name},
#    		 -value   => $sess{_session_id},
#    		 -path    => $conf->{SESSION}->{path},
#    		 -expires => $conf->{SESSION}->{life},
#        );
#}
##Session END
#
#defined $sess{user_id}    or $sess{user_id} = '';
#defined $sess{user_name}  or $sess{user_name} = '';
#defined $sess{user_email} or $sess{user_email} = '';
#$sess{user_language} or $sess{user_language} = detect_browser_language('en_US');
#
#$URL =~ s/^$BaseURL//g;
#($_REQUEST->{Domain}, $_REQUEST->{Controller}, $_REQUEST->{View}) = split(/\//, $URL);
#$_REQUEST->{Domain}     =~ s/\W//g;
#$_REQUEST->{Controller} =~ s/\W//g;
#$_REQUEST->{View}       =~ s/\W//g;
#$_REQUEST->{View}       = '' if(!$_REQUEST->{View});
#
#if(! ($_REQUEST->{Domain})){
#    $_REQUEST->{Domain} = 'MK';
#    $_REQUEST->{Controller} = 'MK';
#    $_REQUEST->{View}       = '';
#}
    
#my $folder_path = '';
#if ($_REQUEST->{Domain} eq 'MK'){
#    if($sess{user_id}){
#        # if we have a session lets redirect to home folder
#        $folder_path = $dbh->selectrow_array("SELECT d.folder FROM xaa.xaa_domains d INNER JOIN xaa.xaa_users_domains ud ON d.domain_id=ud.domain_id " .
#						"WHERE ud.user_id=? AND ud.active=1 LIMIT 1",{},$sess{user_id}) || '';
#        if($folder_path){
#            http_redirect('/'.$folder_path);
#        }else{
#            $sess{user_id}        = "";
#            $sess{user_name}      = "";
#            $sess{user_email}     = "";
#            $sess{user_time_zone} = "";
#            $sess{user_language}  = "";
#            http_redirect('/MK/MK/Login');
#        }
#    }
#}else{
#    $folder_path = $dbh->selectrow_array("SELECT d.folder FROM xaa.xaa_domains d INNER JOIN xaa.xaa_users_domains ud ON d.domain_id=ud.domain_id " .
#                                         "WHERE ud.user_id=? AND ud.active=1 LIMIT 1",{},$sess{user_id});
#    if(! $folder_path){
#        http_redirect('/'.$folder_path);
#    }
#}
#
## Change to domain database
#eval {
#    if($sess{user_id}){
#        # Check access to domain
#        my $domain = $dbh->selectrow_hashref("SELECT d.domain_id, d.database FROM xaa.xaa_domains d INNER JOIN xaa.xaa_users_domains ud ON ud.domain_id=d.domain_id WHERE d.folder=? AND ud.user_id=? ",{},
#                                             $_REQUEST->{Domain}, $sess{user_id});
#        http_redirect('/MK/MK/Login') if (!$domain);
#        $dbh->do("USE xaa_".$_REQUEST->{Domain});
#    }
#};
#if($@){
#    http_redirect('/MK/MK/Login');
#}

## Load basic config
#conf_load('Xaa');
#conf_load('Website');
#conf_load('Domain');
#conf_load('Template');
#
#load_domain_info();
#
## Default template
#$Template = Template->new(
#    INCLUDE_PATH => 'templates/'.$sess{user_language}.'/',
#);

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
    push(@header,"Set-Cookie: " . $Zera->{_SESS}->{cookie});
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

#
#sub cookie_expiration {
#    my $life = shift;
#    msg_add('warning', $cookie->expires());
#    $cookie->expires($life);
#    msg_add('info', $cookie->expires());
#}
#
#sub msg_add {
#  my $type = shift;
#  my $text = shift;
#  $dbh->do("INSERT IGNORE INTO $conf->{Xaa}->{DB}.sessions_msg (session_id, type, msg) values(?,?,?)",{},$sess{_session_id},$type, $text);
#}
#
#sub msg_print {
#  my $HTML = "";
#  my $msgs = $dbh->selectall_arrayref("SELECT m.type, m.msg FROM $conf->{Xaa}->{DB}.sessions_msg m WHERE m.session_id=?",{},$sess{_session_id});
#  foreach my $msg (@$msgs){
#    my $class = '';
#    $HTML .= '<div class="card-panel msg msg-'.$msg->[0].'">' . $msg->[1] . '</div>';
#  }
#  $dbh->do("DELETE FROM $conf->{Xaa}->{DB}.sessions_msg WHERE session_id=?",{},$sess{_session_id}) if($msgs->[0]);
#  return $HTML;
#}
#
#sub msg_get {
#  my $HTML = "";
#  my $msgs = $dbh->selectall_arrayref("SELECT m.type, m.msg FROM $conf->{Xaa}->{DB}.sessions_msg m WHERE m.session_id=?",{},$sess{_session_id});
#  $dbh->do("DELETE FROM $conf->{Xaa}->{DB}.sessions_msg WHERE session_id=?",{},$sess{_session_id}) if($msgs->[0]);
#  return $msgs;
#}
#
## Web browser redirect
#sub http_redirect {
#  my $dest = shift;
#  untie %sess;
#  $dbh->disconnect();
#  print redirect($dest);
#  exit 0;
#}
#
## Save session data and disconect from DB
#sub app_end {
#  untie %sess;
#  $dbh->disconnect();
#  exit 0;
#}
#
#sub conf_load {
#    my $module = shift;
#    my $vars = $dbh->selectall_arrayref("SELECT c.module, c.name, c.value FROM conf c WHERE c.module=? AND value IS NOT NULL",{Slice=>{}},$module);
#    foreach my $var (@$vars){
#        defined $conf->{$var->{module}} or $conf->{$var->{module}} = {};
#        $conf->{$var->{module}}->{$var->{name}} = $var->{value} || '';
#    }
#}
#
#sub detect_browser_language {
#    my $detected_language = shift || 'en_US';
#    if($ENV{HTTP_ACCEPT_LANGUAGE} =~ /es/ ){
#        $detected_language = 'es_MX';
#    }
#    return $detected_language;
#}

#sub set_path_route {
#  my @items = @_;
#  my $route = '';
#  foreach my $item(@items){
#    my $name = $item->[0];
#    $name = CGI::a({-href=>$item->[1]},$name) if($item->[1]);
#    $route .= ' <li>'.$name.'<span class="divider"><i class="icon-angle-right"></i></span></li> ';
#  }
#  $conf->{Page}->{Path} = '<ul class="path"><li><a href="/">Home</a><span class="divider"><i class="glyphicon glyphicon-menu-right"></i></span></li>' . $route.'</ul>';
#}

#sub selectbox_data {
#    my %data = (
#	values => [],
#	labels => {},
#	);
#    
#    my $select = shift || "";
#    my $params = shift;
#    my $sth = $dbh->prepare($select);
#    if($params){
#	if(ref($params) eq 'ARRAY'){
#	    $sth->execute(@$params);
#	}else{
#	    $sth->execute($params);
#	}
#    }else{
#	$sth->execute();
#    }
#    while ( my $rec = $sth->fetchrow_arrayref() ) {
#	push(@{$data{values}},$rec->[0]);
#	$data{labels}{$rec->[0]} = $rec->[1];
#    }
#    return %data;
#}

#sub load_domain_info {    
#    $conf->{Domain} = $dbh->selectrow_hashref(
#	"SELECT d.domain_id, d.name, d.folder, d.database, d.country_id, d.language, d.time_zone, d.address, phone, subscription, " .
#        "d.name_changed, d.eme_emails_limit, d.custom_email, d.custom_email_validated, d.custom_domain, d.custom_domain_validated, " .
#        "d.website, ds.service_id, ds.quantity " .
#	"FROM $conf->{Xaa}->{DB}.xaa_domains d " .
#        "LEFT JOIN $conf->{Xaa}->{DB}.xaa_domains_services ds ON ds.domain_id=d.domain_id " .
#        "WHERE folder = ?",{}, $_REQUEST->{Domain});
#    
#    $conf->{Domain}->{quantity} = 1 if (!$conf->{Domain}->{quantity});
#
#    if(!($conf->{Domain}->{subscription})){
#        $conf->{Domain}->{demo_left_days} = $dbh->selectrow_array("SELECT DATEDIFF(DATE_ADD(added_on, INTERVAL 15 DAY), DATE(NOW())) FROM $conf->{Xaa}->{DB}.xaa_domains d WHERE domain_id = ? ",{}, $conf->{Domain}->{domain_id}) || 0;
#        $conf->{Domain}->{demo_left_days} = 0 if ($conf->{Domain}->{demo_left_days} < 0);
#	$conf->{Domain}->{contacts_metric} = 500;
#    }else{
#	$conf->{Domain}->{contacts_metric} = $dbh->selectrow_array("SELECT metric_a FROM $conf->{Xaa}->{DB}.xaa_services WHERE service_id=?",{}, $conf->{Domain}->{service_id}) || 500;
#    }
#}
#
#
#sub switch_domain {
#    my $domain_id = $_REQUEST->{domain_id};
#    my $results = {};
#    
#    my $access = $dbh->selectrow_hashref("SELECT domain_id, is_admin FROM $conf->{Xaa}->{DB}.xaa_users_domains WHERE user_id=? AND domain_id=? AND active=1",{},$sess{user_id}, $domain_id);
#    
#    if(!int($access->{domain_id})){
#        msg_add('danger','No tiene acceso a la empresa solicitada.');
#        $results->{redirect} = '/'.$conf->{Domain}->{folder};
#        return $results;
#    }
#    
#    my $domain = $dbh->selectrow_hashref("SELECT d.domain_id, d.name, d.database, d.folder FROM $conf->{Xaa}->{DB}.xaa_domains d WHERE d.domain_id=?",{},$domain_id);    
#
#    $sess{is_admin} = $access->{is_admin};
#    if($sess{user_language} eq 'es_MX'){
#        msg_add('info','Accediste a la empresa '.$domain->{name});
#    }else{
#        msg_add('info',$domain->{name} . ' is now active.');
#    }
#
#    $sess{current_folder} = $domain->{folder};    
#    $results->{redirect} = '/'.$domain->{folder};
#    return $results;
#}

#sub force_access_domain {
#    my $folder = $_REQUEST->{folder};
#    my $domain_id = $_REQUEST->{domain_id};
#    my $results = {};        
#
#    if ($sess{user_id} ne 139 and $sess{user_id} ne 118 and $sess{user_id} ne 518 and $sess{user_id} ne 2319){
#	msg_add('danger','ERROR no tiene acceso.');
#        $results->{redirect} = '/';
#        return $results;
#    }
#        
#    my $domain;        
#    $domain = $dbh->selectrow_hashref("SELECT d.domain_id, d.name, d.database, d.folder FROM $conf->{Xaa}->{DB}.xaa_domains d WHERE d.folder=?",{},$folder) if ($folder);
#    $domain = $dbh->selectrow_hashref("SELECT d.domain_id, d.name, d.database, d.folder FROM $conf->{Xaa}->{DB}.xaa_domains d WHERE d.domain_id=?",{},$domain_id) if ($domain_id);
#
#    if(!int($domain->{domain_id})){
#        msg_add('danger','No tiene acceso o el folder no existe.');
#        $results->{redirect} = '/'.$conf->{Domain}->{folder};
#        return $results;
#    }
#
#    $sess{is_admin} = "";
#    $sess{is_admin} = "1";
#    
#    if($sess{user_language} eq 'es_MX'){
#        msg_add('info','Accediste a la empresa '.$domain->{name});
#    }else{
#        msg_add('info',$domain->{name} . ' is now active.');
#    }
#
#    $sess{current_folder} = $domain->{folder};    
#    $results->{redirect} = '/'.$domain->{folder};
#    return $results;
#}


#sub admin_log {
#    my $module = shift;
#    my $action = shift;
#    my $admin_id = shift || $sess{admin_id};
#    
#    $dbh->do("INSERT INTO admins_log (admin_id, date, module, comments, ip_address) VALUES(?,NOW(),?,?,?)",{},
#             $admin_id, $module, $action, $ENV{REMOTE_ADDR});
#}

#sub set_toolbar {
#  my @actions = @_;
#  my $LeftHTML = '';
#  my $RightHTML = '';
#  my $HTML = '';
#
#  foreach my $action (@actions){
#    my $btn = '';
#    my $alt = '';
#    my ($script, $label, $side, $icon, $class, $type) = @$action;
#    $class = 'btn btn-default btn-sm' if(!$class);
#    if($script eq 'index.pl' or ($label eq '')){
#      $alt = 'Level up';
#      $icon  = 'level-up';
#      $side  = 'right';
#    }
#    $btn .= ' <a href="'.$script.'" class="'.$class.'" alt="'.$alt.'" title="'.$alt.'" >';
#    if($icon){
#      $btn .= '<i class="glyphicon glyphicon-'.$icon.'"></i> ';
#    }
#    $btn .= $label.'</a>';
#    if($side eq 'right'){
#      $RightHTML .= $btn;
#    }else{
#      $LeftHTML .= $btn;
#    }
#  }
#
#  $HTML .= $LeftHTML;
#  $HTML .= '<div class="pull-right">' . $RightHTML .'</div>' if($RightHTML);
#
#  $conf->{Page}->{Toolbar} = $HTML;
#}
#
#sub upload_file {
#  my $cgi_param = shift || "";
#  my $dir = shift || "";
#  my $filename = param($cgi_param);
#  my $mime = '';
#  my $save_as = shift || "";
#
#
#  if(!(-e "data/$conf->{Domain}->{folder}")){
#      mkdir ("data/$conf->{Domain}->{folder}");
#  }
#  
#  if(!(-e "data/$conf->{Domain}->{folder}/img")){
#    mkdir ("data/$conf->{Domain}->{folder}/img");
#  }  
#  
#  if(!(-e "data/$conf->{Domain}->{folder}/img/$dir/")){
#    mkdir ("data/$conf->{Domain}->{folder}/img/$dir/");
#  }
#
#  if($filename){
#      my $type = uploadInfo($filename)->{'Content-Type'};
#      my $file = $save_as || (time() . int(rand(9999999)));
#      if($type eq "image/jpeg" or $type eq "image/x-jpeg"  or $type eq "image/pjpeg"){
#	  $file .= ".jpg";
#	  $mime = 'img';
#      }elsif($type eq "image/png" or $type eq "image/x-png"){
#	  $file .= ".png";
#	  $mime = 'img';
#      }elsif($type eq "image/gif" or $type eq "image/x-gif"){
#	  $file .= ".gif";
#	  $mime = 'img';
#      }elsif($filename =~ /\.pdf$/i){
#	  $file .= ".pdf";
#	  $mime = 'pdf';
#      }elsif($filename =~ /\.doc$/i){
#	  $file .= ".doc";
#	  $mime = 'doc';
#      }elsif($filename =~ /\.xls$/i){
#	  $file .= ".xls";
#	  $mime = 'xls';
#      }elsif($filename =~ /\.csv$/i){
#	  $file .= ".csv";
#	  $mime = 'csv';
#      }elsif($filename =~ /\.ppt$/i){
#	  $file .= ".ppt";
#	  $mime = 'ppt';
#      }elsif($filename =~ /\.docx$/i){
#	  $file .= ".docx";
#	  $mime = 'docx';
#      }elsif($filename =~ /\.xlsx$/i){
#	  $file .= ".xlsx";
#	  $mime = 'xlsx';
#      }elsif($filename =~ /\.pptx$/i){
#	  $file .= ".pptx";
#	  $mime = 'pptx';
#      }elsif($filename =~ /\.swf$/i){
#	  $file .= ".swf";
#	  $mime = 'swf';
#      }elsif($filename =~ /\.mp4$/i){
#	  $file .= ".mp4";
#	  $mime = 'mp4';
#      }elsif($filename =~ /\.zip$/i){
#	  $file .= ".zip";
#	  $mime = 'zip';
#      }elsif($filename =~ /\.txt$/i){
#	  $file .= ".txt";
#	  $mime = 'txt';
#      }else{
#	  msg_add("danger","Solo imagenes y archivos pdf y zip son soportados.");
#	  return "";
#      }
#      if($file){
#	  open (OUTFILE,">data/$conf->{Domain}->{folder}/img/$dir/" . $file) or die "$!";
#	  binmode(OUTFILE);
#	  my $bytesread;
#	  my $buffer;
#	  while ($bytesread=read($filename,$buffer,1024)) {
#	      print OUTFILE $buffer;
#	  }
#	  close(OUTFILE);
#	  return $file;
#      }
#  }
#  return "";
#}
#
#
#sub thumbnail {
#    my $new_size = shift;
#    my $source   = shift;
#    my $target   = shift;
#    my $file     = shift;
#    my ($new_width, $new_height) = split(/x/,$new_size);
#    
#    #existe la fuente
#    if(! (-e "data/$_REQUEST->{Domain}/img/$source/$file")){
#        msg_add('error','No se pudo crear imagen chica, no existe la fuente');
#        return;
#    }
#    
#    #Target directory
#    if(!(-e "data/$_REQUEST->{Domain}/img/$target/")){
#        mkdir("data/$_REQUEST->{Domain}/img/$target/") or die 'No se puede crear el directorio de datos.';
#    }
#    my ($width, $height) = imgsize("data/$_REQUEST->{Domain}/img/$source/".$file);
#    if($file =~ /\.gif/i){
#        copy("data/$_REQUEST->{Domain}/img/$source/".$file, "data/$_REQUEST->{Domain}/img/$target/".$file);
#    }else{
#        if($width > $new_width or $height > $new_height){
#            my $t = new Image::Thumbnail(
#                size       => $new_size,
#                module     => "Image::Magick",
#                #attr       => {colorspace=>'RGB'},
#                create     => 1,
#                input      => "data/$_REQUEST->{Domain}/img/$source/".$file,
#                quality    => 90,
#                outputpath => "data/$_REQUEST->{Domain}/img/$target/".$file,
#                );
#        }else{
#            my $t = new Image::Thumbnail(
#                size       => $width.'x'.$height,
#                module     => "Image::Magick",
#                #attr       => {colorspace=>'RGB'},
#                create     => 1,
#                input      => "data/$_REQUEST->{Domain}/img/$source/".$file,
#                quality    => 90,
#                outputpath => "data/$_REQUEST->{Domain}/img/$source/".$file,
#                );
#        }
#    }
#}
#
#
#sub get_display_key {
#    my $salt = shift || rand(999);
#    require Digest::SHA1;
#    return substr(Digest::SHA1::sha1_hex($salt.time().$conf->{Misc}->{Key}),10,30);
#}
#
#sub format_name {
#  my $str = shift;
#  $str =~ s/,//g;
#  $str =~ s/<//g;
#  $str =~ s/>//g;
#  return (join " ", map {ucfirst} split " ", $str),
#}
#
#
#sub format_short_name {
#    my $str = shift;
#    $str =~ s/,//g;
#    $str =~ s/<//g;
#    $str =~ s/>//g;
#    my @words = split(" ",$str);
#    my $name = '';
#    foreach my $word (@words){
#        if($name){
#            $name .= ' '.ucfirst($word);
#            return $name;
#        }else{
#            $name = ucfirst($word);
#        }
#    }
#    return $name;
#}
#
#sub upload_usr_file {
#    my $cgi_param = shift || "";
#    my $dir = shift || "";    
#    my $save_as = shift || "";
#    my $filename = param($cgi_param);
#    my $mime = '';
#    
#
#    if(!(-e "data/$conf->{Domain}->{folder}")){
#        mkdir ("data/$conf->{Domain}->{folder}");
#    }
#    
#    if(!(-e "data/$conf->{Domain}->{folder}/$dir")){
#        mkdir ("data/$conf->{Domain}->{folder}/$dir");
#    }
#
#    if($filename){	
#        my $type = uploadInfo($filename)->{'Content-Type'};
#        my ($name, $extension) = split(/\./, $filename);
#        
#        $name = clean_str(replace_accents($name));        
#        my $file = $name;
#        
#        if($type eq "image/jpeg" or $type eq "image/x-jpeg"  or $type eq "image/pjpeg"){
#            $file .= ".jpg";
#            $mime = 'img';
#        }elsif($type eq "image/png" or $type eq "image/x-png"){
#            $file .= ".png";
#            $mime = 'img';
#        }elsif($type eq "image/gif" or $type eq "image/x-gif"){
#            $file .= ".gif";
#            $mime = 'img';
#        }elsif($filename =~ /\.pdf$/i){
#            $file .= ".pdf";
#            $mime = 'pdf';
#        }elsif($filename =~ /\.doc$/i){
#            $file .= ".doc";
#            $mime = 'doc';
#        }elsif($filename =~ /\.xls$/i){
#            $file .= ".xls";
#            $mime = 'xls';
#        }elsif($filename =~ /\.csv$/i){
#            $file .= ".csv";
#            $mime = 'csv';
#        }elsif($filename =~ /\.ppt$/i){
#            $file .= ".ppt";
#            $mime = 'ppt';
#        }elsif($filename =~ /\.docx$/i){
#            $file .= ".docx";
#            $mime = 'docx';
#        }elsif($filename =~ /\.xlsx$/i){
#            $file .= ".xlsx";
#            $mime = 'xlsx';
#        }elsif($filename =~ /\.pptx$/i){
#            $file .= ".pptx";
#            $mime = 'pptx';
#        }elsif($filename =~ /\.swf$/i){
#            $file .= ".swf";
#            $mime = 'swf';
#        }elsif($filename =~ /\.mp4$/i){
#            $file .= ".mp4";
#            $mime = 'mp4';
#        }elsif($filename =~ /\.zip$/i){
#            $file .= ".zip";
#            $mime = 'zip';
#        }elsif($filename =~ /\.txt$/i){
#            $file .= ".txt";
#            $mime = 'txt';
#        }else{
#            msg_add("danger","Solo documentos y zip son soportados.");
#            return "";
#        }
#        if($file){
#            if (-e "data/$conf->{Domain}->{folder}/$dir/$file") {
#                foreach my $it (1 .. 1000000) {
#                    $file = $name.'_'.$it.$extension;
#                    if(!(-e "data/$conf->{Domain}->{folder}/$dir/$file")){
#                        last;
#                    }
#                }
#            }
#            
#            open (OUTFILE,">data/$conf->{Domain}->{folder}/$dir/" . $file) or die "$!";
#            binmode(OUTFILE);
#            my $bytesread;
#            my $buffer;
#            while ($bytesread=read($filename,$buffer,1024)) {
#                print OUTFILE $buffer;
#            }
#            close(OUTFILE);
#            return $file;
#        }
#    }
#    return "";
#}
#
#
#sub upload_usr_image {
#    my $cgi_param = shift || "";
#    my $dir = shift || "";    
#    my $save_as = shift || "";
#    my $filename = param($cgi_param);
#    my $mime = '';
#    
#
#    if(!(-e "data/$conf->{Domain}->{folder}")){
#        mkdir ("data/$conf->{Domain}->{folder}");
#    }
#
#    if(!(-e "data/$conf->{Domain}->{folder}/img")){
#        mkdir ("data/$conf->{Domain}->{folder}/img");
#    }
#    
#    if(!(-e "data/$conf->{Domain}->{folder}/$dir")){
#        mkdir ("data/$conf->{Domain}->{folder}/$dir");
#    }
#
#    if($filename){
#        my $type = uploadInfo($filename)->{'Content-Type'};
#        my ($name, $extension) = split(/\./, $filename);
#        my $file = $save_as || (time() . int(rand(9999999)) );
#        if($type eq "image/jpeg" or $type eq "image/x-jpeg"  or $type eq "image/pjpeg"){
#            $file .= ".jpg";
#            $mime = 'img';
#        }elsif($type eq "image/png" or $type eq "image/x-png"){
#            $file .= ".png";
#            $mime = 'img';
#        }elsif($type eq "image/gif" or $type eq "image/x-gif"){
#            $file .= ".gif";
#            $mime = 'img';
#        }elsif($filename =~ /\.pdf$/i){
#            $file .= ".pdf";
#            $mime = 'pdf';
#        }elsif($filename =~ /\.doc$/i){
#            $file .= ".doc";
#            $mime = 'doc';
#        }elsif($filename =~ /\.xls$/i){
#            $file .= ".xls";
#            $mime = 'xls';
#        }elsif($filename =~ /\.csv$/i){
#            $file .= ".csv";
#            $mime = 'csv';
#        }elsif($filename =~ /\.ppt$/i){
#            $file .= ".ppt";
#            $mime = 'ppt';
#        }elsif($filename =~ /\.docx$/i){
#            $file .= ".docx";
#            $mime = 'docx';
#        }elsif($filename =~ /\.xlsx$/i){
#            $file .= ".xlsx";
#            $mime = 'xlsx';
#        }elsif($filename =~ /\.pptx$/i){
#            $file .= ".pptx";
#            $mime = 'pptx';
#        }elsif($filename =~ /\.swf$/i){
#            $file .= ".swf";
#            $mime = 'swf';
#        }elsif($filename =~ /\.mp4$/i){
#            $file .= ".mp4";
#            $mime = 'mp4';
#        }elsif($filename =~ /\.zip$/i){
#            $file .= ".zip";
#            $mime = 'zip';
#        }elsif($filename =~ /\.txt$/i){
#            $file .= ".txt";
#            $mime = 'txt';
#        }else{
#            msg_add("danger","Solo documentos y zip son soportados.");
#            return "";
#        }
#        if($file){
#            # if (-e "data/$conf->{Domain}->{folder}/$dir/$file") {
#            #     foreach my $it (1 .. 1000000) {
#            #         $file = $name.'_'.$it.$extension;
#            #         if(!(-e "data/$conf->{Domain}->{folder}/$dir/$file")){
#            #             last;
#            #         }
#            #     }
#            # }
#            
#            open (OUTFILE,">data/$conf->{Domain}->{folder}/$dir/" . $file) or die "$!";
#            binmode(OUTFILE);
#            my $bytesread;
#            my $buffer;
#            while ($bytesread=read($filename,$buffer,1024)) {
#                print OUTFILE $buffer;
#            }
#            close(OUTFILE);
#            return $file;
#        }
#    }
#    return "";
#}
#
#
#sub replace_accents {
#    my $string = shift;
#
#    $string =~ s/(á|ä)/a/gi;
#    $string =~ s/(é|ë)/e/gi;
#    $string =~ s/(í|ï)/i/gi;
#    $string =~ s/(ó|ö)/o/gi;
#    $string =~ s/(ú|ü)/u/gi;   
#
#    return $string;
#}
#
#
#sub clean_str {
#  my $cadena = shift;
#  
#  $cadena =~ s/\s+/ /g;
#  $cadena =~ s/^\W//g;
#  $cadena =~ s/\W+$//g;
#  $cadena =~ s/\s/_/g;
#  $cadena =~ s/\W//g;
#    
#  return $cadena;
#}
#
#sub stripe_to_dec_amount {
#    my $stripe = shift;
#    my @digits = split(//,$stripe);
#    my @reverse = reverse(@digits);
#    my $num_digits = scalar(@reverse);
#    $num_digits = 3 if($num_digits < 3);
#    my $dec = "";
#    for (my $it = 0; $it < $num_digits; $it++){
#	my $digit = $reverse[$it] || 0;
#	$dec = '.' . $dec if($it == 2);
#	$dec = $digit . $dec;
#    }
#    return $dec;
#}
#
#sub dec_to_stripe_amount {
#    my $dec = shift;
#    my $stripe = sprintf("%.2f", $dec);
#    $stripe =~ s/\D//g;
#    return $stripe;
#}
#
#sub stripe_to_date {
#    my $time = shift;
#    my ($sec, $min, $hour, $mday, $mon, $year, $wday, $yday, $isdst) = localtime($time);
#    $year += 1900;
#    return "$mday/$mon/$year";
#}
#
#sub user_permissions {
#    return if (!$sess{user_id});    
#
#    if ($sess{user_id} eq 139 or $sess{user_id} eq 118 or $sess{user_id} eq 518 or $sess{user_id} eq 2319){
#	$sess{is_admin} = "1";
#	return;
#    }
#
#    my $is_admin = $dbh->selectrow_array("SELECT is_admin FROM $conf->{Xaa}->{DB}.xaa_users_domains WHERE user_id=? AND domain_id=? AND active=1",{},$sess{user_id}, $conf->{Domain}->{domain_id}) ;
#    $sess{is_admin} = $is_admin;
#    return if ($is_admin);
#
#    my $denied = 0;
#    my $permissions = $dbh->selectrow_array("SELECT permissions FROM $conf->{Xaa}->{DB}.xaa_users_domains WHERE user_id=? AND domain_id=?",{},$sess{user_id}, $conf->{Domain}->{domain_id});    
#
#    my @modules = split(',', $permissions);    
#
#    foreach my $module (@modules){
#        if ($_REQUEST->{Controller} eq $module){
#            $denied = 0;
#            last;
#        }else{
#            $denied = 1;
#        }
#    }
#    
#    msg_add('info', "¡Ops! No tienes acceso a ese módulo" ) if ($denied);
#    http_redirect('/'.$conf->{Domain}->{folder}) if ($denied);
#    
#    # my $role_id = $dbh->selectrow_array("SELECT role_id FROM $conf->{Xaa}->{DB}.xaa_users_domains WHERE user_id=? AND domain_id=? AND active=1",{},$sess{user_id}, $conf->{Domain}->{domain_id}) ;
#    # $sess{role_id} = $role_id;
#    
#    # return if ($role_id eq 1);
#        
#    # my $denied = 0;
#    
#    # if($role_id eq 5){ # Marketero
#    #     if($_REQUEST->{Controller} ne 'EmailMkt' && $_REQUEST->{Controller} ne 'Forms'){                        
#    #         $denied = 1;
#    #     }
#    # }elsif($role_id eq 4){ #Jefe de Marketing
#    #     if($_REQUEST->{Controller} ne 'EmailMkt' && $_REQUEST->{Controller} ne 'Forms'){                        
#    #         $denied = 1;
#    #     }        
#    # }elsif($role_id eq 3){ #Vendedor
#    #     if($_REQUEST->{Controller} ne 'CRM'){
#    #         $denied = 1;
#    #     }
#    # }elsif($role_id eq 2){ #Jefe de Ventas
#    #     if($_REQUEST->{Controller} ne 'CRM'){
#    #         $denied = 1;
#    #     }
#    # }    
#
#    # msg_add('info', "¡Ops! No tienes acceso a ese módulo" ) if ($denied);
#    # http_redirect('/'.$conf->{Domain}->{folder}) if ($denied);    
#}
#
#sub verify_subscription_status {
#    #return if (!$sess{user_id});
#    #return if($conf->{Domain}->{subscription});
#    
#    #my $trial_period = $dbh->selectrow_array("SELECT IF((DATE_ADD(added_on,INTERVAL 15 DAY) > NOW()),1,0) AS trial FROM xaa.xaa_domains WHERE domain_id=?",{},
#    #                                         $conf->{Domain}->{domain_id}) || 0;
#    #if(!$trial_period){
#    #    if($sess{user_language} eq 'es_MX'){
#    #        msg_add("warning","Tu periodo de prueba ha expirado, debes contratar una subscripción para continuar.");
#    #    }else{
#    #        msg_add("warning","Your trial period has finished, please subscribe using your credit card.");
#    #    }
#    #    http_redirect('/'.$conf->{Domain}->{folder}.'/Management/Subscription');
#    #}
#}
#
#
#sub get_subscription_status {
#    my $domain_id = shift;
#    
#    my $subscription = $dbh->selectrow_array("SELECT IF(ds.next_bill_on>=NOW(), 'Cliente', IF(ds.next_bill_on>=DATE_SUB(NOW(), INTERVAL 3 MONTH), 'Suspendido', 'Cancelado') ) AS status_name "
#					     ."FROM $conf->{Xaa}->{DB}.xaa_domains d INNER JOIN $conf->{Xaa}->{DB}.xaa_domains_services ds "
#					     ."ON ds.domain_id=d.domain_id WHERE subscription=1 AND d.domain_id=?",{},$domain_id) || '';
#    
#    return $subscription if ($subscription);
#    
#    my $trial_period = $dbh->selectrow_array("SELECT IF((DATE_ADD(added_on,INTERVAL 15 DAY) > NOW()),1,0) AS trial FROM xaa.xaa_domains WHERE domain_id=?",{},
#                                             $domain_id) || 0;                        
#    if ($trial_period){
#	return "Demo";
#    }else{
#	return "Demo vencido";
#    }
#    return "";
#}

#
#sub upload_adm_file {
#    my $cgi_param = shift || "";
#    my $dir = shift || "";    
#    my $save_as = shift || "";
#    my $filename = param($cgi_param);
#    my $mime = '';
#        
#    if(!(-e "assets/img/$dir")){
#        mkdir ("assets/img/$dir");
#    }
#
#    if($filename){
#        my $type = uploadInfo($filename)->{'Content-Type'};
#        my ($name, $extension) = split(/\./, $filename);                
#        my $file = $save_as || (time() . int(rand(9999999)));
#        if($type eq "image/jpeg" or $type eq "image/x-jpeg"  or $type eq "image/pjpeg"){
#            $file .= ".jpg";
#            $mime = 'img';
#        }elsif($type eq "image/png" or $type eq "image/x-png"){
#            $file .= ".png";
#            $mime = 'img';
#        }elsif($type eq "image/gif" or $type eq "image/x-gif"){
#            $file .= ".gif";
#            $mime = 'img';
#        }elsif($filename =~ /\.pdf$/i){
#            $file .= ".pdf";
#            $mime = 'pdf';
#        }elsif($filename =~ /\.doc$/i){
#            $file .= ".doc";
#            $mime = 'doc';
#        }elsif($filename =~ /\.xls$/i){
#            $file .= ".xls";
#            $mime = 'xls';
#        }elsif($filename =~ /\.csv$/i){
#            $file .= ".csv";
#            $mime = 'csv';
#        }elsif($filename =~ /\.ppt$/i){
#            $file .= ".ppt";
#            $mime = 'ppt';
#        }elsif($filename =~ /\.docx$/i){
#            $file .= ".docx";
#            $mime = 'docx';
#        }elsif($filename =~ /\.xlsx$/i){
#            $file .= ".xlsx";
#            $mime = 'xlsx';
#        }elsif($filename =~ /\.pptx$/i){
#            $file .= ".pptx";
#            $mime = 'pptx';
#        }elsif($filename =~ /\.swf$/i){
#            $file .= ".swf";
#            $mime = 'swf';
#        }elsif($filename =~ /\.mp4$/i){
#            $file .= ".mp4";
#            $mime = 'mp4';
#        }elsif($filename =~ /\.zip$/i){
#            $file .= ".zip";
#            $mime = 'zip';
#        }elsif($filename =~ /\.txt$/i){
#            $file .= ".txt";
#            $mime = 'txt';
#        }else{
#            msg_add("danger","Solo documentos y zip son soportados.");
#            return "";
#        }
#        if($file){
#            # if (-e "assets/img/$dir/$file") {
#            #     foreach my $it (1 .. 1000000) {
#            #         $file = $name.'_'.$it.$extension;
#            #         if(!(-e "assets/img/$dir/$file")){
#            #             last;
#            #         }
#            #     }
#            # }
#            
#            open (OUTFILE,">assets/img/$dir/" . $file) or die "$!";
#            binmode(OUTFILE);
#            my $bytesread;
#            my $buffer;
#            while ($bytesread=read($filename,$buffer,1024)) {
#                print OUTFILE $buffer;
#            }
#            close(OUTFILE);
#            return $file;
#        }
#    }
#    return "";
#}
#

1;
