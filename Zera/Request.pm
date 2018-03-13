package Zera::Request;

sub new {
    my $class    = shift;
    my $self     = {};
    bless $self,$class;
    my $ENV = shift;
    my $buffer = shift;

    $self->{deny_uploads} = 0;

	if ($ENV{REQUEST_METHOD} =~ /^(get|head)$/i) {
		$self->_decode_url_encoded_data ($ENV{QUERY_STRING}, 'form');
		#return wantarray ? %{$self->{web_data}} : $self->{web_data};
	} elsif ($request_method =~ /^post$/i) {
		#if (!$content_type
		#	|| ($content_type =~ /^application\/x-www-form-urlencoded/)) {
		#	$self->_decode_url_encoded_data ($buffer, 'form');
		#} elsif ($content_type =~ /multipart\/form-data/) {
		#	if ($self->{deny_uploads}) {
		#		$self->_error ("multipart/form-data unacceptable when deny_uploads is set");
		#		return;
		#	}
		#	($boundary) = $content_type =~ /boundary=(\S+)$/;
		#	$self->_parse_multipart_data ($buffer);
		#	return wantarray ? %{$self->{web_data}} : $self->{web_data};
		#} else {
		#	$self->_error ('Invalid content type!');
		#}
	}
    return $self;
}

sub get_params {
    my $self = shift;
    return wantarray ? %{$self->{web_data}} : $self->{web_data};
}

sub _decode_url_encoded_data {
	my ($self, $reference_data, $type) = @_;
	return unless ($reference_data);
	my (@key_value_pairs, $delimiter);

	@key_value_pairs = ();

	if ($type eq 'cookies') {
		$delimiter = qr/[;,]\s*/;
	} else {
		# Only other option is form data
		$delimiter = qr/[;&]/;
	}
    
	@key_value_pairs = split ($delimiter, $reference_data);

	foreach my $key_value (@key_value_pairs) {
		my ($key, $value) = split (/=/, $key_value, 2);
		# avoid 'undef' warnings for "key="
		$value = '' unless defined $value;
		# avoid 'undef' warnings for bogus URLs like 'foobar.cgi?&foo=bar'
		next unless defined $key;
		if ($type eq 'cookies') {
			# Strip leading/trailling whitespace as per RFC 2965
			$key   =~ s/^\s+|\s+$//g;
			$value =~ s/^\s+|\s+$//g;
		}

		$key   = $self->url_decode ($key);
		$value = $self->url_decode ($value);

		if (defined ($self->{web_data}->{$key})) {
			if ($type eq 'cookies' and $self->{unique_cookies} > 0) {
				if ($self->{unique_cookies} == 1) {
					next;
				} elsif ($self->{unique_cookies} == 2) {
					$self->{web_data}->{$key} = $value;
					next;
				} else {
					$self->_error ("Multiple instances of cookie $key");
				}
			}
			$self->{web_data}->{$key} = [$self->{web_data}->{$key}]
			  unless (ref $self->{web_data}->{$key});
			push (@{$self->{web_data}->{$key}}, $value);
		} else {
			$self->{web_data}->{$key} = $value;
			push (@{$self->{ordered_keys}}, $key);
		}
	}

	return;
}

sub url_encode {
	my $self = shift;
	my ($s)=@_;
    
	return '' if (! defined ($s));
	$s= pack("C*", unpack("C*", $s));
	$s=~s/([^-_.a-zA-Z0-9])/sprintf("%%%02x",ord($1))/eg;
	$s;
}

sub url_decode {
	my $self = shift;
	my ($s) = @_;
	return '' if (! defined($s));
	$s =~ s/\+/ /gs;
	$s =~ s/%(?:([0-9a-fA-F]{2})|u([0-9a-fA-F]{4}))/
		defined($1)? chr hex($1) : _utf8_chr(hex($2))/ge;
	return $s;
}

#sub _parse_multipart_data
#{
#	my ($self, $boundary) = @_;
#	my $files = {};
#	$boundary = quotemeta ($boundary);
#
#	eval {
#
#		my ($seen,      $buffer_size, $byte_count,    $platform,
#			$eol,       $handle,      $directory,     $bytes_left,
#			$new_data,  $old_data,    $this_boundary, $current_buffer,
#			$changed,   $store,       $disposition,   $headers,
#			$mime_type, $convert,     $field,         $file,
#			$new_name,  $full_path
#		);
#
#		$seen        = {};
#		$buffer_size = $self->{buffer_size};
#		$byte_count  = 0;
#		$platform    = $self->{platform};
#		$eol         = $self->{eol}->{$platform};
#		$directory   = $self->{multipart_dir};
#
#		while (1) {
#			if (   ($byte_count < $total_bytes)
#				&& (length ($current_buffer || '') < ($buffer_size * 2))) {
#
#				$bytes_left = $total_bytes - $byte_count;
#				$buffer_size = $bytes_left if ($bytes_left < $buffer_size);
#
#				read (STDIN, $new_data, $buffer_size);
#				$self->_error ("Oh, Oh! I'm upset! Can't read what I want.")
#				  if (length ($new_data) != $buffer_size);
#
#				$byte_count += $buffer_size;
#
#				if ($old_data) {
#					$current_buffer = join ('', $old_data, $new_data);
#				} else {
#					$current_buffer = $new_data;
#				}
#
#			} elsif ($old_data) {
#				$current_buffer = $old_data;
#				$old_data       = undef;
#
#			} else {
#				last;
#			}
#
#			$changed = 0;
#
#			##++
#			##  When Netscape Navigator creates a random boundary string, you
#			##  would expect it to pass that _same_ value in the environment
#			##  variable CONTENT_TYPE, but it does not! Instead, it passes a
#			##  value that has the first two characters ("--") missing.
#			##--
#
#			if ($current_buffer =~
#				/(.*?)((?:\015?\012)?-*$boundary-*[\015\012]*)(?=(.*))/os) {
#
#				($store, $this_boundary, $old_data) = ($1, $2, $3);
#
#				if ($current_buffer =~
#					/[Cc]ontent-[Dd]isposition: ([^\015\012]+)\015?\012  # Disposition
#					(?:([A-Za-z].*?)(?:\015?\012))?                     # Headers
#					(?:\015?\012)                                       # End
#					(?=(.*))                                            # Other Data
#					/xs
#				  ) {
#
#					($disposition, $headers, $current_buffer) = ($1, $2, $3);
#					$old_data = $current_buffer;
#
#					$headers ||= '';
#					($mime_type) = $headers =~ /[Cc]ontent-[Tt]ype: (\S+)/;
#
#					$self->_store ($platform, $file, $convert, $handle, $eol,
#						$field, \$store, $seen);
#
#					close ($handle) if (ref ($handle) and fileno ($handle));
#
#					if ($mime_type && $self->{convert}->{$mime_type}) {
#						$convert = 1;
#					} else {
#						$convert = 0;
#					}
#
#					$changed = 1;
#
#					($field) = $disposition =~ /name="([^"]+)"/;
#					++$seen->{$field};
#
#					unless ($self->{'mime_types'}->{$field}) {
#						$self->{'mime_types'}->{$field} = $mime_type;
#					} elsif (ref $self->{'mime_types'}->{$field}) {
#						push @{$self->{'mime_types'}->{$field}}, $mime_type;
#					} else {
#						$self->{'mime_types'}->{$field} = 
#							[$self->{'mime_types'}->{$field}, $mime_type];
#					}
#
#					if ($seen->{$field} > 1) {
#						$self->{web_data}->{$field} =
#						  [$self->{web_data}->{$field}]
#						  unless (ref $self->{web_data}->{$field});
#					} else {
#						push (@{$self->{ordered_keys}}, $field);
#					}
#
#					if (($file) = $disposition =~ /filename="(.*)"/) {
#						$file =~ s|.*[:/\\](.*)|$1|;
#
#						$new_name =
#						  $self->_get_file_name ($platform, $directory, $file);
#
#						if (ref $self->{web_data}->{$field}) {
#							push @{$self->{web_data}->{$field}}, $new_name
#						} else {
#							$self->{web_data}->{$field} = $new_name;
#						}
#
#						$full_path =
#						  join ($self->{file}->{$platform}, $directory,
#							$new_name);
#
#						open ($handle, '>', $full_path)
#						  or $self->_error ("Can't create file: $full_path!");
#
#						$files->{$new_name} = $full_path;
#					}
#				} elsif ($byte_count < $total_bytes) {
#					$old_data = $this_boundary . $old_data;
#				}
#
#			} elsif ($old_data) {
#				$store    = $old_data;
#				$old_data = $new_data;
#
#			} else {
#				$store          = $current_buffer;
#				$current_buffer = $new_data;
#			}
#
#			unless ($changed) {
#				$self->_store ($platform, $file, $convert, $handle, $eol,
#					$field, \$store, $seen);
#			}
#		}
#
#		close ($handle) if ($handle and fileno ($handle));
#
#	};    # End of eval
#
#	$self->_error ($@) if $@;
#
#	$self->_create_handles ($files) if ($self->{file_type} eq 'handle');
#}

1;