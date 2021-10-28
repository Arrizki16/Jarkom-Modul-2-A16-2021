#!/bin/bash

echo '
nameserver 192.168.122.1
#nameserver 10.7.2.2
' > /etc/resolv.conf

apt-get update

apt-get install php -y

apt-get install apache2 -y

apt-get install git -y

apt-get install unzip -y

apt-get install ca-certificates -y

apt-get install lynx -y

service apache2 start

git clone https://github.com/FeinardSlim/Praktikum-Modul-2-Jarkom.git /var/www/source
rm /var/www/source/README.md
unzip /var/www/source/franky.zip -d /var/www/source
unzip /var/www/source/general.mecha.franky.zip -d /var/www/source
unzip /var/www/source/super.franky.zip -d /var/www/source

mkdir /var/www/franky.A16.com
mkdir /var/www/super.franky.A16.com
mkdir /var/www/general.franky.A16.com

cp -r /var/www/source/franky/. /var/www/franky.A16.com
cp -r /var/www/source/super.franky/. /var/www/super.franky.A16.com
cp -r /var/www/source/general.mecha.franky/. /var/www/general.franky.A16.com

rm -r /var/www/source

apt-get install libapache2-mod-php7.0 -y
service apache2 restart

echo '
<VirtualHost *:80>
        ServerAdmin webmaster@localhost
        DocumentRoot /var/www/franky.A16.com
        ServerName www.franky.A16.com

        Alias "/home" "/var/www/franky.A16.com/index.php/home"

        ErrorLog ${APACHE_LOG_DIR}/error.log
        CustomLog ${APACHE_LOG_DIR}/access.log combined

</VirtualHost>

<VirtualHost *:80>
        ServerAdmin webmaster@localhost
        DocumentRoot /var/www/super.franky.A16.com
        ServerName www.super.franky.A16.com

        Alias "/js" "/var/www/super.franky.A16.com/public/js" 
        
        <Directory /var/www/super.franky.A16.com/public>
        	Options +Indexes
        </Directory>

        <Directory /var/www/super.franky.A16.com>
                Options +FollowSymLinks -Multiviews
                AllowOverride All
        </Directory>
        
        ErrorLog ${APACHE_LOG_DIR}/error.log
        CustomLog ${APACHE_LOG_DIR}/access.log combined

        </VirtualHost>

<VirtualHost *:15000 *:15500>
        ServerAdmin webmaster@localhost
        DocumentRoot /var/www/general.franky.A16.com
        ServerName www.general.mecha.franky.A16.com

        <Directory /var/www/general.franky.A16.com>
                Options +FollowSymLinks -Multiviews
                AllowOverride All
                Require all granted
        </Directory>

        ErrorLog ${APACHE_LOG_DIR}/error.log
        CustomLog ${APACHE_LOG_DIR}/access.log combined

</VirtualHost>

<VirtualHost *:80>
        ServerAdmin webmaster@localhost
        DocumentRoot /var/www/franky.A16.com
        ServerName http://10.7.2.4

        Redirect 301 / http://www.franky.A16.com/

        ErrorLog ${APACHE_LOG_DIR}/error.log
        CustomLog ${APACHE_LOG_DIR}/access.log combined
</VirtualHost>
' > /etc/apache2/sites-available/000-default.conf

echo '
# If you just change the port or add more ports here, you will likely also
# have to change the VirtualHost statement in
# /etc/apache2/sites-enabled/000-default.conf

Listen 80
Listen 15000
Listen 15500

<IfModule ssl_module>
        Listen 443
</IfModule>

<IfModule mod_gnutls.c>
        Listen 443
</IfModule>

# vim: syntax=apache ts=4 sw=4 sts=4 sr noet
' > /etc/apache2/ports.conf

touch /var/www/super.franky.A16.com/.htaccess

echo '
ErrorDocument 404 /error/404.html
RewriteEngine On
RewriteBase /var/www/super.franky.A16.com/public/images/
RewriteCond %{REQUEST_FILENAME} !franky.png
RewriteRule (.*)franky(.*) http://super.franky.A16.com/public/images/franky.png
' > /var/www/super.franky.A16.com/.htaccess

htpasswd -c -b /var/www/general.franky.A16.com/.htpasswd luffy onepiece

touch /var/www/general.franky.A16.com/.htaccess

echo '
AuthType Basic
AuthName "Restricted Content"
AuthUserFile /var/www/general.franky.A16.com/.htpasswd
Require valid-user
' > /var/www/general.franky.A16.com/.htaccess

echo '
#nameserver 192.168.122.1
nameserver 10.7.2.2
nameserver 10.7.2.3
' > /etc/resolv.conf

a2enmod rewrite

touch /etc/apache2/sites-available/super.franky.A16.com.conf

echo '
<VirtualHost *:80>
        ServerAdmin webmaster@localhost
        DocumentRoot /var/www/super.franky.A16.com
        ServerName www.super.franky.A16.com

        <Directory /var/www/super.franky.A16.com>
                Options +FollowSymLinks -Multiviews
                AllowOverride All
        </Directory>

        ErrorLog ${APACHE_LOG_DIR}/error.log
        CustomLog ${APACHE_LOG_DIR}/access.log combined
</VirtualHost>
' > /etc/apache2/sites-available/super.franky.A16.com.conf

service apache2 restart

