

# Apache web server configuration
# /private/etc/apache2/httpd.conf

LoadModule rewrite_module libexec/apache2/mod_rewrite.so
LoadModule cgi_module libexec/apache2/mod_cgi.so
Include /private/etc/apache2/extra/httpd-vhosts.conf

sudo apachectl -k restart
