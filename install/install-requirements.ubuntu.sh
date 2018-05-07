#dhclient
if [[ $PWD != */Zera/install ]]; then
    echo "Please, install from Zera/install directory"
    exit 1
fi
cd ..
apt-get update -y
apt-get install apache2 -y
apt-get install mysql-server -y
#apt-get install expect -y
#apt-get install git -y
#git --version
apt-get install build-essential -y
#git clone https://github.com/Alt180/Zera.git
#cd Zera
service start apache2
service enable apache2
service start mysql
service enable mysql
yes | cp install/Ubuntu/000-default.conf /etc/apache2/sites-available/000-default.conf
yes | cp install/Ubuntu/.htaccess /var/www/html/.htaccess
service restart apache2
cp -r * /var/www/html
cd /var/www/html
yes | rm -r install
#chown -R apache:apache *
chmod 755 index.pl
cd ..
chown -R apache:apache html
#firewall-cmd --permanent --add-port=80/tcp
#firewall-cmd --reload
#apt-get remove emacs -y
#apt-get remove expect -y
apt-get install perl-CPAN -y
(echo y;echo sudo;echo y; echo exit)|cpan
yes | cpan install CGI::Minimal Template JSON Switch Email::Sender::Simple MIME::Entity Math::Round Apache::Session::MySQL DBI DBD::mysql Number::Format
reboot
