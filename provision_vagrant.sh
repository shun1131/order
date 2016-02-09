#!/bin/bash

[ $(/usr/bin/whoami) = 'root' ] || {
    /bin/echo root only
    exit 1
}

echo "alias ll='ls -la --color=auto'" >> /etc/profile.d/myalias.sh
systemctl stop firewalld.service
systemctl disable firewalld.service
timedatectl set-timezone Asia/Tokyo
setenforce 0
sed -i -e "s/^SELINUX=enforcing/SELINUX=disabled/g" /etc/selinux/config
yum -y update
yum -y groupinstall "Development Tools"
yum -y install gcc-c++ glibc-headers openssl-devel readline libyaml-devel readline-devel zlib zlib-devel libffi-devel libxml2 libxslt libxml2-devel libxslt-devel httpd libcurl-devel httpd-devel apr-devel apr-util-devel gcc curl-devel ImageMagick ImageMagick-devel ipa-pgothic-fonts vim-enhanced mariadb-server mariadb-devel
git clone https://github.com/sstephenson/rbenv.git /usr/local/rbenv
echo 'export RBENV_ROOT="/usr/local/rbenv"' >> /etc/profile.d/rbenv.sh
echo 'export PATH="${RBENV_ROOT}/bin:${PATH}"' >> /etc/profile.d/rbenv.sh
echo 'eval "$(rbenv init -)"' >> /etc/profile.d/rbenv.sh
git clone git://github.com/sstephenson/ruby-build.git /usr/local/rbenv/plugins/ruby-build
source /etc/profile
rbenv install 2.2.3
rbenv rehash
rbenv global 2.2.3
gem install --no-ri --no-rdoc bundler
rbenv rehash
gem install --no-ri --no-rdoc passenger
rbenv rehash
passenger-install-apache2-module --auto
passenger-install-apache2-module --snippet > /etc/httpd/conf.d/passenger.conf
cat <<'EOS' > /etc/httpd/conf.d/rails.conf
<VirtualHost *:80>
  #ServerName yourserver.com

  # Tell Apache and Passenger where your app's 'public' directory is
  DocumentRoot /order/public

  RailsEnv development

  # Relax Apache security settings
  <Directory /order/public>
    Allow from all
    Options -MultiViews
    # Uncomment this if you're on Apache > 2.4:
    Require all granted
  </Directory>
</VirtualHost>
EOS
systemctl start httpd.service
systemctl enable httpd.service
cat > /etc/my.cnf.d/rails.cnf <<'EOS'
[mysqld]
character-set-server=utf8
EOS
systemctl start mariadb.service
mysql -u root <<EOS 
-- Remove anonymous users
DELETE FROM mysql.user WHERE User='';
-- Disallow remote root login
DELETE FROM mysql.user WHERE User='root' AND Host NOT IN ('localhost',  '127.0.0.1',  '::1');
-- Remove test database
DROP DATABASE IF EXISTS test;
DELETE FROM mysql.db WHERE Db='test' OR Db='test\\_%';
-- Reload privilege tables
FLUSH PRIVILEGES;
EOS
systemctl restart mariadb.service
systemctl enable mariadb.service

cd /order
rm -rf .git README.md
bundle install
bundle exec rails new . -Bf -d mysql

exit 0
