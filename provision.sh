#!/usr/bin/env bash

apt-get update
debconf-set-selections <<< 'mysql-server-5.5 mysql-server/root_password password koala'
debconf-set-selections <<< 'mysql-server-5.5 mysql-server/root_password_again password koala'
apt-get install -y php5-cli apache2 libapache2-mod-php5 \
    mysql-server-5.5 php5-mysql php5-tidy php-apc php5-imagick \
    git-core php5-json memcached php5-memcache nodejs nodejs-legacy npm inotify-tools

echo "<VirtualHost *:80>" > /etc/apache2/sites-enabled/000-default.conf
echo "    DocumentRoot /var/www" >> /etc/apache2/sites-enabled/000-default.conf
echo "    <Directory /var/www/>" >> /etc/apache2/sites-enabled/000-default.conf
echo "        Options FollowSymLinks" >> /etc/apache2/sites-enabled/000-default.conf
echo "        AllowOverride All" >> /etc/apache2/sites-enabled/000-default.conf
echo "        Order allow,deny" >> /etc/apache2/sites-enabled/000-default.conf
echo "        allow from all" >> /etc/apache2/sites-enabled/000-default.conf
echo "    </Directory>" >> /etc/apache2/sites-enabled/000-default.conf
echo "    ErrorLog /var/log/apache2/error.log" >> /etc/apache2/sites-enabled/000-default.conf
echo "    CustomLog /var/log/apache2/access.log combined" >> /etc/apache2/sites-enabled/000-default.conf
echo "</VirtualHost>" >> /etc/apache2/sites-enabled/000-default.conf


echo "short_open_tag = On" >> /etc/php5/apache2/php.ini

a2enmod rewrite

rm -rf /var/www
cp -r /vagrant/app /var/www

chown -R vagrant.www-data /var/www
chmod a+w /var/www/cache /var/www/temp /var/www/log /var/www/log/* /var/www/cache/* /var/www

mkdir /var/uploads
chmod a+w /var/uploads

echo "[production]" > /var/www/config.local.ini
echo "server.domain = localhost" >> /var/www/config.local.ini
echo 'server.baseUrl = ""' >> /var/www/config.local.ini
echo "server.redirectToDomain = false" >> /var/www/config.local.ini
echo 'server.memcache.host = localhost' >> /var/www/config.local.ini
echo "debug.error.log = false" >> /var/www/config.local.ini
echo "database.web.host = localhost" >> /var/www/config.local.ini
echo "database.web.username = root" >> /var/www/config.local.ini
echo "database.web.password = koala" >> /var/www/config.local.ini
echo "database.web.dbname = app" >> /var/www/config.local.ini
echo "uploads = /var/uploads" >> /var/www/config.local.ini

mysql -u root --password=koala -e "CREATE DATABASE app"

service apache2 restart

curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer
npm install -g bower

su vagrant -c "cd /var/www && COMPOSER_PROCESS_TIMEOUT=2000 composer install"
su vagrant -c "php /var/www/bootstrap.php"
su vagrant -c "php /var/www/bootstrap.php clear-cache"
su vagrant -c "php /var/www/bootstrap.php build"
su vagrant -c "php /var/www/bootstrap.php setup"
