#!/bin/bash

# Description : A LAMP development environment with Vagrant using VMware Workstation
# Author : Yoann LAMY <https://github.com/ynlamy/vagrant-lamp>
# Licence : GPLv3

# Provisioning script for Rocky Linux 9 system
echo "Disbaling SELinux..."
setenforce 0
sed -i 's/SELINUX=\(enforcing\|permissive\)/SELINUX=disabled/' /etc/selinux/config

if [ -n "$TIMEZONE" ]; then
  echo "Configuring Timezone..."
  timedatectl set-timezone $TIMEZONE
fi

echo "Cleaning dnf cache..."
dnf -y -q clean all &>/dev/null

echo "Updating the system..."
dnf -y -q update --exclude=kernel* &>/dev/null

echo "Installing LAMP..."
dnf -y -q install epel-release &>/dev/null
dnf -y -q install https://rpms.remirepo.net/enterprise/remi-release-9.rpm &>/dev/null
crb enable &>/dev/null
if [ -z "$MARIADB_VERSION" ]; then
  MARIADB_VERSION="10.6"
fi
if [ -z "$PHP_VERSION" ]; then
  PHP_VERSION="8.4"
fi
echo "
[mariadb]
name = MariaDB
baseurl = https://rpm.mariadb.org/$MARIADB_VERSION/rhel/\$releasever/\$basearch
gpgkey = https://rpm.mariadb.org/RPM-GPG-KEY-MariaDB
gpgcheck = 1
enabled = 1" > /etc/yum.repos.d/mariadb.repo
dnf -y -q module enable php:remi-$PHP_VERSION &>/dev/null
dnf -y -q install mariadb-server httpd php php-bz2 php-gd php-intl php-mbstring php-mysqlnd php-ldap php-zip php-xdebug phpMyAdmin &>/dev/null

echo "Installing Composer..."
dnf -y -q install unzip &>/dev/null
curl -s -o composer-setup.php https://getcomposer.org/installer &>/dev/null
php composer-setup.php --install-dir=/usr/local/bin/ --filename=composer &>/dev/null
rm -f composer-setup.php
export COMPOSER_ALLOW_SUPERUSER=1

echo "Configuring Apache/httpd..."
mv /etc/httpd/conf.d/welcome.conf /etc/httpd/conf.d/welcome.conf.bak
mv /etc/httpd/conf.d/userdir.conf /etc/httpd/conf.d/userdir.conf.bak
sed -i 's/ScriptAlias \/cgi-bin\/ .*/#ScriptAlias \/cgi-bin\/ "\/var\/www\/cgi-bin\/"/' /etc/httpd/conf/httpd.conf
sed -i '/^<Directory \"\/var\/www\/cgi-bin\">$/,/<\/Directory>/ { s/^[^#]/#&/}' /etc/httpd/conf/httpd.conf
rm -fr /var/www/cgi-bin/

if [ "$PHP_FRAMEWORK" == "cakephp" ]; then
  echo "Configuring Apache/httpd for PHP framework (CakePHP)..."
  sed -i 's#DocumentRoot \"\/var\/www\/html\"#DocumentRoot \"\/var\/www\/html\/webroot\"#' /etc/httpd/conf/httpd.conf
  sed -i 's#<Directory \"\/var\/www\/html\"#<Directory \"\/var\/www\/html\/webroot\"#' /etc/httpd/conf/httpd.conf
  sed -i '/<Directory "\/var\/www\/html\/webroot">/,/<\/Directory>/s/AllowOverride None/AllowOverride All/' /etc/httpd/conf/httpd.conf
  mkdir -p /var/www/html/webroot/
elif [ "$PHP_FRAMEWORK" == "laravel" ]; then
  echo "Configuring Apache/httpd for PHP framework (Laravel)..."
  sed -i 's#DocumentRoot \"\/var\/www\/html\"#DocumentRoot \"\/var\/www\/html\/public\"#' /etc/httpd/conf/httpd.conf
  sed -i 's#<Directory \"\/var\/www\/html\"#<Directory \"\/var\/www\/html\/public\"#' /etc/httpd/conf/httpd.conf
  sed -i '/<Directory "\/var\/www\/html\/public">/,/<\/Directory>/s/AllowOverride None/AllowOverride All/' /etc/httpd/conf/httpd.conf
  mkdir -p /var/www/html/public/
elif [ "$PHP_FRAMEWORK" == "symfony" ]; then
  echo "Configuring Apache/httpd for PHP framework (Symfony)..."
  sed -i 's#DocumentRoot \"\/var\/www\/html\"#DocumentRoot \"\/var\/www\/html\/public\"#' /etc/httpd/conf/httpd.conf
  sed -i 's#<Directory \"\/var\/www\/html\"#<Directory \"\/var\/www\/html\/public\"#' /etc/httpd/conf/httpd.conf
  sed -i '/<Directory "\/var\/www\/html\/public">/,/<\/Directory>/s#</Directory>#    FallbackResource /index.php\n</Directory>#' /etc/httpd/conf/httpd.conf
  mkdir -p /var/www/html/public/
fi

echo "Configuring PHP..."
sed -i "s/error_reporting = .*/error_reporting = ${PHP_ERROR_REPORTING}/" /etc/php.ini
sed -i "s/display_errors = .*/display_errors = ${PHP_DISPLAY_ERRORS}/" /etc/php.ini
sed -i "s/display_startup_errors = .*/display_startup_errors = ${PHP_DISPLAY_STARTUP_ERRORS}/" /etc/php.ini
sed -i "s/memory_limit = .*/memory_limit = ${PHP_MEMORY_LIMIT}/" /etc/php.ini
sed -i "s/upload_max_filesize = .*/upload_max_filesize = ${PHP_UPLOAD_MAX_FILESIZE}/" /etc/php.ini
sed -i "s/post_max_size = .*/post_max_size = ${PHP_POST_MAX_SIZE}/" /etc/php.ini
sed -i "s/max_execution_time = .*/max_execution_time = ${PHP_MAX_EXECUTION_TIME}/" /etc/php.ini
sed -i "s#;date.timezone .*#date.timezone = ${TIMEZONE}#" /etc/php.ini
sed -i "s/;xdebug.mode = .*/xdebug.mode = ${PHP_XDEBUG_MODE}/" /etc/php.d/15-xdebug.ini
sed -i "s/;xdebug.client_host = .*/xdebug.client_host = ${PHP_XDEBUG_CLIENT_HOST}/" /etc/php.d/15-xdebug.ini
sed -i "s/;xdebug.start_with_request = .*/xdebug.start_with_request = ${PHP_XDEBUG_START_WITH_REQUEST}/" /etc/php.d/15-xdebug.ini

echo "Configuring phpinfo..."
echo -e "Alias /phpinfo /usr/share/phpinfo\n\n<Directory /usr/share/phpinfo>\n  Require all granted\n</Directory>" > /etc/httpd/conf.d/phpinfo.conf
mkdir /usr/share/phpinfo/
echo "<?php phpinfo(); ?>" > /usr/share/phpinfo/index.php

echo "Configuring phpMyAdmin..."
sed -i 's,Alias /phpMyAdmin .*,#Alias /phpMyAdmin /usr/share/phpMyAdmin,' /etc/httpd/conf.d/phpMyAdmin.conf
sed -i '0,/Require local/s/Require local.*/Require all granted/' /etc/httpd/conf.d/phpMyAdmin.conf
sed -i 's/Require local.*/Require all denied/' /etc/httpd/conf.d/phpMyAdmin.conf
sed -i "s/\$cfg\['Servers'\]\[\$i\]\['AllowNoPassword'\] = .*/\$cfg\['Servers'\]\[\$i\]\['AllowNoPassword'\] = true;/" /etc/phpMyAdmin/config.inc.php
echo "\$cfg['PmaNoRelation_DisableWarning'] = true;" >> /etc/phpMyAdmin/config.inc.php

echo "Configuring MariaDB..."
sed -i 's/#bind-address.*/bind-address = 0.0.0.0/' /etc/my.cnf.d/server.cnf
systemctl enable --now mariadb &>/dev/null
echo -e "\nn\nn\nY\nn\nY\nY\n" | mariadb-secure-installation &>/dev/null
mariadb -e "SET PASSWORD FOR 'root'@'localhost' = PASSWORD('');"
mariadb -e "RENAME USER 'root'@'localhost' TO 'root'@'%';"
mariadb -e "FLUSH PRIVILEGES;"

echo "Starting LAMP..."
systemctl enable --now httpd &>/dev/null

echo -e "\nLAMP is ready !"
echo "- Apache/httpd version :" `dnf info --installed httpd | grep -i "Version" | awk '{ print $3 }'`
echo "- MariaDB version :" `dnf info --installed mariadb-server | grep -i -m 1 "Version" | awk '{ print $3 }'`
echo "- PHP version :" `dnf info --installed php | grep -i "Version" | awk '{ print $3 }'`
echo "- phpMyAdmin version :" `dnf info --installed phpMyAdmin | grep -i "Version" | awk '{ print $3 }'`
echo "- Composer version :" `/usr/local/bin/composer -V 2>/dev/null | grep -i "Composer version" | awk '{ print $3 }'`
echo -e "\nInformations :"
echo "- Web server URL : http://127.0.0.1/"
echo "- phpinfo URL : http://127.0.0.1/phpinfo/"
echo "- phpMyAdmin URL : http://127.0.0.1/phpmyadmin/"
echo "- MariaDB host : localhost"
echo "- MariaDB port : 3306"
echo "- MariaDB user : root"
echo "- MariaDB root password is empty"