# Mac development environment setup


Install command line tools for Mac
From the command line execute the command
  xcode-select --install

Download and install mysql-server community edition
https://dev.mysql.com/downloads/mysql/

Download and install atom or any editor you like.
https://atom.io/

install required perl modules
To install the modules use this commands
  sudo cpan install CGI::Minimal Template Class::HPLOO::Base DBI DBD::mysql
  sudo cpan force install Apache::Session Apache::Session::MySQL
  sudo cpan install JSON::XS JSON Switch Number::Format

Configure the Apache web server (it comes whit your Mac)
Edit the /private/etc/apache2/httpd.conf file. Make sure you included this lines

  LoadModule rewrite_module libexec/apache2/mod_rewrite.so
  LoadModule cgi_module libexec/apache2/mod_cgi.so
  Include /private/etc/apache2/extra/httpd-vhosts.conf

Configure one apache virtual host
Read the mac_vhosts.conf to see an example

Start the apache and mysql servers
	sudo apachectl -k start
  sudo launchctl load -F /Library/LaunchDaemons/com.oracle.oss.mysql.mysqld.plist
