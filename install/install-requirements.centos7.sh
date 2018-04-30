#dhclient
if [[ $PWD != /Zera/install ]]; then
    echo "Please, install from Zera/install directory"
    exit 1
fi
cd ..
yum update -y
yum install httpd -y
yum install mariadb-server mariadb -y
yum install expect -y
#yum install git -y
#git --version
yum groupinstall "Development tools" -y
yum install 'perl(Template)' -y
yum install 'perl(JSON)' -y
yum install 'perl(Switch)' -y
#git clone https://github.com/Alt180/Zera.git
#cd Zera
systemctl start httpd.service
systemctl enable httpd.service
systemctl start mariadb
systemctl enable mariadb
install/CentOS7/confMySQL.exp
yes | cp install/CentOS7/httpd.conf /etc/httpd/conf/httpd.conf
sed -i 's/enforcing/disabled/g' /etc/selinux/config /etc/selinux/config
systemctl restart httpd.service
cp -r * /var/www/html
cd /var/www/html
yes | rm -r install
chown -R apache:apache *
chmod 755 index.pl
firewall-cmd --permanent --add-port=80/tcp
firewall-cmd --reload
#yum remove emacs -y
#yum remove expect -y
yum install perl-CPAN -y
(echo y;echo sudo;echo y; echo exit)|cpan
yes | cpan install CGI::Minimal Email::Sender:Simple MIME::Entity Apache::Session Number::Format JSON::XS
reboot
