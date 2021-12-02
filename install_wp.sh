#!/bin/bash

# Script para instalar Wordpress desde nuestro Vagrantfile

# Instalamos dependencias y herramientas
curl -L -O https://artifacts.elastic.co/downloads/beats/filebeat/filebeat-7.10.0-amd64.deb
sudo apt-get -y update
sudo apt install -y wordpress php mysql-server libapache2-mod-php php-mysql 
sudo dpkg -i filebeat-7.10.0-amd64.deb

# Creamos el site de Wordpress y lo habilitamos
cat <<EOF >/etc/apache2/sites-available/wordpress.conf
Alias /blog /usr/share/wordpress
<Directory /usr/share/wordpress>
    Options FollowSymLinks
    AllowOverride Limit Options FileInfo
    DirectoryIndex index.php
    Order allow,deny
    Allow from all
</Directory>
<Directory /usr/share/wordpress/wp-content>
    Options FollowSymLinks
    Order allow,deny
    Allow from all
</Directory>
EOF

sudo a2ensite wordpress
sudo a2enmod rewrite
systemctl restart apache2
filebeat modules enable apache

# Creamos la base de datos MySql
sudo service mysql start
sudo mysql -u root -e "CREATE DATABASE wordpress;"
sudo mysql -u root -e "CREATE USER wordpress IDENTIFIED BY 'wordpress';"
sudo mysql -u root -e "GRANT ALL ON wordpress.* TO wordpress;"
sudo mysql -u root -e "FLUSH PRIVILEGES;"

sudo cat <<EOF >/etc/wordpress/config-localhost.php
<?php
define('DB_NAME', 'wordpress');
define('DB_USER', 'wordpress');
define('DB_PASSWORD', 'wordpress');
define('DB_HOST', 'localhost');
define('DB_COLLATE', 'utf8_general_ci');
define('WP_CONTENT_DIR', '/usr/share/wordpress/wp-content');
define( 'WP_DEBUG', true );
define( 'WP_DEBUG_LOG', true );
define( 'SAVEQUERIES', true );
?>
EOF

# Setup de FileBeats
sudo sed -i 's#/var/log#/var/log/apache2#g' /etc/filebeat/filebeat.yml 
sudo sed -Ei '/^output.elasticsearch:$/,/^.*hosts: \["localhost:9200"\]$/{s/(^.*$)/#\1/}' /etc/filebeat/filebeat.yml 
sudo sed -Ei '/(^.*#hosts: \["localhost:5044"\]$)/{s/(^.*#)(.*$)/  \2/g}' /etc/filebeat/filebeat.yml 
sudo sed -Ei '/(^#output.logstash:$)/{s/(^.*#)(.*$)/\2/g}' /etc/filebeat/filebeat.yml 
sudo sed -i 's/\localhost\b/192.168.100.11/g' /etc/filebeat/filebeat.yml

sudo systemctl start filebeat


