#!/bin/bash
#update your repositories
sudo apt update

#upgrade your missing packages
sudo apt upgrade -y
echo "Packages Upgraded"

#install your apache webserver
sudo apt install apache2 -y

#add the php ondrej repository
echo -e "\n" | sudo add-apt-repository ppa:ondrej/php

#update your repositories
sudo apt update

# install php8.2
sudo apt install php8.2 -y

#install php dependencies that are needed for laravel to work
sudo apt install php8.2-curl php8.2-dom php8.2-mbstring php8.2-xml php8.2-mysql zip unzip -y

#enable the apache rewrite module
sudo a2enmod rewrite

#restart the apache server
sudo systemctl restart apache2

#Install Git
sudo apt install git -y
echo "Git complete"

#change directory to /usr/bin
cd /usr/bin

#download the composer installer
install composer
sudo curl -sS https://getcomposer.org/installer | sudo php

#move the content of the default composer.phar to composer
sudo mv composer.phar composer

#change directory in /var/www directory for cloning laravel
cd /var/www/
sudo git clone https://github.com/laravel/laravel.git
sudo chown -R $USER:$USER /var/www/laravel
cd laravel/
install composer autoloader --no-interaction
composer install --optimize-autoloader --no-dev --no-interaction  
composer update --no-interaction

#copy the content of the default env file to .env and assign permissions
sudo cp .env.example .env
sudo chown -R www-data storage
sudo chown -R www-data bootstrap/cache
cd
cd /etc/apache2/sites-available/
sudo touch new.conf
sudo echo '<VirtualHost *:80>
    ServerName localhost
    DocumentRoot /var/www/laravel/public

    <Directory /var/www/laravel>
        AllowOverride All
    </Directory>

    ErrorLog ${APACHE_LOG_DIR}/laravel-error.log
    CustomLog ${APACHE_LOG_DIR}/laravel-access.log combined
</VirtualHost>' | sudo tee /etc/apache2/sites-available/new.conf
sudo a2ensite new.conf
sudo a2dissite 000-default.conf
sudo systemctl restart apache2
cd
# Install MySQL and create the Database
sudo apt install mysql-server -y
sudo apt install mysql-client -y
echo "MySQL COMPLETE"

sudo systemctl start mysql
sudo mysql -uroot -e "CREATE DATABASE Altschool_DB;"
sudo mysql -uroot -e "CREATE USER 'chibuzo'@'localhost' IDENTIFIED BY 'batman';"
sudo mysql -uroot -e "GRANT ALL PRIVILEGES ON Altschool_DB.* TO 'chibuzo'@'localhost';"
cd /var/www/laravel
sudo sed -i "23 s/^#//g" /var/www/laravel/.env
sudo sed -i "24 s/^#//g" /var/www/laravel/.env
sudo sed -i "25 s/^#//g" /var/www/laravel/.env
sudo sed -i "26 s/^#//g" /var/www/laravel/.env
sudo sed -i "27 s/^#//g" /var/www/laravel/.env
sudo sed -i '22 s/=sqlite/=mysql/' /var/www/laravel/.env
sudo sed -i '23 s/=127.0.0.1/=localhost/' /var/www/laravel/.env
sudo sed -i '24 s/=3306/=3306/' /var/www/laravel/.env
sudo sed -i '25 s/=laravel/=Altschool_DB/' /var/www/laravel/.env
sudo sed -i '26 s/=root/=chibuzo/' /var/www/laravel/.env
sudo sed -i '27 s/=/=batman/' /var/www/laravel/.env
sudo php artisan key:generate --no-interaction
sudo php artisan storage:link --no-interaction
sudo php artisan migrate --no-interaction
sudo php artisan db:seed --no-interaction
sudo systemctl restart apache2


uptime > /var/log/uptime.log