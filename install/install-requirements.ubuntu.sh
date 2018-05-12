#dhclient
if [[ $PWD != */Zera/install ]]; then
    echo "Please, install from Zera/install directory"
    exit 1
fi
cd ..
apt-get update -y
apt-get install build-essential -y
apt-get install apache2 -y
apt-get install mysql-server -y
apt-get install libmysqlclient-dev -y
#apt-get install git -y
#git --version
#git clone https://github.com/Alt180/Zera.git
#cd Zera
service apache2 start
systemctl enable apache2
service mysql start
systemctl enable mysql
yes | cp install/Ubuntu/000-default.conf /etc/apache2/sites-available/000-default.conf
yes | cp install/Ubuntu/.htaccess /var/www/html/.htaccess
a2enmod rewrite
a2enmod cgi.load
a2enmod dbd.load
service apache2 restart
cp -r * /var/www/html
cd /var/www/html
yes | rm -r install
yes | rm .gitignore
chown -R www-data:www-data *
chmod 755 index.pl
(echo y; echo exit)|cpan
yes | cpan install CGI::Minimal Template JSON Switch Email::Sender::Simple MIME::Entity Math::Round Apache::Session::MySQL DBI DBD::mysql Number::Format
