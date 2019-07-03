if [[ $PWD != */Zera/install ]]; then
    echo "Please, install from Zera/install directory"
    exit 1
fi
cd ..
yum update -y
yum install httpd -y
yum install mariadb-server mariadb -y
yum groupinstall "Development tools" -y
yum install 'perl(Template)' -y
yum install 'perl(JSON)' -y
yum install 'perl(Switch)' -y
yum install perl-CPAN -y
curl -L http://cpanmin.us | perl - --self-upgrade
yes | cpanm CGI::Minimal Email::Sender::Simple MIME::Entity Apache::Session Number::Format JSON::XS Math::Round IO::Socket::SSL MIME::Base64 Authen::SASL
systemctl start httpd.service
systemctl enable httpd.service
systemctl start mariadb
systemctl enable mariadb
sed -i 's/enforcing/disabled/g' /etc/selinux/config /etc/selinux/config
yes | cp install/CentOS7/httpd.conf /etc/httpd/conf/httpd.conf
cp -r * /var/www/html
cd /var/www/html
yes | rm -r install
chown -R apache:apache *
chmod 755 index.pl
systemctl restart httpd.service
reboot
